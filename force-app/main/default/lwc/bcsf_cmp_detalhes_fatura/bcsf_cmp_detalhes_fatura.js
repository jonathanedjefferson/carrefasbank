import { LightningElement, track, api } from 'lwc';
import calloutDetalhesFatura from '@salesforce/apex/BCSF_CLS_CalloutFaturas.buscarDetalhesFatura';


export default class Bcsf_cmp_detalhes_fatura extends LightningElement {

    @api fatura;
    @api columns;
    @api cliente_infos;
    @api is_fatura_aberta;

    @track section = [];
    @track botao_limpar_bloq = true;
    @track linhas_selecionadas_bu = [];
    @track setSelectedRows = [];
    @track detalhes;
    @track pagamentoEfetuado = {};

    @track reasonCode_selecionaveis = ['nrev', 'pint', 'olmt', 'mntf', 'isop', 'carv', 'care','aior','bior','mora','mult'];

    get sectionLabel(){
        return this.is_fatura_aberta ? 'Fatura Aberta' : this.fatura.dados.mesRef;
    }

    get valorFatura(){
        return this.fatura.dados.valorFatura.valor;
    }

    connectedCallback(){
        if(this.is_fatura_aberta) this.fetchDetalhes();
    }

    handleSectionToggle(event) {
        this.section = event.detail.openSections;
    }

    @api
    limparSelecao(){
        this.setSelectedRows = [];
        this.botao_limpar_bloq = true;

        this.sendEvent_attLinhasResumo([], this.linhas_selecionadas_bu);
        this.linhas_selecionadas_bu = [];
    }

    fetchDetalhes() {

        const [dd, mm, yyyy] = this.fatura.dados.dataVencimento.split("/");
        const data_formatada = `${yyyy}-${mm}-${dd}`;

        calloutDetalhesFatura({ 
            numeroConta: this.cliente_infos.numeroConta, 
            dataVencimento: data_formatada, 
            cpfCliente: this.cliente_infos.cpfCliente, 
            unidadeNegocio: this.cliente_infos.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            let infos = JSON.parse(JSON.stringify(result));

            infos.forEach(inf => {
                inf.selecionavel = this.reasonCode_selecionaveis.includes(inf.reasonCode);
                inf.valor = this.inverteValor(inf.valor);
                inf.dataTransacaoFormatada = this.formatDate(inf.dataTransacao);
                this.setPagamentoEfetuado(inf.pagamentoEfetuado);
            });

            this.detalhes = this.agruparPorDescricaoGrupo(infos).sort(this.orderByDataTransacao_Cresc);
            this.section = [this.sectionLabel];
        })
    }

    orderByDataTransacao_Cresc(a,b){
        if(a.dataTransacao == b.dataTransacao) return 0;
    
        return a.dataTransacao < b.dataTransacao ? -1 : 1;
    }

    setPagamentoEfetuado(pagamento){
        if(!pagamento || this.is_fatura_aberta) return;

        this.pagamentoEfetuado = pagamento;
    }

    inverteValor(valor){
        return valor * (-1);
    }

    formatDate(date){
        if(!date) return null;

        const [yyyy, mm, dd] = date.split('-');

        return `${dd}/${mm}/${yyyy}`;
    }

    agruparPorDescricaoGrupo(collection_lancamentos){
        let grupos = [];

        collection_lancamentos.forEach(lancamento => {
            if(lancamento.descricaoGrupo && !grupos.includes(lancamento.descricaoGrupo)) grupos.push(lancamento.descricaoGrupo);
        });

        if(grupos.length === 0) return collection_lancamentos;

        let lancamentos = [];

        grupos.forEach(grupo => {
            const agrupamento = collection_lancamentos.filter(lancamento => lancamento.descricaoGrupo === grupo);

            const summary = {
                _children: agrupamento,
                descricao: grupo,
                dataTransacao: agrupamento[0].dataTransacao,
                dataTransacaoFormatada: this.formatDate(agrupamento[0].dataTransacao),
                numeroCartao: agrupamento[0].numeroCartao,
                selecionavel: false,
                idTransacao: 'summary_' + grupo,
                valor: agrupamento.reduce((total, lancamento) => total + lancamento.valor, 0)
            };

            lancamentos.push(summary);
        });

        const lancamentoSemGrupo = collection_lancamentos.filter(lancamento => !lancamento.descricaoGrupo);
        
        lancamentoSemGrupo.forEach(lancamento => {
            lancamentos.push(lancamento);
        });

        return lancamentos;
    }

    removeUnselectableRows(rows){
        this.setSelectedRows = [];

        rows.forEach(row => {
            if(row.selecionavel) this.setSelectedRows = [...this.setSelectedRows, row.idTransacao];
        });
    }


    onRowSelection(event){
        this.removeUnselectableRows(event.detail.selectedRows);
        
        const linhasSelecionadas = event.detail.selectedRows.filter(row => row.selecionavel === true);
        
        this.botao_limpar_bloq = linhasSelecionadas.length < 1;

        let linhasRemovidas = [];

        this.linhas_selecionadas_bu.forEach(linhaBU => {
            const findLinha = linhasSelecionadas.find(linha => linha.reasonCode === linhaBU.reasonCode && linha.idTransacao === linhaBU.idTransacao) 
            
            if(!findLinha) linhasRemovidas.push(linhaBU);
        });

        this.linhas_selecionadas_bu = [...linhasSelecionadas];

        this.sendEvent_attLinhasResumo(linhasSelecionadas, linhasRemovidas);
    }

    sendEvent_attLinhasResumo(linhasSelecionadas, linhasRemovidas){
        const event = new CustomEvent('updateResumo', {
            detail: {
                linhasSelecionadas: linhasSelecionadas,
                linhasRemovidas: linhasRemovidas
            },
            bubbles: true
        });

        this.dispatchEvent(event);
    }
}