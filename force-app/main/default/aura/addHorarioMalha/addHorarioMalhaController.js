({
	doInit : function(component, event, helper) {
		helper.loadInitialData(component);
	},
	onProductChange : function(component, event, helper) {
		helper.loadMalhas(component);
	},
	onCreate : function(component, event, helper) {
		helper.createHorario(component);
	}
})

({
    myAction : function(component, event, helper) {

    }
})