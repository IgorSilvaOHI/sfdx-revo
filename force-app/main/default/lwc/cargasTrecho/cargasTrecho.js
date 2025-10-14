import {
    LightningElement,
    api,
    track
} from "lwc";

export default class CargasTrecho extends LightningElement {
    @track state = {};

    @api vooWrapper;
    @api listaCompleta;
    @api selected;
    @api principal;
    @api trechoIndex;
    @api screenSize;

    ///*** */
    @api cargas;
    @api header;

    handleFilterChanged(event) {
        this.filtro = event.detail;
    }

    @api
    setGridHeight() {
        let cargasGrid = this.template.querySelector('.cargas-grid');
        let headerLista = this.template.querySelector('.header-lista');

        if (headerLista && cargasGrid) {
            let marginHeight = this.screenSize !== "SMALL" ? '2rem' : this.principal ? '1rem' : '2rem';
            cargasGrid.style.maxHeight = `calc(${this.template.host.offsetHeight}px - ${headerLista.getHeight()}px - ${marginHeight})`;
        }
    }

    get listaCargasClass() {
        return this.principal ? 'lista-cargas principal' : 'lista-cargas';
    }

    handleNovaCarga() {
        const novaCargaEvent = new CustomEvent('novacarga');
        this.dispatchEvent(novaCargaEvent);
    }

    handleCargaClicked(event) {
        const cargaClickedEvent = new CustomEvent('cargaclicked', {
            detail: event.detail
        });
        this.dispatchEvent(cargaClickedEvent);
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

    handleQuantidade(event) {
        const quantidadeMudouEvent = new CustomEvent("quantidademudou", {
            detail: event.detail
        });
        this.dispatchEvent(quantidadeMudouEvent);
    }
}