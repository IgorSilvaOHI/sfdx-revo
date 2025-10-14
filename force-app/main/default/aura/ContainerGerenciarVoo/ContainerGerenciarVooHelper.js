({
	doInit : function(component) 
    {
        this.setAttribute(component, 'c.getVooWrapper', 'v.vooWrapper', true);
        this.getVoo(component);
	},
    
    getVoo: function(component){
        var action = component.get('c.getVoo');
        action.setParams({
            'vooId': component.get('v.recordId')
        });
        action.setCallback(this, function(response) {            
            var state = response.getState();
            
            if (state === 'SUCCESS')
            {
                
                var voo = response.getReturnValue();
                
                if(!voo.Cliente__r.BloquearSolicitacaoVoo__c){
                    this.setVooNaoGerenciavel(component, voo);
                    this.setShowVoo(component, voo);
                }
                else
                {
                    component.set('v.contaBloqueada', true);
                }

                this.setPassageirosCargas(component, voo);
                
            } 
            else if (state == 'ERROR')
            {
                let errors = response.getError();
                if(errors && Array.isArray(errors) && errors.length > 0) 
                {
                    this.showToast(component, 'Error', errors[0].message);
                    this.closeQuickAction();
                }
            }
            
            component.set('v.loading', false);

            if(component.get('v.showVoo')){
                this.redirect(component, 'passageiros', 'c:gerenciarPassageiros');
            }
        });

        $A.enqueueAction(action);
    },
    
    setVooNaoGerenciavel: function(component, voo)
    {
        var naoGerenciavel = voo.Status__c === 'Executado' ||
            voo.Status__c === 'Em Faturamento' ||
            voo.Status__c === 'Faturado' ||
            voo.Status__c === 'Cancelado';
        component.set('v.vooNaoGerenciavel', naoGerenciavel);
    },
    setPassageirosCargas: function(component, voo)
    {
        var showPassageirosCargas = 
            (
                (
                    voo.Status__c === 'Reservado' ||
                    voo.Status__c === 'Confirmado' ||
                    voo.Status__c === 'Pré-reservado'
                ) &&
                voo.TrechosNaoIniciados__c > 0
            );
        component.set('v.showPassageirosCargas', showPassageirosCargas);
    },
    setShowVoo: function(component, voo)
    {
        var showVoo = voo.Status__c === 'Rascunho' || voo.Status__c === 'Reservado' || voo.Status__c === 'Confirmado' || voo.Status__c === 'Pré-reservado';
        component.set('v.showVoo', showVoo);
    },
    
    setAttribute : function(component, functionController, attributeName, parse)
    {
        component.set('v.loading', true);
        var action = component.get(functionController);
        action.setParams
        ({
            'vooId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {            
            var state = response.getState();
            
            if (state === 'SUCCESS')
            {
                var value = parse ? JSON.parse(response.getReturnValue()) : response.getReturnValue();
                component.set(attributeName, value);
            } 
            else if (state == 'ERROR')
            {
                let errors = response.getError();
                if(errors && Array.isArray(errors) && errors.length > 0) 
                {
                    this.showToast(component, 'Error', errors[0].message);
                    this.closeQuickAction();
                }
            }
            
            component.set('v.loading', false);
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, type, msg)
    {
        var toast = $A.get('e.force:showToast');
        toast.setParams({
            "title": "Success!",
            'type': type,
            'message': msg
        });
        toast.fire();
    },
    
    closeQuickAction : function()
    {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    redirect : function(component, auraId, componentName)
    {
        return new Promise((resolve, reject) => {
            $A.createComponent(
                componentName,
                {
                    "aura:id": auraId,
                    "vooWrapper":component.get('v.vooWrapper'),
                    "onclosequickaction":component.getReference("c.closeQuickAction")
                },
                function(newInp, status, errorMessage)
                {
                    if (status === "SUCCESS") 
                    {                    
                        var body = component.get("v.panelGerenciar");
                        body.push(newInp);
                        component.set("v.panelGerenciar", body);
                        component.set('v.abrirGerenciar', true);
                    }
                    else
                    {
                        var errorMsg = "Erro ao carregar o componente [0]";
                        
                        var toast = $A.get('e.force:showToast');
                        toast.setParams({
                            "title": "Erro!",
                            'type': 'error',
                            'message': errorMsg.replace('[0]', componentName)
                        });
                        toast.fire(); 
                    }
                    resolve();
                }
            );
        });
    }
    
})