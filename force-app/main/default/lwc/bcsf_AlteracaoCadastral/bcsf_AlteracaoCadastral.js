import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';

import getContaFinanceira from '@salesforce/apex/AlteracaoCadastralController.GetContaFinanceira';
import alterarDadosCadastrais from '@salesforce/apex/AlteracaoCadastralController.AlterarDadosCadastrais';
import getAssetTitular from '@salesforce/apex/AlteracaoCadastralController.getAssetTitular';
import getEnderecoByCEP from '@salesforce/apex/AlteracaoCadastralController.GetEnderecoByCEP';
import criarCaso from '@salesforce/apex/AlteracaoCadastralController.CriarCaso';
import criarAvaliacaoAlteracao from '@salesforce/apex/AlteracaoCadastralController.CriarAvaliacaoAlteracao';
import GetAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';

const OPTIONS_SOLICITACAO_CARTAO = [
    { label: 'Sim', value: '1' },
    { label: 'Não', value: '2' },
];
const OPTIONS_GENERO = [
    { label: 'MASCULINO', value: '2' },
    { label: 'FEMININO', value: '1' },
];
const OPTIONS_ESTADO_CIVIL = [
    { label: 'SOLTEIRO(A)', value: '1' },
    { label: 'CASADO(A)', value: '2' },
    { label: 'VIÚVO(A)', value: '3' },
    { label: 'DIVORCIADO(A)', value: '4' },
    { label: 'SEPARADO(A)', value: '5' },
];
const OPTIONS_UF = [
    { label: 'AC', value: 'AC' },
    { label: 'AL', value: 'AL' },
    { label: 'AP', value: 'AP' },
    { label: 'AM', value: 'AM' },
    { label: 'BA', value: 'BA' },
    { label: 'CE', value: 'CE' },
    { label: 'DF', value: 'DF' },
    { label: 'ES', value: 'ES' },
    { label: 'GO', value: 'GO' },
    { label: 'MA', value: 'MA' },
    { label: 'MT', value: 'MT' },
    { label: 'MS', value: 'MS' },
    { label: 'MG', value: 'MG' },
    { label: 'PA', value: 'PA' },
    { label: 'PB', value: 'PB' },
    { label: 'PR', value: 'PR' },
    { label: 'PE', value: 'PE' },
    { label: 'PI', value: 'PI' },
    { label: 'RJ', value: 'RJ' },
    { label: 'RN', value: 'RN' },
    { label: 'RS', value: 'RS' },
    { label: 'RO', value: 'RO' },
    { label: 'RR', value: 'RR' },
    { label: 'SC', value: 'SC' },
    { label: 'SP', value: 'SP' },
    { label: 'SE', value: 'SE' },
    { label: 'TO', value: 'TO' }
];


const OPTIONS_EMAIL_AUTO_COMPLETE = ['GMAIL.COM', 'HOTMAIL.COM', 'OUTLOOK.COM', 'BOL.COM.BR', 'UOL.COM.BR', 'YAHOO.COM.BR'];

export default class Bcsf_AlteracaoCadastral extends LightningElement {
    //#region ######################################## VARIAVEIS ########################################
    caseId = '--';
    @track dateToday = this.formatDate(new Date());


    @track allowListProfiles = [];
    @track userProfileName;
    @track componenteAlteracaoCadastral = true;
    @track spinner = false;
    @track canal = 'cockpit';
    @track area = '';
    @track step01 = true;
    @track step02 = false;
    @track step03 = false;
    @track ShowTelaErrorAPI = false;
    @track ShowAlterarCPF = false;
    @track ShowAlteracaoBlindagemSimples = false;
    @track showDropdown = false;
    @track ShowErroDigito10 = false;
    @track RespostaIP = '';
    @track MostarSessao01 = false;
    @track MostarSessao02 = false;
    @track MostarSessao03 = false;
    @track MostarSessao04 = false;

    @track disableButtonVoltar = false;
    @track disableButtonAvancar = true;
    @track disableFiledsEndereco = false;
    @track disableFieldsContato = false;
    @track disableFiled = true;
    @track buttonAvancar = 'Prosseguir';
    @track buttonVoltar = 'Voltar';
    @track AvisoCelularSeguro = '--';
    @track showAvisoCelularSeguro = false;

    @track objAvaliacaoInsert = {};
    @track bodyRequestAlterarDados = {};
    @track AccountId = '--';
    @track UnidadeNegocio = '--';
    @track MostrarNomeDoMeio = false;
    @track NomeCompleto = '--';
    @track PossuiCelularSeguro = '--';
    @track CelularSeguro = '--';
    @track StatusConta = '--';
    @track EmailInfo = '--';
    @track ModoRecebimentoFatura = '--';
    @track ClienteBlindado = null;
    @track ClienteBlindadoFull = null;

    @track PrimeiroNome = '';
    @track PrimeiroNomeOrigin = '';
    @track NomeDoMeio = '';
    @track NomeDoMeioOrigin = '';
    @track UltimoNome = '';
    @track UltimoNomeOrigin = '';
    @track DataNascimento = '';
    @track DataNascimentoOrigin = '';
    @track CPF = '';
    @track CPFOrigin = '';
    @track RG = '';
    @track RGOrigin = '';
    @track Genero = '';
    @track GeneroOrigin = '';
    @track Naturalidade = '';
    @track NaturalidadeOrigin = '';
    @track EstadoCivil = '';
    @track EstadoCivilOrigin = '';
    @track NomeMae = '';
    @track NomeMaeOrigin = '';
    @track CEP = '';
    @track CEPOrigin = '';
    @track Rua = '';
    @track RuaOrigin = '';
    @track NumeroCasa = '';
    @track NumeroCasaOrigin = '';
    @track Complemento = '';
    @track ComplementoOrigin = '';
    @track Bairro = '';
    @track BairroOrigin = '';
    @track Cidade = '';
    @track CidadeOrigin = '';
    @track Estado = '';
    @track EstadoOrigin = '';
    @track TelefoneResidencial = '';
    @track TelefoneResidencialOrigin = '';
    @track Telefone = '';
    @track TelefoneOrigin = '';
    @track Email = '';
    @track EmailOrigin = '';
    @track AceiteRecebimentoEmail = false;
    @track AceiteRecebimentoEmailOrigin = false;
    @track IndicadorAceiteAtualizacaoLimite = false;
    @track IndicadorAceiteAtualizacaoLimiteOrigin = false;
    @track solicitacaoCartao = '';

    @track optionsGenero = OPTIONS_GENERO;
    @track optionsEstadoCivil = OPTIONS_ESTADO_CIVIL;
    @track optionsUF = OPTIONS_UF;
    @track optionsSolicitacaoCartao = OPTIONS_SOLICITACAO_CARTAO;
    @track optionsEmailAutoComplete = OPTIONS_EMAIL_AUTO_COMPLETE;

    @track MudouPrimeiroNome = false;
    @track MudouNomeDoMeio = false;
    @track MudouUltimoNome = false;
    @track MudouDataNascimento = false;
    @track MudouCPF = false;
    @track MudouRG = false;
    @track MudouGenero = false;
    @track MudouNaturalidade = false;
    @track MudouEstadoCivil = false;
    @track MudouNomeMae = false;
    @track MudouCEP = false;
    @track MudouRua = false;
    @track MudouNumeroCasa = false;
    @track MudouComplemento = false;
    @track MudouBairro = false;
    @track MudouCidade = false;
    @track MudouEstado = false;
    @track MudouTelefoneResidencial = false;
    @track MudouTelefone = false;
    @track MudouEmail = false;
    @track MudouAceiteRecebimentoEmail = false;
    @track MudouIndicadorAceiteAtualizacaoLimite = false;

    statusCartaoPrimario = '';

    @track tempo;
    @track allowListProfiles = [];
    @track userProfileName;
    @track dataLimite;
    @track atendente;

