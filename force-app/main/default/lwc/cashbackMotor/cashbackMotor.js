// force-app/main/default/lwc/cashbackMotor/cashbackMotor.js
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFilterOptions from '@salesforce/apex/CashbackMotorController.getFilterOptions';
import getOffers from '@salesforce/apex/CashbackMotorController.getOffers';

export default class CashbackMotor extends LightningElement {
    @track rms = '';
    @track selectedBu = '';
    @track selectedCanal = '';
    @track dataCompra = '';
    @track data = [];
    @track isLoading = false;
    @track showRmsHint = true;
    @track rmsRequired = false;

    paginaAtual = 1;
    itensPorPagina = '10';
    opcoesItensPorPagina = [
        { label: '10', value: '10' },
        { label: '20', value: '20' },
        { label: '50', value: '50' }
    ];

    buOptions = [];
    canalOptions = [];

    API_FAIL_MSG = 'Não foi possível realizar a solicitação devido a uma falha no carregamento de dados.';

    columns = [
        { label: 'RMS', fieldName: 'rms' },
        { label: 'BU', fieldName: 'bu' },
        { label: 'Canal', fieldName: 'canal' },
        { label: 'Início da campanha', fieldName: 'inicio' },
        { label: 'Fim da campanha', fieldName: 'fim' },
        {
            label: 'Status da campanha',
            fieldName: 'statusLabel',
            type: 'text',
            cellAttributes: {
                iconName: { fieldName: 'statusIcon' },
                iconPosition: 'left',
                class: { fieldName: 'statusClass' }
            }
        },
        { label: 'Data cancelamento', fieldName: 'cancelamento' },
        { label: 'Cashback (%)', fieldName: 'cashbackFmt' },
        { label: 'Acelerador (%)', fieldName: 'aceleradorFmt' }
    ];

    connectedCallback() {
        getFilterOptions()
            .then(res => {
                this.buOptions = res?.businessUnit || [];
                this.canalOptions = res?.channelType || [];
            })
            .catch(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Erro',
                    message: this.API_FAIL_MSG,
                    variant: 'error',
                    mode: 'sticky'
                }));
            });
    }

    get totalRegistros() {
        return this.data ? this.data.length : 0;
    }
    get totalPaginas() {
        const total = this.totalRegistros;
        const size = Number(this.itensPorPagina);
        return Math.max(1, Math.ceil(total / size));
    }
    get registrosPaginados() {
        const start = (this.paginaAtual - 1) * Number(this.itensPorPagina);
        return (this.data || []).slice(start, start + Number(this.itensPorPagina));
    }
    get viewStart() {
        if (!this.totalRegistros) return 0;
        return (this.paginaAtual - 1) * Number(this.itensPorPagina) + 1;
    }
    get viewEnd() {
        return Math.min(this.paginaAtual * Number(this.itensPorPagina), this.totalRegistros);
    }
    get isFirstPage() {
        return this.paginaAtual <= 1;
    }
    get isLastPage() {
        return this.paginaAtual >= this.totalPaginas;
    }

    handleRmsChange = (e) => {
        this.rms = e.target.value || '';
        if (this.rms) {
            this.showRmsHint = true;
            this.rmsRequired = false;
        }
    };
    handleBuChange = (e) => { this.selectedBu = e.detail.value || ''; };
    handleCanalChange = (e) => { this.selectedCanal = e.detail.value || ''; };
    handleDataCompraChange = (e) => { this.dataCompra = e.target.value || ''; };

    handleItensPorPagina = (e) => {
        this.itensPorPagina = e.detail.value;
        this.paginaAtual = 1;
    };

    paginaAnterior = () => {
        if (!this.isFirstPage) this.paginaAtual -= 1;
    };
    paginaProxima = () => {
        if (!this.isLastPage) this.paginaAtual += 1;
    };

    handleLimparClick = () => {
        this.rms = '';
        this.selectedBu = '';
        this.selectedCanal = '';
        this.dataCompra = '';
        this.data = [];
        this.paginaAtual = 1;
        this.showRmsHint = true;
        this.rmsRequired = false;
        this.template.querySelectorAll('lightning-input, lightning-combobox').forEach((cmp) => {
            if (cmp.type === 'date' || cmp.type === 'text' || cmp.type === 'search') cmp.value = '';
            if (cmp.nodeName === 'LIGHTNING-COMBOBOX') cmp.value = '';
        });
    };

    handleBuscarClick = async () => {
        const rmsInput = this.template.querySelector('lightning-input[data-id="rms"]');
        const vazio = !this.rms || this.rms.length === 0;

        if (vazio) {
            this.rmsRequired = true;
            this.showRmsHint = false;
            requestAnimationFrame(() => rmsInput && rmsInput.reportValidity());
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erro',
                message: 'Preencha o campo obrigatório de RMS.',
                variant: 'error',
                mode: 'dismissable'
            }));
            return;
        }

        this.isLoading = true;
        this.data = [];
        this.paginaAtual = 1;

        try {
            const res = await getOffers({
                rms: this.rms,
                bu: this.selectedBu || null,
                canal: this.selectedCanal || null,
                dataCompra: this.dataCompra || null
            });

            this.data = (res || []).map((o) => {
                const hasCashback = o.cashback !== null && o.cashback !== undefined && o.cashback !== '';
                const hasAcelerador = o.acelerador !== null && o.acelerador !== undefined && o.acelerador !== '';
                const status = this.mapStatus(o.status);

                return {
                    id: o.id,
                    rms: o.rms ?? this.rms,
                    bu: o.bu ?? '',
                    canal: this.mapCanal(o.canal),
                    inicio: o.inicio ?? '',
                    fim: o.fim ?? '',
                    statusLabel: status.label,
                    statusIcon: status.icon,
                    statusClass: status.className,
                    cancelamento: o.cancelamento ?? '',
                    cashback: o.cashback,
                    acelerador: o.acelerador,
                    cashbackFmt: hasCashback ? `${o.cashback}%` : '',
                    aceleradorFmt: hasAcelerador ? `${o.acelerador}%` : ''
                };
            });

            if (!this.data.length) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Sem resultados',
                    message: 'Nenhuma oferta encontrada.',
                    variant: 'info'
                }));
            }
        } catch (err) {
            console.error('Erro em getOffers', err);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erro',
                message: this.API_FAIL_MSG,
                variant: 'error',
                mode: 'sticky'
            }));
        } finally {
            this.isLoading = false;
        }
    };

    mapCanal(raw) {
        if (raw === null || raw === undefined) return '';
        const dict = { IN_STORE: 'Físico', ONLINE: 'E-commerce' };
        const arr = Array.isArray(raw) ? raw : String(raw).split(',');
        const mapped = arr.map(s => (dict[s.trim()] || s.trim())).filter(Boolean);
        const uniq = [...new Set(mapped)];
        return uniq.join(', ');
    }

    mapStatus(raw) {
        const s = (raw || '').toString().toUpperCase();
        if (s === 'ACTIVE') {
            return { label: 'Vigente',   icon: 'utility:fallback',  className: 'slds-text-color_weak greenColor' };
        }
        if (s === 'FINISHED') {
            return { label: 'Encerrada',   icon: 'utility:success',  className: 'slds-text-color_weak' };
        }
        if (s === 'CANCEL' || s === 'CANCELED' || s === 'CANCELLED') {
            return { label: 'Cancelada', icon: 'utility:close',    className: 'slds-text-color_weak' };
        }
        return { label: raw || '', icon: 'utility:question', className: '' };
    }
}