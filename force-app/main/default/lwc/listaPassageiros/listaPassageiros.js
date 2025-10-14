import { LightningElement, api, track } from "lwc";

import contatosLabel from "@salesforce/label/c.Contatos";
import passageirosVoo from "@salesforce/label/c.PassageirosVoo";
import tituloLimitePassageiros from "@salesforce/label/c.TituloLimitePassageiros";
import mensagemLimitePassageiros from "@salesforce/label/c.MensagemLimitePassageiros";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ListasPassageiros extends LightningElement {
  customLabel = {
    contatos: contatosLabel,
    passageirosVoo,
    tituloLimitePassageiros,
    mensagemLimitePassageiros
  };

  @track state = {};

  @api screenSize;
  @api vooWrapper;
  @api listaCompleta;
  @api filtro;
  @api filterFocus;

  @api passageirosVoo;
  @api contatos;
  @api trechoSelecionado;

  @api numeroAssentosMax;
  @api numeroTrechos;
  @api filterLoading = false;

  handleListaPrincipalConnected() {
    let listaP = this.template.querySelector(".lista-principal");
    if (listaP) {
      listaP.callRender(this.listaPrincipal);
    }
  }

  get isLoading(){
    return !!this.filterLoading;
  }

  get dontUseOrderby(){
    return false;
  }

  get useOrderby(){
    return false;
  }

  handleListaSecundariaConnected() {
    let listaS = this.template.querySelector(".lista-secundaria");
    if (listaS) listaS.callRender(this.listaSecundaria);
  }

  @api
  set listaPrincipal(value) {
    this.state.listaPrincipal = value;
    let listaP = this.template.querySelector(".lista-principal");
    if (listaP) listaP.callRender(value);
  }
  get listaPrincipal() {
    return this.state.listaPrincipal;
  }
  @api
  set listaSecundaria(value) {
    this.state.listaSecundaria = value;
    let listaS = this.template.querySelector(".lista-secundaria");
    if (listaS) listaS.callRender(value);
  }
  get listaSecundaria() {
    return this.state.listaSecundaria;
  }
  //@track loading = true;
  //@track filtro = "";

  // get listaPrincipal() {
  //   return this.state.listaPrincipal;
  // }
  // set listaPrincipal(value) {
  //   this.state.listaPrincipal = value;
  // }

  handleFilterFocus(event) {
    const filterFocusEvent = new CustomEvent("filterfocus", {
      detail: event.detail
    });
    this.dispatchEvent(filterFocusEvent);
  }

  @api
  setListasHeight() {
    let listas = this.template.querySelectorAll("c-lista-contatos");
    for (let lista of listas) {
      lista.setGridHeight();
    }
  }

  get listaGridClass() {
    return !this.filterFocus ? "lista-grid" : "lista-unica";
  }

  get telaPassageirosVoo() {
    return this.trechoSelecionado === -1;
  }
  get listaPrincipalFiltrada() {
    return this.contatosFiltrados(this.state.listaPrincipal);
  }
  get trechos() {
    return this.vooWrapper.trechos;
  }
  get headerPrincipal() {
    if (this.trechoSelecionado === -1) {
      return this.customLabel.contatos;
    }
    return this.customLabel.passageirosVoo;
  }
  get headerSecundario() {
    if (this.trechoSelecionado === -1) {
      return this.customLabel.passageirosVoo;
    }
    return this.vooWrapper.trechos[this.trechoSelecionado].Rota__c;
  }

  handleNovoPassageiro() {
    const novoPassageiroEvent = new CustomEvent("novopassageiro");
    this.dispatchEvent(novoPassageiroEvent);
  }

  handleClickListaPrincipal(event) {
    let maxPassageiros =
      this.trechoSelecionado === -1
        ? this.numeroAssentosMax * this.numeroTrechos
        : this.numeroAssentosMax;
    if (this.listaSecundaria.length >= maxPassageiros) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: this.customLabel.tituloLimitePassageiros,
          message: this.customLabel.mensagemLimitePassageiros,
          variant: "warning"
        })
      );
    } else {
      const clickListaPrincipalEvent = new CustomEvent("clicklistaprincipal", {
        detail: event.detail
      });
      this.dispatchEvent(clickListaPrincipalEvent);
    }
  }

  handleClickListaSecundaria(event) {
    const clickListaSecundariaEvent = new CustomEvent("clicklistasecundaria", {
      detail: event.detail
    });
    this.dispatchEvent(clickListaSecundariaEvent);
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

    // let c = event.detail.contato;
    // let selected = event.detail.selected;
    // if (selected) {
    //   this.passageirosVoo = this.addPassageiro(c, this.passageirosVoo);
    //   this.listaPrincipal = this.delPassageiro(c, this.listaPrincipal);
    // } else {
    //   this.listaPrincipal = this.addPassageiro(c, this.listaPrincipal);
    //   this.passageirosVoo = this.delPassageiro(c, this.passageirosVoo);
    // }
  }

  addPassageiro(contato, lista) {
    return [...lista, contato];
  }

  delPassageiro(contato, lista) {
    return lista.filter((passageiro) => passageiro.Id !== contato.Id);
  }

  handleFilterChanged(event) {
    const filterChangedEvent = new CustomEvent("filterchanged", {
      detail: event.detail
    });
    this.dispatchEvent(filterChangedEvent);
  }

  // handleFilterChanged(event) {
  //   this.filtro = event.detail;
  // }

  normalizar(palavra) {
    return palavra
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");
  }

  contatosFiltrados(contatos) {
    return contatos
      .filter((contato) => {
        if (!contato.selected) {
          let contatoNormalizado = this.normalizar(
            `${contato.Name} ${contato.NumeroDocumento__c}`
          );
          //palavras do filtro contidas no nome
          let palavrasFiltro = this.filtro.split(" ");
          return (
            palavrasFiltro.filter((palavra) =>
              contatoNormalizado.includes(this.normalizar(palavra))
            ).length === palavrasFiltro.length
          );
        }
        return false;
      })
      .sort((a, b) => {
        if (a.Name.toLowerCase() > b.Name.toLowerCase()) {
          return 1;
        }
        return -1;
      });
  }

  handleVoltar() {
    this.trechoSelecionado = this.trechoSelecionado - 1;
  }

  handleAvancar() {
    this.trechoSelecionado = this.trechoSelecionado + 1;
  }
}