import { LightningElement,api } from 'lwc';

export default class MalhaVooCard extends LightningElement {
    @api voo;
    
    handleSelecionar(){
        this.dispatchEvent(new CustomEvent('cellevent', {
          composed: true,
          bubbles: true,
          cancelable: true,
          detail: { name: 'OnNextItem', voo: this.voo }
        }));
    }

    get tempoTranslado(){
      const tempoTranslado = Math.trunc(this.voo.tempoTransladoIda ?? 0) + Math.trunc(this.voo.tempoTransladoRetorno ?? 0);
      
      if(tempoTranslado > 0){
        return this.formatMinutes(Math.trunc(this.voo.tempoMissao) - tempoTranslado);
      }
      return null;
    }

    get hasTranslado(){
      return this.tempoTranslado !== null;
    }

    get tempoVoo(){
      return this.formatMinutes(Math.trunc(this.voo.tempoMissao));
    }
    
    formatMinutes(totalMinutes) {
      const hours = Math.floor(totalMinutes / 60);
      const minutes = totalMinutes % 60;
    
      if (hours > 0 && minutes > 0) {
        return `${hours}h ${minutes}min`;
      } else if (hours > 0) {
        return `${hours}h`;
      } else {
        return `${minutes}min`;
      }
    }

    get getSelectButtonVariant(){
      return this.voo.default ? 'brand' : 'brand-outline';
    }

    hasQuantidadeMaiorQueUm(){
        return this.voo.quantidade > 1;
    }
}