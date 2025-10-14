public class RegraDescontoSelector extends fflib_SObjectSelector 
    implements IRegraDescontoSelector {
    
        public static IRegraDescontoSelector newInstance()
        {
            return (IRegraDescontoSelector) Application.Selector.newInstance(RegraDesconto__c.SObjectType);
        }
        
        public RegraDescontoSelector(Boolean includeFieldSetFields)
        {
            super(includeFieldSetFields);
        }
        
        public RegraDescontoSelector()
        {
            super(true);
        }
        
        public override List<Schema.FieldSet> getSObjectFieldSetList()
        {
            List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
            
            fieldSets.add(SobjectType.RegraDesconto__c.FieldSets.ParaCalculoPreco);
            
            return fieldSets;
        }
        
        public List<Schema.SObjectField> getSObjectFieldList()
        {
            return new List<Schema.SObjectField> {
                RegraDesconto__c.Id
            };
        }
        
        public Schema.SObjectType getSObjectType()
        {
            return RegraDesconto__c.sObjectType;
        }    
    
        public Map<Id, List<RegraDesconto__c>> selectByIdProducts(Set<ID> idProducts) 
        {
            fflib_QueryFactory query = newQueryFactory();
    
            query.setCondition('Produto__c IN :idProducts');
            
            fflib_QueryFactory subquery = query.subselectQuery('Faixas_Regras_de_Desconto__r')
            .selectFieldSet(SobjectType.FaixaRegraDesconto__c.FieldSets.SobjectFieldList);

            List<RegraDesconto__c> regras = Database.query( query.toSOQL() );
    
            Map<Id, List<RegraDesconto__c>> result = new Map<Id, List<RegraDesconto__c>>();
    
            for (RegraDesconto__c regra : regras) {
                
                if (!result.containsKey(regra.Produto__c)) {
                    result.put(regra.Produto__c, new List<RegraDesconto__c>());
                }
    
                result.get(regra.Produto__c).add(regra);
            }
    
            return result; 
        }    
    }