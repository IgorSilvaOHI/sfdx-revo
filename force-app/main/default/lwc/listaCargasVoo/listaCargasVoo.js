import {
    LightningElement,
    api
} from 'lwc';


import templateDesktop from './listaCargasVoo.html';
import templateMobile from './listaCargasVooMobile.html';

import cargasVoo from '@salesforce/label/c.CargasVoo';
import nova from '@salesforce/label/c.Nova';
import vooNaoPossuiCarga from '@salesforce/label/c.VooNaoPossuiCarga';
import cadastrarNovaCarga from '@salesforce/label/c.CadastrarNovaCarga';
import identificacao from '@salesforce/label/c.Identificacao';
import profundidade from '@salesforce/label/c.Profundidade';
import altura from '@salesforce/label/c.Altura';
import largura from '@salesforce/label/c.Largura';
import peso from '@salesforce/label/c.Peso';

export default class ListaCargasVoo extends LightningElement {

    customLabel = {
        cargasVoo,
        nova,
        vooNaoPossuiCarga,
        cadastrarNovaCarga,
        identificacao,
        profundidade,
        altura,
        largura,
        peso
    }

    @api cargasVoo = []

    @api screenSize;

    render() {
        return this.smallScreen ? templateMobile : templateDesktop;
    }

    get possuiCargasVoo() {
        return this.cargasVoo.length > 0;
    }

    get smallScreen() {
        return this.screenSize === 'SMALL';
    }

    handleNovaCarga() {
        const novaCargaEvent = new CustomEvent('novacarga');
        this.dispatchEvent(novaCargaEvent);
    }

    handleEditCarga(event) {
        let button = event.target;
        let cargaId = button.getAttribute('data-carga-id');
        const editCargaEvent = new CustomEvent('editcarga', {
            detail: {
                cargaId
            }
        });
        this.dispatchEvent(editCargaEvent);
    }

    handleDeleteCarga(event) {
        let button = event.target;
        let cargaId = button.getAttribute('data-carga-id');
        const deleteCargaEvent = new CustomEvent('deletecarga', {
            detail: {
                cargaId
            }
        });
        this.dispatchEvent(deleteCargaEvent);
    }
}