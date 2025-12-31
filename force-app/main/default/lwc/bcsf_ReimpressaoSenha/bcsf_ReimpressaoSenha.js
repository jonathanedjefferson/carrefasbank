import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';


import getContaFinanceira from '@salesforce/apex/BCSF_ReimpressaoSenhaController.getContaFinanceira';
import getInfoStatus from '@salesforce/apex/BCSF_BloqueioCartaoController.getInfoStatus';
import createCase from '@salesforce/apex/BCSF_ReimpressaoSenhaController.criarCaso';
import getListCartoes from '@salesforce/apex/BCSF_ReimpressaoSenhaController.getListarCartoes';
import reimprimirSenha from '@salesforce/apex/BCSF_ReimpressaoSenhaController.ReimprimirSenha';
import { NavigationMixin } from 'lightning/navigation';



export default class Bcsf_ReimpressaoSenha extends NavigationMixin(LightningElement) {
    //#region ######### VARIAVEIS ##########
        spinner = false;
        logoTipo;
        caseId;
        @api recordId;
        
        @track possuiCelularSeguro = true;
        @track celularSeguro;
        @track telefone;
        @track cep;
        @track rua;
        @track numero;
        @track complemento;
        @track bairro;
        @track cidade;
        @track estado;



        @track disableButton = true;
        @track buttonPross = true;
    
        @track stepOne = true;
        @track stepTwo = false;
        @track stepThree = false;
        @track showCardPrincipal = true;
        @track showButtonProsseguir = true;
        @track disabledMotivo = true;
    
        @track valueCartoes = null;
        @track numeroCartao = null;
        @track numeroSerno = null;
        @track valueStatusCartoes = null;
        @track newValueStatus = null;
        @track valueMotivo = null;
        @track valueMotivoComCLSC = null;
        @track valueMotivoSemCLSC = null;
        @track valueOrigem = null;
        @track valueCanal = null;
        @track unidadeNegocio = null;
        @track accountId = null;
        
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
        
        @track statusContaInfo = 'Informação indisponível';
        @track statusCartaoInfo = 'Informação indisponível';
        @track canal = 'cockpit';
        @track Area = null;
    
        optionsCanal = [];
        optionsCartoes = [];
        optionsOrigem = [];
        listaCartoes = [];
        numProtocolo;
        
    //#endregion 
        
    //#region ########## CARREGAMENTO DE DATA OPTIONS ##########
    
