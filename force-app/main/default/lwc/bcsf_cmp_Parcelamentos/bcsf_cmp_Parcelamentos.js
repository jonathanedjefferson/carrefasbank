import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { EnclosingTabId } from 'lightning/platformWorkspaceApi';
import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import USER_DRT from '@salesforce/schema/User.DRT__c';

import obterContaFinanceira from '@salesforce/apex/AntecipacaoParcelasController.obterContaFinanceira';
import listarParcelamentos from '@salesforce/apex/AntecipacaoParcelasController.listarParcelamentos';

export default class Bcsf_cmp_Parcelamentos extends NavigationMixin(LightningElement) {

    recordId; 

    //filtros
    @track dataInicial = '';
    @track dataFinal = '';
    @track categoria = '';

    @track dadosCliente = {}
    @track dadosUsuario = {}

    @track solicitacaoDeAtencipacaoRealizada = false;

    //dados cliente
    @track nomeContaFinanceira;

    @track exibirTabela = true;
    @track exibirAlertaAntecipacao = false;
    @track exibirErroListarTabela = false;
    @track exibirErroBuscarCompras = false;
    @track exibirErroAoSimular = false;
    @track exibirModalSelecaoParcelas = false;
    @track exibirModalAntecipacao = false;
    @track mensagemAtualizacao = 'Atualizada há poucos segundos';
    @track totalItens = '0 itens';
    @track botaoVoltar = 'Voltar';
    @track botaoSimular = 'Simular';
    @track desativarBotaoVoltar = false;
    @track desativarBotaoSimular = true;
    @track botaoFecharModalSelecao = 'Fechar';
    @track botaoContinuarSelecao = 'Continuar seleção';
    @track desativarBotaoFecharModalSelecao = false;
    @track desativarBotaoContinuarSelecao = true;
    @track desativaBotaoBuscarCompras = false;
    @track spinner = false;
    @track showTableBody = true;
    @track temParcelaPostada = false;
    
    @track selecionarTodasParcelas = false;
    @track selecionarTodosParcelamentos = false;
    @track listaParcelamentos = [];
    @track listaParcelas = [];
    @track parcelamentosSelecionados = new Map();
    @track lancamentoAberto;
    @track idLancamentoAberto;
    @track parcelamentoAberto;

    @track parcelamentosParaSimular = [];

    @track intervalId;

    get categoriasParcelamentos() {
        return [
            { label: 'Todas as parcelas', value: ''},
            { label: 'Compra', value: 'Desconhecido'},
            { label: 'Crédito Pessoal', value: 'CreditoPessoal' },
            { label: 'Parcele Fácil', value: 'ParceleFacil' },
            { label: 'Parcelamento automático', value: 'ParcelamentoAutomatico'}
        ];
    }

    @wire(CurrentPageReference)
    pagRef;

    @wire(EnclosingTabId) tabId;

    @wire(getRecord, { recordId: USER_ID, fields: [USER_DRT] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.dadosUsuario = {
                perfilOperador:  data.fields.DRT__c.value,
                cpfDrtOperador: data.fields.DRT__c.value
            }

        } else if (error) {
            this.logError('currentUserInfo', error);
        }
    }

    async connectedCallback() {
        this.showSpinner(true);
        this.recordId = this.pagRef.state.c__recordId;
        await obterContaFinanceira({ 
            recordId: this.recordId 
        }).then(result => {
            this.dadosCliente = {
                cpfCliente: result.CPF.replace(/\D/g, ''),
                numeroConta: result.NumeroConta,
                unidadeNegocio: result.UnidadeNegocio,
                titularConta: result.Nome,
                email: result.Email,
                contaFinanceiraId: this.recordId,
                contaPessoalId: result.AccountId
            }
            this.nomeContaFinanceira = result.NomeConta;
            
            this.carregarPacelamentos();
        })
        .catch(error => {
            this.logError('obterContaFinanceira', error);
        });
    }

