import {LightningElement, api} from 'lwc';

export default class EmbedEnvelope extends LightningElement{
    @api aeronave;
    @api datum;
    @api peso;
    @api datumZeroCombustivel;
    @api pesoZeroCombustivel;
 
    get src(){
        return '/apex/envelopeAeronave?id='+this.aeronave+'&atualValue2='+this.datum+'&atualValue1='+this.peso+'&zeroValue2='+this.datumZeroCombustivel+'&zeroValue1='+this.pesoZeroCombustivel;
    }
}