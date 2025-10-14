import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class VincularPassageiroVooModal extends LightningModal {
    @api recordId;
    @api opportunityId;

    get getParameters() {
        return [ { name: 'recordId', value: this.recordId, type: 'String' },
                 { name: 'opportunityId', value: this.opportunityId, type: 'String' }
        ]
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