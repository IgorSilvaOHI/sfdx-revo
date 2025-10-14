({
    search: function (component, textParam, recordId, flgInterno) {
        let params = {
            textParam: textParam,
            recordId: recordId,
            flgInterno: flgInterno
        };
        
        this.apex(component, "buscaTabulacao", params).then(
            function (lstResultSearch) {
                component.set("v.lstResultSearch", lstResultSearch);
            }
        );
    },
    
    createCase: function (component, recordId, tabulationId) {
        let params = {
            idTabulacao: tabulationId,
            recordId: recordId
        };
        
        let helper = this;
        
        this.apex(component, "insereCasoTabulacao", params)
        .then(function (newCase) {
            component.set("v.textParam", "");
            component.set("v.lstResultSearch", []);
            
            if (recordId != newCase.Id) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": newCase.Id,
                    "slideDevName": "Detail"
                });
                navEvt.fire();
            } else {
                $A.get("e.force:refreshView").fire();
                
                let msgSuccess = "Caso tabulado com Sucesso!";
                helper.showToast("dismissible", msgSuccess, "success");
            }

        })
        .catch(function (error) {
            console.log(error);
            
            helper.showToast(
                "sticky",
                "Ocorreu um erro na criação do Caso!",
                "error"
            );
        });
    },
    
    apex: function (cmp, apexAction, params, helper) {
        const p = new Promise(
            $A.getCallback(function (resolve, reject) {
                const action = cmp.get("c." + apexAction + "");
                action.setParams(params);
                action.setCallback(this, function (callbackResult) {
                    if (callbackResult.getState() == "SUCCESS") {
                        resolve(callbackResult.getReturnValue());
                    }
                    if (callbackResult.getState() == "ERROR") {
                        reject(callbackResult.getError());
                    }
                });
                $A.enqueueAction(action);
            })
        );
        
        return p;
    },
    
    showToast: function (mode, message, type) {
        let toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            mode: mode,
            message: message,
            type: type
        });
        
        toastEvent.fire();
    }
});