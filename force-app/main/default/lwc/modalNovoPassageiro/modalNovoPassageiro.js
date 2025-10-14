import { LightningElement, track, wire, api } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";

import fechar from "@salesforce/label/c.Fechar";
import cancelar from "@salesforce/label/c.Cancelar";
import carregando from "@salesforce/label/c.Carregando";
import salvar from "@salesforce/label/c.Salvar";
import sucesso from "@salesforce/label/c.Sucesso";
import sucessoAdicionarPassageiro from "@salesforce/label/c.SucessoAdicionarPassageiro";
import novoPassageiro from "@salesforce/label/c.NovoPassageiro";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class ModalNovoPassageiro extends LightningElement {
  customLabel = {
    fechar,
    cancelar,
    carregando,
    novoPassageiro,
    salvar,
    sucesso,
    sucessoAdicionarPassageiro
  };

  @track objectInfo;
  @track accountId;
  @track loading = false;

  @track contato = {
    FirstName: "",
    LastName: "",
    TipoDocumento__c: "",
    NumeroDocumento__c: "",
    Email: "",
    Nacionalidade__c: "",
    Department: ""
  };

  @api screenSize;

  @api contaVoo;

  @wire(getObjectInfo, {
    objectApiName: CONTACT_OBJECT
  })
  objectInfo;

  get smallScreen() {
    return this.screenSize === "SMALL";
  }

  get contactApiName() {
    return CONTACT_OBJECT;
  }

  get recordTypeId() {
    // Returns a map of record type Ids
    if (this.objectInfo && this.objectInfo.data) {
      const rtis = this.objectInfo.data.recordTypeInfos;
      return Object.keys(rtis).find((rti) => rtis[rti].name === "Passageiro");
    }
    return undefined;
  }

  get nacionalidade() {
    return this.contato && this.contato.Nacionalidade__c
      ? this.contato.Nacionalidade__c
      : "Brasileira";
  }

  handleContaSelecionada(event) {
    this.accountId = event.detail.accountId;
  }

  fecharModal() {
    const fecharModalEvent = new CustomEvent("fecharmodal");
    this.dispatchEvent(fecharModalEvent);
  }

  submitNovoPassageiro() {
    let submitButton = this.template.querySelector(".hidden-submit");
    submitButton.click();
  }

  handleError(event) {
    let errorToast;
    if (event.detail.detail.includes("Email")) {
      errorToast = new ShowToastEvent({
        variant: "error",
        title: event.detail.message,
        message: "Favor verificar se o email inserido é válido"
      });
    } else {
      errorToast = new ShowToastEvent({
        variant: "error",
        title: event.detail.message,
        message: event.detail.detail
      });
    }

    this.dispatchEvent(errorToast);
    this.loading = false;
  }

  handleSubmit(event) {
    this.loading = true;
    event.preventDefault();
    let fields = event.detail.fields;
    this.contato = { ...fields };
    fields = {
      ...fields,
      AccountId: this.contaVoo
    };
    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }

  handleSuccess(event) {
    this.loading = false;
    const passageiroCriado = JSON.stringify(
      this.getPassageiroFromEditForm(event.detail)
    );
    const passageiroCriadoEvent = new CustomEvent(`passageirocriado`, {
      detail: {
        passageiroCriado
      }
    });
    this.dispatchEvent(passageiroCriadoEvent);
    const successToast = new ShowToastEvent({
      variant: "success",
      title: this.customLabel.sucesso,
      message: this.customLabel.sucessoAdicionarPassageiro
    });
    this.dispatchEvent(successToast);
  }

  getPassageiroFromEditForm(contato) {
    let camposContato = contato.fields;
    let passageiro = {};
    for (let campo of Object.keys(camposContato)) {
      passageiro[campo] = camposContato[campo].value;
    }
    const firstName = camposContato.FirstName.value
      ? camposContato.FirstName.value
      : "";
    const middleName = camposContato.MiddleName.value
      ? camposContato.MiddleName.value
      : "";
    const lastName = camposContato.LastName.value
      ? camposContato.LastName.value
      : "";
    passageiro.Id = contato.id;
    passageiro.Name = `${firstName} ${middleName} ${lastName}`.replace(
      /\s+/g,
      " "
    );
    return passageiro;
  }
}