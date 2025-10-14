({
  init: function (component) {
    var actionAccount = component.get("c.getAccountDetails");
    actionAccount.setParams({ recordId: component.get("v.recordId") });
    actionAccount.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var account = response.getReturnValue();

        component.set("v.account", account);

        component.set(
          "v.isPersonAccount",
          account.RecordType.DeveloperName === "PersonAccount"
        );
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
    $A.enqueueAction(actionAccount);

    var actionContact = component.get("c.getContactDetails");
    actionContact.setParams({ recordId: component.get("v.recordId") });
    actionContact.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.contact", response.getReturnValue());
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
    $A.enqueueAction(actionContact);

    var actionGetHumor = component.get("c.getHumorCliente");
    var recordId = component.get("v.recordId");
    actionGetHumor.setParams({
      recordId: recordId
    });
    actionGetHumor.setCallback(this, function (response) {
      var state = response.getState();

      component.set("v.humorCinza", false);
      component.set("v.humorNeutro", false);
      component.set("v.humorSatisfeito", false);
      component.set("v.humorInsatisfeito", false);

      if (state === "SUCCESS") {
        var retorno = response.getReturnValue();

        if (retorno == null) {
          component.set("v.humorCinza", true);
        } else if (retorno === 0) {
          component.set("v.humorNeutro", true);
        } else if (retorno > 0) {
          component.set("v.humorSatisfeito", true);
        } else if (retorno < 0) {
          component.set("v.humorInsatisfeito", true);
        } else {
          component.set("v.humorCinza", false);
        }
      }
    });
    $A.enqueueAction(actionGetHumor);
  },

  subscribe: function (component) {
    var helper = this;

    var empApi = component.find("empApi");
    var channel = "/event/HumorConta__e";
    var replayId = -1;

    empApi.subscribe(
      channel,
      replayId,
      $A.getCallback(function (eventReceived) {
        var account = component.get("v.account");

        var eventAccountId = eventReceived.data.payload.Conta__c.toUpperCase();
        var currentAccountId = account.Id.toUpperCase();

        if (eventAccountId === currentAccountId) {
          helper.init(component);
        }
      })
    );
  }
});