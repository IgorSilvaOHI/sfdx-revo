@isTest
public class ContentDocumentLinksSelectorTest {
	
    @TestSetup()
    private static void testSetup()
    {
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        
        TestUtil.insereConfiguracoesPersonalizadas();
        TestUtil.criarDeContaAteAnexoCargas();
    }
    
    @IsTest
	private static void testSelectById()
	{
        List<Carga__c> cargas = [SELECT Id FROM Carga__c];
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :cargas.get(0).Id];
		ContentDocumentLink CDL = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE Id = :contentDocumentLinks.get(0).Id];		
        
        // Query
        List<ContentDocumentLink> CDLSelecionados = new ContentDocumentLinksSelector().selectById(new Set<Id> {CDL.Id});
        ContentDocumentLink CDLSelecionado = CDLSelecionados.get(0);
		// Assert
		System.assertEquals(CDL.Id, CDLSelecionado.Id);		
		System.assertEquals(CDL.LinkedEntityId, CDLSelecionado.LinkedEntityId);	
        System.assertEquals(CDL.ContentDocumentId, CDLSelecionado.ContentDocumentId);
	}
    
    @IsTest
    private static void testNewInstance()
	{
		IContentDocumentLinksSelector contentDocumentLinksSelector = ContentDocumentLinksSelector.newInstance();
        System.assertNotEquals(contentDocumentLinksSelector, null);
	}
}