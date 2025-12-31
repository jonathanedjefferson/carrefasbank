import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';
import getAssetTitular from '@salesforce/apex/AlteracaoCadastralController.getAssetTitular';
import getContaFinanceira from '@salesforce/apex/BCSF_CancelamentoContaController.getContaFinanceira';
import ListarCartoes from '@salesforce/apex/BCSF_AtivarInativarCartaoController.ListarCartoes';
import Ativar from '@salesforce/apex/BCSF_AtivarInativarCartaoController.Ativar';
import Inativar from '@salesforce/apex/BCSF_AtivarInativarCartaoController.Inativar';
import createCase from '@salesforce/apex/BCSF_AtivarInativarCartaoController.createCase';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import USER_ID from '@salesforce/user/Id';
import GetAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';
export default class Bcsf_AtivarInativarCartao extends LightningElement {
    //#region ######### VARIAVEIS ##########
    spinner = false;
    logoTipo;
    caseId;
    cartaoAtivo = true;

    @api recordId;

    @track disableButton = true;
    @track buttonPross = true;

    @track tempo;
    @track allowListProfiles = [];
    @track userProfileName;
    @track dataLimite;
    @track atendente;

    @track userProfileName;
    @track statusCartaoPrimario;
    @track stepOne = true;
    @track stepTwo = false;
    @track stepThree = false;
    @track stepFour = false;
    @track cartaoAtualizado = false;
    @track novoStatusCartao = null;
    @track quantCartao = 0;
    @track showCardPrincipal = true;
    @track showButtonProsseguir = true;
    @track valueCartoes = null;
    @track numeroCartao = null;
    @track numeroSerno = null;
    @track valueStatusCartoes = null;
    @track newValueStatus = null;
    @track valueOrigem = null;
    @track valueCanal = null;
    @track valueAssunto = null;
    @track valueEvento = null;
    @track unidadeNegocio = null;
    @track accountId = null;
    @track accountId = null;
    @track valorLimiteDisponivel = null;
    @track valorLimiteTotal = null;
    @track numeroCartaoSerno = null;
    @track dataAtual = new Date();
    @track selectedCard = null;
    @track selectedCardLabel = null;

    @track currentStep = '1';
    @track nome = '--';
    @track nomeNoCartao = '--';
    @track numeroConta = '--';
    @track statusConta = '--';
    @track tipoConta = '--';
    @track cpf = '--';
    @track dataNascimento = '--';
    @track hasErrorSteps = false;
    @track hasErrorSteps = false;
    @track ehAtivo = null;
    @track situacaoCartao = null;

    @track statusContaInfo = 'Informação indisponível';
    @track statusCartaoInfo = 'Informação indisponível';
    @track Area = null;
    @track canal = 'cockpit';

    optionsCartoes = [];
    listaCartoes = [];
    numProtocolo;

    //#endregion 

