import {
    LightningElement,
    api,
    track
} from "lwc";

import cargasVoo from '@salesforce/label/c.CargasVoo';

export default class ListaCargas extends LightningElement {

    customLabel = {
        cargasVoo
    }

    @track state = {};

    @api screenSize;
    @api vooWrapper;
    @api listaCompleta;
    @api filtro;
    @api filterFocus;

    @api passageirosVoo;
    @api contatos;
    @api trechoSelecionado;

    @api listaPrincipal;
    @api listaSecundaria;

    handleFilterFocus(event) {
        const filterFocusEvent = new CustomEvent('filterfocus', {
            detail: event.detail
        });
        this.dispatchEvent(filterFocusEvent);
    }

    handleEditCarga(event) {
        const editCargaEvent = new CustomEvent('editcarga', {
            detail: event.detail
        });
        this.dispatchEvent(editCargaEvent);
    }

    handleDeleteCarga(event) {
        const deleteCargaEvent = new CustomEvent('deletecarga', {
            detail: event.detail
        });
        this.dispatchEvent(deleteCargaEvent);
    }

    @api
    setListasHeight() {
        if (!this.primeiraTela) {
            let listas = this.template.querySelectorAll('c-cargas-trecho');
            for (let lista of listas) {
                lista.setGridHeight()
            }
        }

    }
    get primeiraTela() {
        return this.trechoSelecionado === -1;
    }
    get listaPrincipalFiltrada() {
        return this.contatosFiltrados(this.state.listaPrincipal);
    }
    get trechos() {
        return this.vooWrapper.trechos;
    }
    get headerPrincipal() {
        return this.customLabel.cargasVoo;
    }
    get headerSecundario() {
        return this.vooWrapper.trechos[this.trechoSelecionado].Rota__c;
    }

    handleNovaCarga() {
        const novaCargaEvent = new CustomEvent('novacarga');
        this.dispatchEvent(novaCargaEvent);
    }

    handleClickListaPrincipal(event) {
        const clickListaPrincipalEvent = new CustomEvent('clicklistaprincipal', {
            detail: event.detail
        });
        this.dispatchEvent(clickListaPrincipalEvent);
    }

    handleQuantidade(event) {
        const quantidadeMudouEvent = new CustomEvent("quantidademudou", {
            detail: event.detail
        });
        this.dispatchEvent(quantidadeMudouEvent);
    }

    handleClickListaSecundaria(event) {
        const clickListaSecundariaEvent = new CustomEvent('clicklistasecundaria', {
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
        return lista.filter(passageiro => passageiro.Id !== contato.Id);
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
            .filter(contato => {
                if (!contato.selected) {
                    let contatoNormalizado = this.normalizar(
                        `${contato.Name} ${contato.NumeroDocumento__c}`
                    );
                    //palavras do filtro contidas no nome
                    let palavrasFiltro = this.filtro.split(" ");
                    return (
                        palavrasFiltro.filter(palavra =>
                            contatoNormalizado.includes(this.normalizar(palavra))
                        ).length === palavrasFiltro.length
                    );
                }
                return false;
            })
            .sort((a, b) => {
                if (a.Name > b.Name) {
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