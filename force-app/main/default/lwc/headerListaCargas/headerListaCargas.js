import {
    LightningElement,
    api
} from 'lwc';

import quantidade from '@salesforce/label/c.Quantidade';
import identificacao from '@salesforce/label/c.Identificacao';

export default class HeaderListaCargas extends LightningElement {

    customLabel = {
        identificacao,
        quantidade
    }

    @api header;
    @api showNovaCarga;

    @api
    getHeight() {
        let header = this.template.querySelector(`.header-lista-carga`);
        return header.offsetHeight;
    }

    handleNovaCarga() {
        const novaCargaEvent = new CustomEvent('novacarga');
        this.dispatchEvent(novaCargaEvent);
    }
}