    //#endregion 

    //#region ######################################## INICIALIZAÇÃO ########################################
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error;
        }
    }

    async connectedCallback() {
        this.showSpinner();
        await this.buscarDadosValidacao();
        this.carregamentoAlteracaoCadastral();
        this.closeSpinner();
    }

    async carregamentoAlteracaoCadastral() {
        await this.getDadosContaFinanceira();
        let firstInput = this.template.querySelector('[data-id="PrimeiroNome"]');
        if (firstInput) {
            firstInput.blur(); // Remove focus from the first input
        }
    }
    //#endregion

    //#region ######################################## QUERY/DML ########################################
    async getDadosContaFinanceira() {
        await getContaFinanceira({
            idContaFinanceira: this.recordId
        }).then(async result => {
            try {
                let nomeArray = result.Nome.toUpperCase().split(' ');

                this.AccountId = result.AccountId == '--' ? '' : result.AccountId;
                this.NomeCompleto = result.Nome == '--' ? '' : result.Nome.toUpperCase();
                this.StatusConta = result.StatusConta == '--' ? '' : result.StatusConta.toUpperCase();
                this.EmailInfo = result.Email == '--' ? '' : result.Email.toUpperCase();
                this.ModoRecebimentoFatura = result.ModoRecebimentoFatura == '--' ? '' : result.ModoRecebimentoFatura.toUpperCase();
                this.CelularSeguro = result.CelularSeguro == '--' ? '' : result.CelularSeguro.toUpperCase();
                this.UnidadeNegocio = result.UnidadeNegocio == '--' ? '' : result.UnidadeNegocio.toUpperCase();



                this.PrimeiroNome = nomeArray[0];
                this.PrimeiroNomeOrigin = nomeArray[0];
                this.UltimoNome = nomeArray[nomeArray.length - 1];
                this.UltimoNomeOrigin = nomeArray[nomeArray.length - 1];
                this.RG = result.RG == '--' ? '' : result.RG;
                this.RGOrigin = result.RG == '--' ? '' : result.RG;
                this.CPF = result.CPF == '--' ? '' : result.CPF;
                this.CPFOrigin = result.CPF == '--' ? '' : result.CPF;
                this.DataNascimento = result.DataNascimento == '--' ? '' : result.DataNascimento.split('/')[2] + '-' + result.DataNascimento.split('/')[1] + '-' + result.DataNascimento.split('/')[0];
                this.DataNascimentoOrigin = this.DataNascimento;
                this.Genero = result.Genero == '--' ? '' : result.Genero.toUpperCase() == 'M' ? '2' : '1';
                this.GeneroOrigin = this.Genero;
                this.NomeMae = result.NomeMae == '--' ? '' : result.NomeMae.toUpperCase();
                this.NomeMaeOrigin = this.NomeMae;

                this.NumeroConta = result.NumeroConta == '--' ? '' : result.NumeroConta.toUpperCase();
                this.NumeroContaOrigin = this.NumeroConta;
                this.CEP = result.CEP == '--' ? '' : `${result.CEP.substring(0, 5)}-${result.CEP.substring(5, 8)}`;
                this.CEPOrigin = this.CEP;
                this.Rua = result.Rua == '--' ? '' : result.Rua.toUpperCase();
                this.RuaOrigin = this.Rua;
                this.NumeroCasa = result.NumeroCasa == '--' ? '' : result.NumeroCasa.toUpperCase();
                this.NumeroCasaOrigin = this.NumeroCasa;
                this.Complemento = result.Complemento == '--' ? '' : result.Complemento.toUpperCase();
                this.ComplementoOrigin = this.Complemento;
                this.Bairro = result.Bairro == '--' ? '' : result.Bairro.toUpperCase();
                this.BairroOrigin = this.Bairro;
                this.Cidade = result.Cidade == '--' ? '' : this.limitarTexto(result.Cidade.toUpperCase(), 20);
                this.CidadeOrigin = this.Cidade;
                this.Estado = result.Estado == '--' ? '' : result.Estado.toUpperCase();
                this.EstadoOrigin = this.Estado;

                this.Telefone = result.Telefone == '--' ? '' : `(${result.Telefone.substring(2, 4)}) ${result.Telefone.substring(4, 9)}-${result.Telefone.substring(9)}`;
                this.TelefoneOrigin = this.Telefone;
                this.TelefoneResidencial = result.TelefoneResidencial == '--' ? '' : `(${result.TelefoneResidencial.substring(2, 4)}) ${result.TelefoneResidencial.substring(4, 8)}-${result.TelefoneResidencial.substring(8)}`;
                this.TelefoneResidencialOrigin = this.TelefoneResidencial;

                this.EstadoCivilOrigin = result.EstadoCivil == '--' ? '' : result.EstadoCivil.toUpperCase();
                this.EstadoCivil = this.EstadoCivilOrigin;

                this.Email = result.Email == '--' ? '' : result.Email.toUpperCase();
                this.EmailOrigin = this.Email;

                this.ClienteBlindado = result.ClienteBlindado;
                this.ClienteBlindadoFull = result.ClienteBlindadoFull;
                this.showMsgBlindagemSimples = result.ClienteBlindado;

                this.AceiteRecebimentoEmail = result.AceitaRecebimentoEmail;
                this.AceiteRecebimentoEmailOrigin = result.AceitaRecebimentoEmail;

                this.IndicadorAceiteAtualizacaoLimite = result.AumentoAltomaticoLimite;
                this.IndicadorAceiteAtualizacaoLimiteOrigin = result.AumentoAltomaticoLimite;

                this.disableFiledsEndereco = result.ClienteBlindado;
                this.disableFieldsContato = result.ClienteBlindado;

                result.PickListValues.forEach(item => {
                    if (item.Campo == 'EstadoCivil__c') {
                        this.optionsEstadoCivil = [];
                        item.Valores.forEach(element => {
                            this.optionsEstadoCivil.push({
                                label: element.Label,
                                value: element.ApiName
                            });
                        });
                    }
                });

                if (this.CelularSeguro == 'NÃO POSSUI CELULAR SEGURO') {
                    this.PossuiCelularSeguro = false;
                    this.AvisoCelularSeguro = 'Celular não seguro';
                    this.showAvisoCelularSeguro = true;
                } else {
                    this.PossuiCelularSeguro = true;
                    this.AvisoCelularSeguro = 'Celular seguro';
                    this.showAvisoCelularSeguro = false;
                }

                if (nomeArray.length > 2) {
                    this.MostrarNomeDoMeio = true;
                    nomeArray.slice(1, nomeArray.length - 1).forEach(element => {
                        this.NomeDoMeio += element.toUpperCase() + ' ';
                        this.NomeDoMeioOrigin += element.toUpperCase() + ' ';
                    });
                }


            } catch (error) {
                console.log('Erro catch() getContaFinanceira: ' + error);
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getContaFinanceira: ' + error.body.message);
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
        await this.getAssetTitular();
        await this.handleContaValidada();
    }

    handleContaValidada() {
        let ContaCartaoNORM = this.statusCartaoPrimario === this.StatusConta &&
            this.statusCartaoPrimario === 'NORM';
        console.log('allowListProfiles: '+this.allowListProfiles)
        if (this.allowListProfiles.includes(this.userProfileName)) {
            switch (ContaCartaoNORM) {
                case true:

                    if (this.atendente == undefined || this.dataLimite == undefined) {
                        this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
                        console.log('Fechando modal por falta de dados de validação...');
                        this.dispatchEvent(new CloseActionScreenEvent());
                    } else {
                        this.validarTempoExpirado(this.dataLimite);
                    }

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

        if (diferencaMinutos >= this.tempo || this.atendente !== USER_ID) {
            setTimeout(() => {
            this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
            console.log('⛔ Fora do tempo limite. Fechando modal...');
                this.closeQuickAction();
            }, 10);
        } else {
            console.log('✅ Dentro do tempo limite. Mantendo modal aberto. ');
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
            } catch (error) {
                console.log('Erro catch() getAssetTitular: ' + error);
            }
        }).catch(error => {
            console.log('Erro getAssetTitular: ' + error.body.message);
            console.dir(error);
        });
    }

    async CriarCaso() {
        await criarCaso({
            canal: this.valueCanal,
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.AccountId,
            unidadeNegocio: this.UnidadeNegocio,
            assunto: this.Assunto,
            evento: this.Evento,
            status: this.StatusCaso
        }).then(result => {
            try {
                if (result != null) {
                    this.numeroProtocolo = result.CaseNumber;
                    this.caseId = result.Id;
                } else {
                    console.log('Erro catch() CriarCaso: ' + error);
                    this.showToast('Erro', 'Houve um erro ao Criar Protocolo!', 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() CriarCaso: ' + error);
                this.showToast('Erro', 'Houve um erro ao Criar Protocolo!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro CriarCaso: ' + error.body.message);
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao Criar Protocolo!', 'error', true);
        });
    }


    async CriarAvaliacaoAlteracao() {
        await criarAvaliacaoAlteracao({
            avaliacaoJson: JSON.stringify(this.objAvaliacaoInsert)
        }).then(() => {

        }).catch(error => {
            console.log('ErroCriarAvaliacaoAlteracao ' + error.body.message);
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao Criar Protocolo!', 'error', true);
        });
    }
    //#endregion

    //#region ######################################## CHAMADAS DE API ########################################
    async alterarDadosCadastrais() {
        await alterarDadosCadastrais({
            cpf: this.returnApenasNumero(this.CPF),
            idEmpresa: this.UnidadeNegocio,
            canal: this.canal,
            numeroConta: this.NumeroConta,
            area: this.area,
            sistema: this.area,
            bodyRequest: JSON.stringify(this.bodyRequestAlterarDados)
        }).then(result => {
            try {
                if (result) {
                    this.podeCriarCaso = true;
                } else {
                    console.log('Erro else - alterarDadosCadastrais: ');
                    this.irTelaErro();
                }
            } catch (error) {
                console.log('Erro catch() alterarDadosCadastrais: ' + error);
                this.irTelaErro();
            }
        }).catch(error => {
            console.log('Erro alterarDadosCadastrais: ' + error.body.message);
            console.dir(error);
            this.irTelaErro();
        });
    }

    async ObterEnderecoByCEP() {
        await getEnderecoByCEP({
            cpf: this.returnApenasNumero(this.CPF),
            idEmpresa: this.UnidadeNegocio,
            canal: this.canal,
            cep: this.returnApenasNumero(this.CEP)
        }).then(result => {
            try {
                if (result.StatusAPI == 'OK') {
                    this.Rua = result.logradouro != null ? result.logradouro.toUpperCase() : '';
                    this.Bairro = result.bairro != null ? result.bairro.toUpperCase() : '';
                    this.Cidade = result.cidade != null ? this.limitarTexto(result.cidade.toUpperCase(), 20) : '';
                    this.Estado = result.uf != null ? result.uf.toUpperCase() : '';
                    this.Complemento = '';
                    this.NumeroCasa = '';
                } else {
                    console.log('Erro else - ObterEnderecoByCEP: ');
                    this.showToast('', 'Nenhum resultado encontrado para esse CEP', 'warning', false);
                }
            } catch (error) {
                console.log('Erro catch() ObterEnderecoByCEP: ' + error);
                this.showToast('Erro', 'Houve um erro ao buscar informações para esse CEP!', 'warning', false);
            }
        }).catch(error => {
            console.log('Erro ObterEnderecoByCEP: ' + error.body.message);
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao buscar informações para esse CEP!', 'warning', false);
        });
    }
    //#endregion

    //#region ######################################## METODOS HANDLER ########################################
    handlerField(event) {
        try {
            let idCampo = event.target.id;
            let valorCampo = event.target.value != null ? event.target.value.toUpperCase() : '';
            let numeroApenas = this.returnApenasNumero(valorCampo);
            let ultimoCaracter = valorCampo.split('')[valorCampo.split('').length - 1];
            let ehCaracter = JSON.stringify(parseInt(ultimoCaracter)) == 'null' ? true : false;
            let specialCharPattern = /[^a-zA-Z0-9áéíóúÁÉÍÓÚãõÃÕâêîôûÂÊÎÔÛàèìòùÀÈÌÒÙäëïöüÄËÏÖÜçÇ\s]/;
            let temCaracterEspecial = specialCharPattern.test(valorCampo);
            let input = event.target;

            if (idCampo.includes('PrimeiroNome')) {
                if (ehCaracter && !temCaracterEspecial) {
                    this.PrimeiroNome = valorCampo;
                } else {
                    input.value = this.PrimeiroNome;
                }
            } else if (idCampo.includes('NomeDoMeio')) {
                if (ehCaracter && !temCaracterEspecial) {
                    this.NomeDoMeio = valorCampo;
                } else {
                    input.value = this.NomeDoMeio;
                }
            } else if (idCampo.includes('UltimoNome')) {
                if (ehCaracter && !temCaracterEspecial) {
                    this.UltimoNome = valorCampo;
                } else {
                    input.value = this.UltimoNome;
                }
            } else if (idCampo.includes('DataNascimento')) {
                if (numeroApenas.length == 8) {
                    let ehMaior = this.isOver18(valorCampo);
                    this.DataNascimento = valorCampo;
                    if (ehMaior) {
                        input.setCustomValidity('');
                    } else {
                        input.setCustomValidity('O cliente deve ter 18 anos ou mais');
                    }
                } else {
                    input.setCustomValidity('Sua entrada não corresponde ao formato permitido DD/MM/AAAA');
                }
            } else if (idCampo.includes('RG')) {
                this.RG = numeroApenas;
                if (numeroApenas === '' || numeroApenas.length === 9) {
                    if (numeroApenas === '') {
                        this.RG = '';
                        input.setCustomValidity('');
                    } else {
                        let match = numeroApenas.match(/^(\d{2})(\d{3})(\d{3})(\d{1})$/);
                        if (match) {
                            this.RG = `${match[1]}.${match[2]}.${match[3]}-${match[4]}`;
                            input.setCustomValidity('');
                        }
                    }
                } else {
                    input.setCustomValidity('Formato de RG inválido');
                }
                input.value = this.RG;

            } else if (idCampo.includes('Genero')) {
                this.Genero = valorCampo;
            } else if (idCampo.includes('Naturalidade')) {
                if (ehCaracter && !temCaracterEspecial) {
                    this.Naturalidade = valorCampo;
                } else {
                    input.value = this.Naturalidade;
                }
            } else if (idCampo.includes('EstadoCivil')) {
                this.EstadoCivil = valorCampo;
            } else if (idCampo.includes('NomeMae')) {
                if (ehCaracter && !temCaracterEspecial) {
                    this.NomeMae = valorCampo;
                } else {
                    input.value = this.NomeMae;
                }
            } else if (idCampo.includes('CEP')) {
                if (numeroApenas.length > 5) {
                    this.CEP = `${numeroApenas.substring(0, 5)}-${numeroApenas.substring(5, 8)}`;
                } else {
                    input.value = numeroApenas;
                    this.CEP = numeroApenas;
                }
            } else if (idCampo.includes('Rua')) {
                this.Rua = valorCampo;
            } else if (idCampo.includes('NumeroCasa')) {
                this.NumeroCasa = valorCampo;
            } else if (idCampo.includes('Complemento')) {
                this.Complemento = valorCampo;
            } else if (idCampo.includes('Bairro')) {
                this.Bairro = valorCampo;
            } else if (idCampo.includes('Cidade')) {
                this.Cidade = valorCampo;
            } else if (idCampo.includes('Estado')) {
                this.Estado = valorCampo;
            } else if (idCampo.includes('TelefoneResidencial')) {
                if (numeroApenas.length != 10 && numeroApenas.length != 0) {
                    this.ShowErroDigito10 = true;
                    input.value = numeroApenas;
                    this.TelefoneResidencial = numeroApenas;
                } else {
                    this.ShowErroDigito10 = false;
                    if (numeroApenas.length == 10) {
                        this.TelefoneResidencial = `(${numeroApenas.substring(0, 2)}) ${numeroApenas.substring(2, 6)}-${numeroApenas.substring(6)}`;
                    } else {
                        this.TelefoneResidencial = numeroApenas;
                    }
                }
            } else if (idCampo.includes('Telefone')) {
                if (numeroApenas.length == 11) {
                    this.Telefone = `(${numeroApenas.substring(0, 2)}) ${numeroApenas.substring(2, 7)}-${numeroApenas.substring(7)}`;
                    this.ShowErroDigito11 = false;
                } else {
                    this.ShowErroDigito11 = true;
                    input.value = numeroApenas;
                    this.Telefone = numeroApenas;
                }

                if (this.PossuiCelularSeguro && (this.Telefone.toUpperCase() != this.TelefoneOrigin.toLocaleUpperCase() && this.Telefone != null && this.Telefone != undefined && this.Telefone != '')) {
                    this.AvisoCelularSeguro = 'Celular não seguro';
                    this.showAvisoCelularSeguro = true;
                } else if (this.PossuiCelularSeguro && (this.Telefone.toUpperCase() == this.TelefoneOrigin.toLocaleUpperCase() && this.Telefone != null && this.Telefone != undefined && this.Telefone != '')) {
                    this.AvisoCelularSeguro = 'Celular seguro';
                    this.showAvisoCelularSeguro = false;
                }
            } else if (idCampo.includes('Email')) {
                if (valorCampo.includes('@')) {
                    this.optionsEmailAutoComplete = [];
                    OPTIONS_EMAIL_AUTO_COMPLETE.forEach(item => {
                        this.optionsEmailAutoComplete.push(valorCampo.split('@')[0] + '@' + item);
                    });
                    this.showDropdown = true;
                } else {
                    this.showDropdown = false;
                }

                if (ultimoCaracter != ' ') {
                    this.Email = valorCampo;
                } else {
                    input.value = this.Email;
                }
            } else if (idCampo.includes('AceiteRecebimentoE_mail')) {
                this.AceiteRecebimentoEmail = input.checked;
            } else if (idCampo.includes('IndicadorAceiteAtualizacaoLimite')) {
                this.IndicadorAceiteAtualizacaoLimite = input.checked;
            } else if (idCampo.includes('SolicitacaoCartaoBlindagemSimples')) {
                this.solicitacaoCartao = valorCampo;
            }

            this.podeProsseguirStep02().then(result => {
                this.disableButtonAvancar = !result;
            });
        } catch (error) {
            console.log('ERROR handlerField: ' + error);
            this.disableButtonAvancar = true;
        }
    }

    handleButtonVoltar() {
        if (this.step01) {
            this.closeQuickAction();
        } else if (this.step02 || this.ShowAlterarCPF) {
            this.step01 = true;
            this.step02 = false;
            this.step03 = false;
            this.ShowTelaErrorAPI = false;
            this.ShowAlterarCPF = false;
            this.ShowAlteracaoBlindagemSimples = false;

            this.buttonVoltar = 'Voltar';
            this.buttonAvancar = 'Prosseguir';
            this.valueCanal = null;
            this.valueOrigem = null;
            this.CPF = this.CPFOrigin;

            this.podeProsseguirStep02().then(result => {
                this.disableButtonAvancar = !result;
            });
        } else if (this.step03) {
            this.alterarTipoEnvio();
        } else if (this.ShowAlteracaoBlindagemSimples) {
            this.step01 = true;
            this.step02 = false;
            this.step03 = false;
            this.ShowTelaErrorAPI = false;
            this.ShowAlterarCPF = false;
            this.ShowAlteracaoBlindagemSimples = false;

            this.buttonVoltar = 'Voltar';
            this.buttonAvancar = 'Prosseguir';
            this.valueCanal = null;
            this.valueOrigem = null;

            this.CEP = this.CEPOrigin;
            this.Rua = this.RuaOrigin;
            this.NumeroCasa = this.NumeroCasaOrigin;
            this.Complemento = this.ComplementoOrigin;
            this.Bairro = this.BairroOrigin;
            this.Cidade = this.CidadeOrigin;
            this.Estado = this.EstadoOrigin;
            this.TelefoneResidencial = this.TelefoneResidencialOrigin;
            this.Telefone = this.TelefoneOrigin;
            this.Email = this.EmailOrigin;
            this.showAvisoCelularSeguro = this.PossuiCelularSeguro;
            this.AvisoCelularSeguro = this.PossuiCelularSeguro ? 'Celular Seguro' : 'Celular não seguro';
            this.showDropdown = false;

            this.ShowErroDigito10 = false;
            this.TelefoneResidencialErro = false;
            this.ShowErroDigito11 = false;
            this.TelefoneErro = false;
            this.showAvisoCelularSeguro = !this.PossuiCelularSeguro;

            this.disableButtonAvancar = true;
            this.podeProsseguirStep02();
        }
    }

    async handleProsseguir() {
        if (this.step01) {
            this.step01 = false;
            this.step02 = true;
            this.step03 = false;
            this.ShowTelaErrorAPI = false;
            this.ShowAlterarCPF = false;

            await this.MontarJson();

            OPTIONS_GENERO.forEach(item => {
                if (item.value == this.Genero) {
                    this.GeneroFormat = item.label;
                }
            });

            this.optionsEstadoCivil.forEach(item => {
                if (item.value == this.EstadoCivil) {
                    this.EstadoCivilFormat = item.label;
                }
            });

            this.buttonVoltar = 'Voltar';
            this.buttonAvancar = 'Finalizar';
            this.verifyDesable();
        } else if (this.step02) {
            this.showSpinner();
            await this.alterarDadosCadastrais();
            if (this.podeCriarCaso) {
                this.StatusCaso = 'Closed';
                this.Assunto = 'Alteração de Dados Cadastrais';
                if (!this.MostarSessao03 && this.MostarSessao02 && !this.MostarSessao01) {
                    this.Evento = 'Alteração de endereço';
                } else {
                    this.Evento = 'Alteração de dados gerais/contato';
                }
                await this.CriarCaso();

                this.step01 = false;
                this.step02 = false;
                this.step03 = true;
                this.ShowTelaErrorAPI = false;
                this.ShowAlterarCPF = false;

                this.buttonVoltar = 'Tipo de recebimento de fatura';
                this.buttonAvancar = 'Ir para o caso';
            }
            this.closeSpinner();
        } else if (this.step03) {
            this.irCaso();
        } else if (this.ShowTelaErrorAPI) {
            this.showSpinner();
            await this.alterarDadosCadastrais();
            if (this.podeCriarCaso) {
                await this.CriarCaso();

                this.step01 = false;
                this.step02 = false;
                this.step03 = true;
                this.ShowTelaErrorAPI = false;
                this.ShowAlterarCPF = false;

                this.buttonVoltar = 'Tipo de recebimento de fatura';
                this.buttonAvancar = 'Ir para o caso';
            }
            this.closeSpinner();
        } else if (this.ShowAlterarCPF) {
            this.showSpinner();
            this.Assunto = 'Cartão';
            this.Evento = 'Alteração de dados cadastrais CPF';
            this.valueOrigem = 'Pós vendas';
            this.valueCanal = 'Voz';
            this.StatusCaso = 'new';
            await this.CriarCaso();
            await this.MontarObjAvaliacao();
            await this.CriarAvaliacaoAlteracao();

            this.step01 = false;
            this.step02 = false;
            this.step03 = true;
            this.ShowTelaErrorAPI = false;
            this.ShowAlterarCPF = false;
            this.buttonAvancar = 'Ir para o caso';
            this.disableButtonVoltar = true;
            this.closeSpinner();
        } else if (this.ShowAlteracaoBlindagemSimples) {
            this.showSpinner();
            this.Assunto = 'Alteração de Dados Cadastrais';
            this.Evento = 'Cliente Perfil Diferenciado';
            // this.valueOrigem = 'Pós vendas';
            // this.valueCanal = 'Voz';
            this.StatusCaso = 'new';
            await this.CriarCaso();
            await this.MontarObjAvaliacao();
            await this.CriarAvaliacaoAlteracao();

            this.step01 = false;
            this.step02 = false;
            this.step03 = true;
            this.ShowTelaErrorAPI = false;
            this.ShowAlterarCPF = false;
            this.buttonAvancar = 'Ir para o caso';
            this.disableButtonVoltar = true;
            this.ShowAlteracaoBlindagemSimples = false;
            this.closeSpinner();
        }
    }

    handleComplete(event) {
        let valorCampo = event.currentTarget.id.split('-')[0];
        this.showDropdown = false;
        this.Email = valorCampo;

        this.podeProsseguirStep02().then(result => {
            this.disableButtonAvancar = !result;
        });
    }

    focusOutAutoComplete(event) {
        event.target.setCustomValidity('');

        setTimeout(() => {
            this.showDropdown = false;
        }, 150);

        this.podeProsseguirStep02().then(result => {
            this.disableButtonAvancar = !result;
        });
    }

    handleAlteracaoBlindademSimples() {
        this.step01 = false;
        this.step02 = false;
        this.step03 = false;
        this.ShowTelaErrorAPI = false;
        this.ShowAlterarCPF = false;
        this.ShowAlteracaoBlindagemSimples = true;
        this.buttonAvancar = 'Finalizar';
        this.disableButtonAvancar = true;
        this.disableFiled = true;

        // this.showAvisoCelularSeguro = true;
        // this.AvisoCelularSeguro = '';
    }

    handleChangeOrigem(event) {
        this.valueOrigem = event.detail.value;
        this.valueCanal = null;
        this.verifyDesable();
    }

    handleChangeCanal(event) {
        this.valueCanal = event.detail.value;
        this.verifyDesable();
    }

    MontarJson() {
        this.DataNascimentoFormat = `${this.DataNascimento.substring(8, 10)}/${this.DataNascimento.substring(5, 7)}/${this.DataNascimento.substring(0, 4)}`;
        this.TelefoneResidencialFormat = this.TelefoneResidencial == '' ? '--' : this.TelefoneResidencial;
        this.NumeroCasaFormat = this.NumeroCasa == '' ? '--' : this.NumeroCasa;
        this.ComplementoFormat = this.Complemento == '' ? '--' : this.Complemento;

        let Cliente = {};

        let DadosGerais = {};
        let Contrato = {};
        let Documentos = {};
        let Endereco = {};
        let Contato = {};
        let Consentimentos = {};

        DadosGerais.primeiroNome = this.MudouPrimeiroNome ? this.PrimeiroNome : null;
        DadosGerais.nomeMeio = this.MudouNomeDoMeio ? this.NomeDoMeio : null;
        DadosGerais.sobrenome = this.MudouUltimoNome ? this.UltimoNome : null;
        DadosGerais.dataNascimento = this.MudouDataNascimento ? this.DataNascimentoFormat : null;
        DadosGerais.sexo = this.MudouGenero ? this.Genero : null;
        DadosGerais.estadoCivil = this.MudouEstadoCivil ? this.EstadoCivil : null;
        DadosGerais.nomeMae = this.MudouNomeMae ? this.NomeMae : null;
        DadosGerais.naturalidade = null;
        // DadosGerais.naturalidade                        = this.MudouNaturalidade                    ? this.Naturalidade                         : null;

        Contrato.numeroConta = this.NumeroConta;
        Documentos.rg = this.MudouRG ? this.returnApenasNumero(this.RG) : null;

        Endereco.cep = this.MudouCEP ? this.returnApenasNumero(this.CEP) : null;
        Endereco.logradouro = this.MudouRua ? this.Rua : null;
        Endereco.numero = this.MudouNumeroCasa ? this.NumeroCasa : null;
        Endereco.complemento = this.MudouComplemento ? this.Complemento : null;
        Endereco.bairro = this.MudouBairro ? this.Bairro : null;
        Endereco.cidade = this.MudouCidade ? this.Cidade : null;
        Endereco.uf = this.MudouEstado ? this.Estado : null;

        Contato.dddTelefoneResidencial = this.MudouTelefoneResidencial ? this.returnApenasNumero(this.TelefoneResidencial).substring(0, 2) : null;
        Contato.telefoneResidencial = this.MudouTelefoneResidencial ? this.returnApenasNumero(this.TelefoneResidencial).substring(2) : null;
        Contato.dddTelefoneCelular = this.MudouTelefone ? this.returnApenasNumero(this.Telefone).substring(0, 2) : null;
        Contato.telefoneCelular = this.MudouTelefone ? this.returnApenasNumero(this.Telefone).substring(2) : null;
        Contato.email = this.MudouEmail ? this.Email : null;

        Consentimentos.AceiteRecebimentoEmail = this.MudouAceiteRecebimentoEmail ? this.AceiteRecebimentoEmail : null;
        Consentimentos.IndicadorAceiteAtualizacaoLimite = this.MudouIndicadorAceiteAtualizacaoLimite ? this.IndicadorAceiteAtualizacaoLimite : null;


        Cliente.dadosGerais = DadosGerais;
        Cliente.contrato = Contrato;
        Cliente.documentos = Documentos;
        Cliente.endereco = Endereco;
        Cliente.contato = Contato;
        Cliente.consentimentos = Consentimentos;

        this.bodyRequestAlterarDados.cliente = Cliente;
    }

    async MontarObjAvaliacao() {
        await this.podeProsseguirStep02();
        let solicitouCartao = this.solicitacaoCartao == '1' ? 'Sim' : 'Não';

        this.objAvaliacaoInsert.MudouCPF = this.MudouCPF ? true : false;
        this.objAvaliacaoInsert.Complemento = this.MudouComplemento ? this.Complemento == '' ? null : this.Complemento : null;
        this.objAvaliacaoInsert.ComplementoOrigin = this.MudouComplemento ? this.ComplementoOrigin == '' ? null : this.ComplementoOrigin : null;
        this.objAvaliacaoInsert.Cidade = this.MudouCidade ? this.Cidade == '' ? null : this.Cidade : null;
        this.objAvaliacaoInsert.CidadeOrigin = this.MudouCidade ? this.CidadeOrigin == '' ? null : this.CidadeOrigin : null;
        this.objAvaliacaoInsert.Email = this.MudouEmail ? this.Email == '' ? null : this.Email : null;
        this.objAvaliacaoInsert.EmailOrigin = this.MudouEmail ? this.EmailOrigin == '' ? null : this.EmailOrigin : null;
        this.objAvaliacaoInsert.NumeroCasa = this.MudouNumeroCasa ? this.NumeroCasa == '' ? null : this.NumeroCasa : null;
        this.objAvaliacaoInsert.NumeroCasaOrigin = this.MudouNumeroCasa ? this.NumeroCasaOrigin == '' ? null : this.NumeroCasaOrigin : null;
        this.objAvaliacaoInsert.Bairro = this.MudouBairro ? this.Bairro == '' ? null : this.Bairro : null;
        this.objAvaliacaoInsert.BairroOrigin = this.MudouBairro ? this.BairroOrigin == '' ? null : this.BairroOrigin : null;
        this.objAvaliacaoInsert.UF = this.MudouEstado ? this.Estado == '' ? null : this.Estado : null;
        this.objAvaliacaoInsert.UFOrigin = this.MudouEstado ? this.EstadoOrigin == '' ? null : this.EstadoOrigin : null;
        this.objAvaliacaoInsert.Rua = this.MudouRua ? this.Rua == '' ? null : this.Rua : null;
        this.objAvaliacaoInsert.RuaOrigin = this.MudouRua ? this.RuaOrigin == '' ? null : this.RuaOrigin : null;
        this.objAvaliacaoInsert.CPF = this.MudouCPF ? this.CPF == '' ? null : this.returnApenasNumero(this.CPF) : null;
        this.objAvaliacaoInsert.CPFOrigin = this.MudouCPF ? this.CPFOrigin == '' ? null : this.returnApenasNumero(this.CPFOrigin) : null;
        this.objAvaliacaoInsert.CEPOrigin = this.MudouCEP ? this.CEPOrigin == '' ? null : this.returnApenasNumero(this.CEPOrigin) : null;
        this.objAvaliacaoInsert.CEP = this.MudouCEP ? this.CEP == '' ? null : this.returnApenasNumero(this.CEP) : null;
        this.objAvaliacaoInsert.TelefoneResidencial = this.MudouTelefoneResidencial ? this.TelefoneResidencial == '' ? null : this.returnApenasNumero(this.TelefoneResidencial) : null;
        this.objAvaliacaoInsert.TelefoneResidencialOrigin = this.MudouTelefoneResidencial ? this.TelefoneResidencialOrigin == '' ? null : this.returnApenasNumero(this.TelefoneResidencialOrigin) : null;
        this.objAvaliacaoInsert.TelefoneCelular = this.MudouTelefone ? this.Telefone == '' ? null : '55' + this.returnApenasNumero(this.Telefone) : null;
        this.objAvaliacaoInsert.TelefoneCelularOrign = this.MudouTelefone ? this.TelefoneOrigin == '' ? null : '55' + this.returnApenasNumero(this.TelefoneOrigin) : null;

        this.objAvaliacaoInsert.SolicitacaoCartao = this.MudouSolicitacaoCartao ? this.solicitacaoCartao == '' ? null : solicitouCartao : null;
        this.objAvaliacaoInsert.TelefoneContato = this.TelefoneOrigin == '' ? null : '55' + this.returnApenasNumero(this.TelefoneOrigin);
        this.objAvaliacaoInsert.IdConta = this.AccountId;
        this.objAvaliacaoInsert.IdContaFinanceira = this.recordId;
        this.objAvaliacaoInsert.IdCaso = this.caseId;
        // this.objAvaliacaoInsert.IdCaso                      = '5008B000003ZlpcQAC'; 
    }

    AlterarCPF() {
        this.step01 = false;
        this.step02 = false;
        this.step03 = false;
        this.ShowTelaErrorAPI = false;
        this.ShowAlterarTipoEnvio = false;
        this.ShowAlterarCPF = true;
        this.CPF = '';
        this.buttonAvancar = 'Finalizar';
        this.disableButtonAvancar = true;
    }

    handlerCPF(event) {
        try {
            let valueInput = this.returnApenasNumero(event.detail.value);

            if (valueInput.length > 3 && valueInput.length < 7) {
                this.CPF = valueInput.replace(/(\d{3})/, '$1.');
            } else if (valueInput.length >= 7 && valueInput.length < 10) {
                this.CPF = valueInput.replace(/(\d{3})(\d{3})/, '$1.$2.');
            } else if (valueInput.length == 10 || valueInput.length == 11) {
                this.CPF = valueInput.replace(/(\d{3})(\d{3})(\d{3})/, '$1.$2.$3-');
            }

            let cpfValido = this.validarCPF(valueInput);
            this.ShowErroCpfInvalido = !cpfValido;
            this.disableButtonAvancar = !cpfValido;
        } catch (error) {
            console.log('ERROR handlerCPF: ' + error);
        }
    }

    alterarTipoEnvio() {
        this.step01 = false;
        this.step02 = false;
        this.step03 = false;
        this.ShowTelaErrorAPI = false;

        this.ShowAlterarTipoEnvio = true;
        this.componenteAlteracaoCadastral = false;
    }

    async handleLocalizar() {
        this.showSpinner();
        await this.ObterEnderecoByCEP();
        this.podeProsseguirStep02().then(result => {
            this.disableButtonAvancar = !result;
        });
        this.disableFiled = this.ShowAlteracaoBlindagemSimples ? false : true;
        this.closeSpinner();
    }

    //#endregion

    //#region ######################################## INTERAÇÕES COM O USUÁRIO ########################################
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

    returnApenasNumero(valor) {
        return valor.replace(/\D/g, '');
    }

    formatDate(data) {
        var dia = data.getDate();
        var mes = data.getMonth() + 1;
        var ano = data.getFullYear();

        if (dia < 10) dia = '0' + dia;
        if (mes < 10) mes = '0' + mes;

        return dia + '/' + mes + '/' + ano;
    }

    verifyDesable() {
        if (this.valueOrigem == null || this.valueOrigem == undefined || this.valueOrigem == '' ||
            this.valueCanal == null || this.valueCanal == undefined || this.valueCanal == '') {

            this.disableButtonAvancar = true;
        } else {
            if (this.ShowAlteracaoBlindagemSimples) {
                this.podeProsseguirStep02().then(result => {
                    this.disableButtonAvancar = !result;
                });
            } else {
                this.disableButtonAvancar = false;
            }
        }
    }

    irCaso() {
        window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
    }

    irTelaErro() {
        this.disableButtonVoltar = true;
        this.buttonAvancar = 'Tentar novamente';
        this.podeCriarCaso = false;
        this.ShowTelaErrorAPI = true;
        this.step01 = false;
        this.step02 = false;
        this.step03 = false;
    }

    async podeProsseguirStep02() {
        try {
            let emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (this.ShowAlteracaoBlindagemSimples) {
                this.MudouCEP = (this.CEP.toUpperCase() != this.CEPOrigin.toUpperCase()) ? true : false;
                this.MudouRua = (this.Rua.toUpperCase() != this.RuaOrigin.toUpperCase()) ? true : false;
                this.MudouBairro = (this.Bairro.toUpperCase() != this.BairroOrigin.toUpperCase()) ? true : false;
                this.MudouCidade = (this.Cidade.toUpperCase() != this.CidadeOrigin.toUpperCase()) ? true : false;
                this.MudouEstado = (this.Estado.toUpperCase() != this.EstadoOrigin.toUpperCase()) ? true : false;
                this.MudouTelefone = (this.Telefone.toUpperCase() != this.TelefoneOrigin.toUpperCase()) ? true : false;
                this.MudouEmail = (this.Email.toUpperCase() != this.EmailOrigin.toUpperCase()) ? true : false;
                this.MudouNumeroCasa = (this.NumeroCasa.toUpperCase() != this.NumeroCasaOrigin.toUpperCase()) ? true : false;
                this.MudouComplemento = (this.Complemento.toUpperCase() != this.ComplementoOrigin.toUpperCase()) ? true : false;
                this.MudouTelefoneResidencial = (this.TelefoneResidencial.toUpperCase() != this.TelefoneResidencialOrigin.toUpperCase()) ? true : false;
                this.MudouAceiteRecebimentoEmail = (this.AceiteRecebimentoEmail != this.AceiteRecebimentoEmailOrigin) ? true : false;
                this.MudouIndicadorAceiteAtualizacaoLimite = (this.IndicadorAceiteAtualizacaoLimite != this.IndicadorAceiteAtualizacaoLimiteOrigin) ? true : false;
                this.MudouSolicitacaoCartao = (this.solicitacaoCartao != null && this.solicitacaoCartao != undefined && this.solicitacaoCartao != '') ? true : false;

                this.MostarSessao01 = this.MudouPrimeiroNome || this.MudouNomeDoMeio || this.MudouUltimoNome || this.MudouDataNascimento || this.MudouCPF || this.MudouRG || this.MudouGenero || this.MudouNaturalidade || this.MudouEstadoCivil || this.MudouNomeMae ? true : false;
                this.MostarSessao02 = this.MudouCEP || this.MudouRua || this.MudouNumeroCasa || this.MudouComplemento || this.MudouBairro || this.MudouCidade || this.MudouEstado ? true : false;
                this.MostarSessao03 = this.MudouTelefoneResidencial || this.MudouTelefone || this.MudouEmail ? true : false;
                this.MostarSessao04 = this.MudouAceiteRecebimentoEmail || this.MudouIndicadorAceiteAtualizacaoLimite ? true : false;

                let OuveMudanca = this.MudouAceiteRecebimentoEmail || this.MudouIndicadorAceiteAtualizacaoLimite || this.MudouCEP || this.MudouRua || this.MudouNumeroCasa || this.MudouComplemento || this.MudouBairro || this.MudouCidade || this.MudouEstado || this.MudouTelefoneResidencial || this.MudouTelefone || this.MudouEmail ? true : false;
                let PodeSeguir = this.CEP == '' || this.CEP == null || this.CEP == undefined || this.CEP == '-' || this.CEP == '--' || this.Rua == '' || this.Rua == null || this.Rua == undefined || this.Rua == '-' || this.Rua == '--' || this.Bairro == '' || this.Bairro == null || this.Bairro == undefined || this.Bairro == '-' || this.Bairro == '--' || this.Cidade == '' || this.Cidade == null || this.Cidade == undefined || this.Cidade == '-' || this.Cidade == '--' || this.Estado == '' || this.Estado == null || this.Estado == undefined || this.Estado == '-' || this.Estado == '--' || this.solicitacaoCartao == '' || this.solicitacaoCartao == null || this.solicitacaoCartao == undefined || this.solicitacaoCartao == '-' || this.solicitacaoCartao == '--' ? false : true;

                let primeiroResidencial = this.returnApenasNumero(this.TelefoneResidencial).substring(2, 3);
                if (this.MudouTelefoneResidencial && (primeiroResidencial == '0' || primeiroResidencial == '1' || primeiroResidencial == '6' || primeiroResidencial == '7' || primeiroResidencial == '8' || primeiroResidencial == '9')) {
                    this.TelefoneResidencialErro = true;
                    PodeSeguir = false;
                } else {
                    this.TelefoneResidencialErro = false;
                }

                if (this.returnApenasNumero(this.TelefoneResidencial).length != 10 && this.returnApenasNumero(this.TelefoneResidencial).length != 0) {
                    PodeSeguir = false;
                }

                let primeiroTelefone = this.returnApenasNumero(this.Telefone).substring(2, 3);
                if (this.MudouTelefone && (primeiroTelefone != '5' && primeiroTelefone != '6' && primeiroTelefone != '7' && primeiroTelefone != '8' && primeiroTelefone != '9')) {
                    this.TelefoneErro = true;
                    PodeSeguir = false;
                } else {
                    this.TelefoneErro = false;
                }

                if (this.returnApenasNumero(this.Telefone).length != 11) {
                    PodeSeguir = false;
                }

                if (this.Email.toUpperCase().includes('@ATACADAO') || this.Email.toUpperCase().includes('@ATACADÃO') || this.Email.toUpperCase().includes('@CARREFOUR')) {
                    this.ShowErroEmail = true;
                    PodeSeguir = false;
                } else {
                    this.ShowErroEmail = false;
                }

                if (!emailPattern.test(this.Email) && this.Email) {
                    PodeSeguir = false;
                }

                if (this.EmailOrigin && !this.Email) {
                    PodeSeguir = false;
                }

                if (this.MudouCEP && this.returnApenasNumero(this.CEP).length != 8) {
                    PodeSeguir = false;
                }

                if (this.RGOrigin && !this.RG) {
                    PodeSeguir = false;
                }

                if (this.valueOrigem == null || this.valueOrigem == undefined || this.valueOrigem == '' ||
                    this.valueCanal == null || this.valueCanal == undefined || this.valueCanal == '') {

                    PodeSeguir = false;
                }

                return (OuveMudanca && PodeSeguir && this.MudouSolicitacaoCartao);
            } else {
                this.MudouPrimeiroNome = (this.PrimeiroNome.toUpperCase() != this.PrimeiroNomeOrigin.toUpperCase()) ? true : false;
                this.MudouNomeDoMeio = (this.NomeDoMeio.toUpperCase() != this.NomeDoMeioOrigin.toUpperCase()) ? true : false;
                this.MudouUltimoNome = (this.UltimoNome.toUpperCase() != this.UltimoNomeOrigin.toUpperCase()) ? true : false;
                this.MudouDataNascimento = (this.DataNascimento.toUpperCase() != this.DataNascimentoOrigin.toUpperCase()) ? true : false;
                this.MudouCPF = (this.CPF.toUpperCase() != this.CPFOrigin.toUpperCase()) ? true : false;
                this.MudouRG = (this.RG.toUpperCase() != this.RGOrigin.toUpperCase()) ? true : false;
                this.MudouGenero = (this.Genero.toUpperCase() != this.GeneroOrigin.toUpperCase()) ? true : false;
                this.MudouNaturalidade = (this.Naturalidade.toUpperCase() != this.NaturalidadeOrigin.toUpperCase()) ? true : false;
                this.MudouEstadoCivil = (this.EstadoCivil.toUpperCase() != this.EstadoCivilOrigin.toUpperCase()) ? true : false;
                this.MudouNomeMae = (this.NomeMae.toUpperCase() != this.NomeMaeOrigin.toUpperCase()) ? true : false;
                this.MudouCEP = (this.CEP.toUpperCase() != this.CEPOrigin.toUpperCase()) ? true : false;
                this.MudouRua = (this.Rua.toUpperCase() != this.RuaOrigin.toUpperCase()) ? true : false;
                this.MudouBairro = (this.Bairro.toUpperCase() != this.BairroOrigin.toUpperCase()) ? true : false;
                this.MudouCidade = (this.Cidade.toUpperCase() != this.CidadeOrigin.toUpperCase()) ? true : false;
                this.MudouEstado = (this.Estado.toUpperCase() != this.EstadoOrigin.toUpperCase()) ? true : false;
                this.MudouTelefone = (this.Telefone.toUpperCase() != this.TelefoneOrigin.toUpperCase()) ? true : false;
                this.MudouEmail = (this.Email.toUpperCase() != this.EmailOrigin.toUpperCase()) ? true : false;
                this.MudouNumeroCasa = (this.NumeroCasa.toUpperCase() != this.NumeroCasaOrigin.toUpperCase()) ? true : false;
                this.MudouComplemento = (this.Complemento.toUpperCase() != this.ComplementoOrigin.toUpperCase()) ? true : false;
                this.MudouTelefoneResidencial = (this.TelefoneResidencial.toUpperCase() != this.TelefoneResidencialOrigin.toUpperCase()) ? true : false;
                this.MudouAceiteRecebimentoEmail = this.AceiteRecebimentoEmail != this.AceiteRecebimentoEmailOrigin ? true : false;
                this.MudouIndicadorAceiteAtualizacaoLimite = this.IndicadorAceiteAtualizacaoLimite != this.IndicadorAceiteAtualizacaoLimiteOrigin ? true : false;

                this.MostarSessao01 = this.MudouPrimeiroNome || this.MudouNomeDoMeio || this.MudouUltimoNome || this.MudouDataNascimento || this.MudouCPF || this.MudouRG || this.MudouGenero || this.MudouNaturalidade || this.MudouEstadoCivil || this.MudouNomeMae ? true : false;
                this.MostarSessao02 = this.MudouCEP || this.MudouRua || this.MudouNumeroCasa || this.MudouComplemento || this.MudouBairro || this.MudouCidade || this.MudouEstado ? true : false;
                this.MostarSessao03 = this.MudouTelefoneResidencial || this.MudouTelefone || this.MudouEmail ? true : false;
                this.MostarSessao04 = this.MudouAceiteRecebimentoEmail || this.MudouIndicadorAceiteAtualizacaoLimite ? true : false;

                let OuveMudanca = this.MudouAceiteRecebimentoEmail || this.MudouIndicadorAceiteAtualizacaoLimite || this.MudouPrimeiroNome || this.MudouNomeDoMeio || this.MudouUltimoNome || this.MudouDataNascimento || this.MudouCPF || this.MudouRG || this.MudouGenero || this.MudouNaturalidade || this.MudouEstadoCivil || this.MudouNomeMae || this.MudouCEP || this.MudouRua || this.MudouNumeroCasa || this.MudouComplemento || this.MudouBairro || this.MudouCidade || this.MudouEstado || this.MudouTelefoneResidencial || this.MudouTelefone || this.MudouEmail ? true : false;
                let PodeSeguir = this.PrimeiroNome == '' || this.UltimoNome == '' || this.DataNascimento == '' || this.CPF == '' || this.Genero == '' || this.EstadoCivil == '' || this.NomeMae == '' || this.PrimeiroNome == null || this.UltimoNome == null || this.DataNascimento == null || this.CPF == null || this.Genero == null || this.EstadoCivil == null || this.NomeMae == null || this.PrimeiroNome == '--' || this.UltimoNome == '--' || this.DataNascimento == '--' || this.CPF == '--' || this.Genero == '--' || this.EstadoCivil == '--' || this.NomeMae == '--' ? false : true;

                if (!this.ClienteBlindado) {
                    PodeSeguir = this.PrimeiroNome == '' || this.PrimeiroNome == null || this.PrimeiroNome == undefined || this.PrimeiroNome == '-' || this.PrimeiroNome == '--' || this.UltimoNome == '' || this.UltimoNome == null || this.UltimoNome == undefined || this.UltimoNome == '-' || this.UltimoNome == '--' || this.DataNascimento == '' || this.DataNascimento == null || this.DataNascimento == undefined || this.DataNascimento == '-' || this.DataNascimento == '--' || this.CPF == '' || this.CPF == null || this.CPF == undefined || this.CPF == '-' || this.CPF == '--' || this.Genero == '' || this.Genero == null || this.Genero == undefined || this.Genero == '-' || this.Genero == '--' || this.EstadoCivil == '' || this.EstadoCivil == null || this.EstadoCivil == undefined || this.EstadoCivil == '-' || this.EstadoCivil == '--' || this.NomeMae == '' || this.NomeMae == null || this.NomeMae == undefined || this.NomeMae == '-' || this.NomeMae == '--' || this.CEP == '' || this.CEP == null || this.CEP == undefined || this.CEP == '-' || this.CEP == '--' || this.Rua == '' || this.Rua == null || this.Rua == undefined || this.Rua == '-' || this.Rua == '--' || this.Bairro == '' || this.Bairro == null || this.Bairro == undefined || this.Bairro == '-' || this.Bairro == '--' || this.Cidade == '' || this.Cidade == null || this.Cidade == undefined || this.Cidade == '-' || this.Cidade == '--' || this.Estado == '' || this.Estado == null || this.Estado == undefined || this.Estado == '-' || this.Estado == '--' ? false : true;

                    let primeiroResidencial = this.returnApenasNumero(this.TelefoneResidencial).substring(2, 3);
                    if (this.MudouTelefoneResidencial && (primeiroResidencial == '0' || primeiroResidencial == '1' || primeiroResidencial == '6' || primeiroResidencial == '7' || primeiroResidencial == '8' || primeiroResidencial == '9')) {
                        this.TelefoneResidencialErro = true;
                        PodeSeguir = false;
                    } else {
                        this.TelefoneResidencialErro = false;
                    }

                    if (this.returnApenasNumero(this.TelefoneResidencial).length != 10 && this.returnApenasNumero(this.TelefoneResidencial).length != 0) {
                        PodeSeguir = false;
                    }

                    let primeiroTelefone = this.returnApenasNumero(this.Telefone).substring(2, 3);
                    if (this.MudouTelefone && (primeiroTelefone != '5' && primeiroTelefone != '6' && primeiroTelefone != '7' && primeiroTelefone != '8' && primeiroTelefone != '9')) {
                        this.TelefoneErro = true;
                        PodeSeguir = false;
                    } else {
                        this.TelefoneErro = false;
                    }

                    if (this.returnApenasNumero(this.Telefone).length != 11) {
                        PodeSeguir = false;
                    }

                    if (this.Email.toUpperCase().includes('@ATACADAO') || this.Email.toUpperCase().includes('@ATACADÃO') || this.Email.toUpperCase().includes('@CARREFOUR')) {
                        this.ShowErroEmail = true;
                        PodeSeguir = false;
                    } else {
                        this.ShowErroEmail = false;
                    }

                    if (!emailPattern.test(this.Email) && this.Email) {
                        PodeSeguir = false;
                    }

                    if (this.EmailOrigin && !this.Email) {
                        PodeSeguir = false;
                    }

                    if (this.MudouCEP && this.returnApenasNumero(this.CEP).length != 8) {
                        PodeSeguir = false;
                    }

                    if (!this.isOver18(this.DataNascimento)) {
                        PodeSeguir = false;
                    }

                    if (this.RGOrigin && !this.RG) {
                        PodeSeguir = false;
                    }
                }

                return (OuveMudanca && PodeSeguir);
            }
        } catch (error) {
            console.log('ERROR podeProsseguirStep02: ' + error);
        }

    }

    validarCPF(cpf) {
        // Remove caracteres não numéricos
        cpf = cpf.replace(/[^\d]+/g, '');

        // Verifica se o CPF tem 11 dígitos
        if (cpf.length !== 11) return false;

        // Verifica se todos os dígitos são iguais (ex: 111.111.111-11)
        if (/^(\d)\1+$/.test(cpf)) return false;

        // Valida primeiro dígito verificador
        let soma = 0;
        for (let i = 0; i < 9; i++) {
            soma += parseInt(cpf.charAt(i)) * (10 - i);
        }
        let resto = 11 - (soma % 11);
        let digito1 = resto >= 10 ? 0 : resto;

        // Valida segundo dígito verificador
        soma = 0;
        for (let i = 0; i < 10; i++) {
            soma += parseInt(cpf.charAt(i)) * (11 - i);
        }
        resto = 11 - (soma % 11);
        let digito2 = resto >= 10 ? 0 : resto;

        // Verifica se os dígitos verificadores são válidos
        return digito1 === parseInt(cpf.charAt(9)) && digito2 === parseInt(cpf.charAt(10));
    }

    isOver18(birthdate) {
        // Converte a data de nascimento para um objeto Date
        let birthDate = new Date(birthdate);

        // Obtém a data atual
        let today = new Date();

        // Calcula a diferença de anos entre a data atual e a data de nascimento
        let age = today.getFullYear() - birthDate.getFullYear();

        // Ajusta a idade caso o aniversário ainda não tenha ocorrido neste ano
        let monthDifference = today.getMonth() - birthDate.getMonth();
        if (monthDifference < 0 || (monthDifference === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }

        // Retorna true se a idade for 18 ou mais, caso contrário retorna false
        return age >= 18;
    }

    limitarTexto(texto, limite) {
        return texto.length > limite ? texto.substring(0, limite) : texto;
    }
    //#endregion
}