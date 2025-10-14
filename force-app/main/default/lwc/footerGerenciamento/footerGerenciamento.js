import {
    LightningElement,
    api
} from 'lwc';

import voltar from '@salesforce/label/c.Voltar';
import salvarAvancar from '@salesforce/label/c.SalvarAvancar';
import salvarFechar from '@salesforce/label/c.SalvarFechar';


export default class FooterGerenciamento extends LightningElement {

    customLabel = {
        voltar,
        salvarAvancar,
        salvarFechar
    }

    @api trechoSelecionado;
    @api ultimoTrecho;
    @api screenSize;

    @api labelNovo;
    @api mostrarNovo;
    @api avancarDisabled;

    get actionButtonLabel() {
        return !this.ultimoTrecho ? this.customLabel.salvarAvancar : this.customLabel.salvarFechar;
    }

    get smallScreen() {
        return this.screenSize === 'SMALL';
    }

    get mostraVoltar() {
        return !this.smallScreen && this.trechoSelecionado >= 0;
    }

    get brandClass() {
        return this.smallScreen ? 'slds-button_brand full-button' : 'slds-button slds-button_brand'
    }

    handleVoltar() {
        const voltarEvent = new CustomEvent('voltar');
        this.dispatchEvent(voltarEvent);
    }

    handleAvancar() {
        const avancarEvent = new CustomEvent('avancar');
        this.dispatchEvent(avancarEvent);
    }

    handleNovo() {
        const novoPassageiroEvent = new CustomEvent('novo');
        this.dispatchEvent(novoPassageiroEvent);
    }
}