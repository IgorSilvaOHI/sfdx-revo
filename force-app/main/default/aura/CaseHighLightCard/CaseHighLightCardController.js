({
    doInit: function (component, event, helper) {
        var action = component.get("c.getAccountDetails");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.account", response.getReturnValue());
            } else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Erro",
                    type: "error",
                    message: response.getError()[0].pageErrors[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        var actionn = component.get("c.getContactDetails");
        actionn.setParams({ recordId: component.get("v.recordId") });
        actionn.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contact", response.getReturnValue());
            }
        });
        $A.enqueueAction(actionn);
        
        var actionNota = component.get("c.getNota");
        actionNota.setParams({ recordId: component.get("v.recordId") });
        actionNota.setCallback(this, function (response) {
            var state = response.getState();
            var retorno = response.getReturnValue();
            if (state === "SUCCESS") {
                let cNeutral = component.find("neutroId");
                let cGood = component.find("goodId");
                let cBad = component.find("badId");
                
                if (retorno == 0) {
                    var cmpTagAdd = component.find(cNeutral.getLocalId());
                    $A.util.addClass(cmpTagAdd, "active");
                } else if (retorno == 1) {
                    var cmpTagAdd = component.find(cGood.getLocalId());
                    $A.util.addClass(cmpTagAdd, "active");
                } else if (retorno == -2) {
                    var cmpTagAdd = component.find(cBad.getLocalId());
                    $A.util.addClass(cmpTagAdd, "active");
                }
            }
        });
        $A.enqueueAction(actionNota);
        
        var actionGetCase = component.get("c.getCase");
        actionGetCase.setParams({ recordId: component.get("v.recordId") });
        actionGetCase.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.case", response.getReturnValue());
            }
        });
        $A.enqueueAction(actionGetCase);
    },
    
    setHumorCliente: function (component, event, helper) {
        let cTarget = event.currentTarget.id;
        var cmpTag = component.find(cTarget);
        $A.util.addClass(cmpTag, "active");
        
        let nota;
        
        let cNeutral = component.find("neutroId");
        let cGood = component.find("goodId");
        let cBad = component.find("badId");
        
        $A.util.removeClass(component.find(cNeutral.getLocalId()), "active");
        $A.util.removeClass(component.find(cGood.getLocalId()), "active");
        $A.util.removeClass(component.find(cBad.getLocalId()), "active");
        
        if (cTarget == cNeutral.getLocalId()) {
            nota = 0;
            $A.util.addClass(component.find(cNeutral.getLocalId()), "active");
        } else if (cTarget == cGood.getLocalId()) {
            nota = 1;
            $A.util.addClass(component.find(cGood.getLocalId()), "active");
        } else if (cTarget == cBad.getLocalId()) {
            nota = -2;
            $A.util.addClass(component.find(cBad.getLocalId()), "active");
        } else {
            nota = -1;
            $A.util.addClass(component.find(cNeutral.getLocalId()), "active");
        }
        
        let notaAnterior = component.get("v.case.Nota__c");
        
        if (notaAnterior != nota) {
            var actionSaveNota = component.get("c.saveHumorCliente");
            var recordId = component.get("v.recordId");
            actionSaveNota.setParams({
                recordId: recordId,
                nota: nota
            });
            actionSaveNota.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get("e.force:refreshView").fire();
                    
                    component.set("v.case.Nota__c", nota);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Sucesso!",
                        message: "O nível de estresse foi registrado!",
                        type: "success"
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(actionSaveNota);
        }
    }
});