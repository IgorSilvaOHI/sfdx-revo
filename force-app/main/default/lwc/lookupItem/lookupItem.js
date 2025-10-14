import {
    LightningElement,
    api
} from 'lwc';

import contaLabel from '@salesforce/label/c.Conta';

export default class LookupItem extends LightningElement {

    customLabel = {
        contaLabel
    }

    @api conta;

    handleClick() {
        this.dispatchEvent(new CustomEvent('selecionado', {
            detail: {
                accountId: this.conta.Id
            }
        }))
    }
}