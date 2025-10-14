import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ButtonActionNavigationModal from "c/buttonActionNavigationModal";
import { updateRecord } from 'lightning/uiRecordApi';

const columns = [
    { label: 'Nome', fieldName: 'Name', hideDefaultActions:true, type: 'text'},
    { label: 'Descrição', fieldName: 'Description', hideDefaultActions:true, type: 'text'},
    { label: '', fieldName: 'Status__c', hideDefaultActions:true, type: 'text', fixedWidth: 50,
        cellAttributes: {
            iconName: { fieldName: 'ConfiguracaoIcon' },
            iconPosition: 'right',
            alignment: 'right'
        }
    },
    { type: 'action', hideDefaultActions:true,
        typeAttributes: { rowActions: [
            { label: 'Configurar', name: 'editar' },
            { label: 'Remover', name: 'excluir' }
        ] },
    },
];

export default class VincularPassageiroVooDatatable extends LightningElement {
    @api servicosVoo = [];
    @api servicosPassageiro = [];
    @api values = {};
    
    get getColums(){
        return columns;
    }
    
    handleRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'editar':
                this.handleManterServico(row);
                break;
            case 'excluir':
                this.handleExcluirServico(row);
                break;
        }
    }
    
    connectedCallback() {
        //FIX LINK URL
        this.servicosVoo = this.servicosVoo.map(item => {
            const configuredItem = this.servicosPassageiro.find(a => a.ProdutoOportunidade__c === item.Id);
            const newItem = {...item};
            
            newItem.PSId = configuredItem?.Id;
            newItem.Configurado__c = '';
            newItem.Status__c = '';
            newItem.ConfiguracaoIcon = configuredItem?.Status__c === 'Configurado' ? 'utility:success' : configuredItem?.Status__c === 'Removido' ? 'utility:clear' : 'utility:warning';
            
            return newItem;
        });
    }

    get servicosLength(){
        return this.servicosVoo.length;
    }

    handleManterServico(row){

        const linhaPassageiro = this.servicosPassageiro.find(a => a.ProdutoOportunidade__c === row.Pacote__c);

        var passageiroOportunidadeId = linhaPassageiro.length > 1 ? linhaPassageiro[0].Passageiro__c : linhaPassageiro.Passageiro__c ;

        const valuesParam = {
            ProdutoOportunidade__c: row.Id,
            Passageiro__c: passageiroOportunidadeId
        }

        ButtonActionNavigationModal.open({
            recordId: row?.PSId,
            objectApiName: 'ProdutoPassageiro__c',
            title: `Serviço do passageiro - ${row.Description}`,
            values: JSON.stringify(valuesParam),
            recordType: null,
            size: 'small'
        }).then((result) => {
            if(result?.status === 'success'){
                const message = !(row?.Id) ? 'Registro criado com sucesso' : 'Registro alterado com sucesso'
                this.dispatchEvent(new ShowToastEvent({
                    title: message,
                    message: '',
                    variant: 'success',
                    mode: 'pester'
                }));
                
                const servicoLinha = this.servicosVoo.find(a => a.Id === row.Id);
                servicoLinha.PSId = result.id;
                servicoLinha.ConfiguracaoIcon = 'utility:success';
                
                updateRecord({
                    fields: {
                        Id: result.id,
                        Status__c: 'Configurado'
                    }
                });

                this.servicosVoo = [...this.servicosVoo];
            }
        });
    }
    
    async handleExcluirServico(row){

        updateRecord({
            fields: {
                Id: row.PSId,
                Status__c: 'Removido'
            }
        });

        this.dispatchEvent(new ShowToastEvent({
            title: 'Registro removido com sucesso!',
            message: '',
            variant: 'success',
            mode: 'pester'
        }));

        const servicoLinha = this.servicosVoo.find(a => a.Id === row.Id);
        servicoLinha.PSId = null;
        servicoLinha.ConfiguracaoIcon = 'utility:clear';
        servicoLinha.Status__c = '';
        this.servicosVoo = [...this.servicosVoo];
        
    }    

    get isGridLoadedEmpty(){
        return this.servicosVoo.length === 0;
    }

    onrowselected(event){
        this.recordId = event.detail.selectedRows[0].Id;
    }
}