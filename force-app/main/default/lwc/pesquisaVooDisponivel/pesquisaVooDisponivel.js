import { LightningElement,api } from 'lwc';
import getMalhaVoo from "@salesforce/apex/VendaVooController.getMalhaVoo";
import getVooCharterClient from "@salesforce/apex/VendaVooController.getVooCharterClient";
import getVooFullCabin from "@salesforce/apex/VendaVooController.getVooFullCabin";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import Toast from 'lightning/toast';
import criarLinhasOportunidade from "@salesforce/apex/VendaVooController.criarLinhasOportunidade";

const TipoVoo = {Shuttle: 'Shuttle', Charter: 'Charter', FullCabin: 'FullCabin'};
const FixedColumn = { label: '', fieldName: 'modelo', type: "vooImageCard", 
                    typeAttributes: { voo: { fieldName: 'modelo' } },cellAttributes: { alignment: "center", class:"slds-no-row-hover" }, hideDefaultActions:true,
                    fixedWidth: 280 };

export default class PesquisaVooDisponivel extends LightningElement {
    @api conta;
    @api origem;
    @api destino;
    @api diaVoo;
    @api quantidadeAssentos;
    @api codigoPromocional;
    @api tipoVoo;
    @api vooSelecionado = {};
    @api vooSelecionadoServicos = [];
    
    vooSelecionadoCelula;

    colunas = [];
    voosModelo = [];
    voosModeloPorData = [];

    gridLoaded = false;
    gridEmpty = false;

    connectedCallback() {
        const currColumns = [{...FixedColumn}, 
            { label: this.toLabelWhiteSpace('06:00'), fieldName: '0600', fixedWidth: 200, hideDefaultActions:true},
            { label: this.toLabelWhiteSpace('07:00'), fieldName: '0700', fixedWidth: 200, hideDefaultActions:true},
            { label: this.toLabelWhiteSpace('08:00'), fieldName: '0800', fixedWidth: 200, hideDefaultActions:true}];

        const timezoneOffset = this.getFormattedTimezoneOffset();
        const formatedLocalDateFlight = `${this.diaVoo.substring(0,10)}T00:00:00${timezoneOffset}`;

        this.voosModeloPorData = [
            {dataFormatada: this.getVooTime(formatedLocalDateFlight).dateFormatted, 
            data: this.getVooTime(formatedLocalDateFlight).date, 
            colunas: currColumns}];

        this.loadMalhaVoo();
    }

    getFormattedTimezoneOffset() {
        const offset = new Date().getTimezoneOffset();
        const sign = offset > 0 ? "-" : "+";
        const absOffset = Math.abs(offset);
        const hours = String(Math.floor(absOffset / 60)).padStart(2, '0');
        const minutes = String(absOffset % 60).padStart(2, '0');
        
        return `${sign}${hours}:${minutes}`;
    }

    get isGridLoaded()
    {
        return this.gridLoaded;
    }

    get gridLoadedEmpty(){
        return this.gridLoaded && this.gridEmpty;
    }

    loadMalhaVoo() {

        let destino;
        let origem = this.origem;
        if(this.tipoVoo === TipoVoo.Charter){

            destino = this.destino.map((a) =>{
                return a.indexOf(',') > 0 ? JSON.parse(a) : {id: a};
            });

            if(origem.indexOf(',') > 0){
                destino.unshift(JSON.parse(origem));
            }else{
                destino.unshift({id: origem});
            }
        }else{
            destino = this.destino[0];
        }

        const requestParams = {conta: this.conta, 
                               origem: origem, 
                               destino: destino,
                               data: this.diaVoo,
                               codigoPromocional: this.codigoPromocional,
                               quantidade: this.quantidadeAssentos};
        const context = this;

        let getVoo;

        switch(this.tipoVoo){
            case TipoVoo.Charter:
                getVoo = getVooCharterClient;
                break;
            case TipoVoo.FullCabin: 
                getVoo = getVooFullCabin; 
                break;
            case TipoVoo.Shuttle: 
                getVoo = getMalhaVoo; 
                break;
        }

        getVoo(requestParams).then((data) => this.getVoosCallback(context, data))
                             .catch(err => this.showErrorMessage(err));
    }

