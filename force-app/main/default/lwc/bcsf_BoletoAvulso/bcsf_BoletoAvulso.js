import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import DRT from '@salesforce/schema/User.DRT__c';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getContaFinanceira from '@salesforce/apex/BoletoAvulsoController.getContaFinanceira';
import getPametrosIniciais from '@salesforce/apex/BoletoAvulsoController.obterParametrosIniciais';
import gerarBoletoAvulso from '@salesforce/apex/BoletoAvulsoController.gerarBoletoAvulso';
import enviarBoletos from '@salesforce/apex/BoletoAvulsoController.enviarBoleto';
import criarCaso from '@salesforce/apex/BoletoAvulsoController.criarCaso';
import atualizarEmail from '@salesforce/apex/BoletoAvulsoController.atualizarEmail';

import getAssetTitular from '@salesforce/apex/AlteracaoCadastralController.getAssetTitular';
import GetAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';

export default class Bcsf_BoletoAvulso extends LightningElement {

    @api recordId;

    @track buttonAvancar = 'Prosseguir';
    @track buttonVoltar = 'Voltar';
    @track step01 = true;
    @track step02 = false;
    @track step03 = false;
    @track spinner = false;
    @track stepBoletosAbertos = false;
    @track enviarEmailAlternativo = false;
    @track disableValorField = false;
    @track disableButtonAvancar = true;
    @track disableSetValorMaximo = false;
    @track emailNaoInformado = false;
    @track podeAtualizarEmail = false;
    @track checkAtualizarEmail;
    @track showSubTitle;
    @track showTextInfo;
    pdfUrl;
    fileBase64;

    dataAtual;
    accountId;
    @track ehValidado;
    @track ehBlindado;
    @track tipoConta = '-';
    @track logoTipo;
    @track numeroContaCliente;
    @track cpfCliente;
    @track unidadeNegocio;
    @track nomeTitular = '-';
    @track email = '-';
    @track emailLabel = '-';
    @track modoEnvio = 'E-mail';
    @track prazoEnvio = 'Imediato';
    @track tipoPagamento = 'Boleto';
    @track iconeOrdenacao = 'utility:arrowdown';
    @track iconeOrdenacaoSelected = 'utility:arrowdown';

    //dados boleto
    @track valorMinimo;
    @track valorMinimoFormatado = '-';
    @track valorMaximo;
    @track valorMaximoFormatado = '-';
    @track isValorMaximo = false;
    @track possuiBoleto = false;
    @track boletoValidos = [];
    @track valorNovoBoleto;
    @track valorNovoBoletoFormatado;
    @track diasAteVencimento;
    @track codigoBoleto = '--';
    @track dataVenciBoleto = '--'
    @track emailAlternativo = null;
    @track saldoDevedorInsuficiente = false;
    @track saldoDevedorInsuficienteRes = false;
    @track possuiBoletoAvulso = false;
    @track listBoletoAvulso = [];
    @track listBoletoAvulsoSelected = [];


    //dados caso e integração
    @track valueOrigem;
    @track valueCanal;
    @track valueEvento = "Antecipar fatura";
    @track area;
    @track drt;
    @track canal = "Cockpit";
    @track numProtocolo = '--';
    @track caseId;

