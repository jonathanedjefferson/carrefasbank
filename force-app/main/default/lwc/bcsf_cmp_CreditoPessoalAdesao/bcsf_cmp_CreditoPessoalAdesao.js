import { LightningElement, track, api, wire } from 'lwc';
import { formatarValor, logError, formatarPorcentagem, formatarData } from 'c/utils';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BCSF_CP_MC from '@salesforce/messageChannel/BCSF_CreditoPessoal__c';
import { subscribe, publish, MessageContext } from 'lightning/messageService';

import LogoCarrefourBW from '@salesforce/resourceUrl/LogoCarrefourBW';
import LogoAtacadaoBW from '@salesforce/resourceUrl/LogoAtacadaoBW';
import LogoSamsClubBW from '@salesforce/resourceUrl/LogoSamsClubBW';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import AREA_SECUNDARIA from '@salesforce/schema/User.AreasSecundarias__c';

import getContaFinanceira from '@salesforce/apex/CreditoPessoalController.obterContaFinanceira';
import obterChaveLigaDesliga from '@salesforce/apex/CreditoPessoalController.obterChaveLigaDesliga';
import criarCaso from '@salesforce/apex/CreditoPessoalController.criarCaso';
import getAssetTitular from '@salesforce/apex/CreditoPessoalController.getAssetTitular';
import iniciarProposta from '@salesforce/apex/CreditoPessoalController.iniciarProposta';
import obterBancos from '@salesforce/apex/CreditoPessoalController.obterBancos';
import efetuarSimulacao from '@salesforce/apex/CreditoPessoalController.efetuarSimulacao';
import salvarSimulacao from '@salesforce/apex/CreditoPessoalController.salvarSimulacao';
import salvarDadosBancarios from '@salesforce/apex/CreditoPessoalController.salvarDadosBancarios';
import contratar from '@salesforce/apex/CreditoPessoalController.contratacao';
import getAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';

export default class BCSF_cmp_CreditoPessoalAdesao extends LightningElement {

    @api recordId;
    @api status;

    @wire(MessageContext)
    messageContext;

    subscription;

    opcoesTipoConta = [
        { label: 'Corrente', value: 1, nome: 'Corrente' },
        { label: 'Poupança', value: 2, nome: 'Poupança' }
    ];

    /**************************************************
    ***           ESTADOS DE TELA                   ***
    ***************************************************/
    @track step01;
    @track step02;
    @track step03;
    @track clienteElegivel;
    @track clienteInelegivel;
    @track clienteComBloqueio;
    @track creditoNegado;
    @track isLigadoSimular = false;
    @track spinner;
    @track clienteValidado;
    @track currentStep;
    @track hasErrorSteps = false;
    @track apresentarHeaderFooter = false;
    @track apresentarSimulacao = false;
    @track apresentarDadosBancarios = false;
    @track apresentarResumoContratacao = false;
    @track valorInformado = null;
    @track valorSimulado = null;
    @track disableBtnSimular = true;
    @track possuiOpcaoComSeguro = false;
    @track classValidateValor = '';
    @track showButtonVoltar = true;
    @track checkPlanoComSeguro = false;
    @track checkPlanoSemSeguro = false;
    @track modalReenviarTermo = false;
    @track modalDadosSeguro = false;
    @track showErrorAlert = false;
    @track showErrorSalvar = false;
    @track showErrorContratar = false;
    @track errorTitle;
    @track errorMsg;

    /**************************************************
     ***           DADOS                             ***
     ***************************************************/

    @track dadosCliente = {};
    @track dadosSimulacao = {};
    @track listaParcelamentos = {};
    @track idProposta;
    @track valorSimulacao;
    @track bancos = [];
    @track detalhesProposta = {};
    @track areaPrincipal = '';
    @track subAreaPrincipal = '';
    @track codPlanoSelecionado;
    @track planoSelecionado;
    @track planoSelecionadoBKP;
    @track origemValue;
    @track canalValue;

    //Validação de autenticação
    tempoLimite;
    dataLimite;
    profilesToEvaluate;
    userProfileName;
    atendente;
    statusCartaoPrimario;
    statusConta;

    @track dadosBancarios = {
        codBanco: null,
        nomeBanco: null,
        tipoConta: null,
        agencia: null,
        numeroConta: null,
        digitoConta: null
    };

