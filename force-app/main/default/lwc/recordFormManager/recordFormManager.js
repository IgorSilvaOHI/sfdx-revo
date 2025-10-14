import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class RecordFormManager extends LightningElement {
     @api recordId;
     @api objectApiName;
     @api recordType;

     recordTypeId;

     @wire(getObjectInfo, { objectApiName: '$objectApiName' })
     handleObjectInfo({err, data}){
          if(data){
               const targetRecordType = Object.values(data.recordTypeInfos).find(
                    rt => rt.developerName === this.recordType
               );
               this.recordTypeId = targetRecordType?.recordTypeId;
          }
     }

     get loadForm(){
           return !this.recordType || this.recordTypeId;
     }
     
}