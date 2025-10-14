import {
    LightningElement,
    api
} from 'lwc';

export default class NavigationHeader extends LightningElement {
    @api screenSize;
    @api mostrarVoltar;
    @api tituloHeader;

    @api mostrarTextoCentral;
    @api textoCentral;

    get closeSize() {
        return this.screensize === 'SMALL' ? 'small' : 'medium';
    }

    closeQuickAction() {
        const closeQuickActionEvent = new CustomEvent('closequickaction');
        this.dispatchEvent(closeQuickActionEvent);
    }

    voltar() {
        const voltarEvent = new CustomEvent('voltar');
        this.dispatchEvent(voltarEvent);
    }
}