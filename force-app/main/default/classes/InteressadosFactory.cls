public class InteressadosFactory 
{
    public static FINAL Map<InteresseEnum,Type> interesseClass = 
        new Map<InteresseEnum, Type> 
    {             
            InteresseEnum.RESERVA => InteresseReserva.class,
                InteresseEnum.CONCLUSAOVOO => InteresseConclusaoVoo.class,
                InteresseEnum.CONCLUSAOTRECHO => InteresseConclusaoTrecho.class,
                InteresseEnum.EMISSAOEMBARQUE => InteresseEmissaoEmbarque.class,
                InteresseEnum.FATURAMENTO => InteresseFaturamento.class,
                InteresseEnum.TAKEOFFREPORT => InteresseTakeOffReport.class                
  	};
                    
    public static IInteresse newInstance(InteresseEnum i)
    {
        return (IInteresse)interesseClass.get(i).newInstance();
    }

}