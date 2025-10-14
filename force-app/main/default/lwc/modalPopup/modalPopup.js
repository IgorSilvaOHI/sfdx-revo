import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ModalPopup extends LightningModal{
    @api recordId;
    @api flowName;
    @api flowFinished; 

    get inputVariables(){
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }       
        ];           
    }

    handleStatusChange(event){
        if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN'){
            this.flowFinished({ detail: { recordId: this.recordId } });
            this.close();
        }
    }
}