    @track tempo;
    @track allowListProfiles;
    @track userProfileName;
    @track dataLimite;
    @track atendente;
    @track StatusConta;

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL, DRT] })
    currentUserInfo({ data }) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
            this.drt = data.fields.DRT__c.value;
        }
    }

   async connectedCallback() {
        await this.buscarDadosValidacao();
        this.spinnerShow();
        this.dataAtual = this.formatDate(Date.now());
        this.getInfosContaFinanceira();
    }

    getInfosContaFinanceira() {
        
        getContaFinanceira({
            recordId: this.recordId
        }).then(async result => {
            this.nomeTitular = result.Nome;
            this.email = result.Email;
            this.numeroContaCliente = result.NumeroConta;
            this.cpfCliente = result.CPF.replace(/\D/g, '');
            this.ehBlindado = result.ClienteBlindado;
            this.unidadeNegocio = result.UnidadeNegocio;
            this.podeAtualizarEmail = !(this.ehBlindado || this.ehValidado == "false")
            this.accountId = result.AccountId;
            await this.getLogo(result.UnidadeNegocio);
            await this.obterParametrosIniciais();
            
        }).catch(error => {
            console.log('Erro getInfosContaFinanceira: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }

    obterParametrosIniciais() {
        getPametrosIniciais({
            numeroConta: this.numeroContaCliente,
            cpf: this.cpfCliente,
            unidade: this.unidadeNegocio,
            canal: this.canal,
            sistema: this.area,
            area: this.area,
            loginOperador: this.drt
        }).then(result => {
            if (result.statusAPI == 'OK') {
                if (result.saldoDevedorInsuficiente) {
                    this.saldoDevedorInsuficiente = true;
                    this.saldoDevedorInsuficienteRes = true;
                    this.possuiBoletoAvulso = false;
                    this.valorMinimoFormatado = '-';
                    this.valorMaximoFormatado = '-';
                    this.tipoPagamento = '-';
                    this.disableValorField = true;
                    this.disableSetValorMaximo = true;
                    this.showTextInfo = false;
                } else {
                    this.showTextInfo = true;
                    this.valorMinimo = result.valorMinimo;
                    this.valorMinimoFormatado = this.formatValor(this.valorMinimo);
                    this.valorMaximo = result.valorMaximo;
                    this.valorMaximoFormatado = this.formatValor(this.valorMaximo);
                    this.possuiBoletoAvulso = result.boletosValidos.length > 0;
                    if (this.possuiBoletoAvulso) {
                        this.loadListBoletosAvulsos(result.boletosValidos)
                    }
                }
                this.spinnerClose();
            } else {
                this.showToast('Erro', 'Houve um erro ao buscar as informações para pagamento!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro obterParametrosIniciais: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar as informações para pagamento!', 'error', true);
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
                        console.log('ocultar botão');
                        this.ehValidado = "false";
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
                console.log('ocultar botão');
                this.ehValidado = "false";
            }, 1);
        }
    }
    AtualizarEmail() {
        this.spinnerShow();
        let emailSelecionado = this.enviarEmailAlternativo ? this.emailAlternativo : this.email;
        atualizarEmail({
            cpf: this.cpfCliente,
            unidade: this.unidadeNegocio,
            canal: this.canal,
            email: emailSelecionado,
            numeroConta: this.numeroContaCliente,
            area: this.area,
            sistema: this.area
        }).then(result => {
            if (result) {
                this.step01 = false;
                this.step02 = true;
                this.showSubTitle = false;
                this.saldoDevedorInsuficiente = this.saldoDevedorInsuficienteRes;
                this.disableButtonAvancar = !this.valueOrigem || !this.valueCanal ? true : false;
                this.buttonAvancar = 'Finalizar';
                this.emailNaoInformado = this.email == "--" && !this.enviarEmailAlternativo;
            } else {
                this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado do sistema, tente novamente em instantes.', 'error', false);
            }
            this.spinnerClose();
        }).catch(error => {
            console.log('Erro atualizarEmail: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao atualizar o E-mail!', 'error', true);
        });
    }

    EnviarBoletos() {
        this.spinnerShow();
        let emailSelecionado = this.enviarEmailAlternativo ? this.emailAlternativo : this.email;
        let listaIds = this.listBoletoAvulsoSelected.map(item => item.id);
        enviarBoletos({
            numeroConta: this.numeroContaCliente,
            cpf: this.cpfCliente,
            unidade: this.unidadeNegocio,
            canal: this.canal,
            email: emailSelecionado,
            idBoletos: listaIds,
            sistema: this.area,
            area: this.area,
            loginOperador: this.drt
        }).then(result => {
            if (result.statusAPI == 'OK') {
                this.step02 = false;
                this.step03 = true;
                this.buttonVoltar = "Fechar";
                this.buttonAvancar = "Ir para caso"
                this.CriarCaso();
            } else {
                this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado do sistema, tente novamente em instantes.', 'error', false);
                this.spinnerClose();
            }
        }).catch(error => {
            console.log('Erro EnviarBoletos: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao enviar boletos', 'error', true);
        });
    }


    GerarBoletoAvulso() {
        this.spinnerShow();
        let emailSelecionado = this.enviarEmailAlternativo ? this.emailAlternativo : this.email;
        gerarBoletoAvulso({
            numeroConta: this.numeroContaCliente,
            cpf: this.cpfCliente,
            unidade: this.unidadeNegocio,
            canal: this.canal,
            email: emailSelecionado == '--' || !emailSelecionado ? null : emailSelecionado,
            valorBoleto: this.valorNovoBoleto,
            tipoBoleto: 2,
            sistema: this.area,
            area: this.area,
            loginOperador: this.drt
        }).then(result => {
            if (result.statusAPI == 'OK') {
                this.codigoBoleto = result.linhaDigitavel;
                this.dataVenciBoleto = this.formatDate(result.dataVencimentoBoleto);
                this.fileBase64 = result.boletoPdf;
                this.diasAteVencimento = this.calcularDiasAteVencimento(result.dataVencimentoBoleto);
                this.step02 = false;
                this.step03 = true;
                this.buttonVoltar = "Fechar";
                this.buttonAvancar = "Ir para caso"
                this.CriarCaso();
            } else {
                this.showToast('Falha ao realizar a solicitação', 'Houve um comportamento inesperado do sistema, tente novamente em instantes.', 'error', false);
                this.spinnerClose();
            }
        }).catch(error => {
            console.log('Erro GerarBoleto: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao gerar boleto', 'error', true);
        });
    }

    CriarCaso() {
        criarCaso({
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal,
            tipo: 'Execução',
            assunto: "Fatura",
            evento: this.valueEvento
        }).then((result) => {
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.spinnerClose();
        }).catch(error => {
            console.log('Erro CriarCaso: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao Criar Caso', 'error', true);
        });
    }

    loadListBoletosAvulsos(boletos) {
        this.listBoletoAvulso = boletos.map(item => ({
            id: item.id,
            dataEmissao: this.formatDate(item.dataEmissao),
            dataVencimento: this.formatDate(item.dataVencimento),
            dataVencimentoLabel: this.formatDate(item.dataVencimento, false),
            valor: this.formatValor(item.valorBoleto),
            linhaDigitavel: item.linhaDigitavel.replace(/\s+/g, '.'),
            checked: false
        }))

        this.listBoletoAvulso = this.listBoletoAvulso.sort((a, b) => new Date(a.dataEmissao) - new Date(b.dataEmissao));
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
            this.closeQuickAction();
        }
    }

    getLogo(unidade) {
        if (unidade == "1") {
            this.tipoConta = 'CARREFOUR';
            this.logoTipo = LogoCarrefour;
        } else if (unidade == "2") {
            this.tipoConta = 'ATACADÃO';
            this.logoTipo = LogoAtacadao;
        } else if (unidade == "6") {
            this.tipoConta = "SAM'S CLUB";
            this.logoTipo = LogoSamsClub;
        }
    }

    formatValor(valor) {
        return Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL'
        }).format(valor);
    }

    formatDate(date) {
        const data = new Date(date);
        const dia = String(data.getDate()).padStart(2, '0');
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const ano = data.getFullYear();
        return `${dia}/${mes}/${ano}`;
    }

    changeValueHandler(event) {
        this.valorNovoBoleto = event.target.value;
        this.valorNovoBoletoFormatado = this.formatValor(this.valorNovoBoleto);
        if (this.valorNovoBoleto) {
            if (!this.enviarEmailAlternativo) {
                this.disableButtonAvancar = false;
            } else if (this.enviarEmailAlternativo && this.emailAlternativo != null) {
                this.disableButtonAvancar = false;
            }
        } else {
            this.disableButtonAvancar = true;
        }

        if (!this.disableButtonAvancar) {
            const casasDecimais = this.valorNovoBoleto.toString().split('.');
            this.disableButtonAvancar = !(this.valorNovoBoleto >= this.valorMinimo && this.valorNovoBoleto <= this.valorMaximo);
            this.disableButtonAvancar = !this.disableButtonAvancar && (casasDecimais.length > 1 && casasDecimais[1].length > 2) ? true : this.disableButtonAvancar;
        }

    }

    setValorMaximo(event) {
        if (event.target.checked) {
            this.valorNovoBoleto = this.valorMaximo;
            this.valorNovoBoletoFormatado = this.formatValor(this.valorNovoBoleto);
            this.isValorMaximo = true;
            this.disableValorField = true;
            if (!this.enviarEmailAlternativo) {
                this.disableButtonAvancar = false;
            } else if (this.enviarEmailAlternativo && this.emailAlternativo != null) {
                this.disableButtonAvancar = false;
            }
        } else {
            this.disableValorField = false;
            this.isValorMaximo = false;
        }
    }

    emailAlternativoHandler(event) {
        if (event.target.checked) {
            this.enviarEmailAlternativo = true;
            if (this.valorNovoBoleto && this.emailAlternativo) {
                this.disableButtonAvancar = false;
            } else {
                this.disableButtonAvancar = true;
            }
        } else {
            this.enviarEmailAlternativo = false;
            this.disableButtonAvancar = this.valorNovoBoleto ? false : true;
        }
    }

    atualizarEmailHandler(event) {
        this.checkAtualizarEmail = event.target.checked;
        if (this.checkAtualizarEmail) {
            this.valueEvento = "Antecipar fatura - Alteração e-mail";
        } else {
            this.valueEvento = "Antecipar fatura";
        }
    }

    changeEmailHandler(event) {
        this.emailAlternativo = event.target.value;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        this.disableButtonAvancar = true;
        if ((this.valorNovoBoleto || this.stepBoletosAbertos) && emailRegex.test(this.emailAlternativo)) {
            this.disableButtonAvancar = false;
        }
    }

    changeOrigemHandler(event) {
        this.valueOrigem = event.target.value;
        this.disableButtonAvancar = this.valueCanal && this.valueOrigem ? false : true;
    }

    changeCanalHandler(event) {
        this.valueCanal = event.target.value;
        this.disableButtonAvancar = this.valueCanal && this.valueOrigem ? false : true;
    }

    handleBtnVerBoletosGerados() {
        this.stepBoletosAbertos = true;
        this.possuiBoletoAvulso = false;
        this.saldoDevedorInsuficiente = false;
        this.podeAtualizarEmail = true;
        this.showSubTitle = true;
        this.showTextInfo = false;
        this.disableButtonAvancar = this.listBoletoAvulsoSelected.length == 0 ? true : false;
    }

    handleOpenPdf() {
        if (this.fileBase64) {
            const byteCharacters = atob(this.fileBase64);
            const byteNumbers = Array.from(byteCharacters).map(char => char.charCodeAt(0));
            const byteArray = new Uint8Array(byteNumbers);
            const blob = new Blob([byteArray], { type: 'application/pdf' });
            const pdfUrl = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = pdfUrl;
            link.target = '_blank';
            link.click();
            setTimeout(() => URL.revokeObjectURL(pdfUrl), 5000);
        }
    }

    handleProsseguir() {
        if (this.step01) {
            this.showTextInfo = true;
            this.emailLabel = this.enviarEmailAlternativo ? this.emailAlternativo : this.email;
            if (this.checkAtualizarEmail && this.enviarEmailAlternativo) {
                this.AtualizarEmail();
            } else {
                this.step01 = false;
                this.step02 = true;
                this.showSubTitle = false;
                this.saldoDevedorInsuficiente = this.saldoDevedorInsuficienteRes;
                this.disableButtonAvancar = !this.valueOrigem || !this.valueCanal ? true : false;
                this.buttonAvancar = 'Finalizar';
                this.emailNaoInformado = this.email == "--" && !this.enviarEmailAlternativo;
            }
        } else if (this.step02) {
            if (this.stepBoletosAbertos) {
                this.EnviarBoletos();
            } else {
                this.GerarBoletoAvulso();
            }
        } else {
            window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
        }
    }

    handleButtonVoltar() {
        if (this.step01) {
            if (this.stepBoletosAbertos) {
                this.stepBoletosAbertos = false;
                this.possuiBoletoAvulso = true;
                this.showSubTitle = false;
                this.saldoDevedorInsuficiente = this.saldoDevedorInsuficienteRes;
                this.disableButtonAvancar = this.valorNovoBoleto ? false : true;
                this.showTextInfo = this.saldoDevedorInsuficiente || this.stepBoletosAbertos ? false : true;
                this.podeAtualizarEmail = !(this.ehBlindado || this.ehValidado == "false")
            } else {
                this.closeQuickAction();
            }
        } else if (this.step02) {
            this.step01 = true;
            this.step02 = false;
            this.showSubTitle = this.stepBoletosAbertos;
            this.buttonAvancar = 'Prosseguir';
            this.disableButtonAvancar = false;
            this.valueCanal = '';
            this.valueOrigem = '';
            this.saldoDevedorInsuficiente = this.saldoDevedorInsuficienteRes;
            this.showTextInfo = this.saldoDevedorInsuficiente || this.stepBoletosAbertos ? false : true;
        } else if (this.step03) {
            this.closeQuickAction();
        }
    }

    handleCheckTransaction(event) {
        const itemId = event.target.dataset.id;
        this.listBoletoAvulso = this.listBoletoAvulso.map(item => {
            if (item.id == parseInt(itemId, 10)) {
                const updatedItem = { ...item, checked: event.target.checked };
                if (event.target.checked) {
                    this.listBoletoAvulsoSelected.push(updatedItem);
                } else {
                    this.listBoletoAvulsoSelected = this.listBoletoAvulsoSelected.filter(selItem => selItem.id != itemId);
                }
                return updatedItem;
            }
            return item;
        });
        this.listBoletoAvulsoSelected = this.listBoletoAvulsoSelected.sort((a, b) => new Date(a.dataEmissao) - new Date(b.dataEmissao));
        this.disableButtonAvancar = this.listBoletoAvulsoSelected.length == 0 ? true : false;

    }

    handleAlternarOrdenacao() {
        if (this.step01) {
            this.iconeOrdenacao = this.iconeOrdenacao == 'utility:arrowdown' ? 'utility:arrowup' : 'utility:arrowdown';
            this.listBoletoAvulso.reverse();
        } else {
            this.iconeOrdenacaoSelected = this.iconeOrdenacaoSelected == 'utility:arrowdown' ? 'utility:arrowup' : 'utility:arrowdown';
            this.listBoletoAvulsoSelected.reverse();
        }
    }

    handleCopiarBoletoGerado(event) {
        const textBtn = event.target.getAttribute('data-text');
        let formattedText;

        if (textBtn == 'gerado') {
            formattedText = `Código de barras:\n${this.codigoBoleto}\n`;
            formattedText += `\nValor:\n${this.valorNovoBoletoFormatado}\n`;
            formattedText += `\nVencimento:\n${this.dataVenciBoleto}`;
        } else {
            const item = this.listBoletoAvulsoSelected.find(obj => obj.id == textBtn);
            formattedText = `Código de barras:\n${item.linhaDigitavel}\n`;
            formattedText += `\nValor:\n${item.valor}\n`;
            formattedText += `\nVencimento:\n${item.dataVencimento}`;
        }
        const textarea = document.createElement('textarea');
        textarea.value = formattedText;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
    }

    closeQuickAction() {
        this.dispatchEvent(new CustomEvent('closeparentmodal'))
    }

    calcularDiasAteVencimento(vencimento) {
        const hoje = new Date();
        const dataVencimento = new Date(vencimento);
        const diferencaMs = dataVencimento - hoje;

        // Converte a diferença para dias (1 dia = 24h * 60m * 60s * 1000ms)
        const diasRestantes = Math.ceil(diferencaMs / (1000 * 60 * 60 * 24));
        return diasRestantes;
    }

    spinnerShow() {
        this.spinner = true;
    }
    spinnerClose() {
        this.spinner = false;
    }
}