    @track tipoContaLabel;
    @track confirmaTitularConta;

    /**************************************************
    ***           REATIVOS                          ***
    ***************************************************/

    /** 
     * Verifica se o operador é autorizado e está validado via URA.
     * Área Secundária: Crédito Pessoal 
     * Incluída para operadores que possuem certificação CORBAN.
    */
    get operadorHabilitado() {
        return this.subAreaPrincipal !== null && this.subAreaPrincipal.includes('Crédito Pessoal');
    }

    get showBotaoSimularCreditoPessoal() {
        return this.clienteValidado && this.subAreaPrincipal !== null && this.subAreaPrincipal.includes('Crédito Pessoal');
    }

    connectedCallback() {
    console.log('=== Debug showBotaoSimularCreditoPessoal ===');
    console.log('clienteValidado:', this.clienteValidado);
    console.log('subAreaPrincipal:', this.subAreaPrincipal);
    console.log('subAreaPrincipal type:', typeof this.subAreaPrincipal);
    console.log('Resultado final:', this.showBotaoSimularCreditoPessoal);
    }


    get valorPreAprovado() {
        return formatarValor(this.status.valorPreAprovado);
    }

    get showButtonContratar() {
        return this.apresentarResumoContratacao;
    }

    get showButtonProsseguir() {
        return this.apresentarSimulacao || this.apresentarDadosBancarios;
    }

    get msgLimitesValorParcelas() {
        var mensagemValor = 'O valor deverá estar entre ' + formatarValor(this.status.valorMinimoOferta) + ' e ' + formatarValor(this.status.valorPreAprovado) + '.';
        var mensagemParcelas = ' E as parcelas entre ' + this.dadosSimulacao.quantidadeParcelasMinima + 'x e ' + this.dadosSimulacao.quantidadeParcelasMaxima + 'x.';
        return mensagemValor + mensagemParcelas;
    }

    get msgLimitesValor() {
        return 'Valor mínimo ' + formatarValor(this.status.valorMinimoOferta) + ' | Valor máximo ' + formatarValor(this.status.valorPreAprovado);
    }

    get possuiSeguro() {
        return this.detalhesProposta.valorSeguro > 0 ? 'Contratado' : 'Não contratado';
    }

