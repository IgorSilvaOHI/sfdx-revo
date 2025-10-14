public class Aerovias extends fflib_SObjectDomain implements IAerovias 
{
    private static FINAL String BIDIRECIONAL = 'Bidirecional';
    private static FINAL String UNIDIRECIONAL = 'Unidirecional';
    
    public Aerovias(List<Aerovia__c> sObjectList)
    {
        super(sObjectList);
    }
    
    public static IAerovias newInstance(List<Aerovia__c> sObjectList)
    {
        return (IAerovias) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Aerovias(sObjectList);
        }
    }
    
    public override void onBeforeInsert()
    {              
        Map<Id, Id> origemDestinoInserir = new Map<Id, Id>();        
        for (Aerovia__c aerovia : (List<Aerovia__c>)records)
        {
            origemDestinoInserir.put(aerovia.Origem__c, aerovia.Destino__c);
        }        
        List<Aerovia__c> aeroviasBanco = AeroviasSelector.newInstance().selectByOrigemDestino(origemDestinoInserir.keySet(), Utils.getSetIdsByListIds(origemDestinoInserir.values()));
        
        for (Aerovia__c aerovia : (List<Aerovia__c>)records)
        {
            if (aeroviaDuplicada(aerovia, aeroviasBanco))
            {
                aerovia.addError(Label.AeroviaDuplicada);   
            }
        }
    }
    
    public override void onAfterInsert()
    {        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        //Set de Ids das voltas das aerovias inseridas
        Set<Id> origens = Utils.getSetIds(records, 'Origem__c');
        Set<Id> destinos = Utils.getSetIds(records, 'Destino__c');
        //Se alguma aerovia inserida possuir volta, popula um map
        Map<Id, Aerovia__c> mapAerovias = new Map<Id, Aerovia__c>(AeroviasSelector.newInstance().selectWithRetornoByOrigemDestino(origens, destinos));
        
        //Para cada aerovia inserida
        for (Aerovia__c aeroviaInserida : (List<Aerovia__c>)records)
        {
            handleAfterInsert(aeroviaInserida, mapAerovias, uow);            
        }
        
        uow.commitWork();
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {    
        //Set de Ids das voltas das aerovias inseridas
        Set<Id> origens = Utils.getSetIds(records, 'Origem__c');
        Set<Id> destinos = Utils.getSetIds(records, 'Destino__c');
        //Se alguma aerovia inserida possuir volta, popula um map
        Map<Id, Aerovia__c> mapAerovias = new Map<Id, Aerovia__c>(AeroviasSelector.newInstance().selectWithRetornoByOrigemDestino(origens, destinos));
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Set<Id> idsAeroviasExcluir = new Set<Id>();
        
        for (Aerovia__c aerovia : (List<Aerovia__c>)records)
        {            
            //Pega o registro antes de dar update
            Aerovia__c oldAerovia = (Aerovia__c)existingRecords.get(aerovia.Id);
            
            //Verifica se a aerovia foi editada para BIDIRECIONAL
            Boolean aeroviaBidirecional = isBidirecional(aerovia);
            
            //Se o tipo da aerovia foi alterada
            if (!aerovia.Tipo__c.equals(oldAerovia.Tipo__c))
            {
                //Se agora é bidirecional
                if (aeroviaBidirecional)
                {                    
                    Aerovia__c retorno = getRetorno(aerovia, mapAerovias.values());
                    if (retorno == null)
                    {
                        //Cria o retorno                    
                        retorno = criaRetorno(aerovia.CodigoDestino__c + ' - ' + aerovia.CodigoOrigem__c, aerovia.Destino__c, aerovia.Origem__c, aeroviaBidirecional, aerovia.Id);
                        uow.registerNew(retorno);                        
                    }
                    else
                    {
                        retorno.Volta__c = aerovia.Id;
                        uow.registerDirty(retorno);
                    }
                    //TODO: setar o retorno em aerovia
                }
                else
                {
                    //Se agora é unidirecional, exclui o retorno
                    idsAeroviasExcluir.add(aerovia.Volta__c);   
                }
            }
            
        }
        
        for (Aerovia__c aerovia : (List<Aerovia__c>)records)
        {
            if (idsAeroviasExcluir.contains(aerovia.Id))
            {
                //Se editar ida e retorno para unidirecional, não permite a edição
                aerovia.addError(Label.MsgErroAeroviasConflito);
            }
        }
        
        uow.registerDeleted(AeroviasSelector.newInstance().selectById(idsAeroviasExcluir));

        uow.commitWork();
    }
    
    public override void onAfterDelete()
    {
        //Caso a aerovia deletada fosse bidirecional, ou seja, tivesse retorno
        //Seta a aerovia de retorno como unidirecional
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Set<Id> idsVolta = new Set<Id>();
        
        //Pega as ids dos retornos que não tem mais ida, pois a ida foi deletada
        for (Aerovia__c aeroviaDeletada : (List<Aerovia__c>)records)
        {
            if (String.isNotBlank(aeroviaDeletada.Volta__c))
            {
                idsVolta.add(aeroviaDeletada.Volta__c);
            }
        }
        
        Map<Id, Aerovia__c> mapAeroviasEditar = new Map<Id, Aerovia__c>(AeroviasSelector.newInstance().selectById(idsVolta));
        
        //Itera em todas as aerovias bidirecionais deletadas
        //para editar o tipo do retorno para unidirecional
        for (Aerovia__c aeroviaDeletada : (List<Aerovia__c>)records)
        {
            Aerovia__c retorno = mapAeroviasEditar.get(aeroviaDeletada.Volta__c);

            if (retorno != null)
            {
                retorno.Tipo__c = UNIDIRECIONAL;  
                uow.registerDirty(retorno);             
            }
        }

        uow.commitWork();
    }
    
    private void handleAfterInsert(Aerovia__c aeroviaInserida, Map<Id, Aerovia__c> mapAerovias, fflib_ISObjectUnitOfWork uow)
    {
        Aerovia__c retorno = getRetorno(aeroviaInserida, mapAerovias.values());
        
        //Verifica se é bidirecional
        if (isBidirecional(aeroviaInserida))
        {                
            //Caso exista um retorno, e seu campo Volta__c esteja errado, atualiza            
            if (retorno != null && !voltaAtualizada(aeroviaInserida, retorno))
            {                
                retorno.Volta__c = aeroviaInserida.Id;
                retorno.Tipo__c = BIDIRECIONAL;
                uow.registerDirty(retorno);
                if (!voltaAtualizada(aeroviaInserida, retorno))
                {
                    Aerovia__c aeroviaInseridaAux = new Aerovia__c(Id=aeroviaInserida.Id);
                    aeroviaInseridaAux.Volta__c = retorno.Id;
                    uow.registerDirty(aeroviaInseridaAux);
                }
            }
            //Caso não exista um retorno, faz-se necessário criar um
            else if (retorno == null)
            {                
                retorno = criaRetorno(aeroviaInserida.CodigoDestino__c + ' - ' + aeroviaInserida.CodigoOrigem__c, aeroviaInserida.Destino__c, aeroviaInserida.Origem__c, true, aeroviaInserida.Id);
                uow.registerNew(retorno);
            }
        }
        //Se for unidirecional
        else
        {
            //Existe uma aerovia de retorno
            if (retorno != null)
            {
                //Precisa atualizar ambos
                retorno.Volta__c = aeroviaInserida.Id;
                retorno.Tipo__c = BIDIRECIONAL;
                uow.registerDirty(retorno);
                Aerovia__c aeroviaInseridaAux = new Aerovia__c(Id=aeroviaInserida.Id);
                aeroviaInseridaAux.Tipo__c = BIDIRECIONAL;
                aeroviaInseridaAux.Volta__c = retorno.Id;
                uow.registerDirty(aeroviaInseridaAux);
            }
        }
    }
    
    private Aerovia__c getRetorno(Aerovia__c aerovia, List<Aerovia__c> aeroviasPossiveis)
    {        
        Integer i = 0;
        
        while (i < aeroviasPossiveis.size())
        {
            Aerovia__c aeroviaPossivel = aeroviasPossiveis.get(i);           
            
            if (aeroviaPossivel.Origem__c.equals(aerovia.Destino__c) && aeroviaPossivel.Destino__c.equals(aerovia.Origem__c))
            {
                return aeroviaPossivel;
            }
            
            i++;
        }
        
        return null;
    }
    
    private Aerovia__c criaRetorno(String name, Id origem, Id destino, Boolean isBidirecional, Id volta)
    {
        return 
            new Aerovia__c
            (
                //Name=name,
                Origem__c=origem,
                Destino__c=destino,
                Tipo__c = isBidirecional ? BIDIRECIONAL : UNIDIRECIONAL,
                Volta__c = String.isNotBlank(volta) ? volta : ''
            );
    }
    
    private Boolean isBidirecional(Aerovia__c aerovia)
    {
        return aerovia.Tipo__c.equals(BIDIRECIONAL);
    }
    
    private Boolean voltaAtualizada(Aerovia__c aerovia, Aerovia__c volta)
    {
        //Retorna false se a volta estiver preenchida com um valor incorreto ou se não estiver preenchido com nada
        return 
            aerovia.Volta__c != null &&
            String.isNotBlank(aerovia.Volta__c) &&
            !aerovia.Volta__c.equals(volta.Id);             
    }    
    
    private Boolean aeroviaDuplicada(Aerovia__c aerovia, List<Aerovia__c> aeroviasBanco)
    {
        for (Aerovia__c aeroviaBanco : aeroviasBanco)
        {
            if (aerovia.Origem__c.equals(aeroviaBanco.Origem__c) && aerovia.Destino__c.equals(aeroviaBanco.Destino__c))
            {
                return true;
            }
        }
        
        return false;
    }
}