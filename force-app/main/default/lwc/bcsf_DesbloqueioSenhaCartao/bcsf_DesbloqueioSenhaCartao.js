import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import tratarAsset from '@salesforce/apex/AlteracaoVencimentoController.tratarAsset';
import getContaFinanceira from '@salesforce/apex/DesbloqueioSenhaCartaoController.getContaFinanceira';
import createCaseDesbloqueioSenhaCartao from '@salesforce/apex/DesbloqueioSenhaCartaoController.createCaseDesbloqueioSenhaCartao';
import GetListaCartaoDesbloqueioSenha from '@salesforce/apex/DesbloqueioSenhaCartaoController.GetListaCartaoDesbloqueioSenha';
import DesbloquearSenhaCartao from '@salesforce/apex/DesbloqueioSenhaCartaoController.DesbloquearSenhaCartao';

export default class BCSF_DesbloqueioSenhaCartao extends LightningElement {
    
    //#region Variaveis 
    spinner = false;
    optionsCartoes = [];
    canal = 'cockpit';
    sistema = 'cockpit';
    areaPrincipal = null;
    msgAlertCartoes = "Lembre-se de que o cliente tem mais cartões bloqueados devido a tentativas incorretas de senha. O desbloqueio pode ser efetuado após a conclusão desta solicitação.";
    msgAlertSemCartoes = "O cliente não possui nenhum cartão com a senha bloqueada devido a tentativas incorretas.";
    msgAlertUmCartao = "O cliente possui apenas um cartão com a senha bloqueada. Ao prosseguir, será iniciado o processo de desbloqueio!";
    closeModalComponent = true;
    
    @api recordId;
    date = new Date();
    month = (this.date.getMonth() + 1) < 10 ? '0'+(this.date.getMonth() + 1) : (this.date.getMonth() + 1);
    @track dateToday = this.date.getDate() + '/' + this.month + '/' + this.date.getFullYear();
    
    @track showCardPrincipal = false;
    @track stepOne = true;
    @track stepTwo = false;
    @track stepThree = false;
    @track showVoltar = true;
    @track falhaDesbloqueio = false;

    @track numeroConta = '--';
    @track nome = '--';
    @track cpf = '';
    @track dataNascimento = '';
    @track statusConta = '--';
    @track produto = '--'
    @track possuiCelularSeguro = '--';
    @track idEmpresa = null;
    @track accountId = null;
    @track origemValue;
    @track canalValue;
    
    @track disableButtonVoltar = false;
    @track disableButtonProsseguir = true;
    @track disableButtonFinalizar = true;
    @track possuiUmCartaoBloqueado = false;
    @track possuiCartoesBloqueados = false;
    @track naoPossuiCartaoBloqueado = false;
    @track abrirReimprimirSenha = false;

    idSernoCartao = "";
    numeroCartaoOfuscado = "";
    wrongPinRetries = "";
    numeroProtocolo = "";
    idCaso = null;
    dataAberturaCaso = "";

    //#endregion

