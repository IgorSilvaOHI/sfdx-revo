({
  invoke: function (component, event, helper) {
    // Get the record ID attribute
    var record = component.get("v.recordId");

    location.href = "/" + record;
  },
});