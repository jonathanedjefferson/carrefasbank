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

import getContaFinanceira from '@salesforce/apex/BCSF_CancelamentoContaController.getContaFinanceira';
import getListCartoes from '@salesforce/apex/BCSF_BloqueioCartaoController.getListCartoes';
import listStatusBloqueioCartao from '@salesforce/apex/BCSF_BloqueioCartaoController.listStatusBloqueioCartao';
import bloquearCartao from '@salesforce/apex/BCSF_BloqueioCartaoController.bloquearCartao';
import createCase from '@salesforce/apex/BCSF_BloqueioCartaoController.createCase';
import createCaseFalecimento from '@salesforce/apex/BCSF_BloqueioCartaoController.createCaseFalecimento';
import updateAtivo from '@salesforce/apex/BCSF_BloqueioCartaoController.updateAtivo';
import getInfoStatus from '@salesforce/apex/BCSF_BloqueioCartaoController.getInfoStatus';
import getTipoBloqueioCartao from '@salesforce/apex/BCSF_BloqueioCartaoController.getTipoBloqueioCartao';
import getCartaoTitular from '@salesforce/apex/BCSF_BloqueioCartaoController.getCartaoTitular';


export default class Bcsf_BloqueioCartao extends LightningElement {
//#region ######### VARIAVEIS ##########
    spinner = false;
    logoTipo;
    caseId;
    @api recordId;

    @api cmpFalecimento;
    executarBloqueio;
    @track alertStatusFalecido = false;
    @track buttonConfirmaBloqueio = false;
    
    @track disableButton = true;
    @track buttonPross = true;
    @track stepOne = true;
    @track stepTwo = false;
    @track stepThree = false;
    @track stepThreeFalecimento = false;
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
    @track valueMotivoFalecido = null;
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
    // @track unidadeNegocio = '--';
    @track cpf = '--';
    @track dataNascimento = '--';
    @track hasErrorSteps = false;
    @track hasErrorSteps = false;
    
    @track statusContaInfo = 'Informação indisponível';
    @track statusCartaoInfo = 'Informação indisponível';
    @track canal = 'cockpit';
    @track Area = null;
    @track telefoneContato = '';
    @track mostrarErro = false;

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
    
