import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';

import styles from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import getPerfis from '@salesforce/apex/BCSF_cmp_ParceleSimularController.getPerfis'
import getPerfil from '@salesforce/apex/BCSF_cmp_ParceleSimularController.getPerfil'
import criarCaso from '@salesforce/apex/BCSF_cmp_ParceleSimularController.criarCaso'
import alterarPerfil from '@salesforce/apex/BCSF_cmp_ParceleSimularController.alterarPerfil'
import loadAccount from '@salesforce/apex/BCSF_cmp_ParceleSimularController.getContaFinanceira'
import enviarEmail from '@salesforce/apex/BCSF_cmp_ParceleSimularController.enviarEmail'
import pagamentoEntrada from '@salesforce/apex/BCSF_cmp_ParceleSimularController.pagamentoEntrada'
import getModalidades from '@salesforce/apex/BCSF_cmp_ParceleSimularController.modalidadeParcele'
import simularSaldoTotal from '@salesforce/apex/BCSF_cmp_ParceleSimularController.simularSaldoTotal'
import simularSaldoParcial from '@salesforce/apex/BCSF_cmp_ParceleSimularController.simularSaldoParcial'
import simularFaturaFechada from '@salesforce/apex/BCSF_cmp_ParceleSimularController.simularFaturaFechada'
import contratarFaturaFechada from '@salesforce/apex/BCSF_cmp_ParceleSimularController.contratarFaturaFechada'
import contratarSaldoParcial from '@salesforce/apex/BCSF_cmp_ParceleSimularController.contratarSaldoParcial'
import contratarSaldoTotal from '@salesforce/apex/BCSF_cmp_ParceleSimularController.contratarSaldoTotal'

export default class Bcsf_cmp_ParceleSimular extends LightningElement {

    /* var layout */
    @api recordId;
    @track spinner;
    @track currentStep = '2';
    @track pageOne = false;
    @track pageTwo = false;
    @track pageTree = false;
    @track pageFour = false;
    @track pageFive = false;
    @track footerPage = true;
    @track erroPagamento = false;
    @track messageAlerWarning = false;
    @track messageParcelaSelected;
    @track possuiEntrada = false;
    @track possuiEntradaAlert = false;
    @track perfilFuncionario = false;
    @track classValidateData = true;
    @track dataVencidaExpirada = false;
    @track dataVencidaExpiradaAlert = false;
    @track dataVencidaExpiradaLabel = false;
    @track classValidateValor;
    @track labelTitlePagamento;
    @track duasTaxas = false;

    /* var dados cliente e caso  */
    cpf;
    cep;
    numeroConta;
    unidadeNegocio;
    accountId;
    email;
    canalApi = 'cockpit';
    @track origemCaso;
    @track canalCaso;
    @track numProtocolo;
    @track caseId;
    
    
    /* var fields */
    parceleFacilId;
    validateData;
    validateValor;
    valorEntradaParce;
    valorRetornado;
    valorAlterado = false;
    dataAlterada = false;
    @track disableBtnSimular = false;
    @track disabledCheckAllTransaction;
    @track checkAllTranscation;
    @track disableBtnContinuar = true;
    @track disableBtnVoltar = true;
    @track checkPlanoSeguro = false;
    @track checkPulaCiclo = false;
    @track checkEmailAlternativo = false;
    @track disableCheckEmailAlternativo = false;
    @track emailAlternativo;
    @track disableCheckPlanoSeguro = false;
    @track disableCheckPulaCiclo = false;
    @track dataSelecionada;
    @track dataSelecionadaResponse;
    @track dataSelecionadaLabel;
    @track valorInformado;
    @track taxaName;
    @track taxaValue;
    @track perfilELegivelValue;
    @track saldoTotal = '--';
    @track tipoPagamento;
    @track codePagamento;
    @track labelBtnCopiarPagamento;
    @track labelBtnGerarPagamento;
    @track labelBtnAlterarPagamento;
    @track labelBtnContinuar = 'Continuar';
    @track labelBtnVoltar = 'Voltar';
    @track selectedDate = '';
    @track dataMin;
    @track dataMax;
    @track dataJuros;
    @track passouDataJuros = false;
    @track valorMinDivida;
    @track entradaMinValor;
    @track entradaMinLabel;
    @track entradaMaxValor;
    @track entradaMaxLabel;
    @track parcelamentoSelecionado;
    @track jurosEncargos;
    @track simulacaoCustom;

    /* var response apis */
    listTransactionsResponse;
    listFormaPagamentoResponse;
    GetModalidadesReponse;
    listParcelsResponse = [];
    
    /* listas */
    @track listTransctionsSelected = [];
    @track listTransactionsFatura = [];
    @track listTransactions = [];
    @track listParcelas = [];
    @track listParcelasFixed = [];
    @track perfilElegibilidade = [];
    @track resumoObject = [];
    perfisParcelamento = [];

