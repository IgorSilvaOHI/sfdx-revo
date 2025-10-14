import { api, wire, LightningElement } from 'lwc';

import altLogoComunidade from "@salesforce/label/c.AltLogoComunidade";
import { getRecord,deleteRecord  } from 'lightning/uiRecordApi';
import getOpportunityLineItems from '@salesforce/apex/VendaVooController.getOpportunityLineItems';
import isInCommunity from '@salesforce/apex/VendaVooController.isInCommunity';
import { NavigationMixin } from 'lightning/navigation';
import { RefreshEvent, registerRefreshHandler, unregisterRefreshHandler } from "lightning/refresh";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import EditarConfiguracaoModal from "c/editarConfiguracaoModal";
import VincularPassageiroVooModal from "c/vincularPassageiroVooModal";
import ConfigurarVooModal from "c/configurarVooModal";
// Novo
// import FlowModal from "c/flowModal";
// Novo

const columns = [
    { label: 'Nome', fieldName: 'recordLink', hideDefaultActions:true, type: 'url',
        typeAttributes: {
            label: { fieldName: 'nome' },
            target: '',
            tooltip: { fieldName: 'originalName' }
        }},
    { label: 'Previsão', fieldName: 'previsaoEmbarque', hideDefaultActions:true, type: 'text', initialWidth:125},
    { label: 'Descrição', fieldName: 'descricao', hideDefaultActions:false },
    { label: 'Quantidade', fieldName: 'quantidade', type: 'number', hideDefaultActions:true,initialWidth:100  },
    { label: 'Valor unitário', fieldName: 'precoUnitario', type: 'currency', hideDefaultActions:true,initialWidth:110  },
    { label: '% desconto', fieldName: 'percentualDesconto', type: 'percent', hideDefaultActions:true,initialWidth:100 },
    { label: 'Valor desconto', fieldName: 'valorDesconto', type: 'currency', hideDefaultActions:true,initialWidth:110 },
    { label: 'Valor total', fieldName: 'precoTotal', type: 'currency', hideDefaultActions:true,initialWidth:110 },
    { type: 'action', hideDefaultActions:true,
        typeAttributes: { rowActions: [
            { label: 'Configurar pacote', name: 'configurar' },
            { label: 'Passageiros', name: 'passageiros' },
            { label: 'Excluir', name: 'excluir' },
        ] },
    },
];

export default class ListaConfiguracaoVoo extends NavigationMixin(LightningElement) {
    @api recordId;

    datagridOpportunityLineItemColumns = columns;
    customLabel = {altLogoComunidade};
    opportunity = {opportunityLineItems:[]};
    gridLoading = true;
    wiredOpportunityLnResponse;
    wiredOpportunityResponse;
    refreshHandlerID;
    displayAdicionarVoo = true;
    initiatedQuantity;

    @wire(isInCommunity) isCommunity;

    connectedCallback() {
        this.refreshHandlerID = registerRefreshHandler(
          this.template.host,
          this.refreshHandler.bind(this),
        );

        this.handleRowAction.bind(this);
        this.handleDeleteLine.bind(this);
        this.handleVincularPassageiro.bind(this);
    }

    disconnectedCallback() {
        unregisterRefreshHandler(this.refreshHandlerID);
    }

    @wire(getRecord, { recordId: "$recordId", fields:['Opportunity.Amount', 'Opportunity.StageName'], optionalFields: ['Opportunity.CodigoPromocional__c'] })
    wiredOportunidade(result) {
        this.wiredOpportunityResponse = result;
        const data = result.data;
        if (data) {
            this.displayAdicionarVoo = data.fields.StageName.value === 'Cotação';
            
            if(!this.displayAdicionarVoo){
                this.datagridOpportunityLineItemColumns = this.datagridOpportunityLineItemColumns.filter(item => item.type !== 'action');
            }

            this.opportunity.currencyIsoCode = data.fields.CurrencyIsoCode?.value?.CurrencyIsoCode ?? 'BRL';
            this.opportunity.codigoPromocional = data.fields.CodigoPromocional__c.value;
            this.opportunity.totalParcial = data.fields.Amount.value;
            this.opportunity.totalDesconto = 0;
            this.opportunity.totalAPagar = data.fields.Amount.value;
            this.opportunity = {...this.opportunity}
        }
    }
    
