import { LightningElement, api } from 'lwc';

export default class InputLocalVoo extends LightningElement {
    @api value;
    @api label;
    @api formattedValue;
    @api useCoordenades;
    @api tipoVoo;
    @api usarCoordenadasSelecionado;
    @api coordenadasSelecionado;
    
    coordenadeValue;
    locationValue;
    initiated = false;

    connectedCallback() {
        this.usarCoordenadasSelecionado = this.coordenadasSelecionado ?? false;
        this.coordenadasSelecionado = this.coordenadasSelecionado ?? false;

        if(this.value){
            if(this.value?.indexOf(',') > 0){
                this.coordenadeValue = this.value;
                this.usarCoordenadasSelecionado = true;
                this.coordenadasSelecionado = true;
            }else{
                this.locationValue = this.value;
            }
        }

        this.initiated = true;
    }

    get displayBotaoCoordenada(){
        return this.tipoVoo === 'Charter';
    }

    get getColumnClass(){
        return this.tipoVoo === 'Charter' ? 'slds-size_3-of-5 slds-p-right_small slds-p-vertical_small' : 'slds-size_1-of-1 slds-p-vertical_small';
    }
    
    get getUsarCoordenada(){
        return this.usarCoordenadasSelecionado ?? false;
    }

    get isLocal(){
        return !this.getUsarCoordenada && this.initiated;
    }

    get isCoordenada(){
        return this.getUsarCoordenada && this.initiated;
    }

    handleChange(){
        this.usarCoordenadasSelecionado = !this.usarCoordenadasSelecionado;
        this.coordenadasSelecionado = !this.coordenadasSelecionado;
    }

    handleFormatValue(event){
        this.formattedValue = event.detail.formattedValue;
    }

    handleChangeValue(event){
        if(this.usarCoordenadasSelecionado){
            this.coordenadeValue = event.detail.value;
        }else{
            this.locationValue = event.detail.value;
        }
       
        this.formattedValue = event.detail.formattedValue;
        this.value = event.detail.value;
    }
    
    @api
    validate() {
        const lookupComponent = this.template.querySelector('c-lookup-action');
        if (lookupComponent) {
            return lookupComponent.validate();
        }
    }
}