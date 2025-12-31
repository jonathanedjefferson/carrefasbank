import { LightningElement, track, wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';

import USER_ID from '@salesforce/user/Id';
import USERPROFILE_ID from '@salesforce/schema/User.Profile.Name';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';
import styles from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import getAcessoPerfil from '@salesforce/apex/BCSF_CadastroCelularSeguroController.getAcessoPerfil';
import usuarioPossuiPermissao from '@salesforce/apex/BCSF_CadastroCelularSeguroController.usuarioPossuiPermissao';
import getContaFinanceira from '@salesforce/apex/BCSF_CadastroCelularSeguroController.getContaFinanceira';
import criarCaso from '@salesforce/apex/BCSF_CadastroCelularSeguroController.criarCaso';
import gravarCelularSeguro from '@salesforce/apex/BCSF_CadastroCelularSeguroController.gravarCelularSeguro';
import getAssetTitular from '@salesforce/apex/AlteracaoCadastralController.getAssetTitular';

import GetAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';
export default class Bcsf_CadastroCelularSeguro extends LightningElement {

    value = '';
    cenarioSelecionado;
    recordId;
    @track spinner;
    @track showMotivo = false;
    @track disabledBtnPross = true;
    @track labelBtnPross = 'Prosseguir';
    @track labelBtnVoltar = 'Voltar';
    @track pageCenarios;
    @track pageSolicitarCaso;
    @track pageConfirmarDados;
    @track pageCasoGerado;

    ddd;
    @track telefone;
    canalCaso;
    origemCaso;
    motivo;
    dataAtualFormatada
    caseId;
    perfil
    acessoPerfil;
    perfilFraude;
    @track numProtocolo;
    @track evento = 'Cadastro de celular seguro';
    @track textCasoGerado = 'Cadastro de celular seguro realizado!';
    @track acountId;
    @track nomeCliente;
    @track tipoConta;
    @track logoTipo;
    @track unidadeNegocio;
    @track numeroConta;

    @track statusCartaoPrimario;
    @track statusConta;
    @track telefoneAntigo;
    @track telefoneCompleto;
    @track celularSeguro;
    @track cpf;
    @track cpfFormatado;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USERPROFILE_ID] })
    userDetails({ error, data }) {
        if (data) {
            this.perfil = data.fields.Profile.value.fields.Name.value;

            this.GetAcessoPerfil();
        } else if (error) {
            console.log("Error ao identificar perfil: " + JSON.stringify(error));
        }
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, styles)
        ]).catch(error => {
            console.log("Error rendered: " + error.body.message);
        });
    }

    async GetAcessoPerfil() {
        this.spinnerOpen();
        await this.buscarDadosValidacao();
        getAcessoPerfil({
            label: this.perfil
        }).then((result) => {
            if (result) {
                this.perfilFraude = result.Acesso__c === 'Cadastrar celular seguro';
                this.acessoPerfil = result.Acesso__c;
                let permissionStes = result.PermissionSets__c
                if (permissionStes && this.perfilFraude) {
                    this.UsuarioPossuiPermissao(permissionStes.replace(/\s/g, '').split(';'));
                } else {
                    this.GetContaFinanceira();
                }
            } else {
                this.showToast('', 'Usuário não possui acesso!', 'error', true);
            }
        }).catch((error) => {
            console.log('Erro GetAcessoPerfil: ', error.message);
            this.showToast('', 'Não foi possível carregar as informações!', 'error', true);
        });
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
            this.StatusConta = result.statusConta 
            console.log('result: ', result);

        } catch (error) {
            console.error('❌ Erro ao buscar dados:', error);
        }
        await this.getAssetTitular();
        await this.handleContaValidada();
    }
    handleContaValidada() {
        let ContaCartaoNORM = this.statusCartaoPrimario === this.StatusConta &&
            this.statusCartaoPrimario === 'NORM';
        console.log('ContaCartaoNORM: ' + ContaCartaoNORM);
        console.log('statusCartaoPrimario: ' + this.statusCartaoPrimario);
        console.log('StatusConta : ' + this.StatusConta);
        if (this.allowListProfiles.includes(this.userProfileName)) {
            switch (ContaCartaoNORM) {
                case true:
                    console.log('Conta norm')
                    if (this.atendente == undefined || this.dataLimite == undefined) {
                        this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
                        console.log('Fechando modal por falta de dados de validação...');
                        this.dispatchEvent(new CloseActionScreenEvent());
                    } else {
                        console.log('Chamando validação de tempo ')
                        this.validarTempoExpirado(this.dataLimite);
                    }

                    break;
                case false:
                    break;
            }
        }

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
                this.dispatchEvent(new CloseActionScreenEvent());
            }, 1);
        } else {
            console.log('✅ Dentro do tempo limite. Mantendo modal aberto. ');
        }
    }

    UsuarioPossuiPermissao(listaPermissoes) {
        usuarioPossuiPermissao({ permissoesPermitidas: listaPermissoes })
            .then(result => {
                if (result) {
                    this.GetContaFinanceira();
                } else {
                    this.perfilFraude = false
                    this.GetContaFinanceira();
                }
            })
            .catch(error => {
                console.error('Erro ao validar permissões:', error);
            });
    }

    GetContaFinanceira() {
        this.spinnerOpen();
        getContaFinanceira({
            idContaFinanceira: this.recordId
        }).then((result) => {
            this.acountId = result.NomeCliente__c || '-';
            this.nomeCliente = result.NomeCliente__r.Name || '-';
            this.unidadeNegocio = result.UnidadeNegocio__c || '-';
            this.numeroConta = result.NumeroConta__c || '-';
            this.statusConta = result.StatusConta__c || '-';
            this.cpf = result.NomeCliente__r.CPF__c || '-';
            this.telefoneAntigo = this.formatarTelefone(result.Telefone__c);
            this.cpfFormatado = this.formatarCPF(result.NomeCliente__r.CPF__c);
            this.celularSeguro = result.CelularSeguro__c ? 'Sim' : 'Não';
            this.pageCenarios = !this.perfilFraude;
            this.pageSolicitarCaso = this.perfilFraude;
            this.getLogo(this.unidadeNegocio);
            this.spinnerClose();
        }).catch((erro) => {
            console.log('Erro GetContaFinanceira: ' + erro.message);
            this.showToast('', 'Não foi possível carregar as informações', 'error', true);
        });
    }

    CriarCaso() {
        this.spinnerOpen();
        criarCaso({
            telefone: this.telefoneCompleto,
            telefoneAntigo: this.limparTelefone(this.telefoneAntigo),
            contaFinanceiraId: this.recordId,
            accountId: this.acountId,
            cenario: this.cenarioSelecionado,
            unidadeNegocio: this.unidadeNegocio,
            cpf: this.cpf,
            origem: this.origemCaso,
            canal: this.canalCaso
        }).then(result => {
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.pageCenarios = false;
            this.pageSolicitarCaso = false;
            this.pageConfirmarDados = false;
            this.pageConfirmarDados = false;
            this.pageCasoGerado = true;
            this.dataAtualFormatada = this.formatDate(new Date()).split(' ')[0];
            this.labelBtnPross = 'Ir para o caso';
            this.labelBtnVoltar = 'Fechar';
            this.dispatchEvent(new RefreshEvent());
            this.spinnerClose();
        }).catch(error => {
            console.log('Erro getCriarCaso: ' + error.message);
            this.showToast('', 'Não foi possível carregar as informações', 'error', true);
        });
    }

    GravarCelularSeguro() {
        this.spinnerOpen();
        gravarCelularSeguro({
            cpf: this.cpf,
            numeroCelular: this.telefoneCompleto.replace(/\D/g, ''),
            numeroConta: this.numeroConta,
            idEmpresa: this.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if (result) {
                this.CriarCaso();
            } else {
                this.spinnerClose();
                throw new Error("celular não cadastrado");
            }
        }).catch(error => {
            console.log('Erro ao cadastrar celular: ' + error.message);
            this.showToast('', 'Não foi possível carregar as informações', 'error', true);
        });
    }

    handleBtnVoltar() {
        if (this.pageSolicitarCaso && !this.perfilFraude) {
            this.pageSolicitarCaso = false;
            this.pageCenarios = true;
            this.disabledBtnPross = true;
            this.motivo = '';
            this.ddd = '';
            this.telefone = '';
            this.canalCaso = '';
            this.origemCaso = ''
        } else if (this.pageConfirmarDados) {
            this.pageConfirmarDados = false;
            this.pageSolicitarCaso = true;
            this.labelBtnPross = 'Prosseguir';
        } else {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        this.validarBtnPross();
    }

    handleBtnPross() {
        if (this.pageCenarios) {
            if (this.cenarioSelecionado === 'cenario1') {
                this.origemCaso = 'Pós Vendas';
                this.canalCaso = 'Voz';
                this.CriarCaso();
            } else {
                this.pageCenarios = false;
                this.pageSolicitarCaso = true;
                this.disabledBtnPross = true;
                this.validarBtnPross();
            }
        } else if (this.pageSolicitarCaso && !this.perfilFraude) {
            this.pageSolicitarCaso = false;
            this.pageConfirmarDados = true;
            this.labelBtnPross = 'Finalizar';
            this.telefoneCompleto = this.formatarTelefone(this.ddd + this.telefone);
        } else if (this.pageSolicitarCaso && this.perfilFraude) {
            this.telefoneCompleto = this.formatarTelefone(this.ddd + this.telefone);
            this.GravarCelularSeguro();
        } else if (this.pageConfirmarDados) {
            this.CriarCaso();
        } else {
            window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
        }
    }

    handleCenarioChange(event) {
        this.cenarioSelecionado = event.target.value;
        this.motivo = '';
        this.disabledBtnPross = false;
        this.showMotivo = true;
        this.textCasoGerado = 'Cliente informado sobre celular seguro!'
        this.evento = 'Informação sobre celular seguro';

        if (this.cenarioSelecionado === 'cenario2') {
            this.evento = 'Cadastro de celular seguro';
            this.motivo = "Não aceitou ir até a loja mais próxima"
            this.textCasoGerado = 'Solicitação de cadastro de celular seguro realizada!'
        } else if (this.cenarioSelecionado === 'cenario3') {
            this.evento = 'Cadastro de celular seguro';
            this.motivo = "Não possui loja próxima"
            this.textCasoGerado = 'Solicitação de cadastro de celular seguro realizada!'
        }
    }

    handleField(event) {
        const name = event.target.name;
        this[name] = event.target.value;
        this.validarFieldsTelefone(name);
    }

    getLogo(unidade) {
        if (unidade === "1") {
            this.tipoConta = 'CARREFOUR';
            this.logoTipo = LogoCarrefour;
        } else if (unidade === "2") {
            this.tipoConta = 'ATACADÃO';
            this.logoTipo = LogoAtacadao;
        } else if (unidade === "6") {
            this.tipoConta = "SAM'S CLUB";
            this.logoTipo = LogoSamsClub;
        }
    }

    validarFieldsTelefone(name) {
        this.disabledBtnPross = false;
        const regexDDD = /^\d+$/;
        const regexTelefone = /^[\d-]+$/;
        const input = name === 'ddd' ? this.template.querySelector('[data-name="ddd"]') : this.template.querySelector('[data-name="telefone"]');
        input.setCustomValidity('');

        if (!regexDDD.test(this.ddd) && this.ddd) {
            input.setCustomValidity(' ');
            this.disabledBtnPross = true;
        }

        if (this.telefone && !this.disabledBtnPross) {
            if (!regexTelefone.test(this.telefone)) {
                input.setCustomValidity(' ');
                this.disabledBtnPross = true;
            }

            const qtdDigitos = this.telefone.replace(/[^0-9]/g, '').length;
            if (qtdDigitos < 9 && !this.disabledBtnPross) {
                this.disabledBtnPross = true;
            }

            if (this.telefone[0] !== '9' && !this.disabledBtnPross) {
                input.setCustomValidity(' ');
                this.disabledBtnPross = true;
            }
        }
        if (this.disabledBtnPross) {
            input.reportValidity();
        }

        if ((!this.canalCaso || !this.origemCaso || !this.ddd || !this.telefone) && !this.disabledBtnPross) {
            this.disabledBtnPross = true;
        }

        this.fieldsPossuiErro = this.disabledBtnPross;
    }

    validarBtnPross() {
        this.disabledBtnPross = true;
        if (this.pageCenarios && this.motivo) {
            this.disabledBtnPross = false;
        }

        if (this.pageSolicitarCaso && !this.fieldsPossuiErro && (this.canalCaso || this.origemCaso || this.ddd || this.telefone)) {
            this.disabledBtnPross = false;
        }
    }

    formatarCPF(cpf) {
        if (!cpf) return '';

        const cpfNumeros = cpf.replace(/\D/g, '');
        if (cpfNumeros.length !== 11) {
            return cpf;
        }

        return cpfNumeros.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    }

    formatarTelefone(telefone) {
        if (!telefone) return '';

        const numeros = telefone.replace(/\D/g, '');

        if (/^\+55 \d{2} \d{5}-\d{4}$/.test(telefone) || /^\(\d{2}\) \d{4,5}-\d{4}$/.test(telefone)) {
            return telefone;
        }

        if (numeros.length === 13) {
            const ddi = numeros.substring(0, 2);
            const ddd = numeros.substring(2, 4);
            const primeiro = numeros.length === 13 ? numeros.substring(4, 9) : numeros.substring(4, 8);
            const segundo = numeros.substring(9);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }

        if (numeros.length === 11) {
            const ddd = numeros.substring(0, 2);
            const primeiro = numeros.substring(2, 7);
            const segundo = numeros.substring(7);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }

        if (numeros.length === 10) {
            const ddd = numeros.substring(0, 2);
            const primeiro = numeros.substring(2, 6);
            const segundo = numeros.substring(6);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }

        return telefone;
    }

    limparTelefone(telefone) {
        return telefone.replace(/\D/g, '');
    }

    formatDate(dataString) {
        if (!dataString) return '';
        const data = new Date(dataString);
        return data.toLocaleString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        }).replace(',', '');
    }

    showToast(titulo, mensagem, variante, close) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if (close) {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    spinnerClose() {
        this.spinner = false;
    }

    spinnerOpen() {
        this.spinner = true;
    }
}