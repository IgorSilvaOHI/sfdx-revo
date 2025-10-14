import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class EditarConfiguracaoModal extends LightningModal {
    @api recordId;

    get getParameters() {
        return [ {
            name: 'recordId',
            value: this.recordId,
            type: 'String'
        }]
    }

    get hasRecordId(){
        return !!this.recordId;
    }

    handleStatusChange(event){
    
        if (event.detail.status === 'FINISHED') {
            this.close('success');
        }
    }

}