    showErrorMessage(err){
        Toast.show({
            label: 'Erro ao pesquisar voos',
            message: JSON.stringify(err),
            mode: 'sticky',
            variant: 'error'
        }, this);

        this.gridLoaded = true;
        this.gridEmpty = true;
    }
    
    getVooTime(dateTimeStr){
        const localDate = new Date(dateTimeStr);
        const {day, month, formatted} = this.formatDateToLocalString(new Date(localDate));

        return {
            date: formatted.substring(0, 10),
            dateFormatted: `${day}/${month}`,
            timeFormatted: `${formatted.substring(11, 13)}:${formatted.substring(14, 16)}`,
            time: `${formatted.substring(11, 13)}${formatted.substring(14, 16)}`
        };
    }
 
    formatDateToLocalString(date ) {
        const pad = (num, size = 2) => String(num).padStart(size, '0');
      
        const year = date.getFullYear();
        const month = pad(date.getMonth() + 1);
        const day = pad(date.getDate());
        const hours = pad(date.getHours());
        const minutes = pad(date.getMinutes());
        const seconds = pad(date.getSeconds());
      
        return {
            month: month,
            day: day,
            formatted: `${year}-${month}-${day}T${hours}:${minutes}:${seconds}.00`
        } ;
    }

    addGridLine(voo){
        
        const {date, time} = this.getVooTime(voo.dataHora);

        let voosModelo = this.voosModeloPorData.find(a => a.data === date);
        let linhaVooModelo = voosModelo.voos.find(a => a.modeloCode === voo.modelo);

        const tipeAttr = {
            isCharter: this.tipoVoo === TipoVoo.Charter,
            isFullCabin: this.tipoVoo === TipoVoo.FullCabin,
            isShuttle: this.tipoVoo === TipoVoo.Shuttle
        }

        voo = {...voo, ...tipeAttr };

        if(!linhaVooModelo)
        {
            linhaVooModelo = {
                modelo: {...voo, ...tipeAttr, pesoDisponivel: voo.pesoDisponivel?.toFixed(0) ?? 0 },
                tipo: this.tipoVoo,
                modeloCode: voo.modelo,
                ...tipeAttr
            };

            voosModelo.voos.push(linhaVooModelo);
        };
        
        if(voo.invalido){
            return;
        }

        voo.vooCode = linhaVooModelo.modeloCode + time
        
        if(this.tipoVoo === TipoVoo.Shuttle)
        {
            voo.precoUnitarioComServico = voo.precoFinal / voo.quantidade;
    
            if(voo.servicos){
                voo.precoUnitarioComServico += voo.servicos.filter(a => a.obrigatorio && !a.empacotado)
                                                            .reduce((soma, item) => soma + item.precoFinal, 0);
            }
            
            voo.precoFinalComServico = voo.precoUnitarioComServico * voo.quantidade ?? 1;
        }else {
            voo.precoUnitarioComServico = voo.precoUnitario;
            voo.precoFinalComServico = voo.precoFinal;

            if(voo.servicos){
                voo.precoFinalComServico += voo.servicos.filter(a => a.obrigatorio && !a.empacotado)
                                                        .reduce((soma, item) => soma + item.precoFinal, 0);
            }
        }

        voo.assentosDisponiveis = voo.assentosDisponiveis ?? voo.capacidadePassageiros;
        linhaVooModelo[time] = voo;  
    }

    toLabelWhiteSpace(label)
    {
        let whiteSpaces= '';
        for(let i= 0; i < 21; i++){
            whiteSpaces += '\u00A0';
        }

        return `${whiteSpaces}${label}`;
    }

