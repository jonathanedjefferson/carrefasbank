import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import USER_ID from '@salesforce/user/Id';

import getContaFinanceira from '@salesforce/apex/CreditoPessoalController.obterContaFinanceira';
import consultarContratos from '@salesforce/apex/CreditoPessoalController.consultarContratos';
import consultarProposta from '@salesforce/apex/CreditoPessoalController.consultarProposta';
import obterBancos from '@salesforce/apex/CreditoPessoalController.obterBancos';
import obterChaveLigaDesliga from '@salesforce/apex/CreditoPessoalController.obterChaveLigaDesliga';
import cancelamento from '@salesforce/apex/CreditoPessoalController.cancelamento';
import criarCaso from '@salesforce/apex/CreditoPessoalController.criarCaso';
import getAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';

import { subscribe, MessageContext } from 'lightning/messageService';
import BCSF_CP_MC from '@salesforce/messageChannel/BCSF_CreditoPessoal__c';
import getAssetTitular from '@salesforce/apex/AlteracaoCadastralController.getAssetTitular';

export default class Bcsf_cmp_CreditoPessoalConsulta extends LightningElement {

    @api recordId;

    @wire(MessageContext)
    messageContext;

    subscription;

    /**************************************************
    ***           ESTADOS DE TELA                   ***
    ***************************************************/
    @track step01;
    @track step02;
    @track exibirDetalhesContratacao = false;
    @track modalEnviarTermo;
    @track modalAlterarDadosPagamento;
    @track modalCancelar;
    @track contratosLocalizados;
    @track contratosObtidosComSuceso;
    @track spinner;
    @track podeAlterarDadosBanco;
    @track podeEnviarTermo;
    @track isLigadoEnviarTermo;
    @track isLigadoAlterarDadosBanco;
    @track clienteValidado;
    @track desabilitarBotaoEnviarEmail;
    @track desabilitarBotaoDadosBancarios;
    @track pageOneCancelar;
    @track pageTwoCancelar;
    @track numProtocolo;
    @track caseId;
    @track origemCaso;
    @track canalCaso;
    @track dataAtualFormatada;
    @track descricaoField;
    @track titleModalCancelar;
    @track disabledBtnCancelar;

    //Validação de autenticação
    tempoLimite;
    dataLimite;
    profilesToEvaluate;
    userProfileName;
    atendente;
    statusConta;

    statusMap = {
        16: {
            status: 'Aguardando para processamento',
            descricao: 'Vamos iniciar o processamento do seu empréstimo.',
            classe: 'neutro-label'
        },
        17: {
            status: 'Rejeitado',
            descricao: 'Por favor, envie os dados bancários novamente.',
            classe: 'erro-label'
        },
        18: {
            status: 'Dinheiro na conta!',
            descricao: 'Vamos iniciar o seu parcelamento.',
            classe: 'sucesso-label'
        },
        19: {
            status: 'Dinheiro na conta!',
            descricao: 'Seu crédito pessoal já está disponível para uso.',
            classe: 'sucesso-label'
        },
        20: {
            status: 'Cancelado',
            descricao: 'Contrato cancelado por políticas internas ou por solicitação do cliente.',
            classe: 'erro-label'
        }
    };


    /**************************************************
    ***           DADOS                             ***
    ***************************************************/

    @track dadosCliente = {};
    @track bancos = [];
    @track contratos = [];
    @track listaContratos = [];
    @track idPropostaSelecionada;
    @track detalhesProposta = {};

    /**************************************************
    ***           REATIVOS                          ***
    ***************************************************/

    get exibirRevisarDadosBanco() {
        return this.podeAlterarDadosBanco && this.isLigadoAlterarDadosBanco;
    }

    get exibirEnviarTermo() {
        return this.podeEnviarTermo && this.isLigadoEnviarTermo;
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
        await this.obterContaFinanceira();
        await this.verificarClienteValidado();
        await this.obterContratos();
        await this.obterChaveLigaDesliga();
        this.closeSpinner();
    }

    async obterContaFinanceira() {
        await getContaFinanceira({
            recordId: this.recordId
        })
            .then(result => {
                this.dadosCliente = {
                    cpf: result.CPF.replace(/\D/g, ''),
                    numeroConta: result.NumeroConta,
                    unidadeNegocio: result.UnidadeNegocio,
                    titularConta: result.Nome,
                    email: result.Email,
                    contaFinanceiraId: this.recordId,
                    contaPessoalId: result.AccountId,
                    nomeCliente: result.Nome
                }
            })
            .catch(error => {
                this.showToast('Erro ao obter conta financeira', 'Ocorreu um erro inesperado ao obter dados da conta!', 'error');
                this.logError('obeterContaFinanceira', error);
            });
    }

