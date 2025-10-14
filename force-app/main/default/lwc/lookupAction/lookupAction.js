import { api, wire, LightningElement } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class LookupAction extends LightningElement {
    @api objectApiName;
    @api fieldApiName;
    @api recordId;
    @api required;
    @api label;
    @api formattedValue;
    @api parentRecordId;

    recordObjectApiName;
    fieldDataType;
    fieldDetail;
    wiredRecord;

    connectedCallback() {
        if(this.recordId?.indexOf(',') > 0){
            this.fieldDetail = JSON.parse(this.recordId);
            this.formattedValue = `${this.fieldDetail.latitude}, ${this.fieldDetail.longitude}`;

            if(this.recordId){
                this.dispatchEvent(new CustomEvent('formatvalue', {
                    detail: { 
                        formattedValue: this.formattedValue
                    }
                }));
            }
        }else{
            this.formattedValue = this.recordId;
        }

        this.handleInputChange.bind(this);
        this.handleSelectedRecord.bind(this);
    }

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    handleObjectInfo({err, data}){
        if(data){
            this.recordObjectApiName = data.fields[this.fieldApiName]?.referenceToInfos[0]?.apiName ?? '';
            this.fieldDataType = data.fields[this.fieldApiName].dataType;
        }
    }

    async handleInputChange(event){
        if(this.fieldDataType === 'Location'){
            this.recordId = `${JSON.stringify(event.detail)}`;
            this.fieldDetail = event.detail;
            this.formattedValue = `${event.detail.latitude}, ${event.detail.longitude}`;
        }else{
            this.recordId = event.detail.value ? event.detail.value[0] : event.detail.value;
            this.formattedValue = event.detail.value;
        }

        this.dispatchEvent(new CustomEvent('changevalue', {
            detail: { 
                value: this.recordId,
                formattedValue: this.formattedValue
             }
        }));
    }

    get getParentRecordId(){
        return this.parentRecordId ?? '';
    }

    get getRequired(){
        return this.required ? this.toBoolean(this.required) : false;
    }

    get useCustomLabel(){
        return !!this.label;
    }

    get getInputValue(){
        return this.fieldDetail ?? this.recordId;
    }

    get isReference(){
        return this.fieldDataType === 'Reference';
    }

    toBoolean(str) {
        return ['true', '1', 'yes', 'on'].includes(`${str}`.toLowerCase());
    }

    get inputVariant(){
        if(!!this.label){
            return 'label-hidden';
        }else{
            return 'label-stacked';
        }
    }

    handleSelectedRecord(record){
        this.dispatchEvent(new CustomEvent('formatvalue', {
            detail: { 
                formattedValue: record.detail.values.Name.value
            }
        }));
        
        this.formattedValue = record.detail.values.Name.value;
    }

    @api
    validate() {
        let isValid = true;

        if(this.getRequired){
            if(!this.recordId){
                isValid = false;
            }else if(this.fieldDataType === 'Location' && (!this.fieldDetail.latitude || !this.fieldDetail.longitude)){
                isValid = false;
            }
        }

        return { 
            isValid: isValid, 
            errorMessage: 'Por favor, preencha o campo obrigatório.' 
        };
    }
}