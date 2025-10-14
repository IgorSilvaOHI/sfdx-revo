import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class CriarOportunidadeModal extends LightningModal {
    @api flowApiName;
    @api modalLabel;

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            const outputVars = event.detail.outputVariables;
            const novaOportunidade = outputVars.find(x => x.name === 'NovaOportunidade');
            if (novaOportunidade?.value?.Id) {
                this.close({rowId: novaOportunidade.value.Id});
            }else{
                this.close('');
            }
        }
    }
}