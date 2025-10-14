import { LightningElement, api } from "lwc";

import adicionarCarga from "@salesforce/label/c.AdicionarCarga";
import removerCarga from "@salesforce/label/c.RemoverCarga";
import adicionar from "@salesforce/label/c.Adicionar";
import remover from "@salesforce/label/c.Remover";

export default class LinhaListaCargas extends LightningElement {
  customLabel = {
    adicionarCarga,
    removerCarga,
    adicionar,
    remover
  };

  @api carga;
  @api trechoIndex;
  @api principal;
  @api screenSize;

  get smallScreen() {
    return this.screenSize === "SMALL";
  }

  get iconClass() {
    return this.principal
      ? "slds-button slds-button_brand"
      : "slds-button slds-button_destructive";
  }

  get buttonIcon() {
    return `utility:${this.principal ? "add" : "delete"}`;
  }

  get buttonLabel() {
    return this.principal
      ? this.customLabel.adicionar
      : this.customLabel.remover;
  }

  get buttonTitle() {
    return this.principal
      ? this.customLabel.adicionarCarga
      : this.customLabel.removerCarga;
  }

  get buttonVariant() {
    return this.principal ? "brand" : "destructive";
  }

  handleClick() {
    const cargaClickedEvent = new CustomEvent("cargaclicked", {
      detail: {
        Id: this.carga.Id
      }
    });
    this.dispatchEvent(cargaClickedEvent);
  }

  handleQuantidade(event) {
    let Quantidade__c = event.target.value;
    const quantidadeMudouEvent = new CustomEvent("quantidademudou", {
      detail: {
        Id: this.carga.Id,
        Quantidade__c
      }
    });
    this.dispatchEvent(quantidadeMudouEvent);
  }
}