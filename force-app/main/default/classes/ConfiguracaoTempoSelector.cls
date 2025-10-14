public with sharing class ConfiguracaoTempoSelector {
  
    public ConfiguracaoTempo getEntrevoosPorTipoVoo(String tipo) {
        ConfiguracaoTempo configuracaoTempo = new ConfiguracaoTempo();

        if(tipo == 'Charter') {
            configuracaoTempo.entreVoosPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().EntreVoosCharterPre__c ?? 0);
            configuracaoTempo.entreVoosPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().EntreVoosCharterPos__c ?? 0);
        } else if(tipo == 'FullCabin') {
            configuracaoTempo.entreVoosPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().EntreVoosFullCabinPre__c ?? 0);
            configuracaoTempo.entreVoosPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().EntreVoosFullCabinPos__c ?? 0);
        }else{
            configuracaoTempo.entreVoosPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPre__c ?? 0);
            configuracaoTempo.entreVoosPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPos__c ?? 0);
        }

        return configuracaoTempo;
    } 
    
    public ConfiguracaoTempo getEntrevoosByMaxAndMinTime() {
        ConfiguracaoTempo configuracaoTempo = new ConfiguracaoTempo();
        
        // Obter os valores dos campos de configuração
        ConfiguracaoTempo__c config = ConfiguracaoTempo__c.getOrgDefaults();
        
        // Calcular o maior valor para entreVoosPre
        Integer entreVoosCharterPre = Integer.valueOf(config.EntreVoosCharterPre__c ?? 0);
        Integer entreVoosFullCabinPre = Integer.valueOf(config.EntreVoosFullCabinPre__c ?? 0);
        Integer tempoPlanejamentoPre = Integer.valueOf(config.TempoPlanejamentoPre__c ?? 0);
        
        configuracaoTempo.entreVoosPre = Math.max(Math.max(entreVoosCharterPre, entreVoosFullCabinPre), tempoPlanejamentoPre);
        
        // Calcular o maior valor para entreVoosPos
        Integer entreVoosCharterPos = Integer.valueOf(config.EntreVoosCharterPos__c ?? 0);
        Integer entreVoosFullCabinPos = Integer.valueOf(config.EntreVoosFullCabinPos__c ?? 0);
        Integer tempoPlanejamentoPos = Integer.valueOf(config.TempoPlanejamentoPos__c ?? 0);
        
        configuracaoTempo.entreVoosPos = Math.max(Math.max(entreVoosCharterPos, entreVoosFullCabinPos), tempoPlanejamentoPos);

        return configuracaoTempo;
    }
    
    public class ConfiguracaoTempo {
        public Integer entreVoosPre { get; set; }
        public Integer entreVoosPos { get; set; }
    }
}