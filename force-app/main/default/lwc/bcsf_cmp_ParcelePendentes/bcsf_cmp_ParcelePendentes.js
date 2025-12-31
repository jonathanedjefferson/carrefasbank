import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import criarCaso from '@salesforce/apex/BCSF_cmp_ParceleSimularController.criarCaso'
import loadAccount from '@salesforce/apex/BCSF_cmp_ParceleSimularController.getContaFinanceira'
import enviarEmail from '@salesforce/apex/BCSF_cmp_ParceleSimularController.enviarEmail'
import pagamentoEntrada from '@salesforce/apex/BCSF_cmp_ParceleSimularController.pagamentoEntrada'
import listarParcelePendente from '@salesforce/apex/BCSF_cmp_ParceleSimularController.listarParcelePendente'
import ImgErrorOff from '@salesforce/resourceUrl/ImgErrorOff';

export default class Bcsf_cmp_ParcelePendentes extends LightningElement {

    imgEmpty = ImgErrorOff;
    parcelamentoSelecionado;
    @api recordId;
    @track pageOne = true;
    @track pageTwo = false;
    @track pageTree = false;
    @track pageEmpty = false;
    @track footerView = false;
    @track spinner;
    @track checkEmailAlternativo;
    @track email;
    @track emailAlternativo;
    @track origemCaso;
    @track canalCaso;
    @track canalApi = 'cockpit';
    @track tipoPagamento;
    @track disableBtnContinuar = true;
    @track labelBtnCopiarPagamento;
    @track labelBtnAlterarPagamento;
    @track labelBtnGerarPagamento;
    @track labelBtnContinuar = 'Gerar forma de pagamento';
    @track labelBtnVoltar = 'Voltar';
    @track codePagamento;
    @track erroPagamento;
    @track parceleFacilId;
    @track labelTitlePagamento;
    @track numProtocolo;
    @track dataAtual;
    @track caseId;
    @track mensagemLimiteCartao;
    @track resumoObject = [];
    listParcelas = [];
    listParcelasResponse = [];

    connectedCallback(){
        this.spinnerOpen();
        this.LoadAccount();
    }

    LoadAccount(){
        loadAccount({
            contaFinanceiraId: this.recordId
        }).then(result => {
            this.cpf = result.CPF.replace(/\D/g, '');
            this.numeroConta = result.NumeroConta;
            this.unidadeNegocio = result.UnidadeNegocio;
            this.accountId = result.AccountId;
            this.email = result.Email;
            if(this.email == '--'){
                this.disableCheckEmailAlternativo = true;
                this.checkEmailAlternativo = true;
            }
            this.ListarParcelePendente();
        }).catch(error =>{
            console.log('Error LoadAccount: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações! da Conta', 'error', true);
        })
    }

