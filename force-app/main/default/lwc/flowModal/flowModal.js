import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class FlowModal extends LightningModal(LightningElement) {
    @api flowApiName = 'OportunidadeGerarVoosRetroativos';
    @api inputVariables = [];

    handleStatusChange(event) {
        const { status } = event.detail;
        if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
            this.close({ status });
        }
    }
}