import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import iconeOK from '@salesforce/resourceUrl/iconeOK';
import iconeErro from '@salesforce/resourceUrl/iconeErro';

import getContasAtivas from '@salesforce/apex/BCSF_IdentificacaoPositivaController.getContasAtivas';
import getContaFinanceira from '@salesforce/apex/BCSF_IdentificacaoPositivaController.getContaFinanceira';
import getPerguntas from '@salesforce/apex/BCSF_IdentificacaoPositivaController.getPerguntas';
import validarPerguntas from '@salesforce/apex/BCSF_IdentificacaoPositivaController.ValidarPerguntas';
import atualizarContaFinanceira from '@salesforce/apex/BCSF_IdentificacaoPositivaController.atualizarContaFinanceira';


import GetAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';


import USER_ID from '@salesforce/user/Id';
const FIELDS = [
    'User.Profile.Name'
];

export default class Bcsf_IdentificacaoPositiva extends LightningElement {

    @api recordId; // Propriedade para armazenar o recordId

    @track showCardPrincipal = true;
    @track isModalOpen = true;
    @track showloading = false;


    @track buttonIrPerfil = false;
    @track buttonIniciarIdentificacao = false;
    @track buttonProsseguirIdentificacao = false;
    @track desabilitaButtonProsseguir = true;
    @track buttonTentarNovamente = false;
    @track buttonVoltarInicio = false;
    @track mostarCondicional = true;
    @track ehPerfilFraude = false;

    @track stepOne = true;
    @track stepTwo = false;
    @track stepThree = false;
    @track stepFour = false;
    @track showMsgBlindagemSimples = false;
    @track header = 'Validar Identificação Positiva';

    @track currentStep = '1';

    valuetipoCliente = '';
    valueValidaUra = '';


    @track tempo;
    @track allowListProfiles = [];
    @track userProfileName;
    @track dataLimite;
    @track atendente;

    @track optionsTitular = [];
    @track optionsAdicional = [];
    @track optionsTerceiros = [];

    @track canal = 'cockpit';
    @track unidadeNegocio = null;
    @track cpf = '--';
    @track numeroConta = '--';
    @track accountId = null;

    @track sessao;
    @track avisoFinal = '';
    @track iconeAviso = '';
    @track dataHoraUltVerificacao = '';
    @track avisoCabecalho = '';

    @track perguntas = [];
    @track respostas = [];

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    currentUserInfo({ error, data }) {
        if (data) {
            try {
                let perfil = data.fields.Profile.value.fields.Name.value;
                if (perfil.toUpperCase().includes('FRAUDE')) {
                    this.ehPerfilFraude = true;
                }
            } catch (error) {
                console.log('ERROR Catch @Wire: ' + error);
            }
        } else if (error) {
            this.error = error;
            console.error('ERROR @Wire: ', error);
        }
    }

    @wire(CurrentPageReference)
    currentPageReference;

    get optionsValidaUra() {
        return [
            { label: 'Sim', value: 'Sim' },
            { label: 'Não', value: 'Não' },
        ];
    }

    validarTempoExpirado(dataLimiteStr) {
        if (!dataLimiteStr) {
            console.warn('⚠️ Data limite não informada.');
            return;
        }
        const dataLimite = new Date(dataLimiteStr);
        const agora = new Date();
        const diferencaMinutos = (agora.getTime() - dataLimite.getTime()) / (1000 * 60);

        console.log(`🕒 Diferença em minutos: ${diferencaMinutos.toFixed(2)}`);

        if (this.tempo && diferencaMinutos <= this.tempo && this.atendente === USER_ID) {
            console.log('✅ Dentro do tempo limite. Fechando modal...');
            this.closeModal();
        } else {
            console.log('⛔ Fora do tempo limite. Mantendo modal aberto.');
        }
    }


    checkSePodeValidarConta() {
        if ((this.dataLimite != undefined) || (this.atendente != undefined)) {
            console.log('Perfil não permitido, validando tempo...');
            this.validarTempoExpirado(this.dataLimite);
        }else{
            return;
        }
    }


