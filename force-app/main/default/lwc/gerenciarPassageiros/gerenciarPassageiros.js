/* eslint-disable no-console */
import { LightningElement, api, track, wire } from "lwc";
//import getContatosFromConta from '@salesforce/apex/ContatoController.getContatosFromConta';
//import getTrechosAndPassageiroFromVoo from "@salesforce/apex/TrechoController.getTrechosAndPassageiroFromVoo";
import carregando from "@salesforce/label/c.Carregando";
import novoPassageiro from "@salesforce/label/c.NovoPassageiro";
import passageirosSalvosSucesso from "@salesforce/label/c.PassageirosSalvosSucesso";
import sucesso from "@salesforce/label/c.Sucesso";
import erroInesperado from "@salesforce/label/c.ErroInesperado";
import gerenciarPassageiros from "@salesforce/label/c.GerenciarPassageiros";

import getContatosNaoInclusos from "@salesforce/apex/ContatosService.getContatosNaoInclusos";
import getPassageirosVoo from "@salesforce/apex/PassageirosVooService.getPassageirosVoo";
import salvarListaPassageiros from "@salesforce/apex/PassageirosService.salvarListaPassageiros";
import ButtonActionNavigationModal from "c/buttonActionNavigationModal";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class GerenciarPassageiros extends LightningElement {
  customLabel = {
    carregando,
    passageirosSalvosSucesso,
    sucesso,
    erroInesperado,
    gerenciarPassageiros,
    novoPassageiro
  };

  @track state = {};

  @api
  set vooWrapper(value) {
    this.state.vooWrapper = value;
    if (!this.passageirosTrechos) {
      this.setPassageirosTrechos(value.trechos);
    }
  }
  get vooWrapper() {
    return this.state.vooWrapper ? this.state.vooWrapper : {};
  }

  get vooId() {
    return this.vooWrapper.voo ? this.vooWrapper.voo.Id : null;
  }

  get contaVoo() {
    return this.vooWrapper.voo ? this.vooWrapper.voo.Cliente__c : null;
  }

  @track filtro = "";

  @track screenSize;
  @track innerHeight;

  /**** */
  @track mostrarNovoPassageiro;

  @track passageirosVoo = {};
  @track passageirosVooTrecho = [];
  @track contatosVoo = [];
  @track contatos = [];
  @track passageirosTrechos;
  @track trechoSelecionado = -1;
  @track filterFocus = false;

  @track loading = true;
  @track filterLoading = false;

  @track processandoRequisicao;

  @track clicouUltimoSalvar = false;

  get numeroTrechos() {
    return this.vooWrapper && this.vooWrapper.trechos
      ? this.vooWrapper.trechos.length
      : undefined;
  }

  get avancarDisabled() {
    return this.processandoRequisicao || this.loading;
  }

  get numeroAssentosMax() {
    return this.vooWrapper && this.vooWrapper.voo.Prefixo__r
      ? this.vooWrapper.voo.Prefixo__r.NumeroAssentos__c
      : undefined;
  }

  get mostrarNovo() {
    return this.screenSize !== "SMALL";
  }

  get ultimoTrecho() {
    return this.trechoSelecionado === this.vooWrapper.trechos.length - 1;
  }

  get listaPrincipal() {
    let listaPrincipal =
      this.trechoSelecionado === -1
        ? this.contatos
        : this.passageirosVooTrecho[this.trechoSelecionado];
    if (listaPrincipal) {
      listaPrincipal = Object.values(listaPrincipal);
    }
    listaPrincipal =
      listaPrincipal && listaPrincipal.length > 0
        ? listaPrincipal.map((contato) => {
            return {
              Id: contato.Id,
              Name: contato.Name,
              TipoDocumento__c: contato.TipoDocumento__c,
              NumeroDocumento__c: contato.NumeroDocumento__c,
              Empresa__c: contato.Empresa__c
            };
          })
        : [];
    return listaPrincipal;
  }

  get listaSecundaria() {
    let listaSecundaria;
    if (this.trechoSelecionado === -1) {
      listaSecundaria = this.passageirosVoo;
    } else {
      listaSecundaria = this.passageirosTrechos[this.trechoSelecionado];
    }
    if (listaSecundaria) listaSecundaria = Object.values(listaSecundaria).filter(passageiro => !passageiro.Excluido__c);
    listaSecundaria =
      listaSecundaria && listaSecundaria.length > 0
        ? listaSecundaria.map((contato) => {
            return {
              Id: contato.Id,
              Name: contato.Name,
              TipoDocumento__c: contato.TipoDocumento__c,
              NumeroDocumento__c: contato.NumeroDocumento__c,
              Empresa__c: contato.Empresa__c
            };
          })
        : [];
    return listaSecundaria;
  }

  constructor() {
    super();
    this.updateScreenSize();
    window.onresize = this.updateAltura.bind(this);
  }

  connectedCallback() {
    this.setPassageirosVoo();
  }

  renderedCallback() {
    this.setAlturaComponentes();
  }

  setPassageirosVoo() {
    getPassageirosVoo({
      vooId: this.vooId
    })
      .then((data) => {
        let passageirosVoo = JSON.parse(data);
        let passageirosVooTrecho = [];
        for (let passageiroTrecho of this.passageirosTrechos) {
          let passageiroVooT = {
            ...passageirosVoo
          };
          for (let contato of Object.keys(passageiroTrecho)) {
            if (passageiroVooT[contato]) {
              let { novoObj } = this.removePropriedade(passageiroVooT, contato);
              passageiroVooT = novoObj;
            } else {
              passageirosVoo[contato] = passageiroTrecho[contato];
            }
          }
          passageirosVooTrecho.push(passageiroVooT);
        }
        this.passageirosVoo = passageirosVoo;
        this.passageirosVooTrecho = passageirosVooTrecho;
        this.contatosVoo = Object.keys(this.passageirosVoo);
        this.setContatosNaoInclusos();
      })
      .catch((error) => {
        console.error(error);
      });
  }

  setContatosNaoInclusos() {
    if(this.vooWrapper.voo.Tipo__c !== 'ShuttleSeat'){
      getContatosNaoInclusos({
        contatosId: this.contatosVoo,
        filtro: this.filtro
      })
        .then((data) => {
          this.contatos = JSON.parse(data);
          this.loading = false;
          this.filterLoading = false;
        })
        .catch((error) => {
          this.loading = false;
          this.filterLoading = false;
        });
    }
    else{
      this.contatos = [];
      this.loading = false;
      this.filterLoading = false;
    }
  }
/*
  setContatosNaoInclusos() {
    getContatosNaoInclusos2({
      accountId: this.contaVoo,
      contactsIds: this.contatosVoo
    })
      .then((data) => {
        this.contatos = JSON.parse(data);
        this.loading = false;
      })
      .catch((error) => {
        console.error(error);
      });
  }*/

  // @wire(getContatosNaoInclusos, {
  //   contatosId: '$contatosVoo'
  // })
  // wiredContacts({
  //   error,
  //   data
  // }) {
  //   if (data) {
  //     this.contatos = JSON.parse(data);
  //     this.loading = false;
  //   } else if (error) {
  //     this.loading = false;
  //     console.error(error);
  //     // eslint-disable-next-line no-console
  //     this.error = error;
  //   }
  // }

  // @wire(getPassageirosVoo, {
  //   vooId: "$vooId"
  // })
  // wiredPassageirosVoo({
  //   error,
  //   data
  // }) {
  //   if (data) {
  //     try {
  //       let passageirosVoo = JSON.parse(data);
  //       let passageirosVooTrecho = [];
  //       for (let passageiroTrecho of this.passageirosTrechos) {
  //         let passageiroVooT = {
  //           ...passageirosVoo
  //         };
  //         for (let contato of Object.keys(passageiroTrecho)) {
  //           if (passageiroVooT[contato]) {
  //             let {
  //               novoObj
  //             } = this.removePropriedade(passageiroVooT, contato);
  //             passageiroVooT = novoObj;
  //           } else {
  //             passageirosVoo[contato] = passageiroTrecho[contato];
  //           }
  //         }
  //         passageirosVooTrecho.push(passageiroVooT);
  //       }
  //       this.passageirosVoo = passageirosVoo;
  //       this.passageirosVooTrecho = passageirosVooTrecho;
  //       this.contatosVoo = Object.keys(this.passageirosVoo);
  //     } catch (error2) {
  //       console.error(error2)
  //     }

  //   } else if (error) {
  //     this.error = error;
  //   }
  // }

  setAlturaComponentes() {
    try {
      let lista = this.template.querySelector(".lista-container");
      let headerGerenciamento = this.template.querySelector(
        ".header-gerenciamento"
      );
      let container = this.template.querySelector(".container");
      let conteudo = this.template.querySelector(".conteudo");

      let conteudoHeight = this.innerHeight - (this.filterFocus ? 48 : 96);

      if (container) container.style.height = `${this.innerHeight}px`;
      if (conteudo) {
        conteudo.style.height = `${conteudoHeight}px`;
        conteudo.style.maxHeight = `${conteudoHeight}px`;
      }
      if (headerGerenciamento && lista && this.screenSize !== "SMALL") {
        let height = `calc(${conteudoHeight}px - ${headerGerenciamento.getHeight()}px - 2rem)`;
        lista.style.height = height;
        lista.style.maxHeight = height;
      } else if (lista) {
        lista.style.height = "inherit";
        lista.style.maxHeight = "inherit";
      }
      let listaPassageiros = this.template.querySelector("c-lista-passageiros");
      if (listaPassageiros) listaPassageiros.setListasHeight();
    } catch (error) {
      console.error(error);
    }
  }

  setPassageirosTrechos(trechos) {
    let passageirosTrechos = [];
    for (let trecho of trechos) {
      if (trecho.Passageiros__r) {
        let passageirosTrecho = trecho.Passageiros__r.records;
        let passageiros = {};
        for (let passageiro of passageirosTrecho) {
          if(!passageiro.Excluido__c){
            passageiros[passageiro.Contato__r.Id] = passageiro.Contato__r;
          }
        }
        passageirosTrechos.push(passageiros);
      } else {
        passageirosTrechos.push({});
      }
    }
    this.passageirosTrechos = passageirosTrechos;
  }

  handlePassageiroCriado(contato) {
    this.adicionaContatoTodosPassageirosVoo(contato);
  }

  handleClickListaPrincipal(event) {
    let contato = event.detail;
    let removido = this.removeContatoListaPrincipal(contato);
    this.adicionaContatoListaSecundaria(removido);
  }

  removeContatoListaPrincipal(contato) {
    let listaPrincipal =
      this.trechoSelecionado === -1
        ? this.contatos
        : this.passageirosVooTrecho[this.trechoSelecionado];
    let { removido, novoObj } = this.removePropriedade(
      listaPrincipal,
      contato.Id
    );
    if (this.trechoSelecionado === -1) {
      this.contatos = novoObj;
    } else {
      this.passageirosVooTrecho = this.updateItemArray(
        this.passageirosVooTrecho,
        this.trechoSelecionado,
        novoObj
      );
    }
    return removido;
  }

  adicionaContatoListaSecundaria(contato) {
    let listaSecundaria;
    if (this.trechoSelecionado === -1) {
      this.adicionaContatoTodosPassageirosVoo(contato);
    } else {
      listaSecundaria = this.passageirosTrechos[this.trechoSelecionado];
      let novoObj = this.addProperty(listaSecundaria, contato.Id, contato);
      this.passageirosTrechos = this.updateItemArray(
        this.passageirosTrechos,
        this.trechoSelecionado,
        novoObj
      );
    }
  }

  adicionaContatoTodosPassageirosVoo(contato) {
    this.passageirosVoo = this.addProperty(
      this.passageirosVoo,
      contato.Id,
      contato
    );
    let passageirosVooTrecho = [];
    for (let passageirosVoo of this.passageirosVooTrecho) {
      passageirosVoo = this.addProperty(passageirosVoo, contato.Id, contato);
      passageirosVooTrecho.push(passageirosVoo);
    }
    this.passageirosVooTrecho = passageirosVooTrecho;
  }

  handleClickListaSecundaria(event) {
    let contato = event.detail;
    let removido = this.removeContatoListaSecundaria(contato);
    this.adicionaContatoListaPrincipal(removido);
  }

  removeContatoListaSecundaria(contato) {
    let listaSecundaria;
    if (this.trechoSelecionado === -1) {
      let removido = this.removePassageirosVooTodosTrechos(contato);
      return removido;
    }
    listaSecundaria = this.passageirosTrechos[this.trechoSelecionado];
    let { removido, novoObj } = this.removePropriedade(
      listaSecundaria,
      contato.Id
    );
    this.passageirosTrechos = this.updateItemArray(
      this.passageirosTrechos,
      this.trechoSelecionado,
      novoObj
    );
    return removido;
  }

  removePassageirosVooTodosTrechos(contato) {
    let { removido, novoObj } = this.removePropriedade(
      this.passageirosVoo,
      contato.Id
    );
    this.passageirosVoo = novoObj;
    this.passageirosTrechos = this.removeFromAllObjectsOnArray(
      this.passageirosTrechos,
      contato.Id
    );
    this.passageirosVooTrecho = this.removeFromAllObjectsOnArray(
      this.passageirosVooTrecho,
      contato.Id
    );
    return removido;
  }

  removeFromAllObjectsOnArray(array, propriedade) {
    let novoArray = [];
    for (let objeto of array) {
      let { novoObj } = this.removePropriedade(objeto, propriedade);
      novoArray.push(novoObj);
    }
    return novoArray;
  }

  adicionaContatoListaPrincipal(contato) {
    let listaPrincipal =
      this.trechoSelecionado === -1
        ? this.contatos
        : this.passageirosVooTrecho[this.trechoSelecionado];
    let novoObj = this.addProperty(listaPrincipal, contato.Id, contato);
    if (this.trechoSelecionado === -1) {
      this.contatos = novoObj;
    } else {
      this.passageirosVooTrecho = this.updateItemArray(
        this.passageirosVooTrecho,
        this.trechoSelecionado,
        novoObj
      );
    }
  }

  addProperty(obj, propertyName, propertyValue) {
    let result = {
      ...obj,
      [propertyName]: propertyValue
    };
    return result;
  }

  removePropriedade(obj, propertyName) {
    let { [propertyName]: removido, ...novoObj } = obj;
    return {
      removido,
      novoObj
    };
  }

  updateItemArray(array, index, item) {
    return [
      ...array.slice(0, index),
      item,
      ...array.slice(index + 1, array.length)
    ];
  }

  handleFilterFocus(event) {
    this.filterFocus = event.detail.focus;
  }

  get mostrarVoltar() {
    return this.screenSize === "SMALL" && this.trechoSelecionado >= 0;
  }

  handleNovoPassageiro() {
    
    ButtonActionNavigationModal.open({
      recordId: null,
      objectApiName: 'Contact',
      title: 'Passageiro do voo',
      values: JSON.stringify({}),
      recordType: 'Passageiro',
      size: 'medium'
    }).then((result) => {
        if(result?.status === 'success'){
            if(!result.id){
                return;
            }

            this.dispatchEvent(new ShowToastEvent({
                title: 'Registro criado com sucesso',
                message: '',
                variant: 'success',
                mode: 'pester'
            }));

            this.loading = true;
            this.handleFilterChanged({detail: ''});
        }
    });
  }

  updateAltura() {
    this.updateScreenSize();
    this.setAlturaComponentes();
  }

  updateScreenSize() {
    if (window.innerWidth < 768) {
      this.screenSize = "SMALL";
    } else if (window.innerWidth < 1024) {
      this.screenSize = "MEDIUM";
    } else {
      this.screenSize = "LARGE";
    }
    this.innerHeight = window.innerHeight;
  }

  closeQuickAction() {
    const closeQuickActionEvent = new CustomEvent("closequickaction");
    this.dispatchEvent(closeQuickActionEvent);
  }

  handleAvancar() {
    try {
      if (!this.processandoRequisicao) {
        this.processandoRequisicao = true;
        let trechos = this.vooWrapper.trechos;
        let passageirosTrechos = {};
        for (let [index, trecho] of trechos.entries()) {
          passageirosTrechos[trecho.Id] = Object.keys(
            this.passageirosTrechos[index]
          );
        }
        let passageirosVoo = Object.keys(this.passageirosVoo);
        if (this.ultimoTrecho) {
          this.loading = true;
          this.clicouUltimoSalvar = true;
        }
        salvarListaPassageiros({
          passageirosVoo,
          passageirosTrechos,
          vooId: this.vooWrapper.voo.Id
        })
          .then(() => {
            this.processandoRequisicao = false;
            if (this.clicouUltimoSalvar) {
              this.loading = false;
              const event = new ShowToastEvent({
                variant: "success",
                title: this.customLabel.sucesso,
                message: this.customLabel.passageirosSalvosSucesso
              });
              this.dispatchEvent(event);
              this.closeQuickAction();
            }
          })
          .catch((error) => {
            let message = JSON.stringify(error); 
            if (error.body && error.body.output && error.body.output.errors.length > 0) {
              message = error.body.output.errors[0].message;
            } else if (error.body && error.body.message) {
                message = error.body.message;
            }else if(error.body && error.body.pageErrors && error.body.pageErrors.length > 0 ){
                message = error.body.pageErrors[0].message;
            }
            const event = new ShowToastEvent({
              variant: "error",
              title: this.customLabel.erroInesperado,
              message: message
            });
            
            this.processandoRequisicao = false;

            this.dispatchEvent(event);
          });

        if (this.trechoSelecionado < this.passageirosTrechos.length - 1)
          this.trechoSelecionado++;
      }
    } catch (error) {
      console.error(error);
    }
  }
  handleVoltar() {
    if (this.trechoSelecionado >= 0) this.trechoSelecionado--;
  }

  handleFilterChanged(event) {
    this.filtro = event.detail;
    this.filterLoading = true;
    this.setContatosNaoInclusos();
  }

  handleContatoSelected(event) {
    let c = event.detail.contato;
    let selected = event.detail.selected;
    if (selected) {
      this.add(c, this.vooWrapper.passageirosVoo, "passageirosVoo");
      this.del(c, this.vooWrapper.contatos, "contatos");
    } else {
      this.add(c, this.vooWrapper.contatos, "contatos");
      this.del(c, this.vooWrapper.passageirosVoo, "passageirosVoo");
      this.del(c, this.vooWrapper.passageirosTrechos, "passageirosTrechos");
    }
  }

  handlePassageiroSelected(event) {
    let selected = event.detail.selected;
    let trechoIndex = event.detail.trechoIndex;
    let c = {
      ...event.detail.contato,
      trechoIndex: trechoIndex,
      selected: selected
    };

    let itens;
    if (selected) {
      //adicionando passageiro a um trecho
      itens = this.addPassageiroTrecho(
        c,
        this.vooWrapper.passageirosTrechos,
        trechoIndex
      );
    } else {
      itens = this.edit(
        c,
        this.vooWrapper.passageirosTrechos,
        "passageirosTrechos",
        trechoIndex
      );
    }

    this.vooWrapper = {
      ...this.vooWrapper,
      passageirosTrechos: itens
    };
  }

  addPassageiroTrecho(item, lista, trechoIndex) {
    let itens;
    if (
      lista.some(
        (itemLista) =>
          itemLista.Id === item.Id && itemLista.trechoIndex === trechoIndex
      )
    ) {
      itens = this.editItem(item, lista, trechoIndex);
    } else {
      itens = this.addItem(item, lista);
    }

    return itens;
  }

  edit(item, lista, attrName, trechoIndex) {
    return this.editItem(item, lista, trechoIndex);
  }

  editItem(item, lista, trechoIndex) {
    let index = lista.findIndex(
      (p) => p.Id === item.Id && p.trechoIndex === trechoIndex
    );

    let listaAux = lista;
    listaAux[index] = item;

    return [...listaAux];
  }

  add(item, lista, attrName) {
    let itens = this.addItem(item, lista);
    this.vooWrapper = {
      ...this.vooWrapper,
      [attrName]: itens
    };
  }

  addItem(item, lista) {
    return lista ? this.sort([...lista, item]) : [item];
  }

  del(item, lista, attrName) {
    let itens = this.delItem(item, lista);
    this.vooWrapper = {
      ...this.vooWrapper,
      [attrName]: itens
    };
  }

  delItem(item, lista) {
    return lista.filter((itemLista) => itemLista.Id !== item.Id);
  }

  sort(lista) {
    return lista.sort((a, b) => {
      if (a.Name.toLowerCase() > b.Name.toLowerCase()) {
        return 1;
      }
      return -1;
    });
  }
}

