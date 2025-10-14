import { LightningElement, api, track } from "lwc";

import mensagemAuxilioPassageirosVoo from "@salesforce/label/c.MensagemAuxilioPassageirosVoo";
import mensagemAuxilioPassageirosTrecho from "@salesforce/label/c.MensagemAuxilioPassageirosTrecho";

export default class ListaContatos extends LightningElement {
  customLabel = {
    mensagemAuxilioPassageirosVoo,
    mensagemAuxilioPassageirosTrecho
  };

  @track state = {};

  connectedCallback() {
    const listaContatosConnectedEvent = new CustomEvent(
      `lista${this.principal ? "principal" : "secundaria"}connected`
    );
    this.dispatchEvent(listaContatosConnectedEvent);
  }

  get numeroPassageiros() {
    return !this.principal && this.novaLista.length > 0
      ? this.novaLista.length
      : undefined;
  }

  @track _listaCompleta;
  @api
  set listaCompleta(value) {
    this._listaCompleta = value;
  }
  get listaCompleta() {
    return this._listaCompleta;
  }
  @api selected;
  @api principal;
  @api trechoIndex;
  @api screenSize;
  @api useOrderBy = false;
  @track filtro;
  @api filterLoading = false;
  ///*** */
  @api header;


  get isLoading(){
    return !!this.filterLoading;
  }

  handleFilterChanged(event) {
    this.filtro = event.detail;

    this.dispatchEvent(
      new CustomEvent('filterchanged', {
        detail: event.detail,
        bubbles: true,
        composed: true
      })
    );
  }

  @api callRender(value) {
    this.listaCompleta = value;
    this.novaLista = value;
  }

  @api
  setGridHeight() {
    let contatosGrid = this.template.querySelector(".contatos-grid");
    let headerLista = this.template.querySelector(".header-lista");
    if (headerLista && contatosGrid) {
      let marginHeight =
        this.screenSize !== "SMALL" ? "2rem" : this.principal ? "1rem" : "2rem";
      contatosGrid.style.maxHeight = `calc(${
        this.template.host.offsetHeight
      }px - ${headerLista.getHeight()}px - ${marginHeight})`;
    }
  }

  @track novaLista = [];

  get listaVazia() {
    return this.listaFiltrada.length === 0;
  }

  get mensagemAjudaListaVazia() {
    return this.trechoIndex === -1
      ? this.customLabel.mensagemAuxilioPassageirosVoo
      : this.customLabel.mensagemAuxilioPassageirosTrecho;
  }

  get listaContatosClass() {
    return this.principal ? "lista-contatos principal" : "lista-contatos";
  }

  get rotaTrecho() {
    return this.trechoIndex === -1 ? "" : this.header;
  }

  get listaFiltrada() {
    let novaLista = this.novaLista;

    if(!this.useOrderBy){
      return novaLista;
    }

    return novaLista.length > 1
      ? [...novaLista].sort((a, b) => {
          if (a.Name.toLowerCase() > b.Name.toLowerCase()) {
            return 1;
          }
          return -1;
        })
      : novaLista;
  }

  handleFilterFocus(event) {
    const filterFocusEvent = new CustomEvent("filterfocus", {
      detail: event.detail
    });
    this.dispatchEvent(filterFocusEvent);
  }

  handleNovoPassageiro() {
    const novoPassageiroEvent = new CustomEvent("novopassageiro");
    this.dispatchEvent(novoPassageiroEvent);
  }

  get secundaria() {
    return !this.principal;
  }

  normalizar(palavra) {
    return palavra
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");
  }

  handleContatoClicked(event) {
    const contatoClickedEvent = new CustomEvent("contatoclicked", {
      detail: event.detail
    });
    this.dispatchEvent(contatoClickedEvent);
  }

  handleContatoSelected(event) {
    const contatoSelectedEvent = new CustomEvent("contatoselected", {
      detail: event.detail
    });
    this.dispatchEvent(contatoSelectedEvent);
  }

  handlePassageiroSelected(event) {
    const passageiroSelectedEvent = new CustomEvent("passageiroselected", {
      detail: event.detail
    });
    this.dispatchEvent(passageiroSelectedEvent);
  }
}