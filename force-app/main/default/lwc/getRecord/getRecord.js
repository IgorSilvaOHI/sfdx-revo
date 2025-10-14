import { LightningElement, api, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";

export default class GetRecord extends LightningElement {
    @api objectApiName;
    @api recordId;
    
    
    @wire(getRecord, { recordId: "$recordId", fields: "$fields" })
    wiredRecord({ error, data }) {
        if (data) {
            this.dispatchEvent(new CustomEvent('selectedrecord', {
                detail: { 
                    values: JSON.parse(JSON.stringify(data.fields))
                }
            }));
        }
    }
    
    get fields() {
        return [`${this.objectApiName}.Name`]
    }
}