    renderedCallback(){
        const style = document.createElement("style");
        style.innerHTML = `
        .remover-texto-formato .slds-form-element__help {
            display: none;
        }
        `;
        document.head.appendChild(style);
    }

    async carregarPacelamentos(){

        this.showSpinner(true);

        await listarParcelamentos({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpfCliente,
            unidadeNegocio : this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            cpfDrtOperador: this.dadosUsuario.cpfDrtOperador,
            perfilOperador: this.dadosUsuario.perfilOperador, 
            incluirParcelas: true,
            categoria: this.categoria,
            periodoInicial: this.dataInicial,
            periodoFinal: this.dataFinal
        }).then(result => {
            if(result.statusAPI == 'OK'){
                if(result.parcelamentos.length > 0){
                    let qtdItensRetornados = result.parcelamentos.length;
                    this.totalItens = qtdItensRetornados > 1 ? `${qtdItensRetornados} itens` : `${qtdItensRetornados} item`;
                    this.exibirTabela = true;
                    this.showTableBody = true;
                    this.exibirAlertaAntecipacao = true;
                    this.exibirErroBuscarCompras = false;
                    this.exibirErroListarTabela = false;
                    this.desativaBotaoBuscarCompras = false;

                    let parcelamentos = [];

                    parcelamentos = result.parcelamentos.map(parcelamento => {
                        return { 
                            idParcelamento: parcelamento.idParcelamento,
                            codigoAutorizacao: parcelamento.codigoAutorizacao ? parcelamento.codigoAutorizacao : '-',  
                            descricao: parcelamento.descricao, 
                            parcelas: parcelamento.parcelas.map(parcela => {
                                return {
                                    idParcelamento: parcelamento.idParcelamento,
                                    status: this.verificarStatus(parcela),
                                    dataVencimento: this.formatarDataDDMMYYYY(parcela.dataVencimento),
                                    moeda: parcela.valorParcela.moeda,
                                    valor: this.formatarValor(parcela.valorParcela.valor),
                                    numeroParcela: parcela.numeroParcela,
                                    checked: false,
                                    disabled: parcela.isPostada || parcela.inFaturaAberta ? true : false,
                                    isPostada: parcela.isPostada,
                                    inFaturaAberta: parcela.inFaturaAberta
                                }
                            }), 
                            dataTransacaoOriginal: this.formatarDataEhora(parcelamento.dataTransacaoOriginal),
                            valor:  this.formatarValor(parcelamento.valorTotalParcelado.valor),
                            moeda: parcelamento.valorTotalParcelado.moeda,
                            tipoParcelamento: this.setTipo(parcelamento.categoria),
                            checked: false,
                            disabled: false,
                            allSelected: false
                        };
                    });

                    this.listaParcelamentos = [...parcelamentos];
                    this.exibirAlertaAntecipacao = true;

                    this.calcularTempoAtualizacao(Date.now());
                    
                    this.limparParcelasSelecionadas();

                }else if(this.categoria || this.dataInicial || this.dataInicial){
                    this.showToast('Nenhum resultado encontado. Não há registro correspondente ao filtro aplicado!', '', 'info');
                    this.exibirAlertaAntecipacao = true;
                    this.exibirErroBuscarCompras = false;
                    this.exibirErroListarTabela = false;
                    this.parcelamentos = [];
                    this.limparParcelasSelecionadas();
                    this.showTableBody = false;
                }else{
                    this.limparParcelasSelecionadas();
                    this.exibirTabela = false;
                    this.desativaBotaoBuscarCompras = true;
                }
            } else{
                if(this.categoria || this.dataInicial || this.dataInicial){
                    this.exibirErroBuscarCompras = true;
                }else{
                    this.exibirErroListarTabela = true;
                    this.desativaBotaoBuscarCompras = true;
                }

                this.exibirTabela = true;
                this.showTableBody = true;
                this.exibirAlertaAntecipacao = false;
            }

        }).catch(error => {

            this.showSpinner(false);

            this.exibirTabela = true;
            this.exibirAlertaAntecipacao = false;
            this.exibirErroBuscarCompras = true;

            this.logError('carregarPacelamentos', error);
        });

        this.showSpinner(false);
    }

