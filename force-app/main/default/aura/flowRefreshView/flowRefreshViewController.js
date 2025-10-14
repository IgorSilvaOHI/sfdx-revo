({
	doInit : function(component, event, helper) {
		$A.get('e.force:refreshView').fire();

		var navigate = component.get("v.navigateFlow");
      	navigate("NEXT");
	}
})