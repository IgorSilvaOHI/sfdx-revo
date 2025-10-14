import { LightningElement, wire, track, api } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class MonitorarEventoAtendimento extends LightningElement {
    @api recordId;
    @api channelName = '/event/Atendimento__e';   
    subscription = {};
       
    connectedCallback(){
        this.registerErrorListener();
        this.registerEventListeners();
    }
    registerEventListeners() {
        subscribe(this.channelName, -1, this.handleEvent.bind(this)).then((response) => {
            this.subscription = response;
        });
    }

    disconnectedCallback() {
        this.cleanUpSubscriptions();
    }

    cleanUpSubscriptions() {
        if (this.subscription) {
            unsubscribe(this.subscription, (response) => {
                this.subscription = null;
            });
        }
    }

    handleEvent(response) {
        console.log('handleEvent');
        if(response.data.payload.TrechoId__c == this.recordId){
            getRecordNotifyChange([{recordId: this.recordId}]);
            console.log('getRecordNotifyChange');
        }
        
    }
    
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }
}