    //#region ########## CARREGAMENTO DE DATA OPTIONS ##########

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && !this.recordId) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.Area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error;
        }
    }


    //#region ########## CONTROLE DE DESBLOQUEIO DE CARTÃO ##########
    handleContaValidada() {
        console.log('handleContaValidada')
        // const buscarHref = window.location.href;
        // const validado = buscarHref.includes('c__validado=true')
        //     ? true
        //     : buscarHref.includes('c__validado=false')
        //         ? false
        //         : false;

        const ContaCartaoNORM = this.statusCartaoPrimario === this.statusConta &&
            this.statusCartaoPrimario === 'NORM';



        if (this.cartaoAtivo) return;
        if (this.allowListProfiles.includes(this.userProfileName)) {
            switch (ContaCartaoNORM) {
                case true:

                    this.buscarDadosValidacao();

                    break;
                case false:
                    break;
            }
        }

    }
    validarTempoExpirado(dataLimiteStr) {
        if (!dataLimiteStr) {
            console.warn('⚠️ Data limite não informada.');
            return;
        }
        const dataLimite = new Date(dataLimiteStr);
        const agora = new Date();
        const diferencaMinutos = (agora.getTime() - dataLimite.getTime()) / (1000 * 60);

        // console.log(`🕒 Diferença em minutos: ${diferencaMinutos.toFixed(2)}`);

        if (this.tempo && diferencaMinutos >= this.tempo || this.atendente !== USER_ID) {
            this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
            console.log('✅ Dentro do tempo limite. Fechando modal...');
            this.closeQuickAction();
        } else {
            console.log('⛔ Fora do tempo limite. Mantendo modal aberto.');
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
            // console.group('Dados de Validação:');
            // console.log('Tempo Limite:', this.tempo);
            // console.log('Perfis com Bypass:', this.allowListProfiles);
            // console.log('Perfil do Usuário Atual:', this.userProfileName);
            // console.log('Data Limite de Desbloqueio:', this.dataLimite);
            // console.log('Último Operador:', this.atendente);
            // console.groupEnd();
            if (this.atendente == undefined || this.dataLimite == undefined) {
                this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
                console.log('Fechando modal por falta de dados de validação...');
                this.dispatchEvent(new CloseActionScreenEvent());
            }else{
                 this.validarTempoExpirado(this.dataLimite);
            }

        } catch (error) {
            console.error('❌ Erro ao buscar dados:', error);
        }
    }
    async getAssetTitular() {
        await getAssetTitular({
            idContaFinanceira: this.recordId
        }).then(result => {
            try {
                this.statusCartaoPrimario = result.Status;
                this.handleContaValidada();
            } catch (error) {
                console.log('Erro catch() getAssetTitular: ' + error);
            }
        }).catch(error => {
            console.log('Erro getAssetTitular: ' + error.body.message);
            console.dir(error);
        });
    }

    //#endregion

    async connectedCallback() {
        this.showSpinner();
        this.disableButton = this.cmpFalecimento != true ? true : false;
        getContaFinanceira({ contaFinanceiraId: this.recordId })
            .then(result => {
                this.nome = result.Nome;
                this.numeroConta = result.NumeroConta;
                this.cpf = result.CPF;
                this.dataNascimento = result.DataNascimento;
                this.unidadeNegocio = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.statusConta = result.StatusConta;
                console.log('statusConta ' + this.statusConta);
                console.log('statusConta ' + result.StatusConta);
                this.dataAtual = new Date();
                this.dataAtual = this.dataAtual.toLocaleDateString();
                if (result.UnidadeNegocio == "1") {
                    this.tipoConta = 'Carrefour';
                    this.logoTipo = LogoCarrefour;
                } else if (result.UnidadeNegocio == "2") {
                    this.tipoConta = 'Atacadão';
                    this.logoTipo = LogoAtacadao;
                } else if (result.UnidadeNegocio == "6") {
                    this.tipoConta = "Sam's Club";
                    this.logoTipo = LogoSamsClub;
                }
                this.ListCartoes(this.numeroConta, this.unidadeNegocio, this.cpf, this.canal);
                this.closeSpinner();
            })
            .catch(error => {
                console.log('Erro getContaFinanceira: ' + error.body.message);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
                this.closeSpinner();
            });

    }
    //#endregion 

    //#region ########## HANDLER PICKLISTS ##########

    handleChangeCartao(event) {
        this.valueCartoes = event.detail.value;
        this.numeroCartao = event.detail.value.split(" - ")[0];
        this.dataVencimento = event.detail.value.split(" - ")[1];
        this.ehPrimario = event.detail.value.split(" - ")[2];
        this.ehAtivo = event.detail.value.split(" - ")[3];
        if (this.ehAtivo == 'true') {
            this.cartaoAtivo = true;
            this.situacaoCartao = 'Ativo';
        } else {
            this.cartaoAtivo = false;
            this.situacaoCartao = 'Inativo';
        }
        this.statusCartao = event.detail.value.split(" - ")[7];
        this.valorLimiteDisponivel = event.detail.value.split(" - ")[8];
        this.valorLimiteTotal = event.detail.value.split(" - ")[9];
        this.numeroCartaoSerno = event.detail.value.split(" - ")[10]
        this.stepTwo = true;

        this.verifyDesable();

        this.listaCartoes.forEach(item => {
            if (item.numeroCartaoOfuscado == this.numeroCartao) {
                this.numeroSerno = item.numeroCartaoSerno;
            }
        });
    }

    selectFirstCard(value) {
        this.valueCartoes = value;
        this.numeroCartao = value.split(" - ")[0];
        this.dataVencimento = value.split(" - ")[1];
        this.ehPrimario = value.split(" - ")[2];
        this.ehAtivo = value.split(" - ")[3];
        if (this.ehAtivo == 'true') {
            this.cartaoAtivo = true;
            this.situacaoCartao = 'Ativo';
        } else {
            this.cartaoAtivo = false;
            this.situacaoCartao = 'Inativo';
        }
        this.statusCartao = value.split(" - ")[7];
        this.valorLimiteDisponivel = value.split(" - ")[8];
        this.valorLimiteTotal = value.split(" - ")[9];
        this.numeroCartaoSerno = value.split(" - ")[10]
        this.stepTwo = true;

        this.verifyDesable();
    }

    changeToggle() {
        this.cartaoAtivo = !this.cartaoAtivo;
        if (this.cartaoAtivo == true) {
            this.situacaoCartao = 'Ativo';
        } else {
            this.situacaoCartao = 'Inativo';
        }
        this.cartaoAtualizado = true;
        this.verifyDesable();
    }

    handleAtivarInativarCartao() {
        if (this.cartaoAtivo == true) {
            this.AtivarCartao();
        } else {
            this.InativarCartao();
        }
    }

    AtivarCartao() {
        console.log('Ativando Cartão...');
        this.showSpinner();

        Ativar({
            numeroCartaoSerno: this.numeroCartaoSerno,
            idEmpresa: this.unidadeNegocio,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            sistema: this.canal,
            canal: this.canal,
            area: this.Area,
            tipo: 'Ativar'

        }).then(result => {
            if (result) {
                this.novoStatusCartao = 'ativado';
                this.valueAssunto = 'Desbloqueio';
                this.valueEvento = 'Ativação de cartão de crédito';
                this.CreateCase('Ativar');
            } else {
                this.showToast('Erro', 'Não foi possível ativar o Cartão!', 'error', true);
                this.closeSpinner();
            }
        }).catch(error => {
            console.log('Erro ativarCartao: ' + error);
            this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado, tente novamente em instantes', 'error', true);
            this.closeSpinner();
        })
        console.log('fim ativação');
    }

    InativarCartao() {
        console.log('Inativando Cartão...');
        this.showSpinner();

        Inativar({
            numeroCartaoSerno: this.numeroCartaoSerno,
            idEmpresa: this.unidadeNegocio,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            sistema: this.canal,
            canal: this.canal,
            area: this.Area,
            tipo: 'Inativar'
        }).then(result => {
            if (result) {
                this.novoStatusCartao = 'inativado';
                this.valueAssunto = 'Bloqueio';
                this.valueEvento = 'Inativação de cartão de crédito';
                this.CreateCase('Inativar');
            } else {
                this.showToast('Erro', 'Não foi possível inativar o Cartão!', 'error', true);
                this.closeSpinner();
            }
        }).catch(error => {
            console.log('Erro inativarCartao: ' + error);
            this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado, tente novamente em instantes', 'error', true);
            this.closeSpinner();
        })
        console.log('fim inativação');

    }

    handleChangeOrigem(event) {
        this.valueOrigem = event.detail.value;
        this.verifyDesable();
    }

    handleChangeCanal(event) {
        this.valueCanal = event.detail.value;
        this.verifyDesable();
    }
    //#endregion 

    //#region ########## BUTTONS ##########

    handleProsseguir(event) {
        if (this.stepOne == true) {
            this.currentStep = '2';
            this.stepOne = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.stepFour = this.cartaoAtivo;
            this.disableButton = false;
            this.showButtonProsseguir = false;
        } else if (this.stepTwo == true) {
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.stepFour = this.cartaoAtivo;
            this.disableButton = false;
        }
    }

    handleButtonVoltar(event) {
        if (this.stepTwo == true) {
            this.currentStep = '1';
            this.disableButton = true;
            this.stepOne = true;
            this.stepTwo = false;
            this.stepThree = false;
            this.stepFour = false;
            this.showCardPrincipal = true;
            this.showButtonProsseguir = true;

        } else if (this.stepThree == true) {
            this.currentStep = '1';
            this.disableButton = true;
            this.stepOne = true;
            this.stepTwo = false;
            this.stepThree = false;
            this.stepFour = false;
            this.showCardPrincipal = true;
            this.showButtonProsseguir = true;
        }
    }

    verifyDesable() {
        if (this.valueCartoes == null || this.valueCartoes == undefined ||
            this.valueOrigem == null || this.valueOrigem == undefined ||
            this.valueCanal == null || this.valueCanal == undefined ||
            this.cartaoAtualizado == false) {

            this.buttonPross = true;
        } else {
            this.buttonPross = false;
        }
    }

    irCase() {
        window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
    }
    //#endregion 

    //#region ########## DML/QUERY ##########

    CreateCase(tipo) {
        console.log('criando caso');
        this.showSpinner();
        createCase({
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal,
            tipo: tipo
        }).then(result => {
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.disableButton = true;
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
        }).catch(error => {
            console.log('Erro createCase: ' + error);
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
        });
        this.closeSpinner();
        this.handleProsseguir();
    }
    //#endregion 

    //#region ########## INTEGRAÇÕES API ##########

    async ListCartoes(numeroConta, unidadeNegocio, cpf, canal) {
        await ListarCartoes({
            numeroConta: numeroConta,
            unidadeNegocio: unidadeNegocio,
            cpf: cpf.replaceAll('.', '').replaceAll('-', ''),
            canal: canal
        }).then(result => {
            if (result != null && result.length > 0) {
                this.listaCartoes = result;
                let opcoes = [];

                result.forEach(item => {
                    item.cartoes.forEach(valor => {

                        if (valor.statusCartao == 'NORM' ||
                            valor.statusCartao == 'BLCK' ||
                            valor.statusCartao == 'DLNQ' ||
                            valor.statusCartao == 'INTC') {
                            this.quantCartao++;
                            var primario = null;
                            var ultimosNumCartao = valor.numeroCartao.slice(valor.numeroCartao.length - 4);
                            var dataVencimento = valor.vencimentoCartao.slice(5, 7) + '/' + valor.vencimentoCartao.slice(0, 4);

                            if (valor.ehPrimario == true) {
                                primario = '(Titular)'
                            } else {
                                primario = '(Adicional)'
                            }

                            opcoes.push(
                                {
                                    label:
                                        'Final ' +
                                        ultimosNumCartao + ' - ' +
                                        valor.nomePortador + ' ' +
                                        primario,
                                    value:
                                        valor.numeroCartao + ' - ' +
                                        dataVencimento + ' - ' +
                                        primario + ' - ' +
                                        valor.ehAtivo + ' - ' +
                                        ultimosNumCartao + ' - ' +
                                        valor.nomePortador + ' - ' +
                                        primario + ' - ' +
                                        valor.statusCartao + ' - ' +
                                        item.valorLimiteDisponivel + ' - ' +
                                        item.valorLimiteTotal + ' - ' +
                                        valor.id
                                }
                            );
                        }
                    });
                    this.optionsCartoes = opcoes;
                })
                this.selectedCard = opcoes[0].value;
                this.selectedCardLabel = this.quantCartao == 1 ? opcoes[0].label : 'Selecionar Cartão';

            } else {
                this.showToast('Erro', 'Esta conta financeira não possui cartões de crédito disponíveis para Ativar ou Inativar.', 'warning', true);
            }
        }).catch(error => {
            console.log('Erro getListCartoes: ' + error);
            this.showToast('Erro', 'Houve um erro ao buscar cartões para Ativar ou Inativar!', 'error', true);
        });
        console.log('Quantidade Cartões: ' + this.quantCartao);

        if (this.quantCartao == 1) {
            this.selectFirstCard(this.selectedCard);
            this.stepTwo = true;
        }
        await this.getAssetTitular();
    }

    //#region ########## INTERAÇÕES COM USUÁRIO ##########

    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
        this.spinner = false;
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
            this.closeQuickAction();
        }
    }

    @api closeParentComponent;
    closeQuickAction() {
        if (this.closeParentComponent) {
            this.dispatchEvent(new CustomEvent('closeparentmodal'));
        } else {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    //#endregion 
}