    async buscarDadosValidacao() {
        try {
            const result = await GetAllValidationData({
                contaFinanceiraId: this.recordId,
                userId: USER_ID
            });

            this.tempo = result.tempoLimite;
            this.allowListProfiles = result.perfisBypass;
            this.userProfileName = result.perfilUsuario;
            this.dataLimite = result.dataLimiteDesbloqueio;
            this.atendente = result.ultimoOperador;

            console.group('Dados de Validação:');
            console.log('Tempo Limite:', this.tempo);
            console.log('Perfis com Bypass:', this.allowListProfiles);
            console.log('Perfil do Usuário Atual:', this.userProfileName);
            console.log('Data Limite de Desbloqueio:', this.dataLimite);
            console.log('Último Operador:', this.atendente);
            console.groupEnd();
            this.checkSePodeValidarConta();
        } catch (error) {
            console.error('❌ Erro ao buscar dados:', error);
        }
    }

    async connectedCallback() {

        console.log('RecordId da Conta Financeira: ' + this.recordId);
        console.log('User id: ' + USER_ID);

        this.buscarDadosValidacao();

        if (this.currentPageReference.state.c__validado != null) {
            var validado = this.currentPageReference.state.c__validado;
            var idContaFinanceira = this.currentPageReference.state.c__contafinanceira;

            if (validado == 'true' && idContaFinanceira == this.recordId) {
                this.isModalOpen = false;
                return;
            } else {
                if (validado == 'false') {
                    this.showCardPrincipal = false;
                    this.currentStep = '2';
                    this.stepOne = false;
                    this.stepTwo = true;
                    this.stepThree = false;
                    this.stepFour = false;

                    this.buttonIrPerfil = false;
                    this.buttonIniciarIdentificacao = false;
                    this.buttonProsseguirIdentificacao = false;
                    this.desabilitaButtonProsseguir = true;
                    this.buttonTentarNovamente = false;
                    this.buttonVoltarInicio = false;
                    this.buscaDadosContaFinanceira();
                }
            }
        }

        this.showSpinner();
        await this.getContaFinanceira();
        this.closeSpinner();

    }