    //#region INICIALIZAÇÃO
    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL, AREA_SECUNDARIA] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.areaPrincipal = data.fields.AreaPrincipal__c.value;
            this.subAreaPrincipal = data.fields.AreasSecundarias__c.value;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }

    connectedCallback() {
        this.carregarDados();

        this.subscription = subscribe(
            this.messageContext,
            BCSF_CP_MC,
            (message) => this.handleMessage(message)
        );
    }

    async carregarDados() {
        this.showSpinner();
        this.resetComponent();
        await this.obterContaFinanceira();
        await this.getAssetTitular();
        await this.verificarClienteValidado();
        await this.checarStatusCliente();
        this.closeSpinner();
    }

    resetComponent() {
        this.showErrorSalvar = false;
        this.showErrorContratar = false;
        this.erroAPI = false;
        this.disableBtnSimular = false;
        this.apresentarSimulacao = false;
        this.apresentarDadosBancarios = false;
        this.apresentarResumoContratacao = false;
        this.disableButtonVoltar = false;
        this.step01 = true;
        this.step02 = false;
        this.step03 = false;
    }

    async reiniciar() {
        this.resetComponent();
        publish(this.messageContext, BCSF_CP_MC, {
            action: 'reiniciarCreditoPessoal'
        });
    }

    async checarStatusCliente() {
        this.step01 = true;
        this.step02 = false;
        if (this.status.codigo == 0) {
            this.clienteElegivel = true;
            this.clienteInelegivel = false;
            this.clienteComBloqueio = false;
        } else if (this.status.codigo == 1) {
            this.clienteElegivel = false;
            this.clienteInelegivel = true;
            this.clienteComBloqueio = false;
        } else if (this.status.codigo == 2) {
            this.clienteElegivel = false;
            this.clienteInelegivel = false;
            this.clienteComBloqueio = true;
        } else {
            this.clienteElegivel = false;
            this.clienteInelegivel = false;
            this.clienteComBloqueio = false;
        }
    }

    async verificarClienteValidado() {
        await getAllValidationData({
            contaFinanceiraId: this.recordId,
            userId: USER_ID
        }).then(result => {
            this.tempoLimite = result.tempoLimite;
            this.dataLimite = result.dataLimiteDesbloqueio;
            this.profilesToEvaluate = result.perfisBypass;
            this.userProfileName = result.perfilUsuario;
            this.atendente = result.ultimoOperador;
            this.statusConta = result.statusConta;

            let ContaCartaoNORM = this.statusCartaoPrimario === this.StatusConta &&
                this.statusCartaoPrimario === 'NORM';
            if (ContaCartaoNORM) {
                if (!this.profilesToEvaluate.includes(this.userProfileName)) {
                    this.clienteValidado = true;
                    return;
                }
            }
            this.checkSePodeValidarConta();
        }).catch((error) => {
            console.log('ERRO -> ' + JSON.stringify(error));
        });
    }

    checkSePodeValidarConta() {
        if (!this.dataLimite || !this.atendente || !this.tempoLimite) {
            this.clienteValidado = false;
            return;
        }

        this.validarTempoExpirado(this.dataLimite);
    }

    validarTempoExpirado(dataLimiteStr) {
        const dataLimite = new Date(dataLimiteStr);
        const agora = new Date();
        const diferencaMinutos = (dataLimite.getTime() - agora.getTime()) / (1000 * 60);

        if (diferencaMinutos > 0 && diferencaMinutos <= this.tempoLimite && this.atendente === USER_ID) {
            this.clienteValidado = true;
            return;
        }

        this.clienteValidado = false;
    }

    //#region SIMULAR
    handleIniciarSimulacao() {
        this.iniciarProposta();
    }

    selectPlanosComSeguro() {
        this.checkPlanoComSeguro = true;
        this.checkPlanoSemSeguro = false;
        this.listaParcelamentos = this.dadosSimulacao.planosComSeguro;
        if (this.listaParcelamentos != null && this.listaParcelamentos.length > 0) {
            this.codPlanoSelecionado = this.listaParcelamentos[0].codPlano;
            this.planoSelecionado = this.listaParcelamentos[0];
            this.planoSelecionadoBKP = this.listaParcelamentos[0];
        }
    }

    selectPlanosSemSeguro() {
        this.checkPlanoComSeguro = false;
        this.checkPlanoSemSeguro = true;
        this.listaParcelamentos = this.dadosSimulacao.planosSemSeguro;
        if (this.listaParcelamentos != null && this.listaParcelamentos.length > 0) {
            this.codPlanoSelecionado = this.listaParcelamentos[0].codPlano;
            this.planoSelecionado = this.listaParcelamentos[0];
            this.planoSelecionadoBKP = this.listaParcelamentos[0];
        }
    }

    handleValorSimulacao(event) {
        this.valorInformado = event.target.value;
        if (this.valorSimulado == this.valorInformado) {
            this.disableBtnSimular = true;
        } else {
            this.verificarValorCreditoPessoal();
        }
    }

    verificarValorCreditoPessoal() {
        if (this.valorInformado < this.status.valorMinimoOferta || this.valorInformado > this.status.valorPreAprovado || this.erroAPI) {
            this.disableBtnSimular = true;
        } else {
            this.disableBtnSimular = false;
        }
        this.classValidateValor = this.disableBtnSimular ? 'color-error' : '';
        this.validateValor = this.disableBtnSimular;
        this.valorSimulacao = this.valorInformado;
    }

    handleRadioParcelamento(event) {
        this.codPlanoSelecionado = event.target.getAttribute('data-value');
        for (let i = 0; i < this.listaParcelamentos.length; i++) {
            if (this.listaParcelamentos[i].codPlano == this.codPlanoSelecionado) {
                this.listaParcelamentos[i].isSelected = true;
                this.planoSelecionado = this.listaParcelamentos[i];
                this.planoSelecionadoBKP = this.listaParcelamentos[i];
            } else {
                this.listaParcelamentos[i].isSelected = false;
            }
        }
    }

    //#region DADOS BANCÁRIOS

    getLabelPorValor(listaOpcoes, valor) {
        const opcao = listaOpcoes.find(opcao => opcao.value === valor);
        return opcao ? opcao.nome : null;
    }

    async handleBancoAlterado(event) {
        const codBanco = event.target.value;
        this.dadosBancarios.codBanco = codBanco;
        this.dadosBancarios.nomeBanco = this.getLabelPorValor(this.bancos, codBanco);
    }

    handleTipoContaAlterado(event) {
        const tipoConta = parseInt(event.target.value, 10)
        this.dadosBancarios.tipoConta = tipoConta;
        this.tipoContaLabel = this.getLabelPorValor(this.opcoesTipoConta, tipoConta);
    }

    handleAgenciaAlterado(event) {
        const valor = event.target.value;
        if (valor !== "" && !isNaN(valor)) {
            this.dadosBancarios.agencia = parseInt(valor, 10);
        } else {
            this.dadosBancarios.agencia = valor;
        }
    }

    handleNumeroContaAlterado(event) {
        const valor = event.target.value;
        if (valor !== "" && !isNaN(valor)) {
            this.dadosBancarios.numeroConta = parseInt(valor, 10);
        } else {
            this.dadosBancarios.numeroConta = valor;
        }
    }

    handleDigitoContaAlterado(event) {
        const valor = event.target.value;
        if (valor !== "" && !isNaN(valor)) {
            this.dadosBancarios.digitoConta = parseInt(valor, 10);
        } else {
            this.dadosBancarios.digitoConta = valor;
        }
    }

    handleConfirmaTitular(event) {
        this.confirmaTitularConta = event.target.checked;
    }

    get disableButtonProsseguir() {

        if (this.apresentarSimulacao) {
            return this.codPlanoSelecionado === '' || this.erroAPI;
        } else if (this.apresentarDadosBancarios) {
            const dadosBancarios = this.dadosBancarios;
            const codBancoInvalido = !dadosBancarios.codBanco;

            const tipoContaInvalido = (
                !dadosBancarios.tipoConta &&
                dadosBancarios.tipoConta !== 0
            );

            const agenciaInvalido = (
                !dadosBancarios.agencia ||
                isNaN(dadosBancarios.agencia) ||
                dadosBancarios.agencia > 99999
            );

            const numeroContaInvalido = (
                !dadosBancarios.numeroConta ||
                isNaN(dadosBancarios.numeroConta) ||
                dadosBancarios.numeroConta > 9999999999999
            );

            const digitoContaInvalido = (
                (dadosBancarios.digitoConta != 0 || dadosBancarios.digitoConta === "") &&
                (
                    !dadosBancarios.digitoConta ||
                    isNaN(dadosBancarios.digitoConta) ||
                    String(dadosBancarios.digitoConta).length > 1
                )
            );

            const confirmaTitularContaInvalido = !this.confirmaTitularConta;

            return (
                codBancoInvalido ||
                tipoContaInvalido ||
                agenciaInvalido ||
                numeroContaInvalido ||
                digitoContaInvalido ||
                confirmaTitularContaInvalido
            );
        } else if (this.apresentarResumoContratacao) {
            return this.verifyDisabled() || this.erroAPI;
        }
    }

    //#region CRIAR CASO

    handleChangeOrigem(event) {
        this.origemValue = event.target.value;
        this.canalValue = null;
    }

    handleChangeCanal(event) {
        this.canalValue = event.target.value;
        if (this.canalValue === '') {
            this.canalValue = null;
        }
    }

    verifyDisabled() {
        if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null || this.canalValue == undefined) {
            return true;
        } else {
            return false;
        }
    }

    async criarProtocolo() {

        const caso = {
            "accountId": this.dadosCliente.contaPessoalId,
            "status": 'Closed',
            "assunto": 'Credito Pessoal',
            "evento": 'Adesão',
            "origem": this.origemValue,
            "contaFinanceiraId": this.dadosCliente.contaFinanceiraId,
            "unidadeNegocio": this.dadosCliente.unidadeNegocio,
            "tipo": 'Execução',
            "canal": this.canalValue,
            "prioridade": 'Medium'
        };

        await criarCaso({
            inputs: caso
        }).then((result) => {
            this.numeroProtocolo = result.CaseNumber;
            this.idCaso = result.Id;
            this.step02 = false;
            this.step03 = true;
            this.closeSpinner();
        }).catch(error => {
            this.showToast('Houve um erro ao Criar Caso', '', 'error', 'sticky');
            this.logError('criarProtocolo', error);
            this.closeSpinner();
        });
    }

    //#region FUNÇÕES GERAIS

    async handleButtonVoltar() {

        this.showErrorAlert = false;
        this.showErrorSalvar = false;
        this.erroAPI = false;

        if (this.apresentarSimulacao) {
            this.apresentarHeaderFooter = false;
            this.apresentarSimulacao = false;
            this.step02 = false;
            this.step01 = true;
        } else if (this.apresentarDadosBancarios) {
            this.apresentarDadosBancarios = false;
            this.apresentarSimulacao = true;
            this.currentStep = '1';
        } else if (this.apresentarResumoContratacao) {
            this.apresentarResumoContratacao = false;
            this.apresentarDadosBancarios = true;
            this.currentStep = '2';
        }
    }

    async handleButtonContratar() {
        this.showSpinner();
        if (this.apresentarSimulacao) {
            await this.salvarDadosSimulacao();
        } else if (this.apresentarDadosBancarios) {
            await this.salvarDadosBancarios();
        } else if (this.apresentarResumoContratacao) {
            await this.contratar();
        }
    }

    saibaMaisSeguro() {
        this.modalDadosSeguro = true;
    }

    handleButtonReenviarTermo() {
        this.modalReenviarTermo = true;
    }

    async handleMessage(message) {
        if (message.action === 'voltarParaInicioAdesao') {
            await this.carregarDados();
        }
    }

    handleButtonIrCaso() {
        window.location.href = '/lightning/r/Case/' + this.idCaso + '/view';
    }

    @api closemodal;
    closeQuickAction() {
        this.modalReenviarTermo = false;
        this.modalDadosSeguro = false;
    }

    @api eventotentarnovamente
    async handleTentarNovamente() {
        this.showSpinner();
        // Cartão com restrição
        if (this.status.codigo == 2) {
            var urlConta = '/lightning/r/Account/' + this.recordId + '/view';
            if (this.clienteValidado) {
                urlConta = urlConta + '?c__contafinanceira=' + this.recordId + '&c__validado=true';
            }

            window.location.href = urlConta;
        }
        this.closeSpinner();
    }

    @api reloadparent;
    async handleRecarregarComponente() {
        this.showSpinner();
        await this.verificarClienteValidado();
        await this.obterDetalhesProposta();
        this.closeSpinner();
    }

    showSpinner() {
        this.spinner = true;
    }

    closeSpinner() {
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante, mode = 'dismissable') {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    formatarDetalhesProposta() {
        this.detalhesProposta = {
            codPlano: this.planoSelecionado.codPlano,
            valorSolicitado: formatarValor(this.planoSelecionado.valorSolicitado),
            percentualValorSolicitado: this.planoSelecionado.percentualValorSolicitado,
            valorTotal: formatarValor(this.planoSelecionado.valorTotal),
            percentualValorTotal: this.planoSelecionado.percentualValorTotal,
            valorParcela: formatarValor(this.planoSelecionado.valorParcela),
            valorSeguro: this.planoSelecionado.valorSeguro,
            valorSeguroFormatado: formatarValor(this.planoSelecionado.valorSeguro),
            percentualValorSeguro: this.planoSelecionado.percentualValorSeguro,
            valorIOFTotal: formatarValor(this.planoSelecionado.valorIOFTotal),
            percentualValorIOFTotal: this.planoSelecionado.percentualValorIOFTotal,
            valorTotalDespesas: formatarValor(this.planoSelecionado.valorTotalDespesas),
            percentualDespesas: this.planoSelecionado.percentualDespesas,
            encargosParcelamento: formatarValor(this.planoSelecionado.encargosParcelamento),
            quantidadeParcelas: this.planoSelecionado.quantidadeParcelas,
            juros: formatarPorcentagem(this.planoSelecionado.juros),
            percentualJuros: this.planoSelecionado.percentualJuros,
            cetAnual: formatarPorcentagem(this.planoSelecionado.cetAnual),
            dataPrimeiraParcela: formatarData(this.planoSelecionado.dataPrimeiraParcela),
            encargosParcelamentoPercentual: formatarValor(this.planoSelecionado.encargosParcelamentoPercentual),
            valorTotalDespesasPercentual: formatarValor(this.planoSelecionado.valorTotalDespesasPercentual),
            iofDiario: formatarValor(this.planoSelecionado.iofDiario),
            percentualIofDiario: this.planoSelecionado.percentualIofDiario,
            iofAdicional: formatarValor(this.planoSelecionado.iofAdicional),
            percentualIofAdicional: this.planoSelecionado.percentualIofAdicional,
            valorTotalJuros: formatarValor(this.planoSelecionado.valorTotalJuros),
            percentualJurosDespesa: this.planoSelecionado.percentualJurosDespesa,
            valorSeguroMensal: formatarValor(this.planoSelecionado.valorSeguroMensal),
        }
        this.diaVencimentoParcela = this.detalhesProposta?.dataPrimeiraParcela?.substring(0, 2);
    }

    // #region CHAMADAS CONTROLLER

    async obterContaFinanceira() {
        await getContaFinanceira({
            recordId: this.recordId
        })
            .then(result => {
                this.dadosCliente = {
                    cpfFormatado: result.CPF,
                    cpf: result.CPF.replace(/\D/g, ''),
                    numeroConta: result.NumeroConta,
                    unidadeNegocio: result.UnidadeNegocio,
                    titularConta: result.Nome,
                    email: result.Email,
                    contaFinanceiraId: this.recordId,
                    contaPessoalId: result.AccountId,
                    nomeCliente: result.Nome,
                    tipoConta: '',
                    logo: ''
                }

                var msg = 'Orientar a utilizar mais o seu Cartão {nomeCartao}, estar sempre em dia com suas faturas e voltar a entrar em contato em um prazo de 15 a 30 dias.';
                if (this.dadosCliente.unidadeNegocio == "1") {
                    this.logoTipo = LogoCarrefourBW;
                    this.mensagemOrientacao = msg.replace('{nomeCartao}', 'Carrefour');
                } else if (this.dadosCliente.unidadeNegocio == "2") {
                    this.logoTipo = LogoAtacadaoBW;
                    this.mensagemOrientacao = msg.replace('{nomeCartao}', 'Atacadão');
                } else if (this.dadosCliente.unidadeNegocio == "6") {
                    this.logoTipo = LogoSamsClubBW;
                    this.mensagemOrientacao = msg.replace('{nomeCartao}', 'Sam\'s Club');
                }
            })
            .catch(error => {
                this.showToast('Erro ao obter conta financeira', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
                logError('obeterContaFinanceira', error);
            });
    }

    async getAssetTitular() {
        await getAssetTitular({
            idContaFinanceira: this.recordId
        })
            .then(result => {
                this.numeroFinalCartao = result.NumeroCartao?.substring(15);
                this.statusCartaoPrimario = result.Status;
            })
            .catch(error => {
                this.showToast('Erro ao obter conta financeira', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
                logError('obeterContaFinanceira', error);
            });
    }

    async obterChaveLigaDesliga() {
        await obterChaveLigaDesliga({
            prefix: 'btnCreditoPessoal_%'
        }).then(result => {
            if (result != null && result.length > 0) {
                result.forEach(item => {
                    if ('btnCreditoPessoal_Simular' === item.DeveloperName) {
                        this.isLigadoSimular = item.IsLigado;
                    }
                });
            }
        }).catch(error => {
            logError('obterChaveLigaDesliga', error);
        });
    }

    async carregarBancos() {
        await obterBancos({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
        })
            .then(result => {
                if (result.statusAPI === 'OK') {
                    this.bancos = result.bancos.map(item => {
                        return {
                            label: item.codigo.padStart(3, "0") + ' - ' + item.nome,
                            value: item.codigo.padStart(3, "0"),
                            ispb: item.ispb,
                            nome: item.nome
                        }
                    });
                } else {
                    throw new Error('API ERRO: Carregar Bancos');
                }
            })
            .catch(error => {
                this.showToast('', 'Não foi possível carregar as informações de bancos', 'error');
                logError('obterBancos', error);
            });
    }

    async iniciarProposta() {
        this.showSpinner();
        this.valorSimulacao = null;

        await iniciarProposta({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            valorPreAprovado: String(this.status.valorPreAprovado),
            valorSolicitado: String(this.status.valorPreAprovado),
            origem: '6'
        })
            .then(result => {
                if (result.statusAPI === 'OK') {
                    this.currentStep = '1';
                    this.step01 = false;
                    this.step02 = true;
                    this.dadosSimulacao = result;
                    this.idProposta = result.idProposta;
                    this.valorSimulado = this.status.valorPreAprovado;
                    this.apresentarHeaderFooter = true;
                    this.apresentarSimulacao = true;

                    if (this.dadosSimulacao.planosComSeguro != null && this.dadosSimulacao.planosComSeguro.length > 0) {
                        this.possuiOpcaoComSeguro = true;
                        this.selectPlanosComSeguro();
                    } else {
                        this.possuiOpcaoComSeguro = false;
                        this.selectPlanosSemSeguro();
                    }
                } else if (result.statusAPI === 'NAO_ELEGIVEL') {
                    this.step01 = false;
                    this.step02 = true;
                    this.creditoNegado = true;
                } else {
                    // TODO: apresentar erro genérico
                    throw new Error('API ERRO: Iniciar Proposta');
                }
                this.closeSpinner();
            })
            .catch(error => {
                this.showToast('Erro', 'Não foi possível iniciar a simulação.', 'error', 'sticky');
                logError('obterContratos', error);
                this.closeSpinner();
            });
    }

    async handleSimular() {
        this.showSpinner();
        await efetuarSimulacao({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            idProposta: this.idProposta,
            valorSolicitado: this.valorSimulacao
        })
            .then(result => {
                if (result.statusAPI === 'OK') {
                    this.dadosSimulacao = result;
                    this.valorSimulado = this.valorSimulacao;
                    if (this.dadosSimulacao.planosComSeguro != null && this.dadosSimulacao.planosComSeguro.length > 0) {
                        this.possuiOpcaoComSeguro = true;
                        this.selectPlanosComSeguro();
                    } else {
                        this.possuiOpcaoComSeguro = false;
                        this.selectPlanosSemSeguro();
                    }
                } else {
                    // TODO: apresentar erro genérico
                    throw new Error('API ERRO: Iniciar Proposta');
                }
                this.closeSpinner();
            })
            .catch(error => {
                this.showToast('Erro', 'Não foi possível carregar a simulação do Crédito Pessoal.', 'sticky');
                logError('handleSimular', error);
                this.closeSpinner();
            });
    }

    async salvarDadosSimulacao() {
        const possuiSeguro = this.planoSelecionadoBKP.valorSeguro > 0 ? 1 : 0;
        const percentualJuros = this.planoSelecionadoBKP.percentualJuros.replace('%', '').replace(',', '.');

        const planoSimulacao = {
            "codPlano": this.planoSelecionadoBKP.codPlano,
            "iof": this.planoSelecionadoBKP.valorIOFTotal,
            "possuiSeguro": possuiSeguro,
            "cet": this.planoSelecionadoBKP.cetAnual,
            "qtdParcelas": this.planoSelecionadoBKP.quantidadeParcelas,
            "valorParcela": this.planoSelecionadoBKP.valorParcela,
            "juros": this.planoSelecionadoBKP.juros,
            "taxaJuros": parseFloat(percentualJuros),
            "valorSeguro": this.planoSelecionadoBKP.valorSeguro,
            "valorFinanciado": this.planoSelecionadoBKP.valorTotal
        }

        await salvarSimulacao({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            idProposta: this.idProposta,
            valorSolicitado: this.valorSimulado,
            planoSimulacao: JSON.stringify(planoSimulacao)
        })
            .then(result => {
                this.showErrorSalvar = true;
                this.erroAPI = true;
                this.disableBtnSimular = true;
                if (result.statusAPI === 'OK') {
                    this.carregarBancos();
                    this.currentStep = '2';
                    this.apresentarSimulacao = false;
                    this.apresentarDadosBancarios = true;
                    this.showErrorSalvar = false;
                    this.erroAPI = false;
                    this.disableBtnSimular = false;
                }
                this.closeSpinner();
            }).catch(error => {
                this.showErrorSalvar = true;
                this.erroAPI = true;
                this.disableBtnSimular = true;
                logError('salvarDadosSimulação', error);
                this.closeSpinner();
            });
    }

    async salvarDadosBancarios() {

        const dadosBancariosCliente = {
            'codigoBanco': '' + this.dadosBancarios.codBanco,
            'agencia': '' + this.dadosBancarios.agencia,
            'conta': '' + this.dadosBancarios.numeroConta,
            'digitoConta': '' + this.dadosBancarios.digitoConta,
            'tipoConta': this.dadosBancarios.tipoConta
        }

        await salvarDadosBancarios({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            idProposta: this.idProposta,
            dadosBancarios: JSON.stringify(dadosBancariosCliente)
        })
            .then(result => {
                this.showErrorAlert = true;
                this.errorTitle = 'Os dados da conta estão incorretos.';
                this.errorMsg = 'Por favor, revise os dados e tente novamente.';
                if (result.statusAPI === 'OK') {
                    if (result.valido && result.resultado !== null) {
                        this.showErrorAlert = false;
                        this.currentStep = '3';
                        this.apresentarResumoContratacao = true;
                        this.apresentarDadosBancarios = false;
                        this.formatarDetalhesProposta();
                    }
                }
                this.closeSpinner();
            }).catch(error => {
                this.closeSpinner();
                this.showToast('Erro', 'Não foi possível salvar os dados bancários', 'error', 'sticky');
                logError('salvarDadosBancarios', error);
            });
    }

    async contratar() {

        const possuiSeguro = this.planoSelecionadoBKP.valorSeguro > 0 ? 1 : 0;

        const plano = {
            "codPlano": this.planoSelecionadoBKP.codPlano,
            "possuiSeguro": possuiSeguro,
            "valorFinanciado": this.planoSelecionadoBKP.valorSolicitado,
            "valorTotal": this.planoSelecionadoBKP.valorTotal,
            "valorParcela": this.planoSelecionadoBKP.valorParcela,
            "valorSeguro": this.planoSelecionadoBKP.valorSeguro,
            "valorTotalDespesas": this.planoSelecionadoBKP.valorTotalDespesas,
            "encargosParcelamento": this.planoSelecionadoBKP.encargosParcelamento,
            "valorSeguroPercentual": parseFloat(this.planoSelecionadoBKP.percentualValorSeguro.replace('%', '').replace(',', '.')),
            "valorSolicitadoPercentual": parseFloat(this.planoSelecionadoBKP.percentualValorSolicitado.replace('%', '').replace(',', '.')),
            "iofAdicionalPercentual": parseFloat(this.planoSelecionadoBKP.percentualIofAdicional.replace('%', '').replace(',', '.')),
            "iofDiarioPercentual": parseFloat(this.planoSelecionadoBKP.percentualIofDiario.replace('%', '').replace(',', '.')),
            "encargosParcelamentoPercentual": this.planoSelecionadoBKP.encargosParcelamentoPercentual,
            "valorTotalDespesasPercentual": this.planoSelecionadoBKP.valorTotalDespesasPercentual,
            "qtdParcelas": this.planoSelecionadoBKP.quantidadeParcelas,
            "juros": this.planoSelecionadoBKP.juros,
            "taxaJuros": parseFloat(this.planoSelecionadoBKP.percentualJuros.replace('%', '').replace(',', '.')),
            "iof": this.planoSelecionadoBKP.valorIOFTotal,
            "iofAdicional": this.planoSelecionadoBKP.iofAdicional,
            "taxaIOF": parseFloat(this.planoSelecionadoBKP.percentualValorIOFTotal.replace('%', '').replace(',', '.')),
            "cet": this.planoSelecionadoBKP.cetAnual,
            "dataPrimeiraParcela": this.planoSelecionadoBKP.dataPrimeiraParcela
        }

        const dadosBancariosCliente = {
            'codBanco': '' + this.dadosBancarios.codBanco,
            'agencia': this.dadosBancarios.agencia,
            'numeroConta': '' + this.dadosBancarios.numeroConta,
            'digitoConta': '' + this.dadosBancarios.digitoConta,
            'tipoConta': this.dadosBancarios.tipoConta,
            'banco': this.dadosBancarios.nomeBanco,
            'salvarDados': null
        }

        await contratar({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            idProposta: this.idProposta,
            plano: JSON.stringify(plano),
            dadosBancarios: JSON.stringify(dadosBancariosCliente),
            origemAdesao: 6
        })
            .then(result => {
                this.showErrorContratar = true;
                this.erroAPI = true;
                this.disableButtonVoltar = true;

                if (result.statusAPI === 'OK') {
                    if (result.resultado) {
                        this.criarProtocolo();
                        this.showErrorContratar = false;
                        this.erroAPI = false;
                        this.disableButtonVoltar = false;
                    } else {
                        this.closeSpinner();
                    }
                } else {
                    this.closeSpinner();
                }
            })
            .catch(error => {
                this.showErrorContratar = true;
                this.erroAPI = true;
                this.disableButtonVoltar = true;
                logError('contratar', error);
                this.closeSpinner();
            });
    }

}