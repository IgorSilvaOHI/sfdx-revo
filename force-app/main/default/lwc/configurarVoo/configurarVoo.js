import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import criarLinhasOportunidade from "@salesforce/apex/VendaVooController.criarLinhasOportunidade";
import flightRecalculate from "@salesforce/apex/VendaVooController.flightRecalculate";

const columns = [
    { label: 'Nome', fieldName: 'NomeProduto', hideDefaultActions:true, hideDefaultActions:true },
    { label: 'Quantidade', fieldName: 'Quantidade', type: 'decimal', editable: { fieldName: 'PorPassageiro' }, 
                    typeAttributes: {maximumFractionDigits: '0'},
                    displayReadOnlyIcon: { fieldName: 'IsReadOnly' },
                    hideDefaultActions:true},
    { label: 'Empacotado?', fieldName: 'Empacotado', type: 'boolean', hideDefaultActions:true },
    { label: 'Preço unitário', fieldName: 'PrecoUnitario', type: 'currency', hideDefaultActions:true },
    { label: '% desconto', fieldName: 'PercentualDesconto', type: 'percent', hideDefaultActions:true },
    { label: 'Valor desconto', fieldName: 'ValorDesconto', type: 'currency', hideDefaultActions:true },
    { label: 'Preço total', fieldName: 'PrecoTotal', type: 'currency', hideDefaultActions:true }
];

const TipoVoo = {Shuttle: 'ShuttleSeat', Charter: 'Charter', FullCabin: 'FullCabin'};

export default class ConfigurarVoo extends LightningElement {
    @api conta = {};
    @api codigoPromocional = {};
    @api vooSelecionado = [];
    @api vooSelecionadoServicos = [];
    @api vooExcluidoServicos = [];
    @api vooSelecionadoDestinos = [];
    @api editMode = false;
    @api tipoVoo;

    vooSelecionadoServicosState = [];
    data = [];
    selectedRows = [];
    isLoading = false;
    draftValues = [];

    get getColums(){
        return columns;
    }

    connectedCallback() {

        this.loadScreen();

        if(this.editMode){
            this.isLoading = true;
            this.sendFlightRecalculate([]);
        }
        
        this.handleSave.bind(this);
        this.handleCellChange.bind(this);
        this.loadScreen.bind(this);
    }

    loadScreen(){
        let position = 0;
        this.vooSelecionadoServicosState = [];
        this.data = [];
        this.selectedRows = [];
        this.vooSelecionadoServicos.forEach(servico => {

            if(servico.Selecionado__c || servico.Obrigatorio__c || servico.Id || servico.Empacotado__c){
                this.selectedRows.push(position);
            }

            const discountValue = servico.DescontoPercentual__c > 0 ? servico.PrecoUnitario__c * servico.DescontoPercentual__c / 100 : servico.DescontoValor__c ?? 0;

            this.data.push({
                Position: position,
                Product2Id: servico.Product2Id,
                NomeProduto: servico.Description,
                Quantidade: servico.Quantity,
                PrecoUnitario: servico.PrecoUnitario__c,
                PercentualDesconto: servico.DescontoPercentual__c / 100,
                ValorDesconto: servico.DescontoValor__c,
                PrecoTotal: servico.UnitPrice  * servico.Quantity,
                Selecionado: servico.Selecionado__c,
                Obrigatorio: servico.Obrigatorio__c,
                Empacotado: servico.Empacotado__c,
                PorPassageiro: servico.ServicaoPorPassageiro__c && !servico.Empacotado__c,
                IsReadOnly: !(servico.ServicaoPorPassageiro__c && !servico.Empacotado__c)
            });

            this.vooSelecionadoServicosState.push({Position: position, ...servico});
            
            position++;
        });

        this.vooSelecionadoServicos = this.vooSelecionadoServicosState.filter((servico) => this.selectedRows.includes(servico.Position));
    }
    
