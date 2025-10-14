({
    doInit : function(component, event, helper) {

        let recordId = component.get('v.recordId');
    },

    search : function(component, event, helper){

        let textParam = component.get('v.textParam');
        let recordId = component.get('v.recordId');
        let flgInterno = component.get('v.Interno');

        if(textParam.length > 1){
            helper.search(component, textParam, recordId, flgInterno);
        }else{
            component.set('v.lstResultSearch', []);
        }
        
    },

    createCase : function(component, event, helper){
        
        let index =  event.currentTarget.dataset.record;
        
        let recordId = component.get('v.recordId');
        let tabulationId = component.get('v.lstResultSearch')[index].Id;

        helper.createCase(component, recordId, tabulationId);

    }

})