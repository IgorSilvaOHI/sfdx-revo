({
  invoke: function (component, event, helper) {
    let flowAction = null;
    let availableActions = component.get("v.availableActions");

    for (
      let idx = 0;
      idx < availableActions.length && null == flowAction;
      idx++
    ) {
      let availAction = availableActions[idx];

      if ("NEXT" == availAction) {
        flowAction = availAction;
      } else if ("FINISH" == availAction) {
        flowAction = availAction;
      }
    }

    if (null != flowAction) {
      let navigate = component.get("v.navigateFlow");
      navigate(flowAction);
    }

    $A.get("e.force:refreshView").fire();
  }
});