    @wire(getOpportunityLineItems, { opportunityId: '$recordId' })
    wiredLineItems(result) {
        this.wiredOpportunityLnResponse = result;

        if (result.data) {
            
            this.opportunity.opportunityLineItems = [];
            const pesos = {};
            let pesoBase = 100;

            for (const item of result.data) {
                if (!item.Pacote__c) {
                    pesos[item.Id] = pesoBase;
                    pesoBase += 100;
                }
            }

            result.data.forEach(opportunityLineItem =>{
                const name = opportunityLineItem.Pacote__c ? `└ ${opportunityLineItem.Product2.Name}` : `▶ ${opportunityLineItem.Product2.Name}`;
                
                const pesoPai = opportunityLineItem.Pacote__c ? pesos[opportunityLineItem.Pacote__c] : pesos[opportunityLineItem.Id];
                const peso = opportunityLineItem.Pacote__c ? pesoPai + 1 : pesoPai; 

                this.opportunity.opportunityLineItems.push({
                    peso,
                    id: opportunityLineItem.Id,
                    nome: name,
                    originalName: opportunityLineItem.Product2.Name,
                    quantidade: opportunityLineItem.Quantity,
                    precoUnitario: opportunityLineItem.PrecoUnitario__c,
                    precoTotal: opportunityLineItem.TotalPrice,
                    descricao: opportunityLineItem.Description,
                    recordLink: '/' + opportunityLineItem.Id,
                    pacote: opportunityLineItem.Pacote__c,
                    percentualDesconto: opportunityLineItem.DescontoPercentual__c / 100,
                    valorDesconto: opportunityLineItem.DescontoValor__c,
                    obrigatorio: opportunityLineItem.Obrigatorio__c,
                    previsaoEmbarque: opportunityLineItem.PrevisaoEmbarque__c ? new Date(opportunityLineItem.PrevisaoEmbarque__c).toLocaleString(undefined, {
                        year: 'numeric',
                        month: '2-digit',
                        day: '2-digit',
                        hour: '2-digit',
                        minute: '2-digit',
                        second: undefined,
                        hour12: false
                      }) : ''
                });
            });

            this.opportunity.opportunityLineItems.sort((a, b) => a.peso - b.peso);

            if(this.opportunity.opportunityLineItems.filter(a => !a.pacote).length > this.initiatedQuantity){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Criação concluída com sucesso',
                    message: '',
                    variant: 'success',
                    mode: 'pester'
                }));
            }
            
            this.initiatedQuantity = this.opportunity.opportunityLineItems.filter(a => !a.pacote).length;
            this.opportunity = {...this.opportunity};
        }
        
        this.gridLoading = false;
    }

    async refreshHandler() {
        await refreshApex(this.wiredOpportunityLnResponse);  
        await refreshApex(this.wiredOpportunityResponse); 
    }

    async handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'configurar':
                this.handleConfigurar(row);
                break;
            case 'passageiros':
                this.handleVincularPassageiro(row);
                break;
            case 'excluir':
                this.gridLoading = true;
                this.handleDeleteLine(row);
                break;
        }
    }

    async handleConfigurar(row){
        EditarConfiguracaoModal.open({
            recordId: row.pacote ?? row.id
          }).then((result) => {
            if(result === 'success'){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Configuração atualizada com sucesso!',
                    message: '',
                    variant: 'success',
                    mode: 'pester'
                }));
                
                refreshApex(this.wiredOpportunityLnResponse);  
            }
          });
    }

    async handleVincularPassageiro(row){
        VincularPassageiroVooModal.open({
            recordId: row.pacote ?? row.id,
            opportunityId: this.recordId,
            onnavigate: (e) => {
                this[NavigationMixin.Navigate](e.detail);
            }
          }).then((result) => {
            if(result === 'success'){
                refreshApex(this.wiredOpportunityLnResponse);  
            }else if (!result){
                this.dispatchEvent(new RefreshEvent());
            }
          });
    }

    async handleDeleteLine(row){
        const optLnToDelete = this.opportunity.opportunityLineItems.filter(item => item.pacote === row.id);

        if(row.pacote && row.obrigatorio){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Não é possível remover serviços obrigatórios',
                message: '',
                variant: 'error',
                mode: 'pester'
            }));
        }else{
            try{
                for(let i = 0; i < optLnToDelete.length; i++){
                    await deleteRecord(optLnToDelete[i].id);
                }
        
                await deleteRecord(row.id);
        
                this.dispatchEvent(new RefreshEvent());
                await refreshApex(this.wiredOpportunityLnResponse);

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Produto excluído com sucesso!',
                    message: '',
                    variant: 'success',
                    mode: 'pester'
                }));

            }catch(err){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Erro ao excluir registro!',
                    message: `${err}`,
                    variant: 'error',
                    mode: 'sticky'
                }));
            }
        }
        
        this.gridLoading = false;         
    }

    handleAdicionarVoo(){
        ConfigurarVooModal.open({
            recordId: this.recordId, 
            modalSize: this.isCommunity.data ? 'medium' : 'large'
        }).then((result) => {
            if(result === 'success'){
                refreshApex(this.wiredOpportunityLnResponse);  
            }
        });
    }

    // Novo
    // async handleAbrirFlowRetro(){
    //     const inputVariables = [
    //         { name: 'recordId', type: 'String', value: this.recordId }
    //     ];
    //     await FlowModal.open({
    //         size: 'large',
    //         label: 'Oportunidade - Gerar Voos Retroativos',
    //         flowApiName: 'OportunidadeGerarVoosRetroativos',
    //         inputVariables
    //     });
    // }

    // Novo

    get isGridLoadedEmpty(){
        return this.opportunity.opportunityLineItems.length === 0 && !this.gridLoading;
    }

    get getVoosLength(){
        return this.opportunity.opportunityLineItems.filter(a => !a.pacote).length;
    }
}