    async obterContratos() {
        await consultarContratos({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta
        })
            .then(result => {


                this.step02 = false;
                this.step01 = true;

                if (result.statusAPI === 'OK') {

                    this.contratosObtidosComSuceso = true;
                    this.contratosLocalizados = result.itens.length !== 0;

                    if (!this.contratosLocalizados) {
                        return;
                    }

                    this.listaContratos = result.itens.map(item => {
                        return {
                            numeroContrato: item.numeroContrato ? item.numeroContrato : 'abrir',
                            origem: this.setCanal(item.origem),
                            valorSolicitado: this.formatarValor(item.valorSolicitado),
                            dataInclusao: this.formatarData(item.dataInclusao),
                            status: this.setStatus(item.status),
                            id: item.id,
                            statusClass: this.setStatusClass(item.status)
                        }
                    });

                    this.ordenarContratosPorData();

                } else {
                    throw new Error('API ERRO: Consultar Contratos');
                }

            })
            .catch(error => {
                this.step02 = false;
                this.step01 = true;
                this.contratosObtidosComSuceso = false;
                this.showToast(null, 'Não foi possível carregar informacões do Crédito Pessoal', 'error', 'sticky');
                this.logError('obterContratos', error);
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
                            value: item.codigo,
                            ispb: item.ispb,
                            nome: item.nome
                        }
                    });
                } else {
                    throw new Error('API ERRO: Carregar Bancos');
                }
            })
            .catch(error => {
                this.showToast(null, 'Não foi possível carregar as informações de bancos', 'error');
                this.logError('obterContratos', error);
            });
    }

    async obterDetalhesProposta() {
        await consultarProposta({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            idProposta: this.idPropostaSelecionada
        })
            .then(result => {


                if (result.statusAPI === 'OK') {
                    const proposta = result.proposta;

                    this.detalhesProposta = {
                        idProposta: proposta.id,
                        valorFinanciado: this.formatarValor(proposta.valorFinanciado),
                        valorSolicitado: proposta.valorSolicitado,
                        valorSolicitadoFormatado: this.formatarValor(proposta.valorSolicitado),
                        cet: this.formatarPorcentagem(proposta.cet),
                        qtdParcelas: proposta.qtdParcelas,
                        valorParcela: this.formatarValor(proposta.valorParcela),
                        juros: this.formatarPorcentagem(proposta.juros),
                        codBanco: proposta.codBanco,
                        agencia: proposta.agencia,
                        numeroConta: proposta.numeroConta,
                        tipoConta: proposta.tipoConta,
                        labelTipoConta: this.setTipoConta(proposta.tipoConta),
                        nomeCliente: proposta.nomeCliente,
                        cpf: proposta.cpf,
                        cpfFormatado: this.formatarCPF(proposta.cpf),
                        finalCartao: this.obterFinalCartao(proposta.numeroCartao),
                        numeroContrato: proposta.numeroContrato,
                        dataInclusao: this.formatarData(proposta.dataInclusao),
                        realizadoEm: this.formatarDataHora(proposta.dataInclusao),
                        digitoConta: proposta.digitoConta,
                        nomeBanco: this.getLabelPorValor(this.bancos, proposta.codBanco),
                        codPlano: proposta.codPlano,
                        numeroAutorizacao: proposta.numeroAutorizacao,
                        statusClass: this.setStatusClass(proposta.status),
                        statusNome: this.setStatus(proposta.status),
                        statusDescricao: this.setDescricaoStatus(proposta.status),
                        numeroContaTsys: proposta.numeroContaTsys,
                        iof: this.formatarValor(proposta.iof),
                        valorSeguro: this.formatarValor(proposta.valorSeguro),
                        possuiSeguro: this.setSeguro(proposta.possuiSeguro),
                        jurosTotal: this.formatarValor(proposta?.planoProposta.valorTotalJuros)
                    }

                    this.definirAcoesPorStatus(proposta.status);

                    this.step01 = false;
                    this.step02 = true;
                    this.exibirDetalhesContratacao = true;

                } else {
                    throw new Error('Erro de API: CP - Detalhes Proposta')
                }
            })
            .catch(error => {
                this.showToast(null, 'Não foi possível carregar informacões do contrato', 'error');
                this.logError('obterDetalhesProposta', error);
            });
    }

    async obterChaveLigaDesliga() {
        await obterChaveLigaDesliga({
            prefix: 'btnCreditoPessoal_%'
        }).then(result => {
            if (result != null && result.length > 0) {
                result.forEach(item => {
                    if ('btnCreditoPessoal_EnviarTermo' === item.DeveloperName) {
                        this.isLigadoEnviarTermo = item.IsLigado;
                    } else if ('btnCreditoPessoal_AlterarDadosBanco' === item.DeveloperName) {
                        this.isLigadoAlterarDadosBanco = item.IsLigado;
                    }
                });
            }
        }).catch(error => {
            this.logError('obterChaveLigaDesliga', error);
        });
    }

    async verificarClienteValidado() {
        await getAssetTitular()
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
                    console.log('Deve sair, pq não é um perfil que precisa ser avaliado');
                    this.desabilitarBotaoEnviarEmail = false;
                    this.desabilitarBotaoDadosBancarios = false;
                    return;
                }

                this.checkSePodeValidarConta();
            }

        }).catch((error) => {
            console.log('ERRO -> ' + JSON.stringify(error));
        });
    }

    checkSePodeValidarConta() {
        if (!this.dataLimite || !this.atendente || !this.tempoLimite) {
            this.desabilitarBotaoEnviarEmail = true;
            this.desabilitarBotaoDadosBancarios = true;
            return;
        }

        console.log('Campos necessário preenchidos');
        this.validarTempoExpirado(this.dataLimite);
    }

    validarTempoExpirado(dataLimiteStr) {
        const dataLimite = new Date(dataLimiteStr);
        const agora = new Date();
        const diferencaMinutos = (dataLimite.getTime() - agora.getTime()) / (1000 * 60);
        console.log('diferencaMinutos -> ' + diferencaMinutos);
        console.log('this.tempoLimite -> ' + this.tempoLimite);

        if (diferencaMinutos > 0 && diferencaMinutos <= this.tempoLimite && this.atendente === USER_ID) {
            console.log('Autorizado');
            this.desabilitarBotaoEnviarEmail = false;
            this.desabilitarBotaoDadosBancarios = false;
            return;
        }

        console.log('Bloqueado');
        this.desabilitarBotaoEnviarEmail = true;
        this.desabilitarBotaoDadosBancarios = true;
    }
    async getAssetTitular() {
        await getAssetTitular({
            idContaFinanceira: this.recordId
        }).then(result => {
            try {
                this.statusCartaoPrimario = result.Status;
                console.log('statusCartaoPrimario: ' + this.statusCartaoPrimario);
            } catch (error) {
                console.log('Erro catch() getAssetTitular: ' + error);
            }
        }).catch(error => {
            console.log('Erro getAssetTitular: ' + error.body.message);
            console.dir(error);
        });
    }

    async criarProtocolo() {
        const caso = {
            "accountId": this.dadosCliente.contaPessoalId,
            "status": 'Closed',
            "assunto": 'Credito Pessoal',
            "evento": 'Cancelamento de crédito pessoal',
            "origem": this.origemCaso,
            "contaFinanceiraId": this.dadosCliente.contaFinanceiraId,
            "unidadeNegocio": this.dadosCliente.unidadeNegocio,
            "tipo": 'Execução',
            "canal": this.canalCaso,
            "descricao": this.descricaoField,
            "prioridade": 'Medium'
        };

        await criarCaso({
            inputs: caso
        }).then((result) => {
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.pageOneCancelar = false;
            this.pageTwoCancelar = true;
            this.dataAtualFormatada = this.formatarData(new Date()).split(' ')[0];
            this.titleModalCancelar = 'Crédito Pessoal';
            this.closeSpinner();
        }).catch(error => {
            this.showToast('', 'Houve um erro ao Criar Caso', 'error');
            this.logError('criarProtocolo', error);
            this.closeSpinner();
        });
    }

    async cancelar() {
        this.showSpinner();
        cancelamento({
            idProposta: this.idPropostaSelecionada,
            cpf: this.dadosCliente.cpf,
            unidadeNegocio: this.dadosCliente.unidadeNegocio,
            canal: 'Cockpit'
        }).then((result) => {
            if (result.statusAPI === '200') {
                this.criarProtocolo();
            } else if (result.statusAPI === '400' || result.statusAPI === '409') {
                this.showToast(null, result.mensagem, 'warning');
                this.closeSpinner();
            } else {
                this.showToast(null, result.mensagem, 'error');
                this.closeSpinner();
            }
        }).catch((error) => {
            this.showToast('Erro', 'Ocorreu um erro inesperado ao cancelar!', 'error');
            this.logError('cancelamento', error);
            this.closeSpinner();
        });
    }

    ordenarContratosPorData() {
        try {
            this.listaContratos.sort((a, b) => {
                const [diaA, mesA, anoA] = a.dataInclusao.split('/');
                const [diaB, mesB, anoB] = b.dataInclusao.split('/');

                const dateA = new Date(`${anoA}-${mesA}-${diaA}`);
                const dateB = new Date(`${anoB}-${mesB}-${diaB}`);

                return dateB - dateA;
            });
        } catch (error) {
            this.logError('ordenarContratosPorData', error);
        }
    }

    async handleMessage(message) {
        if (message.action === 'voltarParaInicio') {
            this.showSpinner();
            await this.obterContratos();
            this.closeSpinner();
        }
    }

    async handleAbrirContrato(event) {
        this.idPropostaSelecionada = event.target.name;
        this.showSpinner();
        await this.carregarBancos();
        await this.obterDetalhesProposta();
        this.closeSpinner();
    }

    handleEnviarTermo() {
        this.modalEnviarTermo = true;
    }

    handleAlterarDadosBancarios() {
        this.modalAlterarDadosPagamento = true;
    }

    handleTabClick(event) {
        this.handleTableSected(event);
    }

    handleFieldCaseCancelar(event) {
        const name = event.target.name;
        this[name] = event.target.value;
        this.disabledBtnCancelar = !this.origemCaso || !this.canalCaso;
    }

    handleBtnCancelar() {
        if (!this.modalCancelar) {
            this.modalCancelar = true;
            this.disabledBtnCancelar = true;
            this.pageOneCancelar = true;
            this.titleModalCancelar = 'Cancelar Empréstimo Pessoal';
        } else if (this.pageOneCancelar) {
            this.cancelar();
        } else {
            window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
        }
    }

    handleTableSected(event) {

        const selectedTab = event.target.dataset.tab;
        const allTabs = this.template.querySelectorAll('.slds-tabs_default__item');
        allTabs.forEach(tab => tab.classList.remove('slds-is-active'));
        event.target.parentElement.classList.add('slds-is-active');

        const allContents = this.template.querySelectorAll('[data-content]');
        allContents.forEach(content => {
            if (content.dataset.content === selectedTab) {
                content.classList.remove('slds-hide');
                content.classList.add('slds-show');
            } else {
                content.classList.remove('slds-show');
                content.classList.add('slds-hide');
            }
        });
    }

    mostrarTooltip(event) {
        const id = event.currentTarget.dataset.id;

        if (id) {
            this.listaContratos = this.listaContratos.map(item => {
                return {
                    ...item,
                    showTooltip: item.id == id
                };
            });
        }
    }

    ocultarTooltip() {
        this.listaContratos = this.listaContratos.map(item => {
            return {
                ...item,
                showTooltip: false
            };
        });
    }


    setSeguro(possuiSeguro) {
        switch (Number(possuiSeguro)) {
            case 0:
                return 'Não contratado';
            case 1:
                return 'Contratado';
            default:
                return '--';
        }
    }

    setCanal(canal) {
        switch (Number(canal)) {
            case 0:
                return 'Central de Atendimento';
            case 1:
                return 'Loja';
            case 2:
                return 'TAS';
            case 3:
                return 'Portal de Cartões';
            case 4:
                return 'Aplicativo';
            case 6:
                return 'Cockpit';
            default:
                return canal;
        }
    }

    definirAcoesPorStatus(status) {
        const configuracoes = {
            16: {
                podeAlterarDadosBanco: false,
                podeEnviarTermo: true,
                desabilitarBotaoEnviarEmail: this.desabilitarBotaoEnviarEmail
            },
            17: {
                podeAlterarDadosBanco: true,
                podeEnviarTermo: true,
                desabilitarBotaoEnviarEmail: true
            },
            18: {
                podeAlterarDadosBanco: false,
                podeEnviarTermo: true,
                desabilitarBotaoEnviarEmail: this.desabilitarBotaoEnviarEmail
            },
            19: {
                podeAlterarDadosBanco: false,
                podeEnviarTermo: true,
                desabilitarBotaoEnviarEmail: this.desabilitarBotaoEnviarEmail
            },
            20: {
                podeAlterarDadosBanco: false,
                podeEnviarTermo: false,
                desabilitarBotaoEnviarEmail: this.desabilitarBotaoEnviarEmail
            },
        };

        const config = configuracoes[status] || {
            podeAlterarDadosBanco: false,
            podeEnviarTermo: false
        };

        this.podeAlterarDadosBanco = config.podeAlterarDadosBanco;
        this.podeEnviarTermo = config.podeEnviarTermo;
        this.desabilitarBotaoEnviarEmail = config.desabilitarBotaoEnviarEmail;
    }

    setStatus(status) {
        return this.statusMap[status]?.status || status;
    }

    setDescricaoStatus(status) {
        return this.statusMap[status]?.descricao || 'Status desconhecido';
    }

    setStatusClass(status) {
        return this.statusMap[status]?.classe || 'neutro-label';
    }

    setTipoConta(tipoConta) {
        switch (tipoConta) {
            case 1:
                return 'Corrente';
            case 2:
                return 'Poupança';
            default:
                return tipoConta
        }
    }


    @api closemodal;
    closeQuickAction() {
        this.modalEnviarTermo = false;
        this.modalAlterarDadosPagamento = false;
        this.modalCancelar = false;
        this.origemCaso = null;
        this.canalCaso = null;
        this.descricaoField = null;
    }

    @api eventotentarnovamente
    async handleRecarregarContratos() {
        this.showSpinner();
        await this.obterContratos();
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

    formatarValor(valor) {
        try {
            return new Intl.NumberFormat('pt-BR', {
                style: 'currency',
                currency: 'BRL'
            }).format(valor);
        } catch (error) {
            this.logError('formatarValor', error);
            return valor;
        }
    }


    formatarPorcentagem(valor, locale = 'pt-BR') {
        try {
            const numero = parseFloat(Number(valor));
            const formatoBR = numero.toLocaleString(locale) + '%';
            return formatoBR;
        } catch (error) {
            this.logError('formatarPorcentagem', error);
            return valor;
        }
    }

    formatarCPF(cpf) {
        try {
            cpf = cpf.replace(/\D/g, '');

            if (cpf.length === 11) {
                return cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
            }

            return cpf;
        } catch (error) {
            this.logError('formatarCPF', error);
            return cpf;
        }
    }

    formatarData(dataString) {
        try {

            if (!dataString) return '--';

            const data = new Date(dataString);

            const dia = String(data.getDate()).padStart(2, '0');
            const mes = String(data.getMonth() + 1).padStart(2, '0');
            const ano = data.getFullYear();

            return `${dia}/${mes}/${ano}`;
        } catch (error) {
            this.logError('formatarData', error);
            return '--';
        }
    }

    formatarDataHora(dataString) {
        try {
            if (!dataString) return '--';

            const data = new Date(dataString);

            const dia = String(data.getDate()).padStart(2, '0');
            const mes = String(data.getMonth() + 1).padStart(2, '0');
            const ano = data.getFullYear();

            const hora = String(data.getHours()).padStart(2, '0');
            const minutos = String(data.getMinutes()).padStart(2, '0');

            return `${dia}/${mes}/${ano} ${hora}:${minutos}`;
        } catch (error) {
            this.logError('formatarDataHora', error);
            return '--';
        }
    }

    getLabelPorValor(listaOpcoes, valor) {
        try {
            const opcao = listaOpcoes.find(opcao => opcao.value === valor);
            return opcao ? opcao.nomeBanco : null;
        } catch (error) {
            console.error('Erro em getLabelPorValor:', error);
            return '--';
        }
    }

    obterFinalCartao(numeroCartao, qtdDigitos = 4) {
        try {
            if (!numeroCartao) return '';
            return numeroCartao.slice(-qtdDigitos);
        } catch (error) {
            console.error('Erro em obterFinalCartao:', error);
            return '--';
        }
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

    logError(metodo, error) {
        if (error) {
            console.error('componente => ', 'bcsf_cmp_CreditoPessoalConsulta');
            console.error('metodo => ', metodo);
            console.error('erro => ', error);
            if (error.body) {
                console.error('error.body.exceptionType => ', error.body.exceptionType);
                console.error('error.body.message => ', error.body.message);
                console.error('error.body.stackTrace => ', error.body.stackTrace);
            } else {
                console.error('error.name => ' + error.name);
                console.error('error.message => ' + error.message);
                console.error('error.stack => ' + error.stack);
            }

        }
    }

}