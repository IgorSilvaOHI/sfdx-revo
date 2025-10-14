import { LightningElement, api } from "lwc";

import naoDefinido from "@salesforce/label/c.NaoDefinido";
export default class LinhaListaContatos extends LightningElement {
  customLabel = {
    naoDefinido
  };

  @api contato;
  @api trechoIndex;
  @api selected;
  @api screenSize;

  get smallScreen() {
    return this.screenSize === "SMALL";
  }

  get iconClass() {
    return !this.selected
      ? "slds-button slds-button_brand"
      : "slds-button slds-button_destructive";
  }

  get buttonIcon() {
    return `utility:${this.selected ? "delete" : "add"}`;
  }

  get buttonLabel() {
    return this.selected ? "Remover" : "Adicionar";
  }

  get buttonTitle() {
    return this.selected ? "Remover Passageiro" : "Adicionar Passageiro";
  }

  get buttonVariant() {
    return this.selected ? "destructive" : "brand";
  }

  get mostrarDocumento() {
    return this.contato.TipoDocumento__c && this.contato.NumeroDocumento__c;
  }

  get documento() {
    return this.contato.TipoDocumento__c && this.contato.NumeroDocumento__c
      ? `${this.contato.TipoDocumento__c} - ${this.contato.NumeroDocumento__c}`
      : this.customLabel.naoDefinido;
  }

  get possuiEmpresa(){
    return !!this.contato.Empresa__c;
  }

  handleClick() {
    const contatoClickedEvent = new CustomEvent("contatoclicked", {
      detail: {
        Id: this.contato.Id
      }
    });
    this.dispatchEvent(contatoClickedEvent);
  }

  handleSelected() {
    let eventName =
      this.trechoIndex > -1 ? "passageiroselected" : "contatoselected";

    const contatoSelectedEvent = new CustomEvent(eventName, {
      detail: {
        contato: this.contato,
        trechoIndex: this.trechoIndex,
        selected: !this.selected
      }
    });
    this.dispatchEvent(contatoSelectedEvent);
  }
}