    connectedCallback() { 
        this.showSpinner();
        this.disableButton = this.cmpFalecimento != true? true : false;
        this.buttonConfirmaBloqueio = this.cmpFalecimento == true? true : false;
        
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

                if(this.cmpFalecimento){
                    this.listarCartaoFalecido();
                } else {
                    this.listarCartoes(this.canal, this.Area);
                }
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

    handleChangeStatusBloqueio(event) {
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
                    if (this.valueMotivo == 'CLSC') {
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

    handleChangeMotivoCancelamento(event) {
        this.valueMotivo = event.detail.value;
        this.newValueStatus = event.detail.value;

        if(this.newValueStatus == 'DCED' && this.cmpFalecimento != true){
            this.alertStatusFalecido = true;
        }else{
            this.alertStatusFalecido = false;
        }

        this.verifyDesable();
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
            this.disableButton = this.cmpFalecimento != true? true : false;
            this.stepOne = true;
            this.stepTwo = false;
            this.showButtonProsseguir = true;
            
        }else if(this.stepThree == true){
            this.currentStep = '2';
            this.stepTwo = true;
            this.stepThree = false;
            this.showCardPrincipal = true;
            this.disableButton = false;
        }else if(this.stepOne == true){
            const event = new CustomEvent('reload');
            this.dispatchEvent(event);
        }
    }

    handleConfirmaBloqueio(event){
        if(this.cmpFalecimento && !this.executarBloqueio){
            // Cartão já com bloqueio definitivo. Apenas criar o caso.
            this.CreateCaseFalecimento();
        } else {
            this.BloquearCartao(this.canal, this.Area);
        }
    }

    handleTelefoneChange(event) {
        const inputValue = event.target.value;
        const numeroApenas = inputValue.replace(/\D/g, '');
        
        // Validação para um número de celular brasileiro
        if (numeroApenas.length == 13) {
            this.telefoneContato = `+${numeroApenas.substring(0, 2)} (${numeroApenas.substring(2, 4)}) ${numeroApenas.substring(4, 9)}-${numeroApenas.substring(9)}`;
            this.mostrarErro = false;
            this.buttonConfirmaBloqueio = false;
        } else if (numeroApenas.length == 11) {
            this.telefoneContato = `(${numeroApenas.substring(0, 2)}) ${numeroApenas.substring(2, 7)}-${numeroApenas.substring(7)}`;
            this.mostrarErro = false;
            this.buttonConfirmaBloqueio = false;
        } else {
            this.mostrarErro = true;
            this.buttonConfirmaBloqueio = true;
        }
    }

    verifyDesable(){
        if (this.valueCartoes == null || this.valueCartoes == undefined ||
            this.valueMotivo == null || this.valueMotivo == undefined ||
            this.valueOrigem == null || this.valueOrigem == undefined ||
            this.valueCanal == null || this.valueCanal == undefined || 
            this.alertStatusFalecido == true) {
            
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
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal
        }).then(result => {
            this.UpdateCartao();

            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.disableButton = true;
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
        }).catch(error => {
            console.log('Erro createCase: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
        });
    }

    CreateCaseFalecimento(){
        this.showSpinner();
        this.telefoneContato = this.telefoneContato.replace(/[^\d]/g, '').length == 11 ? '55'+this.telefoneContato : this.telefoneContato;
        createCaseFalecimento({
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal,
            telefoneContato: this.telefoneContato.replace(/[^\d]/g, '')
        }).then(result => {
            this.UpdateCartao();

            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThreeFalecimento = true;
            this.disableButton = true;
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
    
        }).catch(error => {
            console.log('Erro createCase: '+ error);
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
        });
    }


    UpdateCartao(){
        this.showSpinner();

        updateAtivo({
            contaFinanceiraId: this.recordId,
            cartaoOfuscado: this.numeroCartao,
            newStatus: this.newValueStatus
        }).then(() => {
            this.closeSpinner();
        }).catch(error => {
            console.log('Erro updateAtivo: '+ error);
            this.showToast('Erro', 'Houve um erro ao atualizar Cartão!', 'error', true);
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
        });
    }

//#endregion 

//#region ########## INTEGRAÇÕES API ##########

    listarCartoes(canal, area){
        this.showSpinner();

        getListCartoes({
            canal: canal,
            area: area,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta
        }).then(result => {
            if (result.length > 0) {
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
                this.ListarStatusBloqueioCartao(canal, area);
            }else{
                this.showToast('Erro', 'Esta conta financeira não possui cartões de crédito disponíveis para bloqueio.', 'error', true);
            }
            
        }).catch(error => {
            console.log('Erro getListCartoes: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar cartões para bloquear!', 'error', true);
        });
    }

    async listarCartaoFalecido(){
        // Consultar cartão primário e titular da Conta Financeira nos Assets.
        this.showSpinner();
        getCartaoTitular({
            contaFinanceiraId: this.recordId
        }).then(result => {
            if (result != null) {
                let opcoes = [];
                
                opcoes.push(
                    {
                        label: result.NomeReduzido + ' - ' +result.NumeroCartao + ' - ' + result.Status, 
                        value: result.NomeReduzido + ' - ' +result.NumeroCartao + ' - ' + result.Status,
                        ehPrimario: true
                    }
                );

                this.valueCartoes = result.NomeReduzido + ' - ' +result.NumeroCartao + ' - ' + result.Status;
                this.numeroSerno = result.NumeroSernoId;
                this.nomeNoCartao = result.NomeReduzido;
                this.numeroCartao = result.NumeroCartao;
                this.valueStatusCartoes = result.Status;
                
                this.optionsCartoes = opcoes;

                this.ListarStatusBloqueioCartao(this.canal, this.Area);
            } else{
                this.showToast('Erro', 'Cartão Titular não foi encontrado nesta Conta Financeira.', 'error', true);
            }
        }).catch(error => {
            console.log('Erro listarCartaoFalecido: '+ JSON.stringify(error));
            this.showToast('Erro', 'Houve um erro ao buscar cartões para bloquear!', 'error', true);
        });
    }


    ListarStatusBloqueioCartao(canal, area){
        this.showSpinner();
        
        listStatusBloqueioCartao({
            canal: canal,
            area: area
        }).then(result => {
            let opcoesComCLSC = [];
            let opcoesSemCLSC = [];
            let opcaoFalecido = [];
            result.status.forEach(item => {
                if (item.nome != 'CLSC') {
                    opcoesSemCLSC.push(
                        {label: item.nome + ' - ' + item.descricao, value: item.nome}
                    )
                }
                
                if(item.nome == 'DCED') {
                    opcaoFalecido.push(
                        {label: item.nome + ' - ' + item.descricao, value: item.nome}
                    )
                }

                opcoesComCLSC.push(
                    {label: item.nome + ' - ' + item.descricao, value: item.nome}
                )
                
            });
            this.valueMotivoSemCLSC = opcoesSemCLSC;
            this.valueMotivoComCLSC = opcoesComCLSC;
            this.valueMotivoFalecido = opcaoFalecido;

            if(this.cmpFalecimento && this.valueStatusCartoes){
                this.ListarStatusBloqueioFalecido(this.valueStatusCartoes);  
            }
            this.closeSpinner();
        }).catch( error => {
            console.log('Erro listStatusBloqueioCartao: '+ error);
            this.showToast('Erro', 'Houve um erro ao buscar lista de status para bloquear!', 'error', true);
        })
    }

    ListarStatusBloqueioFalecido(statusCartao){
        this.showSpinner();
        
        getTipoBloqueioCartao({
            statusCartao: statusCartao
        }).then(result => {
            // Não é permitido alterar o status definitivo.
            if('STATUS_DEFINITIVO' === result){
                this.executarBloqueio = false;
                this.disabledMotivo = true;
                this.optionsMotivo = this.valueMotivoComCLSC;
                let containsMotivo = false;
                this.optionsMotivo.forEach(item => {
                    if(item.value === statusCartao){
                        containsMotivo = true;
                    }
                });
                if(!containsMotivo){
                    this.optionsMotivo.push({
                        label: statusCartao, 
                        value: statusCartao
                    });
                }


                this.valueMotivo = statusCartao;
            } else {
                // No fluxo de falecido permitido apenas bloqueio para status DCED.
                this.executarBloqueio = true;
                this.optionsMotivo = this.valueMotivoFalecido;
                this.valueMotivo = 'DCED';
                this.newValueStatus = 'DCED';
                this.disabledMotivo = true;
            }

            this.verifyDesable();
            this.closeSpinner();
        }).catch( error => {
            console.log('Erro ListarStatusBloqueioFalecido: '+ JSON.stringify(error));
            this.showToast('Erro', 'Houve um erro ao buscar lista de status para bloquear!', 'error', true);
        })
    }


    BloquearCartao(canal, area){
        this.showSpinner();

        bloquearCartao({
            idEmpresa: this.unidadeNegocio, 
            sistema: canal, 
            canal: canal, 
            area: area,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''), 
            numeroConta: this.numeroConta, 
            numeroCartaoSerno: this.numeroSerno, 
            novoStatus: this.newValueStatus
        }).then(result => {
            if (result) {
                if(this.cmpFalecimento){
                    this.CreateCaseFalecimento();
                }else{
                    this.CreateCase();
                }
            }else{
                this.showToast('Erro', 'Não foi possivel bloquear o Cartão!', 'error', true);
            }
        }).catch( error => {
            console.log('Erro bloquearCartao: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao bloquear o Cartão!', 'error', true);
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
            this.dispatchEvent(new CustomEvent('closeparentmodal'))
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
//#endregion 

}