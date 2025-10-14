import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAeronavesComVoos from '@salesforce/apex/AeronaveTimelineController.getAeronavesComVoos';

export default class AeronaveTimeline extends NavigationMixin(LightningElement) {
    @track aeronaves = [];
    @track horarios = [];
    @track dataReferencia = new Date();
    @track isLoading = false;

    // ✅ Escala fixa
    pxPerHour = 140; // cada hora ocupa 140px (dobro da anterior)
    pxPerMinute = this.pxPerHour / 60; // ≈ 1.1667px por minuto

    connectedCallback() {
        this.gerarHorarios();
        this.carregarVoos();
    }

    get dataFormatada() {
        return this.dataReferencia.toLocaleDateString('pt-BR', {
            weekday: 'long',
            day: '2-digit',
            month: '2-digit'
        });
    }

    get dataReferenciaISO() {
        const ano = this.dataReferencia.getFullYear();
        const mes = (this.dataReferencia.getMonth() + 1).toString().padStart(2, '0');
        const dia = this.dataReferencia.getDate().toString().padStart(2, '0');
        return `${ano}-${mes}-${dia}`;
    }

    get showTimeline() {
        return !this.isLoading && this.aeronaves.length > 0;
    }

    get showNoDataMessage() {
        return !this.isLoading && this.aeronaves.length === 0;
    }

    handleDiaAnterior() {
        this.isLoading = true;
        this.dataReferencia.setDate(this.dataReferencia.getDate() - 1);
        setTimeout(() => {
            this.carregarVoos();
            this.isLoading = false;
        }, 500);
    }

    handleProximoDia() {
        this.isLoading = true;
        this.dataReferencia.setDate(this.dataReferencia.getDate() + 1);
        setTimeout(() => {
            this.carregarVoos();
            this.isLoading = false;
        }, 500);
    }

    handleRefresh() {
        this.isLoading = true;
        // Regera horários (caso existam mudanças de escala futuras) e recarrega voos
        this.gerarHorarios();
        Promise.resolve()
            .then(() => this.carregarVoos())
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleDataChange(event) {
        const value = event.target.value; // formato YYYY-MM-DD
        if (!value) return;
        const [ano, mes, dia] = value.split('-').map(Number);
        this.isLoading = true;
        this.dataReferencia = new Date(ano, mes - 1, dia);
        Promise.resolve()
            .then(() => this.carregarVoos())
            .finally(() => {
                this.isLoading = false;
            });
    }

    async carregarVoos() {
        try {
            // Criar data sem fuso horário para evitar problemas
            const ano = this.dataReferencia.getFullYear();
            const mes = this.dataReferencia.getMonth() + 1;
            const dia = this.dataReferencia.getDate();
            const dataSF = `${ano}-${mes.toString().padStart(2, '0')}-${dia.toString().padStart(2, '0')}`;
            
            console.log('Data de referência:', this.dataReferencia);
            console.log('Data para Salesforce:', dataSF);
            
            const resultado = await getAeronavesComVoos({ dataReferencia: dataSF });
            console.log('Resultado da API:', resultado);

            const paleta = ['#0b3326', '#b6ccc0', '#8f126f', '#084f85', '#b39680', '#ad3143'];

            this.aeronaves = resultado.map((aero, index) => {
                const cor = paleta[index % paleta.length];
                return {
                    ...aero,
                    cor,
                    voos: aero.voos.map(v => {
                        const style = this.calcularVooStyle(v) + ` background-color:${cor}; color:white;`;
                        console.log(`Voo ${v.nome} - Estilo final:`, style);
                        return {
                            ...v,
                            style: style
                        };
                    })
                };
            });
            
            console.log('Aeronaves processadas:', this.aeronaves);
        } catch (erro) {
            console.error('Erro ao carregar voos:', erro);
            this.aeronaves = [];
        }
    }

    gerarHorarios() {
        const inicio = 5;
        const fim = 23;
        this.horarios = [];
        for (let hora = inicio; hora <= fim; hora++) {
            // Apenas horas cheias para rotulagem no cabeçalho; linhas verticais serão via CSS
            this.horarios.push(hora.toString().padStart(2, '0') + ':00');
        }
    }

    calcularVooStyle(voo) {
        console.log('Calculando estilo para voo:', voo);
        
        const gridStartHour = 5;
        const gridEndHour = 23;
        const pxPerHour = this.pxPerHour;
        const pxPerMinute = this.pxPerMinute;

        const start = new Date(voo.inicio);
        const end = voo.fim ? new Date(voo.fim) : new Date(start.getTime() + 30 * 60 * 1000);
        
        console.log('Start:', start, 'End:', end);

        const gridStart = new Date(
            this.dataReferencia.getFullYear(),
            this.dataReferencia.getMonth(),
            this.dataReferencia.getDate(),
            gridStartHour,
            0, 0, 0
        );
        const gridEnd = new Date(
            this.dataReferencia.getFullYear(),
            this.dataReferencia.getMonth(),
            this.dataReferencia.getDate(),
            gridEndHour,
            0, 0, 0
        );

        // diferença em minutos desde o início da grade
        const startMinutes = (start - gridStart) / 60000;
        const endMinutes = (end - gridStart) / 60000;
        const totalGridMinutes = (gridEnd - gridStart) / 60000;

        const clippedStart = Math.max(startMinutes, 0);
        const clippedEnd = Math.min(endMinutes, totalGridMinutes);
        const durationMinutes = Math.max(6, clippedEnd - clippedStart);

        // ✅ sem arredondamento de horário — cálculo exato em pixels
        const leftPx = clippedStart * pxPerMinute;
        const widthPx = durationMinutes * pxPerMinute;

        console.log('Cálculos:', {
            startMinutes,
            endMinutes,
            clippedStart,
            clippedEnd,
            durationMinutes,
            leftPx,
            widthPx
        });

        const result = `left:${leftPx}px; width:${widthPx}px;`;
        console.log('Estilo calculado:', result);
        return result;
    }

    handleAbrirVoo(event) {
        const vooId = event.currentTarget.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: vooId,
                objectApiName: 'Voo__c',
                actionName: 'view'
            }
        }).then(url => {
            if (url) {
                window.open(url, '_blank');
            }
        });
    }
}