    //#region wire's

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.areaPrincipal = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }

    //#endregion

    async connectedCallback() {
        this.showSpinner();
        await this.getDadosContaFinanceira();
        await this.getDadosAsset();
        this.closeSpinner();
    }

    async getDadosContaFinanceira() {
        await getContaFinanceira({ recordId: this.recordId })
            .then(result => {
                this.cpf = result.CPF;
                this.numeroConta = result.NumeroConta;
                this.idEmpresa = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.statusConta = result.StatusConta;
                this.nome = result.Nome
                this.dataNascimento = result.DataNascimento;
                this.possuiCelularSeguro = result.CelularSeguro;

                this.carregarCartoesComSenhaBloqueada();
            })
            .catch(error => {
                console.log(error);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
            });
    }

    async getDadosAsset(){
        await tratarAsset({
            contaFinanceiraId: this.recordId
        }).then(resultAsset => {
            try {
                this.produto = resultAsset.ProductName;
            } catch (error) {
                console.log('Erro catch() tratarAsset: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro tratarAsset: '+ error);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }

   //#region métodos handle

    handleButtonVoltar(event) {
        if(this.stepOne){
            this.closeQuickAction();
        } else if(this.stepTwo){
            this.stepTwo = false;
            this.stepOne = true;
            this.disableButtonFinalizar = true;

            if(this.possuiUmCartaoBloqueado){
                this.disableButtonProsseguir = false;
            } else{
                this.disableButtonProsseguir = true;
            }
        }
    }

    handleButtonProsseguir(event) {
        this.numeroCartaoOfuscado = '';
        this.wrongPinRetries = '';

        this.optionsCartoes.forEach(item => {
            if(item.numeroCartaoSerno == this.idSernoCartao){
                this.numeroCartaoOfuscado = item.numeroCartaoOfuscado;
                this.wrongPinRetries = item.wrongPinRetries;
            }
        });

        this.disableButtonProsseguir = true;
        this.disableButtonFinalizar = true;
        this.showVoltar = true;
        this.stepOne = false;
        this.stepTwo = true;
        this.stepThree = false;
        this.verifyDisabled();
    }

    async handleButtonFinalizar(event) {
        this.showSpinner(); 
        await this.desbloquearSenhaCartao();

        if(this.sucessoDesbloquearSenha){
            await this.CriarCaso();

            if(this.idCaso != null){
                this.disableButtonProsseguir = true;
                this.disableButtonFinalizar = true;
                this.stepOne = false;
                this.stepTwo = false;
                this.stepThree = true;
                this.showVoltar = false;
                this.falhaDesbloqueio = false;
            }
        } else {
            this.stepOne = false;
            this.stepTwo = false;
            this.stepThree = false;
            this.falhaDesbloqueio = true;
            this.disableButtonVoltar = true;
        }

        this.closeSpinner();
    }

    async handleButtonInicio(event) {
        this.showSpinner();
        this.showCardPrincipal = true;
        this.showVoltar = true;
        this.disableButtonVoltar = false;
        this.possuiUmCartaoBloqueado = false;
        this.possuiCartoesBloqueados = false;
        this.naoPossuiCartaoBloqueado = false;
        this.idSernoCartao = "";
        this.numeroCartaoOfuscado = "";
        this.wrongPinRetries = "";
        this.numeroProtocolo = "";
        this.idCaso = null;
        this.dataAberturaCaso = "";

        await this.carregarCartoesComSenhaBloqueada();
        
        this.stepOne = true;
        this.stepTwo = false;
        this.stepThree = false;
        this.falhaDesbloqueio = false;
        this.closeSpinner();
    }

    handleButtonReimprimirSenha(event) {
        this.showCardPrincipal = false;
        this.abrirReimprimirSenha = true;
    }

    handleButtonIrCaso(event) {
        window.location.href = '/lightning/r/Case/'+ this.idCaso +'/view';
    }

    changRadioCartaoSelecionado(event){
        this.idSernoCartao = event.target.value;
        this.disableButtonProsseguir = false;
    }

    handleChangeOrigem(event){
        this.origemValue = event.target.value;
        this.canalValue = null;
        this.verifyDisabled();
    }
    handleChangeCanal(event){
        this.canalValue = event.target.value;
        this.verifyDisabled();
    }

    //#endregion

    //#region métodos Toast, Spinner e verify
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
            messageData: [
                {
                    url: '/lightning/r/ContaFinanceira__c/' + this.recordId + '/related/Ativos__r/view',
                    label: 'Verifique o modúlo Ativos'
                },
            ],
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
            this.dispatchEvent(new CustomEvent('closeparentmodal'))
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    //#endregion

    async carregarCartoesComSenhaBloqueada() {
        await GetListaCartaoDesbloqueioSenha({
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            idEmpresa: this.idEmpresa,
            canal: this.canal,
            area: this.areaPrincipal,
            sistema: this.sistema
        }).then(result => {
            if (result != null && result.length > 0) {
                let opcoes = [];
                result.forEach(item => {
                    opcoes.push(
                        { 
                            numeroCartaoOfuscado: item.numeroCartaoOfuscado, 
                            numeroCartaoSerno: item.numeroCartaoSerno,
                            wrongPinRetries: item.wrongPinRetries
                        }
                    );
                });

                this.optionsCartoes = opcoes;
                if(opcoes.length == 1){
                    this.possuiUmCartaoBloqueado = true;
                    this.disableButtonProsseguir = false;
                    this.idSernoCartao = opcoes[0].numeroCartaoSerno;
                } else {
                    this.possuiCartoesBloqueados = true;
                    this.disableButtonProsseguir = true;
                }
            } else {
                this.naoPossuiCartaoBloqueado = true;
                this.disableButtonProsseguir = true;
            }
            this.showCardPrincipal = true;
        }).catch(error => {
            this.showToast('Consulta de cartões com senha bloqueada.', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', true);
        });
    }

    async desbloquearSenhaCartao() {
             
        await DesbloquearSenhaCartao({
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            idEmpresa: this.idEmpresa,
            canal: this.canal,
            area: this.areaPrincipal,
            sistema: this.sistema,
            listaCartoesSerno: [this.idSernoCartao]
        }).then(result => {
            
            if (result != null && result.length > 0) {
                let resultado = [];
                result.forEach(item => {
                    resultado.push(
                        { 
                            numeroCartaoSerno: item.idSerno,
                            sucesso: item.sucesso
                        }
                    );
                });

                // inicialmente enviamos apenas um cartão para desbloqueio
                this.sucessoDesbloquearSenha = resultado[0].sucesso;  
            } else {
                this.sucessoDesbloquearSenha = false;
            }
        }).catch(error => {
            console.log(error);
        });
    }

    async CriarCaso() {
        await createCaseDesbloqueioSenhaCartao({
            canal: this.canalValue,
            origem: this.origemValue,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa,
        }).then(result => {
            if (result != null) {
                this.numeroProtocolo = result.CaseNumber
                this.idCaso = result.Id;
            }
        }).catch(error => {
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao criar Caso.', 'error', true);
        });
    }

    verifyDisabled(){
        if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null || this.canalValue == undefined) {
                this.disableButtonFinalizar = true;
        } else {
            this.disableButtonFinalizar = false;
        }
    }

}