        @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
            if (currentPageReference) {
                this.recordId = currentPageReference.state.recordId;
            }
        } 
    
        @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL]}) 
        currentUserInfo({error, data}) {
            if (data) {
                this.Area = data.fields.AreaPrincipal__c.value;
            } else if (error) {
                this.error = error ;
            }
        }

        navegarParaAlteracao(){
            this[NavigationMixin.Navigate]({
                type: 'standard__quickAction',
                attributes: {
                    apiName:"ContaFinanceira__c.AlteracaoDadosCadastrais"
                },
                state: {
                    recordId: this.recordId
                }
            });
        }
        
        connectedCallback() { 
            this.showSpinner();
            getContaFinanceira({
                contaFinanceiraId: this.recordId
            }).then(result => {
                try {
                    this.nome = result.Nome;
                    this.numeroConta = result.NumeroConta;
                    this.statusConta = result.StatusConta;
                    this.cpf = result.CPF;
                    this.dataNascimento = result.DataNascimento;
                    this.unidadeNegocio = result.UnidadeNegocio;
                    this.accountId = result.AccountId;
                    this.cep = result.CEP;
                    this.rua = result.Rua;
                    this.numero = result.Numero;
                    this.complemento = result.Complemento;
                    this.bairro = result.Bairro;
                    this.cidade = result.Cidade;
                    this.estado = result.Estado;
                    this.telefone = result.Telefone;
                    this.celularSeguro = result.CelularSeguro;
                    if(this.celularSeguro == 'Não possui Celular Seguro'){
                        this.possuiCelularSeguro = false;
                    }


                    this.GetStatusInfo(result.StatusConta, false, true);
                    
                    if (result.UnidadeNegocio == "1") {
                        this.tipoConta = 'Carrefour';
                        this.logoTipo = LogoCarrefour;
                    } else if (result.UnidadeNegocio == "2") {
                        this.tipoConta = 'Atacadão';
                        this.logoTipo = LogoAtacadao;
                    }else if (result.UnidadeNegocio == "6"){
                        this.tipoConta = "Sam's Club";
                        this.logoTipo = LogoSamsClub;
                    }
                    this.listarCartoes(this.canal, this.Area);
                } catch (error) {
                    console.log('Erro catch() getContaFinanceira: '+ error);   
                    this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
                } 
            }).catch(error => {
                console.log('Erro getContaFinanceira: '+ error.body.message);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
            });
           
        }
    //#endregion 
    
    //#region ########## HANDLER PICKLISTS ##########
    
        handleChangeStatusReimpressao(event) {
            this.disabledMotivo = false;
            this.valueCartoes = event.detail.value;
            this.nomeNoCartao = event.detail.value.split(" - ")[0];
            this.numeroCartao = event.detail.value.split(" - ")[1];
            this.valueStatusCartoes = event.detail.value.split(" - ")[2];
            this.optionsMotivo = this.valueMotivoComCLSC;
    
            
            this.GetStatusInfo(event.detail.value.split(" - ")[2], true, false);
    
            this.optionsCartoes.forEach(item => {
                if (item.value == this.valueCartoes && item.ehPrimario) {
                    this.optionsMotivo = this.valueMotivoSemCLSC;
    
                    if (this.valueMotivo != null || this.valueMotivo != undefined) {
                        if (this.valueMotivo.split(" - ")[0] == 'CLSC') {
                            this.valueMotivo = null;
                        }
                    }
                    
                }
            });
            
            this.listaCartoes.forEach(item => {            
                if (item.numeroCartaoOfuscado == this.numeroCartao) {
                    this.numeroSerno = item.numeroCartaoSerno;
                }
            });    
            
            this.verifyDesable();
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
            if(this.stepOne == true){
                this.currentStep = '2';
                this.stepOne = false;
                this.stepTwo = true;
                this.disableButton = false;
                this.showButtonProsseguir = false;
            }else if(this.stepTwo == true){
                this.currentStep = '3';
                this.showCardPrincipal = false;
                this.stepTwo = false;
                this.stepThree = true;
                this.disableButton = false;
            }
        }
    
        handleButtonVoltar(event) {
            if(this.stepTwo == true){
                this.currentStep = '1';
                this.disableButton = true;
                this.stepOne = true;
                this.stepTwo = false;
                this.showButtonProsseguir = true;
                
            }else if(this.stepThree == true){
                this.currentStep = '2';
                this.stepTwo = true;
                this.stepThree = false;
                this.showCardPrincipal = true;
                this.disableButton = false;
            }
        }
    
        handleConfirmaReimpressao(event){
            this.ReimprimirSenha(this.canal, this.Area);
        }
    
        verifyDesable(){
            if (this.valueCartoes == null || this.valueCartoes == undefined ||
                this.valueMotivo == null || this.valueMotivo == undefined ||
                this.valueOrigem == null || this.valueOrigem == undefined ||
                this.valueCanal == null || this.valueCanal == undefined) {
                
                    this.buttonPross = true;
            }else{
                this.buttonPross = false;
            }
        }
    
        irCase(){
            window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
        }
    //#endregion 
    
    //#region ########## DML/QUERY ##########
    
        CreateCase(){
            this.showSpinner();
    
            createCase({
                contaFinanceiraId: this.recordId,
                accountId: this.accountId,
                unidadeNegocio: this.unidadeNegocio,
                origem: this.valueOrigem,
                canal: this.valueCanal,
                evento: this.evento,
                assunto: this.assunto
            }).then(result => {
                this.possuiCelularSeguro = true;
                this.currentStep = '3';
                this.showCardPrincipal = false;
                this.stepTwo = false;
                this.stepThree = true;
                this.disableButton = true;
                this.numProtocolo = result.CaseNumber;
                this.caseId = result.Id;
                this.closeSpinner();
                this.showToast('Segunda Via de Senha realizada com sucesso!', 
                    'Em casos de envio via SMS, o prazo de recebimento da nova senha é de 48h (contando os dias de fim de semana).'+
                    'Em casos de envio via correio, o prazo de recebimento de nova senha é em 5 dias úteis.', 
                    'info', false);
            }).catch(error => {
                console.log('Erro createCase: '+ error.body.message);
                this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
            });
        }
        
        GetStatusInfo(status, StatusCartao, StatusConta){
            getInfoStatus({
                status: status
            }).then(result => {
                
                if (StatusCartao && !StatusConta) {
                    this.statusCartaoInfo = result.Descricao__c;
                }else if(!StatusCartao && StatusConta){
                    this.statusContaInfo = result.Descricao__c;
                }
            }).catch(error => {
                console.log('Erro getInfoStatus: '+ error.body.message);
                // this.showToast('Aviso!', 'Descrição de Status Não encontrada!', 'warning', false);
            });
        }
    
    //#endregion 
    
    //#region ########## INTEGRAÇÕES API ##########
    
        listarCartoes(canal, area){   
            getListCartoes({
                canal: canal,
                area: area,
                idEmpresa: this.unidadeNegocio,
                cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
                numeroConta: this.numeroConta
            }).then(result => {
                if (result.length > 0) {

                    if(result[0].StatusOK  == "ERROR"){
                        this.showToast('Erro', 'Houve um erro ao buscar cartões!', 'error', true);
                    } else {
                        this.listaCartoes = result;
                        let opcoes = [];
                        
                        result.forEach(item => {
                            opcoes.push(
                                {
                                    label: item.nomeCartao + ' - ' +item.numeroCartaoOfuscado + ' - ' + item.status, 
                                    value: item.nomeCartao + ' - ' +item.numeroCartaoOfuscado + ' - ' + item.status,
                                    ehPrimario: item.ehPrimario
                                }
                            );
                            
                        });

                        this.optionsCartoes = opcoes;
                    }
    
                    this.closeSpinner();
                }else{
                    this.showToast('Erro', 'Esta conta financeira não possui cartões', 'error', true);
                }
            }).catch(error => {
                console.log('Erro getListCartoes: '+ error.body.message);
                this.showToast('Erro', 'Houve um erro ao buscar cartões!', 'error', true);
            });
        }
    
        ReimprimirSenha(canal, area){
            this.showSpinner();
    
            reimprimirSenha({
                idEmpresa: this.unidadeNegocio, 
                sistema: canal, 
                canal: canal, 
                area: area,
                cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''), 
                numeroConta: this.numeroConta, 
                numeroCartaoSerno: this.numeroSerno
            }).then(result => {
                if (result == 'OK') {
                    this.CreateCase();
                }else if(result == 'Em andamento'){
                    this.showToast('Processando', 'A reimpressão de senha já está em processamento!', 'warning', true);
                }else{
                    this.showToast('Erro', 'Não foi possivel reimprimir a senha do Cartão!', 'error', true);
                }
            }).catch( error => {
                console.log('Erro ReimprimirSenha: '+ error.body.message);
                this.showToast('Erro', 'Houve um erro ao reimprimir a senha do Cartão!', 'error', true);
            })
        }
    //#endregion 
    
    //#region ########## INTERAÇÕES COM USUÁRIO ##########
        
        showSpinner(){
            this.spinner = true;
        }
        closeSpinner(){
            this.spinner = false;
        }
    
        showToast(titulo, mensagem, variante, closeModal, mode = 'dismissable') {
            const evt = new ShowToastEvent({
                title: titulo,
                message: mensagem,
                variant: variante,
                mode: mode
            });
            this.dispatchEvent(evt);
    
            if (closeModal) {
                this.closeSpinner();
                this.closeQuickAction();
            }
        }
    
        @api closeParentComponent;
        closeQuickAction() {
        if (this.closeParentComponent) {
            this.dispatchEvent(new CustomEvent('closeparentmodal'));
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    //#endregion 
    
    }