    renderedCallback(){
        Promise.all([
            loadStyle(this, styles)
        ]).catch(error => {
            console.log("Error " + error.body.message);
        });
    }

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
            this.GetModalidades();
        }).catch(error =>{
            console.log('Error LoadAccount: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações! da Conta', 'error', true);
        })
    }

    GetModalidades(){
        this.spinnerOpen();
        this.perfilElegibilidade = [];
        this.listTransactions = [];
        getModalidades({
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                let idCounter = 1; 
                let listRetorno;
                if(result.permissaoFaturaFechada){
                    this.perfilElegibilidade.push({ label: "Parcelamento fatura", value: "fatura" })
                    this.perfilELegivelValue = "fatura";
                }
                if(result.permissaoSaldoParcial){
                    this.perfilElegibilidade.push({ label: "Parcelamento saldo parcial", value: "saldo parcial" })
                    this.perfilELegivelValue = this.perfilELegivelValue ? this.perfilELegivelValue : "saldo parcial";
                }
                if(result.permissaoSaldoTotal){
                    this.perfilElegibilidade.push({ label: "Parcelamento saldo total", value: "saldo total" })
                    this.perfilELegivelValue = this.perfilELegivelValue ? this.perfilELegivelValue : "saldo total";
                }
                this.valorMinDivida = result.valorMinimoDivida.valor;
                this.dataJuros = this.formatDate(result.faturaFechada.dataVencimentoReal);
                this.dataVencidaExpirada = this.stringToDate(this.formatDate( result.faturaFechada.dataVencimentoReal)) >= this.stringToDate(this.formatDate(Date.now())) ? false : true;
                this.listTransactionsResponse = result;
                let fatura = result.faturaFechada;
                this.listTransactions.push({ 
                        id: idCounter, 
                        codigo: '0000000xx', 
                        lancamentos: 'Fatura atual', 
                        parcelaLabel: '-',
                        parcela: 1, 
                        valor: this.formatCurrency(fatura.valorTotal.valor), 
                        valorNumber: this.invertValue(fatura.valorTotal.valor), 
                        moeda: fatura.valorTotal.moeda,
                        tipo: 'faturaFechada',
                        checked: true,
                        disabled: true });

                listRetorno = result.transacoes.map(item => {
                    idCounter++
                    let parcelas = item.numeroParcelasRestantes ? item.numeroParcelasRestantes : 1;
                    let parcelasLabel = item.numeroParcelasRestantes ? item.numeroParcelasRestantes : '-';
                    let check = item.valorTotal.valor > 0 ? true : false;
                    return { 
                        id: idCounter,
                        codigo: item.codigo,  
                        lancamentos: item.nome, 
                        parcelaLabel: parcelasLabel,
                        parcela: parcelas, 
                        valor: this.formatCurrency(item.valorTotal.valor), 
                        valorNumber: this.invertValue(item.valorTotal.valor), 
                        moeda: item.valorTotal.moeda,
                        tipo: 'parcial',
                        checked: check,
                        disabled: check };
                });
                this.listTransactions = [...this.listTransactions, ...listRetorno];

                listRetorno = result.faturaAberta.transacoes.map(item => {
                    idCounter++
                    let parcelas = item.numeroParcelasRestantes ? item.numeroParcelasRestantes : 1;
                    let parcelasLabel = item.numeroParcelasRestantes ? item.numeroParcelasRestantes : '-';
                    let check = item.valorTotal.valor > 0 ? true : false;
                    return { 
                        id: idCounter, 
                        codigo: item.codigo, 
                        lancamentos: item.nome, 
                        parcelaLabel: parcelasLabel,
                        parcela: parcelas, 
                        valor: this.formatCurrency(item.valorTotal.valor), 
                        valorNumber: this.invertValue(item.valorTotal.valor), 
                        moeda: item.valorTotal.moeda,
                        tipo: 'faturaAberta',
                        checked: check,
                        disabled: check };
                });
                this.listTransactions = [...this.listTransactions, ...listRetorno];

                this.listTransctionsSelected = this.listTransactions.filter(item => item.checked);
                this.pageTwo = true;

                if(this.pageOne){
                    this.currentStep = '1';
                    this.pageOne = false;
                    this.pageTwo = true;
                    this.disableBtnContinuar = true;
                    this.disableBtnVoltar = false;
                    this.verificarBtnContinuar();
                }
                if(this.pageFive){
                    this.pageFive = false;
                    this.pageTwo = true;
                    this.currentStep = '2';
                    this.disableBtnContinuar = true;
                    this.disableBtnVoltar = true;
                    this.canalCaso = '';
                    this.origemCaso = '';
                    this.tipoPagamento = '';
                    this.dataSelecionada = '';
                    this.valorInformado = '';
                    this.labelBtnContinuar = 'Continuar';
                    this.labelBtnVoltar = 'Voltar';
                    this.checkPlanoSeguro = false;
                    this.checkPulaCiclo = false;
                    this.valorAlterado = false;
                    this.dataAlterada = false;
                    this.validateData = false;
                    this.validateValor = false;
                    this.erroPagamento = false;
                    this.verificarBtnContinuar();
                }
                this.loadPerfilSelecionado();
                this.GetPerfil();
                this.spinnerClose();
            }else{
                this.messagePerfilErro(result.codigoErro);
            }
        }).catch(error =>{
            this.closePages();
            console.log('Error GetModalidades: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar modalidades!', 'error', true);
        })
    }

    GetPerfil(){
    this.spinnerOpen();
    getPerfil({
        numeroConta: this.numeroConta, 
        cpf: this.cpf, 
        canal: this.canalApi, 
        idEmpresa: this.unidadeNegocio
    }).then(result => {
        if(result.statusAPI == 'OK'){
            this.perfilFuncionario = result.ehFuncionario;
        }else {
            this.messagePerfilErro(result.codigoErro);
            this.restartComponent();
        }
        this.spinnerClose();
    }).catch(error =>{
        console.log('Error GetPerfis: '+ error.message);
        this.showToast('Erro', 'Houve um erro ao buscar perfil!', 'error', true);
    })
    }

    GetPerfis(){
        this.spinnerOpen();
        getPerfis({
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.perfisParcelamento = result.perfisParcelamento.map(perfil => {
                    return { label: perfil, value: perfil };
                });
            }else {
                this.messagePerfilErro(result.codigoErro);
            }
            this.spinnerClose();
        }).catch(error =>{
            console.log('Error GetPerfis: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar perfis!', 'error', true);
        })
    }

    AlterarPerfil(){
        this.spinnerOpen();
        alterarPerfil({
            nomePerfil: this.taxaName,
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.GetModalidades();
            }else {
                this.messagePerfilErro(result.codigoErro);
            }
        }).catch(error =>{
            console.log('Error AlterarPerfil: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao alterar perfil!', 'error', true);
        })
    }

    async SimularSaldo(){
        this.spinnerOpen()
        if(this.perfilELegivelValue == 'fatura'){
            await this.SimularFaturaFechada()
        }else if(this.perfilELegivelValue == 'saldo parcial'){
            await this.SimularSaldoParcial();
        }else if(this.perfilELegivelValue == 'saldo total'){
            await this.SimularSaldoTotal();
        }
        this.dataSelecionada = this.dataSelecionada ? this.dataSelecionada : this.formatDateLong(new Date());
        this.dataSelecionadaLabel = this.formatDate(this.dataSelecionada);
        this.marcarMenorTaxa();
    }

    SimularFaturaFechada(){
        simularFaturaFechada({
            dataEntrada: this.dataSelecionada && this.simulacaoCustom ? this.formatDateLong(this.dataSelecionada) : ' ',
            valorEntrada: this.valorInformado && this.simulacaoCustom ? this.valorInformado.toString() : ' ',
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.loadVarParcelas(result);
                this.loadListParcelas(result);
                this.filtrarListaParcelamento();
                this.spinnerClose();
            }else{
                if (result.codigoErro > 1) {
                    this.messageSimularAndContratarErro(result.codigoErro);
                } else {
                    this.messageSimularErro(result.codigoErro);
                }
            }
        }).catch(error =>{
            console.log('Error SimularFatura: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao simular parcelamento', 'error', true);
        })
    }

    SimularSaldoTotal(){
        simularSaldoTotal({
            dataEntrada: this.dataSelecionada && this.simulacaoCustom  ? this.formatDateLong(this.dataSelecionada) : ' ',
            valorEntrada: this.valorInformado && this.simulacaoCustom  ? this.valorInformado.toString() : ' ',
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.loadVarParcelas(result);
                this.loadListParcelas(result);
                this.filtrarListaParcelamento();
                this.spinnerClose();
            }else{
                if (result.codigoErro > 1) {
                    this.messageSimularAndContratarErro(result.codigoErro);
                } else {
                    this.messageSimularErro(result.codigoErro);
                }
            }
        }).catch(error =>{
            console.log('Error SimularFatura: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao simular parcelamento', 'error', true);
        })
    }

    SimularSaldoParcial(){
        let listTransacoes = this.loadListaSimularParcial();
        simularSaldoParcial({
            transacoes: JSON.stringify(listTransacoes),
            dataEntrada: this.dataSelecionada && this.simulacaoCustom  ? this.formatDateLong(this.dataSelecionada) : ' ',
            valorEntrada: this.valorInformado && this.simulacaoCustom  ? this.valorInformado.toString() : ' ',
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.loadVarParcelas(result);
                this.loadListParcelas(result);
                this.filtrarListaParcelamento();
                this.spinnerClose();
            }else{
                if (result.codigoErro > 1) {
                    this.messageSimularAndContratarErro(result.codigoErro);
                } else {
                    this.messageSimularErro(result.codigoErro);
                }
            }
        }).catch(error =>{
            console.log('Error SimularFatura: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao simular parcelamento', 'error', true);
        })
    }

    ContratarParcelamento(){
        this.spinnerOpen();
        this.dataSelecionada = this.simulacaoCustom ? this.dataSelecionada : this.dataSelecionadaResponse;
        if(this.perfilELegivelValue == 'fatura'){
            this.ContratarFaturaFechada();
        }else if(this.perfilELegivelValue == 'saldo parcial'){
            this.ContratarSaldoParcial();
        }else if(this.perfilELegivelValue == 'saldo total'){
            this.ContratarSaldoTotal();
        }
    }

    ContratarSaldoTotal(){
        let entrada = this.valorInformado ? { "valor": this.valorInformado, "moeda": "R$"} : null;
        contratarSaldoTotal({
            formaPagamento: JSON.stringify(this.parcelamentoSelecionado), 
            valorEntrada: JSON.stringify(entrada), 
            dataPagamento: this.formatDateLong(this.dataSelecionada),
            tipoPagamento: this.possuiEntrada ? this.tipoPagamento : 'null', 
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.parceleFacilId = result.parceleFacilId;
                if(result.boleto || result.pix){
                    this.codePagamento = this.tipoPagamento == '0' ? result.boleto.linhaDigitavel : result.pix.copiaCola;
                }
                this.erroPagamento = !this.codePagamento && this.possuiEntrada ? true : false;
                this.CriarCaso();
            }else{
                if (result.codigoErro != 1) {
                    this.messageSimularAndContratarErro(result.codigoErro);
                } else {
                    this.showToast('', 'Não é possível contratar um Parcele Fácil. Clique no botão Contratar para tentar novamente.', 'error', true);
                    this.spinnerClose();
                }
            }
        }).catch(error =>{
            console.log('Error ContratarSaldoTotal: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao contratar parcelamento', 'error', true);
        })
    }

    ContratarFaturaFechada(){
        let entrada = this.valorInformado ? { "valor": this.valorInformado, "moeda": "R$"} : null;
        contratarFaturaFechada({
            formaPagamento: JSON.stringify(this.parcelamentoSelecionado), 
            valorEntrada: JSON.stringify(entrada), 
            dataPagamento: this.formatDateLong(this.dataSelecionada), 
            tipoPagamento: this.possuiEntrada ? this.tipoPagamento : 'null', 
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.parceleFacilId = result.parceleFacilId;
                if(result.boleto || result.pix){
                    this.codePagamento = this.tipoPagamento == '0' ? result.boleto.linhaDigitavel : result.pix.copiaCola;
                }
                this.erroPagamento = !this.codePagamento && this.possuiEntrada ? true : false;
                this.CriarCaso();
            }else{
                if (result.codigoErro != 1) {
                    this.messageSimularAndContratarErro(result.codigoErro);
                } else {
                    this.showToast('', 'Não é possível contratar um Parcele Fácil. Clique no botão Contratar para tentar novamente.', 'error', true);
                    this.spinnerClose();
                }
            }
        }).catch(error =>{
            console.log('Error ContratarFaturaFechada: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao contratar parcelamento', 'error', true);
        })
    }

    ContratarSaldoParcial(){
        let listTransacoes = this.loadListaSimularParcial();
        let entrada = this.valorInformado ? { "valor": this.valorInformado, "moeda": "R$"} : null;
        contratarSaldoParcial({
            formaPagamento: JSON.stringify(this.parcelamentoSelecionado), 
            transacoes: JSON.stringify(listTransacoes),
            valorEntrada: JSON.stringify(entrada), 
            dataPagamento: this.formatDateLong(this.dataSelecionada), 
            tipoPagamento: this.possuiEntrada ? this.tipoPagamento : 'null', 
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.parceleFacilId = result.parceleFacilId;
                if(result.boleto || result.pix){
                    this.codePagamento = this.tipoPagamento == '0' ? result.boleto.linhaDigitavel : result.pix.copiaCola;
                }
                this.erroPagamento = !this.codePagamento && this.possuiEntrada ? true : false;
                this.CriarCaso();
            }else{
                if (result.codigoErro != 1) {
                    this.messageSimularAndContratarErro(result.codigoErro);
                } else {
                    this.showToast('', 'Não é possível contratar um Parcele Fácil. Clique no botão Contratar para tentar novamente.', 'error', true);
                    this.spinnerClose();
                }
            }
        }).catch(error =>{
            console.log('Error ContratarSaldoParcial: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao contratar parcelamento', 'error', true);
        })
    }

    EnviarEmail(email){
        this.spinnerOpen();
        enviarEmail({
            parceleId: this.parceleFacilId, 
            email: email, 
            tipoPagamento: this.possuiEntrada ? this.tipoPagamento : 'default',
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

    PagamentoEntrada(tipoPagamento){
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
            casoType: 'simular',
            contaFinanceiraId: this.recordId, 
            accountId: this.accountId, 
            unidadeNegocio: this.unidadeNegocio,  
            Origem: this.valueOrigem, 
            Canal: this.valueCanal
        }).then(result=>{
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.pageFour = false;
            this.pageFive = true;
            this.labelBtnContinuar = 'Ver caso';
            this.labelBtnVoltar = 'Voltar para o início';
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    //#region Métodos Handle
    handleChangeTaxa(event) {
        this.taxaName = event.detail.value;
        this.verificarBtnContinuar();
    }

    handleCheckAllTransactions(event) {
        this.checkAllTranscation = event.target.checked;
        this.listTransactions = this.listTransactions.map(item => ({ ...item, checked: this.checkAllTranscation || (item.valorNumber < 0) || item.tipo == 'faturaFechada' }));
        this.listTransctionsSelected = this.listTransactions.filter(item => item.checked);
        this.calcularTotal()
    }

    handleCheckTransaction(event) {
        const itemId = event.target.dataset.id;
        this.listTransactions = this.listTransactions.map(item => {
            if (item.id == parseInt(itemId, 10)) {
                const updatedItem = { ...item, checked: event.target.checked };
                if (event.target.checked) {
                    this.listTransctionsSelected.push(updatedItem);
                } else {
                    this.listTransctionsSelected = this.listTransctionsSelected.filter(selItem => selItem.id != itemId);
                }
                return updatedItem;
            }
            return item;
        });
        this.calcularTotal()
    }

    handlePerfilElegibilidade(event) {
        this.perfilELegivelValue = event.detail.value;
        this.loadPerfilSelecionado();
    }

    handleRadioParcelamento(event){
        let codigoParcelamento = event.target.getAttribute('data-value');
        this.parcelamentoSelecionado = this.listParcelsResponse.find(item => item.codigo == codigoParcelamento);
        let itemParce = this.parcelamentoSelecionado;
        let entradaValor = itemParce.valorEntrada ? this.formatCurrency(itemParce.valorEntrada.valor, false) : this.formatCurrency( 0.0 , false);
        let entradaMoeda = itemParce.valorEntrada ? itemParce.valorEntrada.moeda : 'R$';
        this.messageParcelaSelected = itemParce.alertaLimiteCartao.mensagem;
        this.valorEntradaParce = itemParce.valorEntrada ? itemParce.valorEntrada.valor : '';
        const novosValores = {
            numeroParcelas: itemParce.quantidadeParcelas,
            numeroParcelasLiberacaoLimite: itemParce.numeroParcelasParaLiberacaoLimite ? itemParce.numeroParcelasParaLiberacaoLimite : '0',
            valorParcela: `${itemParce.valorParcela.moeda} ${this.formatCurrency(itemParce.valorParcela.valor, false)}`,
            valorEntrada: `${entradaMoeda} ${entradaValor}`,
            pulaCiclo: itemParce.pulaCicloAtivo ? 'Sim' : 'Não',
            seguro: itemParce.seguroAtivo ? 'Sim' : 'Não',
            dataPromessaPagamento: this.possuiEntrada? this.formatDate(this.dataSelecionada) : '-',
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
        this.verificarBtnContinuar();
    }

    handleDateChange(event) {
        this.dataSelecionada = event.target.value;
        this.disableRadio = true;
        this.disableBtnContinuar = true;
        this.dataAlterada = true; 
        this.dataSelecionadaLabel = this.formatDate(this.dataSelecionada+'T00:00:00');
        this.verificarDatas();
    }
    
    handleValorEntrada(event) {
        this.valorInformado = event.target.value;
        this.disableRadio = true;
        this.disableBtnContinuar = true;
        this.valorAlterado = true
        if((this.valorRetornado == this.valorInformado) && !this.dataAlterada ){
            this.disableRadio = false;
            this.disableBtnContinuar = false;
            this.valorAlterado = false;
        }
        this.verificarValorEntrada();
    }

    handleBtnSimular(){
        this.simulacaoCustom = true;
        this.SimularSaldo();
    }

    handleBtnContinuar(){
        if(this.pageOne){
            this.AlterarPerfil();
        }else if(this.pageTwo){
            this.currentStep = '3';
            this.pageTwo = false;
            this.pageTree = true;
            this.disableBtnContinuar = true;
            this.disableBtnVoltar = false;
            this.SimularSaldo();
        }else if(this.pageTree){
            this.currentStep = '4';
            this.pageTree = false;
            this.pageFour = true;
            this.disableBtnContinuar = true;
            this.labelBtnContinuar = 'Contratar';
            this.valorInformado = this.valorEntradaParce ? this.valorEntradaParce : this.valorInformado;
        }else if(this.pageFour){
            this.ContratarParcelamento();
        }else if(this.pageFive){
            window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
        }
        this.verificarBtnContinuar();
    }

    handleBtnVoltar(){
        if(this.pageTwo){
            this.currentStep = '1';
            this.pageTwo = false;
            this.pageOne = true;
            this.disableBtnContinuar = false;
            this.disableBtnVoltar = false;
        }else if(this.pageTree){
            this.currentStep = '2';
            this.listParcelas = [];
            this.pageTree = false;
            this.pageTwo = true;
            this.disableBtnContinuar = true;
            this.disableBtnVoltar = true;
            this.valorInformado = '';
            this.dataSelecionada = '';
            this.checkPlanoSeguro = false;
            this.checkPulaCiclo = false;
            this.valorAlterado = false;
            this.dataAlterada = false;
            this.validateData = false;
            this.validateValor = false;
            this.parcelamentoSelecionado = '';
            this.verificarBtnContinuar();
        }else if(this.pageFour){
            this.currentStep = '3';
            this.pageTwo = false;
            this.pageTree = true;
            this.canalCaso = '';
            this.origemCaso = '';
            this.tipoPagamento = '';
            this.disableBtnContinuar = true;
            this.labelBtnContinuar = 'Continuar';
        }else if(this.pageFive){
            this.perfilELegivelValue = '';
            this.GetModalidades();
        }
    }

    handleBtnSimularOutraTaxa(){
        this.GetPerfis();
        this.currentStep = '1';
        this.pageTree = false;
        this.pageOne = true;
        this.disableBtnContinuar = true;
        this.valorInformado = '';
        this.dataSelecionada = '';
        this.checkPlanoSeguro = false;
        this.checkPulaCiclo = false;
        this.valorAlterado = false;
        this.dataAlterada = false;
        this.validateData = false;
        this.validateValor = false;
        this.parcelamentoSelecionado = '';
    }

    handleCheckPlanoSeguro(event) {
        this.checkPlanoSeguro = event.target.checked;
        this.filtrarListaParcelamento();
    }

    handleCheckPulaCiclo(event) {
        this.checkPulaCiclo = event.target.checked;
        this.filtrarListaParcelamento();
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
    //#endregion 

    loadVarParcelas(result){
        this.disableRadio = false;
        this.dataMin = this.formatDate(Date.now());
        this.dataMax = this.formatDate(result.simulacao.dataMaximaPagamento);
        this.disableCheckPlanoSeguro = !result.simulacao.possuiPlanosComSeguro;
        this.disableCheckPulaCiclo = !result.simulacao.possuiPlanosPulaCiclo;
        this.jurosEncargos = result.simulacao.jurosEncargos ?  result.simulacao.jurosEncargos.moeda + this.formatCurrency(result.simulacao.jurosEncargos.valor, false) : '';
        this.passouDataJuros = this.jurosEncargos && !this.dataVencidaExpirada;
        this.dataVencidaExpiradaAlert = this.jurosEncargos && this.dataVencidaExpirada;
        this.classValidateData = !this.dataVencidaExpirada;
        this.dataVencidaExpiradaLabel = this.dataVencidaExpirada;
        this.dataSelecionada = result.simulacao.dataPagamento;
        this.dataSelecionada = this.dataSelecionada ? result.simulacao.dataPagamento : this.formatDateLong(new Date());
        this.dataSelecionadaLabel = this.formatDate(this.dataSelecionada);
        this.dataSelecionadaResponse = result.simulacao.dataPagamento;
        this.listParcelsResponse = result.simulacao.formasPagamento;
        this.possuiEntrada = result.simulacao.possuiEntrada;
        this.dataSelecionada = this.simulacaoCustom ? this.dataSelecionada : result.simulacao.dataMaximaPagamento;
        if(result.simulacao.possuiEntrada){
            this.valorInformado = result.simulacao.valorEntrada.valor;
            this.valorRetornado = result.simulacao.valorEntrada.valor;
            this.entradaMinValor = result.simulacao.valorMinimoEntrada.valor;
            this.entradaMinLabel = result.simulacao.valorMinimoEntrada.moeda + this.formatCurrency(result.simulacao.valorMinimoEntrada.valor, false);
            this.entradaMaxValor = result.simulacao.valorMaximoEntrada.valor;
            this.entradaMaxLabel = result.simulacao.valorMaximoEntrada.moeda + this.formatCurrency(result.simulacao.valorMaximoEntrada.valor, false);
        }else{
            this.possuiEntradaAlert = this.perfilFuncionario ? false : true;
        }
        if(result.simulacao.possuiSomentePlanosPulaCiclo){
            this.disableCheckPlanoSeguro = true;
            this.disableCheckPulaCiclo = true;
            this.checkPlanoSeguro = false;
            this.checkPulaCiclo = true;
        }
    }

    loadPerfilSelecionado(){
        if (this.perfilELegivelValue == 'saldo total') {
            this.disabledCheckAllTransaction = true;
            this.checkAllTranscation = true;
            this.listTransactions = this.listTransactions.map(item => ({
                ...item,
                checked: true,
                disabled: true
            }));
        } else if (this.perfilELegivelValue.includes('fatura')) {
            this.checkAllTranscation = false;
            this.disabledCheckAllTransaction = true;
            this.listTransactions = this.listTransactions.map(item => ({
                ...item,
                checked: (item.tipo == 'faturaFechada' || item.valorNumber < 0),
                disabled: true
            }));
        } else {
            this.checkAllTranscation = false;
            this.disabledCheckAllTransaction = false;
            this.listTransactions = this.listTransactions.map(item => ({
                ...item,
                checked: (item.tipo == 'faturaFechada' || item.valorNumber < 0),
                disabled: (item.tipo == 'faturaFechada' || item.valorNumber < 0)
            }));
        }

        this.listTransctionsSelected = this.listTransactions.filter(item => item.checked);
        this.calcularTotal();
    }

    loadListParcelas(result){
        let idCounter = 1; 
        this.listParcelasFixed = result.simulacao.formasPagamento.map(item => {
        idCounter++
        let entradaValor =item.valorEntrada ? this.formatCurrency(item.valorEntrada.valor, false) : this.formatCurrency( 0.0 , false);
        let entradaMoeda =item.valorEntrada ? item.valorEntrada.moeda : 'R$';
        return { 
            id: idCounter, 
            quantidadeParcelas: item.quantidadeParcelas, 
            numeroParcelasLiberacaoLimite: item.numeroParcelasParaLiberacaoLimite, 
            valorParcela: this.formatCurrency(item.valorParcela.valor, false), 
            moedaParcela: item.valorParcela.moeda,
            valorEntrada: entradaValor, 
            moedaEntrada: entradaMoeda,
            tipo: item.alertaLimiteCartao.tipo,
            pulaCiclo: item.pulaCicloAtivo,
            planoSeguro: item.seguroAtivo,
            codigo: item.codigo,
            icon: false,
            style: '',
            taxaJuros: item.taxaJuros};
    });
    }

    loadListaSimularParcial(){
        let result = this.listTransactionsResponse;
        let listRetorno;
        let listCode = this.listTransctionsSelected.map(item => item.codigo);
        listRetorno = [...result.transacoes, ...result.faturaAberta.transacoes].filter(item => listCode.includes(item.codigo));
        return listRetorno
    }

    loadPagamento(tipoPag){
        let retorno = {
            "valorEntrada": this.valorInformado ? this.valorInformado : null,
            "dataEntrada": this.dataSelecionada,
            "codigoPlanoPagamento": this.parcelamentoSelecionado.codigo,
            "valorParcela": this.parcelamentoSelecionado.valorParcela.valor,
            "quantidadeParcelas": this.parcelamentoSelecionado.quantidadeParcelas,
            "taxaJuros": this.parcelamentoSelecionado.taxaJuros,
            "tipoPagamento": tipoPag
        }
        return retorno;
    }

    filtrarListaParcelamento(){
        this.listParcelas = this.listParcelasFixed.filter(item => 
            item.planoSeguro == this.checkPlanoSeguro && item.pulaCiclo == this.checkPulaCiclo
        );
        this.marcarMenorTaxa();
    }

    populaValoresResumo(novosValores) {
        this.resumoObject = [
            { name: 'Número de parcelas', value: novosValores.numeroParcelas },
            { name: 'Número de parcelas para liberar limite', value: novosValores.numeroParcelasLiberacaoLimite },
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
    }

    calcularTotal() {
        const total = this.listTransctionsSelected.reduce((acc, row) => {
            return acc + row.valorNumber;
        }, 0);       
        this.saldoTotal =  this.formatCurrency(total, false);
        this.verificarBtnContinuar();
    }

    formatCurrency(value, inverter = true) {
        if(inverter)
            value = this.invertValue(value);
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

    formatDateLong(inputDate) {
        if(!this.validDateFormat(inputDate)){
            let date = new Date(inputDate);
            let day = ('0' + date.getDate()).slice(-2); 
            let month = ('0' + (date.getMonth() + 1)).slice(-2); 
            let year = date.getFullYear();
            let formattedDate = `${year}-${month}-${day}`;
            return formattedDate;
        }
        return inputDate.toString();
    }
    
    formatStringNumber(valor) {
        let cleanValue = valor.replace(/\./g, '');
        cleanValue = cleanValue.replace(',', '.');
        let result = parseFloat(cleanValue);
        return result;
    }

    validDateFormat(dataString) {
        const regex = /^\d{4}-\d{2}-\d{2}$/;
        return regex.test(dataString);
    }
    
    formatPorcentagem(valor) {
        return `${valor.toFixed(2).replace('.', ',')}%`;
    }

    invertValue(value){
        return value = -value;
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
        let listValidation = this.listTransctionsSelected.length == 1 ? true : false;
        if(listValidation){
            listValidation = this.listTransctionsSelected.some(item => item.valorNumber > 0);
        }else{
            listValidation = true;
        }
        
        this.disableBtnContinuar = true;
        if(this.pageOne && this.taxaName){
            this.disableBtnContinuar = false;
        }else if(this.pageTwo && this.perfilELegivelValue && this.listTransctionsSelected.length != 0 && listValidation){
            this.disableBtnContinuar = false;
        }else if( this.pageTree && this.parcelamentoSelecionado ){
            this.disableBtnContinuar = false;
        }else if( this.pageFour && this.origemCaso && this.canalCaso && (this.tipoPagamento || !this.possuiEntrada)){
            this.disableBtnContinuar = false;
        }
        
        if(this.pageTwo && this.perfilELegivelValue == 'saldo parcial'){
            if(this.pageTwo && (this.formatStringNumber(this.saldoTotal) >= parseFloat(this.valorMinDivida)) ){
                this.disableBtnContinuar = false;
            }else{
                this.disableBtnContinuar = true;
            }

            let parcialValidation = this.listTransctionsSelected.some(item => item.valorNumber > 0 && item.tipo != 'faturaFechada');
            this.disableBtnContinuar = parcialValidation && !this.disableBtnContinuar ? false : true;
        }
    }

    spinnerOpen(){
        this.spinner = true;
    }

    spinnerClose(){
        this.spinner = false;
    }

    messageErrorProccess(){
        this.currentStep = '1';
        this.pageOne = false;
        this.pageTwo = true;
        this.pageTree = false;
        this.pageFour = false;
        this.disableBtnContinuar = true;
        this.disableBtnVoltar = false;
        this.dataSelecionada = '';
        this.valorInformado = '';
        this.verificarBtnContinuar();
    }

    stringToDate(dataString) {
        const [dia, mes, ano] = dataString.split('/').map(Number);
        return new Date(ano, mes - 1, dia);
    }

    marcarMenorTaxa() {
        this.duasTaxas = false;
        const menorTaxa = Math.min(...this.listParcelas.map(item => item.taxaJuros));
        const todasIguais = this.listParcelas.every(item => item.taxaJuros === menorTaxa);
        if(!todasIguais){
            this.duasTaxas = true;
            this.listParcelas = this.listParcelas.map(item => {
                if (item.taxaJuros === menorTaxa) {
                    return {
                        ...item,
                        icon: true,
                        style: 'taxaAlternativa'
                    };
                }
                return item;
            });
        }
    }

    verificarBtnSimular(){
        let validarData = this.validateData;
        let validarValor = this.validateValor;
        this.disableBtnSimular  = true;
        if(!validarData && !validarValor){
            this.disableBtnSimular = false;
        }
    }

    verificarDatas() {
        const dataformatada = this.dataSelecionada.toString()+'T00:00:00'
        const dataSelecionadaDate = this.stringToDate(this.formatDate(dataformatada));
        const dataMinDate = this.stringToDate(this.dataMin);
        const dataMaxDate = this.stringToDate(this.dataMax);
        const dataJurosDate = this.stringToDate(this.dataJuros);

        const entreMinMax = dataSelecionadaDate >= dataMinDate && dataSelecionadaDate <= dataMaxDate;
        this.disableBtnSimular = !entreMinMax;

        let isWeekEnd = this.verificarDiaSemana(dataSelecionadaDate);
        if(isWeekEnd){
            this.disableBtnSimular = true
        }

        if (this.dataVencidaExpirada) {
            this.dataVencidaExpiradaLabel = this.disableBtnSimular ? false : true;
        } else {
            this.classValidateData = this.disableBtnSimular ? false : true;
        }
        this.validateData = this.disableBtnSimular;  
        this.verificarBtnSimular();
    }

    verificarDiaSemana(value){
        let day = value.getDay()
        return day === 0 || day === 6;
    }

    verificarValorEntrada(){
        if(this.valorInformado <= this.entradaMaxValor && this.valorInformado >= this.entradaMinValor){
            this.disableBtnSimular = false;
        }else{
            this.disableBtnSimular = true;
        }
        this.classValidateValor = this.disableBtnSimular ? 'errorValidate' : '';
        this.validateValor = this.disableBtnSimular;
        this.verificarBtnSimular();
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
    
    restartComponent(pegarPerfil = true){
        if(pegarPerfil)
            this.GetPerfis();
        this.currentStep = '1';
        this.pageTwo = false;
        this.pageOne = true;
        this.disableBtnContinuar = true;
        this.disableBtnVoltar = false;
        this.dataSelecionada = '';
        this.valorInformado = '';
        this.parcelamentoSelecionado = '';
        this.checkPulaCiclo = false;
        this.checkPlanoSeguro = false;
        this.valorAlterado = false;
        this.dataAlterada = false;
        this.validateData = false;
        this.validateValor = false;
        this.footerPage = true;
    }

    closePages(){
        this.pageOne = false;
        this.pageTwo = false;
        this.pageTree = false;
        this.pageFour = false;
        this.pageFive = false;
        this.footerPage = false;
    }

    //#region switch mensagens de erro
    messageSimularAndContratarErro(codigoErro) {
        switch(codigoErro) {
            case 99:
                this.showToast('', 'Parcele indisponível', 'error', false);
                this.closePages();
                break;
            case 96:
                this.showToast('', 'Selecione a opção Saldo parcial e faça a escolha de quais valores deseja incluir no seu Parcele Fácil.', 'error', false);
                if(this.pageTree)
                    this.handleBtnVoltar();
                break;
            case 35:
                this.showToast('', 'Existe uma contratação de Parcele pendente. Regularize o pagamento ou faça uma nova simulação com um valor diferente.', 'error', false);
                if(this.pageFour)
                    this.handleBtnVoltar();
                break;
            case 31:
                this.showToast('', 'O Parcele Fácil não está disponível', 'error', false);
                this.closePages();
                break;
            case 30:
                this.showToast('', 'Não é possível realizar um refinanciamento do Parcele.', 'error', false);
                if(this.pageTree)
                    this.handleBtnVoltar();
                break;
            case 27:
                this.showToast('', 'Ocorreu um erro em nosso sistema. Não foi possível completar a sua simulação. Por favor, tente novamente mais tarde.', 'error', false);
                this.closePages();
                break;
            case 16:
                this.showToast('', 'A data de fechamento da fatura está próxima, a simulação está indisponível. Aguarde alguns dias e tente novamente.', 'error', false);
                this.closePages();
                break;
            case 15:
                this.showToast('', 'A data de fechamento da fatura está próxima, a simulação está indisponível. Aguarde alguns dias e tente novamente.', 'error', false);
                this.closePages();
                break;
            case 13:
                this.showToast('', 'Você atingiu o limite máximo de parcelamentos.', 'error', false);
                this.closePages();
                break;
            case 12:
                this.showToast('', 'Não é possível realizar o Parcele Fácil, porque existe um pagamento em atraso.', 'error', false);
                this.closePages();
                break;
            case 10:
                this.showToast('', 'Não é possível realizar o Parcele Fácil, porque não existe oferta de parcelamento disponível.', 'error', false);
                this.restartComponent();
                break;
            case 8:
                this.showToast('', 'A data de pagamento da entrada não é válida.', 'error', false);
                if(this.pageFour)
                    this.handleBtnVoltar();
                break;
            case 7:
                this.showToast('', 'O valor da entrada está maior ou menor que o permitido. Por favor, escolha um novo valor e tente novamente.', 'error', false);
                if(this.pageFour)
                    this.handleBtnVoltar();
                break;
            default:
                this.showToast('', 'Ocorreu um erro inesperado. Clique no botão para tentar novamente.', 'error', false);
        }
        this.spinnerClose();
    }

    messageSimularErro(codigoErro) {
        switch(codigoErro) {
            case 1:
                this.showToast('', 'Nenhuma transação informada para simulação de saldo parcial.', 'error', false);
                if(this.pageTree)
                    this.handleBtnVoltar();
                break;
            case 0:
                this.showToast('', 'Não foram encontrados ofertas para essa simulação.', 'error', false);
                if(this.pageTree)
                    this.handleBtnVoltar();
                break;
            default:
                this.showToast('', 'Ocorreu um erro inesperado. Clique no botão para tentar novamente.', 'error', false);
            }
            this.spinnerClose();
        }
        
        messagePerfilErro(codigoErro) {
            switch(codigoErro) {
                case 4:
                    this.showToast('', 'Esta conta atingiu o número máximo de parcelamentos permitido.', 'error', false);
                    this.closePages();
                    break;
                case 3:
                    this.showToast('', 'Identificamos que esta conta possui atraso no pagamento de outro parcelamento', 'error', false);
                    this.closePages();
                    break;
                case 2:
                    this.showToast('', 'Identificamos que o perfil da conta não possui permissão para realizar o parcelamento selecionado.', 'error', false);
                    this.restartComponent();
                    break;
                case 1:
                    this.showToast('', 'Período de contratação disponível para colaboradores é do dia 1 ao dia 8 de cada mês.', 'error', false);
                    this.closePages();
                    break;
                case 0:
                    this.showToast('', 'O parcele fácil está indisponível no momento.', 'error', false);
                    this.restartComponent();
                    break;
                default:
                    this.showToast('', 'Houve um erro ao alterar taxa de juros. ', 'error', false);
        }
        this.spinnerClose();
    }
    //#endregion
}