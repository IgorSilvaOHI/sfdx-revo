public class GeraPDFOportunidadeController {
    
    public String imageUrl { get; set; }
    public Boolean hasLogo { get; set; }
    
    // Logo separado para o footer (menor)
    public String footerLogoUrl { get; set; }
    public Boolean hasFooterLogo { get; set; }
    
    // URLs das imagens das aeronaves
    public String h135ExteriorUrl { get; set; }
    public String h135InteriorUrl { get; set; }
    public String h155ExteriorUrl { get; set; }
    public String h155InteriorUrl { get; set; }
    
    // URLs das imagens das substâncias proibidas
    public String corrosivosUrl { get; set; }
    public String explosivosUrl { get; set; }
    public String gasesUrl { get; set; }
    public String radioativosUrl { get; set; }
    public String liquidosUrl { get; set; }
    public String miscelaneosUrl { get; set; }
    public String solidosUrl { get; set; }
    public String toxicosUrl { get; set; }
    public String oxidantesUrl { get; set; }
    public String facaUrl { get; set; }
    public String armaUrl { get; set; }
    public String tesouraUrl { get; set; }
    
    // Variáveis booleanas para identificar modelos de aeronaves nos percursos
    public Boolean hasH135Model { get; set; }
    public Boolean hasH155Model { get; set; }
    
    public String formatDateTime(DateTime dt) {
        if (dt == null) return '';
        TimeZone tz = UserInfo.getTimeZone(); 
        return dt.format('dd/MM/yyyy HH:mm', tz.getID());
    }
    
    
    public GeraPDFOportunidadeController(ApexPages.StandardController controller) {
        this.imageUrl = '';
        this.hasLogo = false;
        
        // Inicializar logo do footer
        this.footerLogoUrl = '';
        this.hasFooterLogo = false;
        
        // Inicializar URLs das imagens das aeronaves
        this.h135ExteriorUrl = '';
        this.h135InteriorUrl = '';
        this.h155ExteriorUrl = '';
        this.h155InteriorUrl = '';
        
        // Inicializar URLs das imagens das substâncias proibidas
        this.corrosivosUrl = '';
        this.explosivosUrl = '';
        this.gasesUrl = '';
        this.radioativosUrl = '';
        this.liquidosUrl = '';
        this.miscelaneosUrl = '';
        this.solidosUrl = '';
        this.toxicosUrl = '';
        this.oxidantesUrl = '';
        this.facaUrl = '';
        this.armaUrl = '';
        this.tesouraUrl = '';
        
        // Inicializar variáveis booleanas dos modelos
        this.hasH135Model = false;
        this.hasH155Model = false;
        
        try {
            String currentId = ApexPages.currentPage().getParameters().get('id');
            
            // Buscar ContentDocumentLink com título 'logo-revo'
            List<ContentDocumentLink> listOfCDL = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE ContentDocument.Id = '069U600000RtyqnIAB'
                LIMIT 1
            ];
            
            if (!listOfCDL.isEmpty()) {
                // Buscar ContentVersion mais recente
                List<ContentVersion> cvs = [
                    SELECT Id, VersionData 
                    FROM ContentVersion
                    WHERE ContentDocumentId = :listOfCDL[0].ContentDocumentId 
                    AND IsLatest = true
                ];
                
                if (!cvs.isEmpty()) {
                    // Opção 1: URL de download direto (melhor qualidade)
                    this.imageUrl = '/sfc/servlet.shepherd/version/download/' + cvs[0].Id;
                    this.hasLogo = true;
                    
                    // Logo do footer (mesmo ContentDocument, mas propriedade separada)
                    this.footerLogoUrl = '/sfc/servlet.shepherd/version/download/' + cvs[0].Id;
                    this.hasFooterLogo = true;
                    
                    System.debug('URL da imagem: ' + this.imageUrl);
                    System.debug('URL do logo do footer: ' + this.footerLogoUrl);
                }
            }
            
            // Buscar URLs das imagens das aeronaves
            this.loadAircraftImages();
            
            // Buscar URLs das imagens das substâncias proibidas
            this.loadSubstanceImages();
            
            // Verificar modelos de aeronaves nos percursos
            this.checkAircraftModels();
            
        } catch (Exception e) {
            System.debug('Erro ao buscar logo: ' + e.getMessage());
        }
    }
    
    private void loadAircraftImages() {
        try {
            // IDs dos ContentDocuments das imagens das aeronaves
            Map<String, String> imageIds = new Map<String, String>{
                'H135_EXTERIOR' => '069U600000Ru7NVIAZ',
                'H135_INTERIOR' => '069U600000RuFePIAV',
                'H155_EXTERIOR' => '069U600000Ru9FcIAJ',
                'H155_INTERIOR' => '069U600000RuO8FIAV'
            };
            
            // Buscar ContentVersions para cada imagem
            List<ContentVersion> cvs = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :imageIds.values()
                AND IsLatest = true
            ];
            
            // Criar mapa de ContentDocumentId para ContentVersionId
            Map<String, String> docToVersionMap = new Map<String, String>();
            for (ContentVersion cv : cvs) {
                docToVersionMap.put(cv.ContentDocumentId, cv.Id);
            }
            
            // Atribuir URLs
            this.h135ExteriorUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(imageIds.get('H135_EXTERIOR'));
            this.h135InteriorUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(imageIds.get('H135_INTERIOR'));
            this.h155ExteriorUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(imageIds.get('H155_EXTERIOR'));
            this.h155InteriorUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(imageIds.get('H155_INTERIOR'));
            
            System.debug('URLs das imagens carregadas:');
            System.debug('H135 Exterior: ' + this.h135ExteriorUrl);
            System.debug('H135 Interior: ' + this.h135InteriorUrl);
            System.debug('H155 Exterior: ' + this.h155ExteriorUrl);
            System.debug('H155 Interior: ' + this.h155InteriorUrl);
            
        } catch (Exception e) {
            System.debug('Erro ao carregar imagens das aeronaves: ' + e.getMessage());
        }
    }
    
    private void loadSubstanceImages() {
        try {
            // IDs dos ContentDocuments das imagens das substâncias proibidas
            Map<String, String> substanceIds = new Map<String, String>{
                'CORROSIVOS' => '069U600000RuJq1IAF',
                'EXPLOSIVOS' => '069U600000RtzJTIAZ',
                'GASES' => '069U600000RuJtFIAV',
                'RADIOATIVOS' => '069U600000RuCyEIAV',
                'LIQUIDOS' => '069U600000Rtv1PIAR',
                'MISCELANEOS' => '069U600000Rtu8XIAR',
                'SOLIDOS' => '069U600000Ru4vtIAB',
                'TOXICOS' => '069U600000RtmuBIAR',
                'OXIDANTES' => '069U600000RttnYIAR',
                'FACA' => '069U600000RuA8SIAV',
                'ARMA' => '069U600000Ru1xzIAB',
                'TESOURA' => '069U600000Ru7tkIAB'
            };
            
            // Buscar ContentVersions para cada imagem
            List<ContentVersion> cvs = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :substanceIds.values()
                AND IsLatest = true
            ];
            
            // Criar mapa de ContentDocumentId para ContentVersionId
            Map<String, String> docToVersionMap = new Map<String, String>();
            for (ContentVersion cv : cvs) {
                docToVersionMap.put(cv.ContentDocumentId, cv.Id);
            }
            
            // Atribuir URLs das substâncias proibidas
            this.corrosivosUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('CORROSIVOS'));
            this.explosivosUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('EXPLOSIVOS'));
            this.gasesUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('GASES'));
            this.radioativosUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('RADIOATIVOS'));
            this.liquidosUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('LIQUIDOS'));
            this.miscelaneosUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('MISCELANEOS'));
            this.solidosUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('SOLIDOS'));
            this.toxicosUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('TOXICOS'));
            this.oxidantesUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('OXIDANTES'));
            this.facaUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('FACA'));
            this.armaUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('ARMA'));
            this.tesouraUrl = '/sfc/servlet.shepherd/version/download/' + docToVersionMap.get(substanceIds.get('TESOURA'));
            
            System.debug('URLs das imagens das substâncias carregadas');
            
        } catch (Exception e) {
            System.debug('Erro ao carregar imagens das substâncias: ' + e.getMessage());
        }
    }
    
    public void checkAircraftModels() {
        try {
            // Obter o ID da Opportunity atual da URL
            String oppId = ApexPages.currentPage().getParameters().get('id');
            
            if (oppId != null) {
                // Buscar os OpportunityLineItems com ModeloSelecionado__c preenchido
                List<OpportunityLineItem> lineItems = [
                    SELECT ModeloSelecionado__r.Name
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :oppId
                    AND ModeloSelecionado__c != null
                ];
            
                // Verificar se há modelos H135 ou H155
                for (OpportunityLineItem item : lineItems) {
                    String modelName = item.ModeloSelecionado__r.Name;
                    if (modelName != null) {
                        if (modelName.contains('H-135')) {
                            this.hasH135Model = true;
                        }
                        if (modelName.contains('H-155')) {
                            this.hasH155Model = true;
                        }
                    }
                }
                
                System.debug('Modelos encontrados:');
                System.debug('H-135: ' + this.hasH135Model);
                System.debug('H-155: ' + this.hasH155Model);
            }
            
        } catch (Exception e) {
            System.debug('Erro ao verificar modelos das aeronaves: ' + e.getMessage());
        }
    }
}