    async getContaFinanceira() {
        await getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(result => {
            try {
                this.numeroConta = result.NumeroConta;
                this.cpf = result.CPF;
                this.unidadeNegocio = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.ClienteBlindado = result.ClienteBlindado;
                this.ClienteBlindadoFull = result.ClienteBlindadoFull;
                this.showMsgBlindagemSimples = result.ClienteBlindado;

                if (result.ClienteIdentificado == true) {
                    this.dataHoraUltVerificacao = result.DataIdentificacao + ' às ' + result.HoraIdentificacao;
                } else {
                    this.dataHoraUltVerificacao = '';
                }

                if (this.ClienteBlindadoFull && !this.ehPerfilFraude) {
                    this.ShowClienteBlindadoFull = true;
                    this.stepOne = false;
                    this.header = 'Não é possível iniciar o atendimento'
                }

            } catch (error) {
                console.log('Erro catch() getContaFinanceira: ' + error);
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getContaFinanceira: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }

    changRadioValidaUra(event) {
        this.valueValidaUra = event.detail.value;

        sessionStorage.setItem('keyValidaUra', this.valueValidaUra);
        if (this.valueValidaUra == 'Sim') {
            this.buttonIrPerfil = true;
            this.buttonIniciarIdentificacao = false;
        } else {
            this.buttonIrPerfil = false;
            this.buttonIniciarIdentificacao = true;
        }
    }

    changRadioTitular(event) {
        this.valuetipoCliente = 'titular';
        this.buttonProsseguirIdentificacao = true;
    }

    changRadioAdicional(event) {
        this.valuetipoCliente = 'adicional';
        this.buttonProsseguirIdentificacao = true;
    }

    changRadioTerceiro(event) {
        this.valuetipoCliente = 'terceiro';
        this.buttonProsseguirIdentificacao = true;
    }

    changRadioPergunta(event) {
        let idPergunta = event.detail.value.split(' - ')[0];
        let opcaoMarcada = event.detail.value.split(' - ')[1];

        let temp = [...this.respostas];
        const remove = this.respostas.find(item => item.key === idPergunta);

        if (remove) {
            const lineIndex = temp.indexOf(remove);
            temp.splice(lineIndex, 1);
        }

        this.respostas = [...temp];

        this.respostas.push({ key: idPergunta, value: opcaoMarcada });

        if (this.respostas.length > 1) {
            this.desabilitaButtonProsseguir = false;
        }

    }

    closeModal() {
        this.isModalOpen = false;
    }

    showSpinner() {
        this.showloading = true;
    }

    closeSpinner() {
        this.showloading = false;
    }

    showToast(titulo, mensagem, variante, closeModal) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            setTimeout(() => {
                this.redirecionarAccount();
            }, "3000");
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    buscaDadosContaFinanceira() {
        this.showSpinner();

        getContasAtivas({
            contaFinanceiraId: this.recordId
        }).then(result => {
            try {

                let optionsValuesTitular = [];
                let optionsValuesAdicional = [];
                let optionsValuesTerceiros = [];

                result.forEach(item => {
                    if (item.CartaoPrimario__c == true) {
                        optionsValuesTitular.push({
                            label: item.NomeReduzido__c + ' - ' + 'titular',
                            value: 'titular'
                        })
                    } else {
                        optionsValuesAdicional.push({
                            label: item.NomeReduzido__c + ' - ' + 'adicional',
                            value: 'adicional'
                        })
                    }
                });

                optionsValuesTerceiros.push({
                    label: 'Terceiro',
                    value: 'terceiro'
                })

                this.optionsTitular = optionsValuesTitular;
                this.optionsTerceiros = optionsValuesTerceiros;
                if (optionsValuesAdicional.length > 0) {
                    this.optionsAdicional = optionsValuesAdicional;
                } else {
                    this.mostarCondicional = false;
                }


                this.closeSpinner();

            } catch (error) {
                console.log('Erro catch() getContasAtivas: ' + error);
                this.closeSpinner();
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getContasAtivas: ' + error.body.message);
            this.closeSpinner();
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }

    buscaPerguntas() {
        this.showSpinner();

        let questions = [];
        let contadorPerguntas = 0;

        getPerguntas({
            sistema: this.canal,
            canal: this.canal,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            idEmpresa: this.unidadeNegocio,
            numeroConta: this.numeroConta
        }).then(result => {

            if (result.Status == 'OK') {
                this.sessao = result.sessao;

                result.perguntas.forEach(pergunta => {
                    let opcoes = [];
                    let contadorAlternativa = 0;

                    pergunta.alternativas.forEach(item => {
                        opcoes.push(
                            {
                                id: item.descricao,
                                label: item.descricao,
                                value: pergunta.id + ' - ' + contadorAlternativa
                            }
                        );

                        contadorAlternativa = contadorAlternativa + 1;
                    });

                    contadorPerguntas = contadorPerguntas + 1;

                    questions.push(
                        {
                            id: pergunta.id,
                            item: contadorPerguntas,
                            descricao: pergunta.descricao,
                            alternativas: opcoes
                        }
                    );

                });

                this.perguntas = questions;

                if (questions.length === 3) {
                    this.avisoCabecalho = 'O titular deve responder as três perguntas abaixo para prosseguir';
                }
                else if (questions.length === 2) {
                    this.avisoCabecalho = 'O titular deve responder as duas perguntas abaixo para prosseguir';
                }
                else {
                    this.avisoCabecalho = '';
                }

                this.closeSpinner();

            } else {
                console.log('ERRO NA VALIDAÇÃO');
                this.closeSpinner();
                this.showToast('Erro', 'Não foi possivel consultar as perguntas!', 'error', true);
            }

        }).catch(error => {
            console.log('Erro buscaPerguntas: ' + error.body.message);
            this.closeSpinner();
            this.showToast('Erro', 'Houve um erro ao consultar as perguntas!', 'error', true);
        })
    }

    validaPerguntas() {
        this.showSpinner();

        let questions = [];
        let contadorPerguntas = 0;

        validarPerguntas({
            sessao: this.sessao,
            mapRepostas: JSON.stringify(this.respostas),
            idEmpresa: this.unidadeNegocio,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal: 'cockpit'
        }).then(result => {
            if (result.Status == 'OK' && result.aprovado == false) {
                this.perguntas = [];
                this.respostas = [];

                if (result.perguntas == null || result.perguntas == undefined) {
                    this.avisoFinal = 'Cliente não foi validado na identificação positiva!';
                    this.iconeAviso = iconeErro;
                    this.buttonVoltarInicio = true;
                    this.closeSpinner();
                } else {
                    result.perguntas.forEach(pergunta => {
                        let opcoes = [];
                        let contadorAlternativa = 0;

                        this.avisoFinal = 'Cliente não foi validado na primeira tentativa!';
                        this.iconeAviso = iconeErro;
                        this.buttonTentarNovamente = true;

                        pergunta.alternativas.forEach(item => {
                            opcoes.push({
                                id: item.descricao,
                                label: item.descricao,
                                value: pergunta.id + ' - ' + contadorAlternativa
                            });
                            contadorAlternativa = contadorAlternativa + 1;
                        });
                        contadorPerguntas = contadorPerguntas + 1;

                        questions.push({
                            id: pergunta.id,
                            item: contadorPerguntas,
                            descricao: pergunta.descricao,
                            alternativas: opcoes
                        });
                    });

                    this.perguntas = questions;

                    if (questions.length === 3) {
                        this.avisoCabecalho = 'O titular deve responder as três perguntas abaixo para prosseguir';
                    }
                    else if (questions.length === 2) {
                        this.avisoCabecalho = 'O titular deve responder as duas perguntas abaixo para prosseguir';
                    }
                    else {
                        this.avisoCabecalho = '';
                    }

                    this.closeSpinner();
                }

            } else if (result.Status == 'OK' && result.aprovado == true) {
                this.UpdateContaFinanceira();

                this.avisoFinal = 'Cliente validado com sucesso!';
                this.iconeAviso = iconeOK;
                this.buttonIrPerfil = true;
                this.closeSpinner();
            } else {
                this.showToast('Erro', 'Erro ao tentar validar as perguntas!', 'error', true);
                this.avisoFinal = 'Erro ao tentar validar as respostas!';
                this.iconeAviso = iconeErro;
                this.closeSpinner();
            }
        }).catch(error => {
            console.log('Erro validarPerguntas: ' + error.body.message);
            this.closeSpinner();
            this.showToast('Erro', 'Houve um erro ao validar as perguntas!\n' + error.body.message, 'error', true);
        })
    }

    UpdateContaFinanceira() {
        this.showSpinner();

        atualizarContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(() => {
            this.closeSpinner();
        }).catch(error => {
            console.log('Erro UpdateContaFinanceira: ' + error.body.message);
            this.closeSpinner();
            this.showToast('Erro', 'Houve um erro ao atualizar Conta Financeira!', 'error', true);
        });
    }

    handleButton(event) {
        if (this.stepOne == true) {
            this.showCardPrincipal = false;
            this.currentStep = '2';
            this.stepOne = false;
            this.stepTwo = true;
            this.stepThree = false;
            this.stepFour = false;

            this.buttonIrPerfil = false;
            this.buttonIniciarIdentificacao = false;
            this.buttonProsseguirIdentificacao = false;
            this.desabilitaButtonProsseguir = true;
            this.buttonTentarNovamente = false;
            this.buttonVoltarInicio = false;
            this.buscaDadosContaFinanceira();

        } else if (this.stepTwo == true && this.valuetipoCliente == 'terceiro') {
            this.closeModal();

        } else if (this.stepTwo == true) {
            this.showSpinner();
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.stepFour = false;

            this.buttonIrPerfil = false;
            this.buttonIniciarIdentificacao = false;
            this.buttonProsseguirIdentificacao = false;
            this.desabilitaButtonProsseguir = true;
            this.buttonTentarNovamente = false;
            this.buttonVoltarInicio = false;
            this.buscaPerguntas();
        }
        else if (this.stepThree == true) {
            this.showSpinner();

            this.currentStep = '4';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThree = false;
            this.stepFour = true;

            this.buttonIrPerfil = false;
            this.buttonIniciarIdentificacao = false;
            this.buttonProsseguirIdentificacao = false;
            this.desabilitaButtonProsseguir = true;
            this.buttonTentarNovamente = false;
            this.buttonVoltarInicio = false;
            this.validaPerguntas();

        } else if (this.stepFour == true) {
            this.redirecionarAccount();
        }
    }

    handleTentarNovamente() {
        this.currentStep = '3';
        this.showCardPrincipal = false;
        this.stepTwo = false;
        this.stepThree = true;
        this.stepFour = false;

        this.buttonIrPerfil = false;
        this.buttonIniciarIdentificacao = false;
        this.buttonProsseguirIdentificacao = false;
        this.desabilitaButtonProsseguir = true;
        this.buttonTentarNovamente = false;
        this.buttonVoltarInicio = false;

        this.avisoFinal = '';
        this.this.iconeAviso = '';
    }

    redirecionarAccount() {
        const host = window.location.host;
        var url = 'https://' + host + '/' + this.accountId;

        window.location.assign(url);
    }
}