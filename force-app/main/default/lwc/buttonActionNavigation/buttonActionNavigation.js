import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import ButtonActionNavigationModal from "c/buttonActionNavigationModal";
import {FlowNavigationNextEvent} from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ButtonActionNavigation extends NavigationMixin(LightningElement) {
    @api type = ''
    @api objectApiName;
    @api actionName;
    @api values = {};
    @api label;
    @api title;
    @api recordId;
    @api openedFromModal;
    @api refreshUI;
    
    handleEvent() {
        ButtonActionNavigationModal.open({
            recordId: this.recordId,
            objectApiName: this.objectApiName,
            title: this.title,
            values: this.values,
            size: 'small'
        }).then((result) => {
            if(result.status === 'success'){
                const message = !this.recordId ? 'Registro criado com sucesso' : 'Registro alterado com sucesso'
                this.dispatchEvent(new ShowToastEvent({
                    title: message,
                    message: '',
                    variant: 'success',
                    mode: 'pester'
                }));

                this.recordId = result.id;
                this.dispatchEvent(new FlowNavigationNextEvent());
            }
        });
    }
}