// addPassageiroVoo(contato) {
//   this.passageirosVoo = [...this.passageirosVoo, contato];
// }

// delPassageiroVoo(contato) {
//   this.passageirosVoo = this.passageirosVoo.filter(
//     passageiro => passageiro.Id !== contato.Id
//   );
// }

// handleAvancar() {
//   if (this.mostrarSelecaoPassageirosVoo) {
//     this.mostrarSelecaoPassageirosVoo = false;
//   } else {
//     //salva no banco
//     if (this.trechoSelecionado < this.trechos.length - 1) {
//       this.trechoSelecionado = this.trechoSelecionado + 1;
//     } else {
//     }
//   }
// }

// handleVoltar() {
//   if (this.trechoSelecionado > 0) {
//     this.trechoSelecionado = this.trechoSelecionado - 1;
//   } else {
//     this.mostrarSelecaoPassageirosVoo = true;
//   }
// }

// get headerGerenciamentoTitle() {
//   if (this.mostrarSelecaoPassageirosVoo) {
//     return "Passageiros do Voo";
//   }
//   let trecho = this.trechos[this.trechoSelecionado];
//   let trechoName = `${trecho.Origem__r.Name} - ${trecho.Destino__r.Name}`;
//   return trechoName;
// }

// get headerGerenciamentoSub() {
//   return this.mostrarSelecaoPassageirosVoo ? "Obs: Todos os trechos" : "";
// }