import { LightningElement, api } from 'lwc';
import CriarOportunidadeModal from "c/criarOportunidadeModal";
import { NavigationMixin } from 'lightning/navigation';

export default class CriarOportunidadeFlowLauncher extends NavigationMixin(LightningElement) {

    @api flowApiName;
    @api modalLabel;
    
    renderedCallback(){
        
        CriarOportunidadeModal.open({
            flowApiName: this.flowApiName,
            modalLabel: this.modalLabel,
            options: [],
            size: 'small'
        }).then((result) => {
            this.handleRedirect(result?.rowId);
        });
    }

    handleRedirect(recordId) {

        if(recordId){
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                }
            }, true).then(url =>{
                window.location.href = url;
            });
        }else{
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Opportunity',
                    actionName: 'list'
                }
            }, true).then(url =>{
                window.location.href = url;
            });
        }
    }
}