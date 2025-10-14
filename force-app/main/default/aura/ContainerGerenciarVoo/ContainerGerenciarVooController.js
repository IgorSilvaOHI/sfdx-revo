({
	doInit : function(component, event, helper)
    {
		helper.doInit(component);
	},
    
    redirectVoo : function(component, event, helper)
    {
        if(!component.get('v.acaoSelecionada'))
        {
            component.set('v.acaoSelecionada', true);
            helper.redirect(component, 'voo', 'c:gerenciarVoo');
        }
    },
    
    redirectPassageiros : function(component, event, helper)
    {
        if(!component.get('v.acaoSelecionada'))
        {
            component.set('v.acaoSelecionada', true);
            helper.redirect(component, 'passageiros', 'c:gerenciarPassageiros');
        }
    },
    
    redirectCargas : function(component, event, helper)
    {
        if(!component.get('v.acaoSelecionada'))
        {
            component.set('v.acaoSelecionada', true);
        }
    },
    
	closeQuickAction : function(component, event, helper)
    {
		helper.closeQuickAction();
    }
})