    addGridColumn(dataVoo){
        const {date, dateFormatted, time, timeFormatted} = this.getVooTime(dataVoo);

        let voosModelo = this.voosModeloPorData.find(a => a.data === date);

        if(!voosModelo){
            voosModelo = {
                data: date,
                dataFormatada: dateFormatted,
                colunas: [...this.colunas],
                voos:[]
            }
            this.voosModeloPorData.push(voosModelo);
        }

        if(!voosModelo.colunas.some(a => a.fieldName === time)){        
            voosModelo.colunas.push({
                label: this.toLabelWhiteSpace(timeFormatted),
                fieldName: time,
                type: "vooCard",
                typeAttributes: {
                  voo: { fieldName: time },
                },
                cellAttributes: { alignment: "center", class:"slds-no-row-hover" }, 
                hideDefaultActions: true,
                fixedWidth: 200
            });
        }
    }

    getVoosCallback(context, data)
    {
        if(data?.length > 0){
            context.colunas = [{...FixedColumn}];
            context.voosModeloPorData = [];
            data.forEach(voo => {

                if(context.tipoVoo === TipoVoo.Shuttle){
                    context.addGridColumn(voo.dataHora);
                    context.addGridLine(voo);
                }else{
                    voo.horarios.forEach(bloco => {
                        context.addGridColumn(bloco.data);
                        context.addGridLine({ ...voo, ...bloco, dataHora: bloco.data });
                    });
                }
            });

            //PREENCHE INDISPONIBILIDADE
            
            let defaultFlightIndex;
            context.voosModeloPorData.forEach(voosModelo => {
                let index = 1;
                voosModelo.colunas.forEach(coluna => {
                    voosModelo.voos.forEach(vooLine => {
                        if(!vooLine[coluna.fieldName]){
                            vooLine[coluna.fieldName] = {disponivel: false};
                        }else{
                            vooLine[coluna.fieldName].disponivel = true;
                        }

                        if(context.diaVoo === vooLine[coluna.fieldName].dataHora){
                            vooLine[coluna.fieldName].default = true;
                            defaultFlightIndex = index;
                        }else{
                            vooLine[coluna.fieldName].default = false;
                        }
                    });
                    index++;
                });
            });
            
            context.voosModeloPorData = [...context.voosModeloPorData];

            if(defaultFlightIndex > 0){
                setTimeout(() => {
                    this.scrollToPosition((defaultFlightIndex -1) * 200);
                },200);
            }
        }
        else{
            context.gridEmpty = true;
        }

        context.gridLoaded = true;
    }

    async scrollToPosition(vooCode){
        const child = this.template.querySelector('c-malha-voo-datatable');
        if (child) {
            child.scrollToPosition(vooCode);
        }
    }

    async handleCellEvent(event){
        this.gridLoaded = false;

        if(event.detail.name === 'OnNextItem'){
            this.vooSelecionadoCelula = event.detail.voo;
            this.converteOpportunityLineItems(event.detail.voo).then(result =>{
                this.dispatchEvent(new FlowNavigationNextEvent());
            });
        }
    }

    async converteOpportunityLineItems(voo){
        const selectedFlight = {
            ...voo,
            voo: voo
        };
        
        const linhasOportuniadde = await criarLinhasOportunidade({
            flightTipe: this.tipoVoo,
            selectedFlight: JSON.stringify(selectedFlight)
        });

        this.vooSelecionado = linhasOportuniadde[0];
        this.vooSelecionadoServicos = linhasOportuniadde.slice(1).map(item => {
            const servico = voo.servicos.find(a => a.produto === item.Product2Id);
            item.Empacotado__c = servico.empacotado ?? false;
            item.Obrigatorio__c = servico.obrigatorio ?? false;
            item.Selecionado__c = servico.selecionado ?? false;
            item.Description = servico.servico ?? '';
            item.ServicaoPorPassageiro__c = servico.porPassageiro ?? false;
            return item;
        });
    }

    @api
    validate() {
        
        if(!this.vooSelecionadoCelula){
            return { isValid: false, errorMessage: 'Selecione um voo disponível para prosseguir' };
        }

        if(this.tipoVoo === TipoVoo.Shuttle && this.quantidadeAssentos > this.vooSelecionadoCelula.assentosDisponiveis){
            return { isValid: false, errorMessage: 'Quantidade de assentos indisponível para este voo' };
        }

        return { isValid: false};
    }
}