    showErrorMessage(err){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Erro ao pesquisar voos',
            message: JSON.stringify(err),
            variant: 'error',
            mode: 'pester'
        }));

        this.isLoading = false;
    }

    async getVoosCallback(context, data)
    {
        if(data?.length > 0){
            const flights = [];
            data.forEach(voo => {
                if(context.tipoVoo === TipoVoo.Shuttle){
                    flights.push(voo);
                }else{
                    voo.horarios.forEach(bloco => {
                        flights.push({ ...voo, ...bloco, dataHora: bloco.data });
                    });
                }
            });

            const flight = flights.find(a => a.dataHora === context.vooSelecionado.PrevisaoEmbarque__c);

            if(flight){
                
                let tipoVoo = context.tipoVoo.replace('Flight', '');
                tipoVoo = tipoVoo === TipoVoo.Shuttle ? 'Shuttle' : tipoVoo === TipoVoo.Charter ? 'Charter' : 'FullCabin';

                const selectedFlight = {
                    ...flight,
                    voo: flight
                };

                const linhasOportuniadde = await criarLinhasOportunidade({
                    flightTipe: tipoVoo,
                    selectedFlight: JSON.stringify(selectedFlight)
                });

                context.vooSelecionadoServicos = linhasOportuniadde.slice(1).map(item => {
                    const oldItem = context.vooSelecionadoServicos.find(a => a.Product2Id === item.Product2Id);
                    const itemServico = flight.servicos.find(a => a.produto  === item.Product2Id );
                    return context.createOpportunityLineItem(context, item, oldItem, itemServico);
                });
                this.selectedRows = [];
            }else{
                context.showErrorMessage('Erro ao encontrar disponibilidade de voo, contate o administrador do sistema');
            }
            
            context.loadScreen();
        }
        
        this.isLoading = false;
    }
    
    createOpportunityLineItem(context, item, oldItem, itemServico){
        const newItem = {...item};
        newItem.Description = itemServico.servico;
		newItem.OpportunityId = context.vooSelecionado.OpportunityId;
		newItem.Pacote__c = context.vooSelecionado.Id;

        if(oldItem){
            newItem.Id = oldItem.Id;
            newItem.Selecionado__c = Object.keys(context.selectedRows).map(a => context.selectedRows[a]).some(a => a == oldItem.Position);
        }

        return newItem;
    }

    onrowselected(event){
        this.selectedRows = [];

        this.vooSelecionadoServicosState.forEach(servico => { 
            const selected = event.detail.selectedRows.some(a => a.Position === servico.Position);

            if(((servico.Obrigatorio__c || servico.Empacotado__c) && !selected) || selected){
                this.selectedRows.push(servico.Position);
            }
            servico.Selecionado__c = selected;
        });

        this.vooSelecionadoServicosState = [...this.vooSelecionadoServicosState];
        this.vooExcluidoServicos = [...this.vooSelecionadoServicosState.filter((servico) => servico.Id && !this.selectedRows.includes(servico.Position))];
        this.vooSelecionadoServicos = [...this.vooSelecionadoServicosState.filter((servico) => this.selectedRows.includes(servico.Position))];
    }

    sendFlightRecalculate(draftValues){
        this.isLoading = true;
        const tipoVoo = this.tipoVoo.replace('Flight', '');

        const flightRequest = {
            oppotunityType: tipoVoo,
            promotionalCode: this.promotionalCode,
            account: this.conta
        }

        const flight = {
            productId: this.vooSelecionado.Product2Id,
            quantity: parseInt(`${this.vooSelecionado.Quantity}`) ,
            flightDateTime: this.vooSelecionado.PrevisaoEmbarque__c,
            departurePointId: this.vooSelecionado.Origem__c,
            destinationPointId: this.vooSelecionado.Destino__c,
            modeloId: this.vooSelecionado.ModeloSelecionado__c,
            services: this.vooSelecionadoServicosState.map(servico => {
                const draftService = draftValues.find(a => a.Position == servico.Position);
                const quantity = parseInt(`${draftService?.Quantidade ?? servico.Quantity}`);
                return {
                    productId: servico.Product2Id,
                    quantity: quantity == 0 ? 1 : quantity,
                }
            })
        }

        if(tipoVoo === TipoVoo.Charter){
            this.vooSelecionadoDestinos = [...this.vooSelecionadoDestinos];
            this.vooSelecionadoDestinos.sort((a, b) => a.Sequencia__c - b.Sequencia__c);

            flight.route = this.vooSelecionadoDestinos.map((a, idx) => {
                return {id: a.Local__c, sequence: idx, latitude: a.Coordenadas__Latitude__s, longitude: a.Coordenadas__Longitude__s};
            });
        }

        switch(tipoVoo){
            case TipoVoo.Charter:
                flightRequest.charters = [flight];
                break;
            case TipoVoo.FullCabin:
                flightRequest.fullCabins = [flight];
                break;
            case TipoVoo.Shuttle:
                flightRequest.shuttleSeats = [flight];
                break;
        }

        flightRecalculate({param: flightRequest}).then(dataResponse => {
            let dataParam;
            
            switch(tipoVoo){
                case TipoVoo.Charter:
                    dataParam = dataResponse.charters;
                    break;
                case TipoVoo.FullCabin:
                    dataParam = dataResponse.fullCabins;
                    break;
                case TipoVoo.Shuttle:
                    dataParam = dataResponse.shuttleSeats;
                    break;
            }
            this.getVoosCallback(this, dataParam).then(() => {
                this.draftValues = [];
            });
        }).catch(err => this.showErrorMessage(err));
        
    }

    handleSave(event) {
        this.draftValues = event.detail.draftValues;
        this.sendFlightRecalculate(this.draftValues);
    }

    handleCellChange(event) {
        const { draftValues } = event.detail;
        this.draftValues.forEach(draft => {
            if(!draftValues.some(a => a.Position == draft.Position)){
                draftValues.push(draft);
            }
        });

        this.draftValues = draftValues.filter(draft =>  this.vooSelecionadoServicosState.find(a => a.Position == draft.Position && a.ServicaoPorPassageiro__c));
    }
}