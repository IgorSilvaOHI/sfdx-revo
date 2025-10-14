public with sharing class AeronaveTimelineController {
    @AuraEnabled(cacheable=true)
    public static List<AeronaveWrapper> getAeronavesComVoos(Date dataReferencia) {
        if (dataReferencia == null) dataReferencia = Date.today();

        Datetime inicioDoDia = Datetime.newInstance(dataReferencia.year(), dataReferencia.month(), dataReferencia.day(), 0, 0, 0);
        Datetime fimDoDia = inicioDoDia.addDays(1);

        List<Voo__c> voos = [
            SELECT Id, Name, Prefixo__r.Name, Prefixo__c, DataHoraVoo__c, DataEsperadaFimVoo__c
            FROM Voo__c
            WHERE DataHoraVoo__c >= :inicioDoDia AND DataHoraVoo__c < :fimDoDia
            ORDER BY Prefixo__r.Name, DataHoraVoo__c
        ];

        Map<Id, AeronaveWrapper> mapaAeronaves = new Map<Id, AeronaveWrapper>();

        for (Voo__c v : voos) {
            if (v.Prefixo__c == null) continue;

            if (!mapaAeronaves.containsKey(v.Prefixo__c)) {
                mapaAeronaves.put(v.Prefixo__c, new AeronaveWrapper(v.Prefixo__c, v.Prefixo__r.Name));
            }

            mapaAeronaves.get(v.Prefixo__c).voos.add(
                new VooWrapper(v.Id, v.Name, v.DataHoraVoo__c, v.DataEsperadaFimVoo__c)
            );
        }

        return mapaAeronaves.values();
    }

    public class AeronaveWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String nome { get; set; }
        @AuraEnabled public List<VooWrapper> voos { get; set; }

        public AeronaveWrapper(Id id, String nome) {
            this.id = id;
            this.nome = nome;
            this.voos = new List<VooWrapper>();
        }
    }

    public class VooWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String nome { get; set; }
        @AuraEnabled public Datetime inicio { get; set; }
        @AuraEnabled public Datetime fim { get; set; }

        public VooWrapper(Id id, String nome, Datetime inicio, Datetime fim) {
            this.id = id;
            this.nome = nome;
            this.inicio = inicio;
            this.fim = fim;
        }
    }
}