    ListarParcelePendente(){
        this.spinnerOpen();
        listarParcelePendente({
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK' && result.formasPagamento.length != 0){
                this.listParcelasResponse = result.formasPagamento;
                this.listParcelas = result.formasPagamento.map(item => {
                    let entradaValor =item.valorEntrada ? this.formatCurrency(item.valorEntrada.valor, false) : this.formatCurrency( 0.0 , false);
                    let entradaMoeda =item.valorEntrada ? item.valorEntrada.moeda : 'R$';
                    return { 
                        id: item.codigo, 
                        quantidadeParcelas: item.quantidadeParcelas, 
                        numeroParcelasLiberacaoLimite: item.numeroParcelasParaLiberacaoLimite, 
                        valorParcela: this.formatCurrency(item.valorParcela.valor, false), 
                        moedaParcela: item.valorParcela.moeda,
                        valorEntrada: entradaValor, 
                        moedaEntrada: entradaMoeda,
                        dataEntradaLabel: this.formatDate(item.dataPromessaPagamento),
                        dataEntrada: item.dataPromessaPagamento,
                        dataCriacao: this.formatDate(item.dataCriacao),
                        taxaJuros: item.taxaJuros};
                });
            }else{
                this.pageEmpty = true;
                this.footerView = false;
                this.pageOne = false;
            }
            this.spinnerClose();
        }).catch(error =>{
            console.log('Error GetParcelePendentes: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar parcelamentos pendentes!', 'error', true);
        })
    }


    EnviarEmail(email){
        this.spinnerOpen();
        enviarEmail({
            parceleId: this.parceleFacilId, 
            email: email, 
            tipoPagamento: this.tipoPagamento,
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.showToast('', 'Email Enviado com sucesso!', 'success', true);
            }else{
                this.showToast('Erro', 'Houve um erro ao enviar e-mail!', 'error', true);
            }
        }).catch(error =>{
            console.log('Error EnviarEmail: '+ error.message);
            this.showToast('Erro', 'Houve um erro enviar email!', 'error', true);
        })
    }

    PagamentoEntrada(tipoPagamento, gerarCaso = false) {
        this.spinnerOpen();
        let pagamento = this.loadPagamento(tipoPagamento);
        this.tipoPagamento = tipoPagamento;
        pagamentoEntrada({
            pagamento: JSON.stringify(pagamento), 
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                if(result.boleto || result.pix){
                    this.codePagamento = this.tipoPagamento == '0' ? result.boleto.linhaDigitavel : result.pix.copiaCola;
                }
                this.erroPagamento = !this.codePagamento ? true : false;
                if(gerarCaso){
                    this.CriarCaso();
                }
            }else{
                this.showToast('Erro', 'Houve um erro ao buscar forma de pagamento', 'error', true);
            }
            this.spinnerClose();
        }).catch(error =>{
            console.log('Error pagamentoEntrada: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar forma de pagamento', 'error', true);
        })
    }

    CriarCaso(){
        criarCaso({
            casoType: 'pendente',
            contaFinanceiraId: this.recordId, 
            accountId: this.accountId, 
            unidadeNegocio: this.unidadeNegocio,  
            Origem: this.valueOrigem, 
            Canal: this.valueCanal
        }).then(result=>{
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.dataAtual = this.formatDate(Date.now()); 
            this.pageTwo = false;
            this.pageTree = true;
            this.labelBtnContinuar = "Ver caso";
            this.labelBtnVoltar = "Voltar para o início";
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    handleBtnVerResumo(event){
        this.spinnerOpen();
        let code = event.target.getAttribute('data-value');
        this.parcelamentoSelecionado = this.listParcelasResponse.find(item => item.codigo == code);
        let itemParce = this.parcelamentoSelecionado;
        let entradaValor = itemParce.valorEntrada ? this.formatCurrency(itemParce.valorEntrada.valor, false) : this.formatCurrency( 0.0 , false);
        let entradaMoeda = itemParce.valorEntrada ? itemParce.valorEntrada.moeda : 'R$';
        this.parceleFacilId = itemParce.parceleFacilId;
        this.valorInformado = entradaValor;
        this.mensagemLimiteCartao = itemParce.textoLimiteCartao;
        this.jurosEncargos = itemParce.jurosEncargos ?  itemParce.jurosEncargos.moeda + this.formatCurrency(itemParce.jurosEncargos.valor, false) : '';
        const novosValores = {
            numeroParcelas: itemParce.quantidadeParcelas,
            numeroParcelasLiberacaoLimite: itemParce.numeroParcelasParaLiberacaoLimite ? itemParce.numeroParcelasParaLiberacaoLimite : '0',
            valorParcela: `${itemParce.valorParcela.moeda} ${this.formatCurrency(itemParce.valorParcela.valor, false)}`,
            valorEntrada: `${entradaMoeda} ${entradaValor}`,
            pulaCiclo: itemParce.pulaCicloAtivo ? 'Sim' : 'Não',
            seguro: itemParce.seguroAtivo ? 'Sim' : 'Não',
            dataPromessaPagamento: this.formatDate(itemParce.dataPromessaPagamento),
            dataPrimeiroPagamento: this.formatDate(itemParce.dataPrimeiroPagamento),
            saldoTotal: `${itemParce.valorTotalParcelamento.moeda} ${this.formatCurrency(itemParce.valorTotalParcelamento.valor, false)} (${this.formatPorcentagem(itemParce.porcentagemTotalParcelamento)})`,
            taxaJuros: this.formatPorcentagem(itemParce.taxaJuros),
            cetMaximo: this.formatPorcentagem(itemParce.cet),
            despesasVinculadasParcelamento: `${itemParce.valorTotalDespesas.moeda} ${this.formatCurrency(itemParce.valorTotalDespesas.valor, false)} (${this.formatPorcentagem(itemParce.porcentagemTotalDespesas)})`,
            encargosParcelamento: `${itemParce.valorEncargos.moeda} ${this.formatCurrency(itemParce.valorEncargos.valor, false)} (${this.formatPorcentagem(itemParce.porcentagemEncargos)})`,
            valorSeguro: `${itemParce.valorSeguro.moeda} ${this.formatCurrency(itemParce.valorSeguro.valor, false)}`,
            iofDiario: `${itemParce.iof.moeda} ${this.formatCurrency(itemParce.iof.valor, false)} (${this.formatPorcentagem(itemParce.iofPorcentagem)})`,
            iofAdicional: `${itemParce.iofDiario.moeda} ${this.formatCurrency(itemParce.iofDiario.valor, false)} (${this.formatPorcentagem(itemParce.iofDiarioPorcentagem)})`,
        };
        this.populaValoresResumo(novosValores);
    }

    handleBtnContinuar(){
        if(this.pageTwo){
            this.PagamentoEntrada(this.tipoPagamento, true);
        }else{
            window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
        }
    }

    handleBtnVoltar(){
        if(this.pageTwo){
            this.pageOne = true;
            this.pageTwo = false;
            this.footerView = false;
            this.labelBtnContinuar = "Gerar forma de pagamento";
            this.labelBtnVoltar = "Voltar";
            this.tipoPagamento = "";
            this.canalCaso = "";
            this.origemCaso = "";
        }else{
            this.pageOne = true;
            this.pageTree = false;
            this.footerView = false;
            this.erroPagamento = false;
            this.labelBtnContinuar = "Gerar forma de pagamento";
            this.labelBtnVoltar = "Voltar";
            this.tipoPagamento = "";
            this.canalCaso = "";
            this.origemCaso = "";
            this.emailAlternativo = "";
            this.ListarParcelePendente();
        }
    }
    
    handleCheckEmailAlternativo(event) {
        this.checkEmailAlternativo = event.target.checked;
    }

    handleFieldEmailAlternativo(event){
        this.emailAlternativo = event.target.value;
    }

    handleRadioPagamento(event){
        this.tipoPagamento = event.target.getAttribute('data-value');
        if(this.tipoPagamento == '0'){
            this.labelBtnCopiarPagamento = 'Copiar código de barras';
            this.labelBtnAlterarPagamento = 'Alterar para Pix';
            this.labelBtnGerarPagamento = 'Gerar boleto novamente'
            this.labelTitlePagamento = 'boleto';
        }else{
            this.labelBtnCopiarPagamento = 'Copiar código Pix';
            this.labelBtnAlterarPagamento = 'Alterar para Boleto';
            this.labelBtnGerarPagamento = 'Gerar código pix novamente'
            this.labelTitlePagamento = 'código Pix';
        }
        this.verificarBtnContinuar();
    }

    handleFieldCanalCaso(event) {
        this.canalCaso = event.detail.value;
        this.verificarBtnContinuar();
    }

    handleFieldOrigemCaso(event) {
        this.origemCaso = event.detail.value;
        this.verificarBtnContinuar();
    }

    handleBtnEnviarEmail(){
        let email
        if(this.checkEmailAlternativo){
            email = this.emailAlternativo;
        }else{
            email = this.email;
        }

        if((this.checkEmailAlternativo && this.emailAlternativo) || (!this.checkEmailAlternativo && this.email)){
            this.EnviarEmail(email);
        }else{
            this.showToast('Erro', 'Informe um e-mail válido', 'error', true);
        }
    }

    handleBtnAlterarPagamento(){
        if(this.tipoPagamento == '0'){
            this.PagamentoEntrada(1);
            this.labelBtnCopiarPagamento = 'Copiar código Pix';
            this.labelBtnAlterarPagamento = 'Alterar para Boleto';
            this.labelBtnGerarPagamento = 'Gerar código pix novamente'
            this.labelTitlePagamento = 'código Pix';
        }else{
            this.PagamentoEntrada(0);
            this.labelBtnCopiarPagamento = 'Copiar código de barras';
            this.labelBtnAlterarPagamento = 'Alterar para Pix';
            this.labelBtnGerarPagamento = 'Gerar boleto novamente'
            this.labelTitlePagamento = 'boleto';
        }
    }

    handleBtnGerarPagamento(){
        if(this.tipoPagamento == '0'){
            this.PagamentoEntrada(0);
        }else{
            this.PagamentoEntrada(1);
        }
    }

    loadPagamento(tipoPag){
        let retorno = {
            "valorEntrada": this.parcelamentoSelecionado.valorEntrada.valor ? this.parcelamentoSelecionado.valorEntrada.valor : null,
            "dataEntrada": this.parcelamentoSelecionado.dataPromessaPagamento,
            "codigoPlanoPagamento": this.parcelamentoSelecionado.codigo,
            "valorParcela": this.parcelamentoSelecionado.valorParcela.valor,
            "quantidadeParcelas": this.parcelamentoSelecionado.quantidadeParcelas,
            "taxaJuros": this.parcelamentoSelecionado.taxaJuros,
            "tipoPagamento": tipoPag
        }
        return retorno;
    }

    formatCurrency(value, inverter = true) {
        if(inverter)
            value = -value;
        return value.toFixed(2).replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }

    formatDate(date, addDia = false) {
        if (!date) return '';
        const dt = new Date(date);
        const day = addDia ? String(dt.getDate()+1).padStart(2, '0') : String(dt.getDate()).padStart(2, '0');
        const month = String(dt.getMonth() + 1).padStart(2, '0');
        const year = dt.getFullYear();
        return `${day}/${month}/${year}`;
    }

    formatPorcentagem(valor) {
        return `${valor.toFixed(2).replace('.', ',')}%`;
    }

    copyResumoObject() {
        const formattedText = this.resumoObject.map(item => `${item.name}/ ${item.value}`).join('\n');
        const textarea = document.createElement('textarea');
        textarea.value = formattedText;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
        this.showToast('', 'Resumo copiado!', 'success', true);
    }

    copyCodePagamento() {
        const textarea = document.createElement('textarea');
        textarea.value = this.codePagamento;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);

        if(this.tipoPagamento == '0'){
            this.showToast('', 'Código de barras copiado!', 'success', true);
        }else{
            this.showToast('', 'Código Pix copiado!', 'success', true);
        }
    }

    verificarBtnContinuar(){
        this.disableBtnContinuar = true;
        if( this.pageTwo && this.tipoPagamento && this.origemCaso && this.canalCaso ){
            this.disableBtnContinuar = false;
            if(this.checkEmailAlternativo && this.emailAlternativo){
                this.showToast('Atenção', 'O campo E-mail alternativo está vázio!', 'warning', false);
                this.disableBtnContinuar = true;
            }
        }
    }
    
    populaValoresResumo(novosValores) {
        this.resumoObject = [
            { name: 'Número de parcelas', value: novosValores.numeroParcelas },
            { name: 'Valor da parcela', value: novosValores.valorParcela },
            { name: 'Valor da entrada', value: novosValores.valorEntrada },
            { name: 'Pula Ciclo', value: novosValores.pulaCiclo },
            { name: 'Seguro', value: novosValores.seguro },
            { name: 'Data da promessa de pagamento', value: novosValores.dataPromessaPagamento },
            { name: 'Data do primeiro pagamento', value: novosValores.dataPrimeiroPagamento },
            { name: 'Saldo total', value: novosValores.saldoTotal },
            { name: 'Taxa de juros', value: novosValores.taxaJuros},
            { name: 'CET máximo', value: `${novosValores.cetMaximo} AA` },
            { name: 'Despesas vinculadas ao parcelamento', value: novosValores.despesasVinculadasParcelamento},
            { name: 'Encargos de parcelamento', value: novosValores.encargosParcelamento},
            { name: 'Valor do seguro', value: novosValores.valorSeguro },
            { name: 'IOF diário', value: novosValores.iofDiario},
            { name: 'IOF adicional', value: novosValores.iofAdicional}
        ];
        if(this.jurosEncargos)
            this.resumoObject.push({name: 'Juros de atraso da fatura', value: this.jurosEncargos});

        this.pageOne = false;
        this.pageTwo = true;
        this.footerView = true;
        this.verificarBtnContinuar();
        this.spinnerClose();
    }

    showToast(titulo, mensagem, variante, close) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if(close){
            this.spinner = false;
        }
    }

    spinnerOpen(){
        this.spinner = true;
    }

    spinnerClose(){
        this.spinner = false;
    }
    
}