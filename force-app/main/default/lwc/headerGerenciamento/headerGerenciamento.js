import { LightningElement, api } from "lwc";

import voo from "@salesforce/label/c.Voo";
import modeloAeronave from "@salesforce/label/c.ModeloAeronave";
import rota from "@salesforce/label/c.Rota";
import data from "@salesforce/label/c.Data";
import payload from "@salesforce/label/c.Payload";
import Utils from "c/utils";
export default class HeaderGerenciamento extends LightningElement {
  customLabel = {
    voo,
    modeloAeronave,
    rota,
    data,
    payload
  };

  @api vooWrapper;

  @api
  getHeight() {
    return this.template.querySelector(".voo-info").offsetHeight;
  }
  get dataLabel() {
    return this.customLabel.data + ":";
  }

  get data() {
    return this.vooWrapper.voo.DataVoo__c;
  }
}