    handleTentarNovamenteParcelamentos(){
        this.showSpinner(true);
        this.carregarPacelamentos();
    }

    handleTentarNovamenteSimulacao(){
        this.exibirModalAntecipacao = true;
    }

    async handleVoltarContaFinanceira() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'ContaFinanceira__c', 
                actionName: 'view'
            }
        });
    }

    handleDataInicial(event){
        this.dataInicial = this.formatarData(event.detail.value);
    }

    handleDataFinal(event){
        this.dataFinal = this.formatarData(event.detail.value);
    }

    handleTipoParcela(event){
        this.categoria = event.detail.value;
    }

    handleBuscarCompras(){
        this.showSpinner(true);
        this.carregarPacelamentos();
    }

    handleLimparFiltros(){
        this.dataInicial = '';
        this.dataFinal = '';
        this.categoria = '';
    }

    limparParcelasSelecionadas(){
        if(this.parcelamentosSelecionados){
            this.parcelamentosSelecionados.clear();
            this.handleProsseguir();
        }
    }

    
    handleAbrirParcelas(event){
        this.exibirModalSelecaoParcelas = true;
        this.parcelamentoAberto = this.listaParcelamentos.find(parcelamento => parcelamento.idParcelamento == event.target.dataset.id);
        this.listaParcelas = this.parcelamentoAberto.parcelas;
        this.idLancamentoAberto = parseInt(this.parcelamentoAberto.idParcelamento, 10);
        this.desativarBotaoContinuarSelecao = this.parcelamentosSelecionados.has(this.idLancamentoAberto) ? false : true;
    }

    handleFecharParcelas(){
        if(this.parcelamentosSelecionados.has(this.idLancamentoAberto)){
            this.parcelamentosSelecionados.delete(this.idLancamentoAberto);
        }

        this.listaParcelamentos = this.listaParcelamentos.map(item => {
            if (item.idParcelamento == this.idLancamentoAberto) {
                const parcelamentoAtualizado = { 
                    ...item, 
                    checked: false, 
                    parcelas: item.parcelas.map(parcela => ({
                        ...parcela, 
                        checked: false
                    })),
                    allChecked: false
                };
                return parcelamentoAtualizado;
            }
            return item;
        });

        this.selecionarTodosParcelamentos = false;

        this.listaParcelas = [];
        this.lancamentoAberto = '';
        this.idLancamentoAberto = '';

        this.fecharModalParcelas();
        this.handleProsseguir();
    }

    handleContinuarSelecao(){
        this.fecharModalParcelas();
    }

    fecharModalParcelas(){
        this.exibirModalSelecaoParcelas = false;
    }

    handleSelecionarParcela(event){
        const idParcelamento = parseInt(event.target.dataset.idparcelamento, 10);
        const numeroParcela = parseInt(event.target.dataset.numeroparcela, 10);
        const checked = event.target.checked;

        let parcelasSelecionadas = [...(this.parcelamentosSelecionados.get(idParcelamento) || [])];
        
        if (checked) {
            parcelasSelecionadas.push(numeroParcela);
        } else {
            parcelasSelecionadas = parcelasSelecionadas.filter(parcela => parcela != numeroParcela);
        }

        if(parcelasSelecionadas.length > 0){
            this.parcelamentosSelecionados.set(idParcelamento, parcelasSelecionadas);
        }else{
            this.parcelamentosSelecionados.delete(idParcelamento);
        }

        this.desativarBotaoContinuarSelecao = this.parcelamentosSelecionados.size === 0;

        this.listaParcelamentos = this.listaParcelamentos.map(item =>
            item.idParcelamento == idParcelamento
                ? this.parcelamentoAberto = {
                    ...item,
                    allChecked: checked ? item.allChecked : checked,
                    checked: parcelasSelecionadas.length > 0,
                    parcelas: this.listaParcelas = item.parcelas.map(parcela =>
                        parcela.numeroParcela == numeroParcela
                            ? { ...parcela, checked: checked }
                            : parcela
                    )
                }
                : item
        );

        this.handleProsseguir();

    }

    selecionarTodasAsParcelas(event){

        const idParcelamento = parseInt(event.target.dataset.idparcelamento, 10);
        const checked = event.target.checked;

        const parcelamento = this.listaParcelamentos.find(p => p.idParcelamento == idParcelamento);

        const parcelasAtualizadas = parcelamento.parcelas.map(parcela => ({
            ...parcela,
            checked: parcela.disabled ? parcela.checked : checked
        }));

        this.listaParcelas = parcelasAtualizadas;
    
        this.listaParcelamentos = this.listaParcelamentos.map(item => 
            item.idParcelamento == idParcelamento
                ?  this.parcelamentoAberto = { ...item, checked, parcelas: parcelasAtualizadas, allChecked: checked }
                : item
        );

        const parcelasSelecionaveis = parcelasAtualizadas
        .filter(parcela => !parcela.disabled)
        .map(parcela => parcela.numeroParcela);

        if(checked){
            if(parcelasSelecionaveis.length > 0){
                this.parcelamentosSelecionados.set(idParcelamento, parcelasSelecionaveis);
                this.desativarBotaoContinuarSelecao = false;
            }
        }else{
            this.parcelamentosSelecionados.delete(idParcelamento);
            this.desativarBotaoContinuarSelecao = true;
        }

        this.handleProsseguir();
    }

    handleSelecionarTodosParcelamentos(event){
        const checked = event.target.checked;
        if(checked){
            this.parcelamentosSelecionados.clear();
           
            this.parcelamentosSelecionados = new Map(
                this.listaParcelamentos
                    .map(parcelamento => ({
                        id: parcelamento.idParcelamento,
                        parcelas: parcelamento.parcelas
                            .filter(parcela => !parcela.disabled)
                            .map(parcela => parcela.numeroParcela)
                    }))
                    .filter(({ parcelas }) => parcelas.length > 0)
                    .map(({ id, parcelas }) => [id, parcelas])
            );
        } else{
            this.parcelamentosSelecionados.clear();
        }

        this.listaParcelamentos = this.listaParcelamentos.map(parcelamento => ({
            ...parcelamento,
            checked,
            allChecked: checked,
            parcelas: parcelamento.parcelas.map(parcela =>
                parcela.disabled ? parcela : { ...parcela, checked }
            )
        }));

        this.selecionarTodosParcelamentos = checked;

        this.handleProsseguir();
    }

    handleSimularAntecipacao(){
        this.verificarParcelaPostada();
        this.formatarParcelamentosParaSimular();
        this.exibirModalAntecipacao = true;
    }

    handleFecharAntecipacao(){
        if(this.solicitacaoDeAtencipacaoRealizada){
          this.carregarPacelamentos();
          this.solicitacaoDeAtencipacaoRealizada = false;
        }
        this.exibirModalAntecipacao = false;
    }

    verificarParcelaPostada(){

        let parcelaPostada = false;

        for (const idSelecionado of this.parcelamentosSelecionados.keys()) {

            const parcelamento = this.listaParcelamentos.find(p => p.idParcelamento == idSelecionado);

            for (const parcela of parcelamento.parcelas) {
                if (parcela.isPostada && parcela.inFaturaAberta) {
                    parcelaPostada = true;
                    break;
                }
            }
    
            if (parcelaPostada) {
                break;
            }
        }

        this.temParcelaPostada = parcelaPostada;

    }

    formatarParcelamentosParaSimular(){
        this.parcelamentosParaSimular =  Array.from(this.parcelamentosSelecionados, ([idParcelamento, listaParcelas]) => ({
            idParcelamento,
            parcelas: listaParcelas 
        }))
    }

    setTipo(tipo){
        switch (tipo) {
            case 'Desconhecido':
                return 'Compra';
            case 'ParceleFacil':
                return 'Parcele Fácil';
            case 'CreditoPessoal':
                return 'Crédito Pessoal';
            case 'ParcelamentoAutomatico':
                return 'Parc. Automático';
            default:
                return tipo
        }
    }

    verificarStatus(parcela){
        if(parcela.inFaturaAberta){
            return 'Fatura aberta';
        }else if(parcela.isPostada){
            return 'Lançado';
        } else {
            return 'A vencer';
        }
    }

    handleProsseguir(){
        this.desativarBotaoSimular = this.parcelamentosSelecionados.size > 0 ? false : true;
    }

    formatarData(data){
        data = new Date(data);

        const ano = data.getFullYear();
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const dia = String(data.getDate()).padStart(2, '0');
    
        return `${ano}-${mes}-${dia}`;
    }

    formatarDataEhora(data){
        data = new Date(data);

        const ano = String(data.getFullYear()).slice(-2); 
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const dia = String(data.getDate()).padStart(2, '0');
        const hora = String(data.getHours()).padStart(2, '0');
        const minuto = String(data.getMinutes()).padStart(2, '0');
    
        return `${dia}/${mes}/${ano} ${hora}:${minuto}`;
    }

    formatarDataDDMMYYYY(data){
        data = new Date(data);

        const ano = String(data.getFullYear()); 
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const dia = String(data.getDate()).padStart(2, '0');

        return `${dia}/${mes}/${ano}`;
    }

    formatarValor(valor) {
        return Intl.NumberFormat('pt-BR', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(valor);
    }

    calcularTempoAtualizacao(dataAtualizacao){
        if(dataAtualizacao){

            if(this.intervalId){
                clearInterval(this.intervalId);
            }

            this.mensagemAtualizacao = 'Atualizada há poucos segundos';
            
            this.intervalId = setInterval(() => {
                var segundos = Math.abs(Math.floor((dataAtualizacao - Date.now()) / 1000));
                var minutos = Math.floor(segundos / 60);
                if(minutos >= 1){
                    this.mensagemAtualizacao = minutos > 1 ? `Atualizada há ${minutos} minutos` : `Atualizada há ${minutos} minuto`;
                }
            }, 60000);
        } 
    }

    @api closeparentmodal;
    fecharModalAntecipacao() {
        this.handleFecharAntecipacao();
    }

    @api errosimulacao;
    handleErroSimulacao(){
        this.exibirAlertaAntecipacao = false;
        this.exibirErroAoSimular = true;
    }

    @api sucessosimulacao
    handleSucessoSimulacao(){
        this.exibirAlertaAntecipacao = true;
        this.exibirErroAoSimular = false;
    }

    @api atualizartabela
    handleAtualizarTabela(){
        this.carregarPacelamentos();
    }

    @api solicitacaorealizada
    handleSolicitacaoRealizada(){
      this.solicitacaoDeAtencipacaoRealizada = true;
    }

    showToast(titulo, mensagem, variante) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent())
    }

    showSpinner(show){
        this.spinner = show ? true: false;
    }

    logError(metodo, error) {
        if (error) {
            console.error('componente => ', 'bcsf_cmp_Parcelamentos'); 
            console.error('metodo => ', metodo); 
            console.error('erro => ', error);  
            if(error.body){
                console.error('error.body.exceptionType => ', error.body.exceptionType);
                console.error('error.body.message => ', error.body.message);
                console.error('error.body.stackTrace => ', error.body.stackTrace);
            }else{
                console.error('error.name => ' + error.name );
                console.error('error.message => ' + error.message );
                console.error('error.stack => ' + error.stack );
            }
           
        }
    }
    
}