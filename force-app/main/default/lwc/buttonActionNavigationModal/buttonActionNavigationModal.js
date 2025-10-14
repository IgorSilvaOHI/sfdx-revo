import { api,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { getLayout } from "lightning/uiLayoutApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class ButtonActionNavigationModal  extends LightningModal {
    @api recordId;
    @api objectApiName;
    @api recordType;
    @api title;
    @api values;

    sections = [];
    recordTypeId;
    isLoading = false;

    @wire(getLayout, { objectApiName: '$objectApiName', layoutType: 'Full', mode: 'Edit', recordTypeId: '$recordTypeId'})
    wiredLayout({ error, data }) {
        
        if (data) {
            const values = JSON.parse(this.values);
            const processedSections = [];
            data.sections.forEach((section, sectionIndex) => {
                const rows = [];

                section.layoutRows.forEach((row, rowIndex) => {
                    const items = [];

                    row.layoutItems.forEach((item, colIndex) => {
                        item.layoutComponents.forEach(component => {
                            if (component.apiName && (item.editableForUpdate || component.apiName === 'Name')) {
                                items.push({
                                    fieldName: component.apiName,
                                    cssClass: section.columns > 1 ? `slds-col slds-size_1-of-2 slds-p-horizontal_small` : `slds-grid slds-size_1-of-1 label-inline`,
                                    value: values[component.apiName],
                                    required: item.required || false
                                });
                            }
                        });
                    });

                    if (items.length > 0) {
                        rows.push({
                            key: `${sectionIndex}-${rowIndex}`,
                            items
                        });
                    }
                });

                if (rows.length > 0) {
                    processedSections.push({
                        label: section.useHeading ? section.heading : null,
                        key:  `sk-${sectionIndex}`,
                        rows
                    });
                }
            });

            this.sections = processedSections; 
        }
    }

    handleExternalSubmit(event) {
        const btn = this.template.querySelector( ".hidden" );

        if( btn ){ 
            btn.click();
        }

        this.isLoading = [...this.template.querySelectorAll('lightning-input-field')]
                .reduce((validSoFar, inputCmp) => {
                    return validSoFar && inputCmp.reportValidity(); // Verifica se está válido
                }, true);
    }

    handleSuccess(event){
        this.close({status: 'success', id: event.detail.id, detail: event.detail });
    }

    handleError(event){
        this.isLoading = false;
    }

    handleCloseTab(){
        this.close({status: 'close'});
    }
    
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    handleObjectInfo({err, data}){
        if(data){
            const targetRecordType = Object.values(data.recordTypeInfos).find(
                rt => rt.name === this.recordType
            );
            this.recordTypeId = targetRecordType?.recordTypeId;
        }
    }

    get loadForm(){
        return !this.recordType || this.recordTypeId;
    }
}