import {
    LightningElement,
    api
} from 'lwc';

import total from '@salesforce/label/c.Total';

export default class HeaderListasPassageiros extends LightningElement {

    @api header = 'Passageiros Voo Grande Pakas';
    @api showFilter;
    @api numeroPassageiros;

    customLabel = {
        total
    }

    get headerClass() {
        return this.showFilter ? 'header-filter' : 'full-header';
    }

    handleFilterChanged(event) {
        const filterChangedEvent = new CustomEvent('filterchanged', {
            detail: event.detail
        });
        this.dispatchEvent(filterChangedEvent);
    }

    handleFilterFocus(event) {
        const filterFocusEvent = new CustomEvent('filterfocus', {
            detail: event.detail
        });
        this.dispatchEvent(filterFocusEvent);
    }

    @api
    getHeight() {
        let header = this.template.querySelector(`.header-lista-passageiro`);
        return header.offsetHeight;
    }

    handleNovoPassageiro() {
        const novoPassageiroEvent = new CustomEvent('novopassageiro');
        this.dispatchEvent(novoPassageiroEvent);
    }
}