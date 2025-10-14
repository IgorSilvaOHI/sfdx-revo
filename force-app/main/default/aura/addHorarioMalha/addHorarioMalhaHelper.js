({
	setLoading: function(component, isLoading) {
		component.set("v.isLoading", isLoading);
	},
	showToast: function(title, message, type) {
		var toast = $A.get("e.force:showToast");
		if (toast) {
			toast.setParams({ title: title, message: message, type: type || 'info' });
			toast.fire();
		}
	},
	loadInitialData: function(component) {
		var self = this;
		self.setLoading(component, true);
		var action = component.get("c.getProducts");
		action.setCallback(this, function(r){
			if (r.getState() === 'SUCCESS') {
				component.set("v.productOptions", r.getReturnValue());
			} else {
				self.showToast('Erro', self.getError(r), 'error');
			}
			self.setLoading(component, false);
		});
		$A.enqueueAction(action);
	},
	loadMalhas: function(component) {
		var self = this;
		self.setLoading(component, true);
		component.set("v.malhaOptions", []);
		component.set("v.selectedMalhaId", "");
		var productId = component.get("v.selectedProductId");
		var action = component.get("c.getMalhasByProduct");
		action.setParams({ productId: productId });
		action.setCallback(this, function(r){
			if (r.getState() === 'SUCCESS') {
				component.set("v.malhaOptions", r.getReturnValue());
			} else {
				self.showToast('Erro', self.getError(r), 'error');
			}
			self.setLoading(component, false);
		});
		$A.enqueueAction(action);
	},
	createHorario: function(component) {
		var self = this;
		var malhaId = component.get("v.selectedMalhaId");
		var dataHora = component.get("v.selectedDataHora");
		if (!malhaId || !dataHora) {
			self.showToast('Validação', 'Selecione produto, malha e data/hora.', 'warning');
			return;
		}
		self.setLoading(component, true);
		var action = component.get("c.createHorarioExtra");
		action.setParams({ malhaId: malhaId, dataHora: dataHora });
		action.setCallback(this, function(r){
			if (r.getState() === 'SUCCESS') {
				self.showToast('Sucesso', 'Horário extra criado.', 'success');
				// Reset only the data/hora selection so user can add more
				component.set("v.selectedDataHora", "");
			} else {
				self.showToast('Erro', self.getError(r), 'error');
			}
			self.setLoading(component, false);
		});
		$A.enqueueAction(action);
	},
	getError: function(response) {
		try {
			var errs = response.getError();
			if (errs && errs[0]) {
				if (errs[0].message) return errs[0].message;
				if (errs[0].pageErrors && errs[0].pageErrors[0] && errs[0].pageErrors[0].message) return errs[0].pageErrors[0].message;
			}
		} catch(e) {}
		return 'Ocorreu um erro inesperado.';
	}
})

({
    helperMethod : function() {

    }
})