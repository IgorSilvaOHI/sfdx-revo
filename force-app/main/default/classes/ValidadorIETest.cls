@isTest
public class ValidadorIETest 
{
    
    @isTest
    public static void validadorIEACCerto()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'AC';
        accs.get(0).InscricaoEstadual__c = '0152098707271';
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEEstadoInvalido()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'ABCDE';
        accs.get(0).InscricaoEstadual__c = '123456789';
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = e.getMessage().contains(Label.PreenchaValorValido);
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIEACErrado()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'AC';
        accs.get(0).InscricaoEstadual__c = '9999999999999';        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = e.getMessage().contains(Label.InscricaoEstadualInvalida);
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIEAL()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'AL';
        accs.get(0).InscricaoEstadual__c = '248679228';        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEAM()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'AM';
        accs.get(0).InscricaoEstadual__c = '212025503';        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIECE()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'CE';
        accs.get(0).InscricaoEstadual__c = '246632674';        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEDF()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'DF';
        accs.get(0).InscricaoEstadual__c = '0777389500154';        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEES()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'ES';
        accs.get(0).InscricaoEstadual__c = '832527424';        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEAP()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'AP';
        accs.get(0).InscricaoEstadual__c = '037166590';        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEAPErrado()
    {        
        Boolean erro = false;
        Test.startTest();
        try
        {
            ValidadorIEFactory.newInstance(Estado.AP).execute('Inscrição Estadual AP Incorreta');            
        }
        catch (Exception e)
        {
            erro = e.getMessage().contains(Label.InscricaoEstadualAPIncorreta);
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIEAP2()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'AP';
        accs.get(0).InscricaoEstadual__c = '030000000'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = e.getMessage().contains(Label.InscricaoEstadualAPInvalida);
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIEAP3()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'AP';
        accs.get(0).InscricaoEstadual__c = '030000012'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEAP4()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'AP';
        accs.get(0).InscricaoEstadual__c = '030170011'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIERJ()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'RJ';
        accs.get(0).InscricaoEstadual__c = '03912345'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEGO()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'GO';
        accs.get(0).InscricaoEstadual__c = '110944020'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEGO2()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'GO';
        accs.get(0).InscricaoEstadual__c = '110944021'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEGO3()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'GO';
        accs.get(0).InscricaoEstadual__c = '101031051'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEGO4()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'GO';
        accs.get(0).InscricaoEstadual__c = '109480589'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEGO5()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'GO';
        accs.get(0).InscricaoEstadual__c = '100000010'; 
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEGO6()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'GO';
        accs.get(0).InscricaoEstadual__c = '100000100';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEMA()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'MA';
        accs.get(0).InscricaoEstadual__c = '126653020';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEMT()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'MT';
        accs.get(0).InscricaoEstadual__c = '24484116085';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEMS()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'MS';
        accs.get(0).InscricaoEstadual__c = '284500232';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEPA()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'PA';
        accs.get(0).InscricaoEstadual__c = '156700140';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEPB()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'PB';
        accs.get(0).InscricaoEstadual__c = '096206845';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEPR()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'PR';
        accs.get(0).InscricaoEstadual__c = '8682244446';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEPE()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'PE';
        accs.get(0).InscricaoEstadual__c = '774608390';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEPI()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'PI';
        accs.get(0).InscricaoEstadual__c = '009447407';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    
    
    @isTest
    public static void validadorIERN9D()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'RN';
        accs.get(0).InscricaoEstadual__c = '208514023';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIERN10D()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'RN';
        accs.get(0).InscricaoEstadual__c = '2085140238';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIERS()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'RS';
        accs.get(0).InscricaoEstadual__c = '6217065960';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIERO9()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'RO';
        accs.get(0).InscricaoEstadual__c = '101625213';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIERO14()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'RO';
        accs.get(0).InscricaoEstadual__c = '94771223172924';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIERR()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'RR';
        accs.get(0).InscricaoEstadual__c = '240013407';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIERRErrado()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'RR';
        accs.get(0).InscricaoEstadual__c = '240013406';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIESC()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'SC';
        accs.get(0).InscricaoEstadual__c = '065568745';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIESE()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'SE';
        accs.get(0).InscricaoEstadual__c = '506813967';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIETO()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account acc = TestUtil.createAccount('Conta');
        acc.ShippingState = 'TO';
        acc.InscricaoEstadual__c = '79030264315';
        uow.registerNew(acc);
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIETOInvalido()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'TO';
        accs.get(0).InscricaoEstadual__c = '79877664315';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = e.getMessage().contains(Label.InscricaoEstadualInvalida);
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIEBA8DMOD10()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'BA';
        accs.get(0).InscricaoEstadual__c = '22457857';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEBA2DErrado()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'BA';
        accs.get(0).InscricaoEstadual__c = '99999999';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIEBA8DMOD11()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'BA';
        accs.get(0).InscricaoEstadual__c = '61234557';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEBA9DMOD10()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'BA';
        accs.get(0).InscricaoEstadual__c = '100000306';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEMG()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'MG';
        accs.get(0).InscricaoEstadual__c = '6461333187412';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIEMG1DVErrado()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'MG';
        accs.get(0).InscricaoEstadual__c = '6461333187422';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = e.getMessage().contains(Label.InscricaoEstadualInvalida);
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIEMG2DVErrado()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'MG';
        accs.get(0).InscricaoEstadual__c = '6461333187413';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = e.getMessage().contains(Label.InscricaoEstadualInvalida);
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIEMGTamErrado()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'MG';
        accs.get(0).InscricaoEstadual__c = '64613331874130';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = e.getMessage().contains(Label.InscricaoEstadualInvalida);
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIESP()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'SP';
        accs.get(0).InscricaoEstadual__c = '680945810235';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIESP1DErrado()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'SP';
        accs.get(0).InscricaoEstadual__c = '680945811235';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(erro);
    }
    
    @isTest
    public static void validadorIESPRural()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Account> accs = TestUtil.criarContas(uow, 1);
        accs.get(0).ShippingState = 'SP';
        accs.get(0).InscricaoEstadual__c = 'P011004243002';
        
        Boolean erro = false;
        
        Test.startTest();
        try
        {
            uow.commitWork();            
        }
        catch (Exception e)
        {
            erro = true;
        }
        Test.stopTest();
        
        System.assert(!erro);
    }
    
    @isTest
    public static void validadorIETamInvalido()
    {        
        Boolean tamanhoValido;
        
        
        ValidadorIE v = new ValidadorIE();
        v.inscricaoEstadual = '123456';
        v.tamanho = 2;
        Test.startTest();
        tamanhoValido = v.tamanhoValidado();
        Test.stopTest();
        
        System.assert(!tamanhoValido);
    }
    
}