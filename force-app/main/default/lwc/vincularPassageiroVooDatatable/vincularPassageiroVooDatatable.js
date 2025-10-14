import { LightningElement, api, wire } from 'lwc';
import { deleteRecord  } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ButtonActionNavigationModal from "c/buttonActionNavigationModal";
import {FlowNavigationNextEvent} from 'lightning/flowSupport';

const columns = [
    { label: 'Passageiro', fieldName: 'recordLink', hideDefaultActions:true, type: 'url',
        typeAttributes: {
            target: '_blank',
            label: { fieldName: 'NomePassageiro__c' },
            target: '',
            tooltip: { fieldName: 'NomePassageiro__c' }
        }},
    { label: 'Número do documento', fieldName: 'NumeroDocumento__c', hideDefaultActions:true, type: 'text'},
    { label: 'Email', fieldName: 'Email__c', hideDefaultActions:true, type: 'text'},
    { type: 'action', hideDefaultActions:true,
        typeAttributes: { rowActions: [
            { label: 'Editar', name: 'editar' },
            { label: 'Excluir', name: 'excluir' }
        ] },
    },
];

export default class VincularPassageiroVooDatatable extends LightningElement {
    @api passageirosSelecionados = [];
    @api values = {};
    @api refreshUI;
    @api recordId;
    
    get getColums(){
        return columns;
    }

    selectedRows;
    
    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'editar':
                this.handleManterPassageiro(row.Id);
                break;
            case 'excluir':
                this.handleExcluirProdutoPassageiro(row);
                break;
        }
    }
    
    connectedCallback() {
        //FIX LINK URL
        this.passageirosSelecionados = this.passageirosSelecionados.map(item => {
            const newItem = {...item};
            newItem.recordLink = '/' + item.Id;
            return newItem;
        });

        if(this.passageirosSelecionados.length > 0){
            this.selectedRows = [this.passageirosSelecionados[0].Id];
            this.recordId = this.passageirosSelecionados[0].Id;
            
            const event = {
                detail : {
                    selectedRows: [this.passageirosSelecionados[0]]
                }
            }
            this.onrowselected(event);
        }
    }

    get passageirosLength(){
        return this.passageirosSelecionados.length;
    }

    async handleExcluirProdutoPassageiro(row){
        deleteRecord(row.Id).then(response => {
            this.refreshUI = 'Delete';
            this.recordId = row.PassageiroOportunidade__c;
            this.dispatchEvent(new FlowNavigationNextEvent());
        });

        this.dispatchEvent(new ShowToastEvent({
            title: 'Registro excluído com sucesso!',
            message: '',
            variant: 'success',
            mode: 'pester'
        }));

        this.passageirosSelecionados = this.passageirosSelecionados.filter(a => a.Id !== row.Id);

        if(this.passageirosSelecionados.length > 0){
            this.selectedRows = [this.passageirosSelecionados[0].Id];
        }else{
            this.selectedRows = [];
        }
    }

    handleInserirRegistro(event){
        this.handleManterPassageiro();
    }

    handleManterPassageiro(recordId){
        ButtonActionNavigationModal.open({
            recordId: recordId,
            objectApiName: 'ProdutoPassageiro__c',
            title: 'Passageiro do voo',
            values: this.values,
            recordType: 'PassageiroVoo',
            size: 'small'
        }).then((result) => {
            if(result?.status === 'success'){
                if(!result.id){
                    return;
                }

                const message = !recordId ? 'Registro criado com sucesso' : 'Registro alterado com sucesso'
                this.dispatchEvent(new ShowToastEvent({
                    title: message,
                    message: '',
                    variant: 'success',
                    mode: 'pester'
                }));

                if(!recordId){
                    this.refreshUI = 'Add';
                    this.recordId = result.id;
                    this.dispatchEvent(new FlowNavigationNextEvent());
                }
            }
        });
    }
    
    get isGridLoadedEmpty(){
        return this.passageirosSelecionados.length === 0;
    }

    onrowselected(event){
        this.recordId = event.detail.selectedRows[0].Id;
        this.refreshUI = 'Configure';
    }
}