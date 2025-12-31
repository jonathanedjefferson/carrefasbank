import { LightningElement, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {createRecord} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';


//Dados de caso
import CASE_OBJECT from "@salesforce/schema/Case";
import ORIGEM_FIELD from "@salesforce/schema/Case.Origin";
import CANAL_FIELD from "@salesforce/schema/Case.CanalEntrada__c";
import ACCOUNT_FIELD from '@salesforce/schema/Case.NomeCliente__c';
import UNIDADE_NEGOCIO from '@salesforce/schema/Case.UnidadeNegocio__c';
import ASSUNTO_FIELD from "@salesforce/schema/Case.Assunto__c";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import EVENT_FIELD from "@salesforce/schema/Case.Evento__c";
import RECORD_TYPE_ID from '@salesforce/schema/Case.RecordTypeId';
import CONTA_FINANCEIRA_FIELD from '@salesforce/schema/Case.ContaFinanceira__c';
//Dados do usuário
import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getAceiteAvaliacao from '@salesforce/apex/BCSF_AvaliacaoEmergencialController.Consultar';
//import getTaxasAvaliacao from '@salesforce/apex/BCSF_AvaliacaoEmergencialController.ConsultarTaxas';
import getTemplateTermo from '@salesforce/apex/BCSF_AvaliacaoEmergencialController.ConsultarTermo';
import gravarAvaliacao from '@salesforce/apex/BCSF_AvaliacaoEmergencialController.Gravar';
import getContaFinanceira from '@salesforce/apex/BCSF_AvaliacaoEmergencialController.getContaFinanceira';
import getAssetTitular from '@salesforce/apex/BCSF_AvaliacaoEmergencialController.getAssetTitular';

const ACCOUNT_FIELDS = [
    'Account.Name',
    'Account.CPF__c'
];

const ASSET_FIELDS = [
    'Asset.Product2Id'
];



export default class Bcsf_AvaliacaoEmergencialCredito extends NavigationMixin(LightningElement) {
    @track recordId;
    contaFinanceira;
    clienteId; 
    clienteData;
    spinner = false;
    assetId;
    productId;



    //Campos do caso
    caseRecordTypeId;
    originValues;
    canalValues;
    valueOrigin;
    valueCanal;
    @track comboboxOptionsCanal = [];
    @track comboboxOptionsOrigin = [];
    caseId;
    recordTypeName = 'BCSF Atendimento';
    @track recordTypeId;
    @track numeroProtocolo;

    //Campos dados do cliente
    @track nomeCliente;
    @track cpf;
    @track tipoConta;
    @track logoTipo;
    @track numeroConta;
    @track statusConta;
    @track nomeProduto;
    //@track DataInicioConta;
    @track data

    //Campos get Aceite avaliação emergencial
    AceiteAvaliacao;
    DataUltimaModificacao;
    erroAceite;
    disabledProsseguir = true;

    //Campos get Taxas avaliação emergencial
    taxaEmDia;
    taxaEmAtraso;
    taxaUltimaFaturaFechada;

    //Campos get Termo template avaliação emergencial
    templateTermos;
    tipoTemplate;

    //Campos gravar avaliacaoEmergencial
    accountNumber;
    operation;
    errorGravacao;

    @track showModalDadosConta = true;
    @track showModalTermos = false;
    @track showModalAlteracao = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    results({ error, data }) {
        if (data) {
        this.caseRecordTypeId = data.defaultRecordTypeId;
        this.error = undefined;
        } else if (error) {
        this.error = error;
        this.caseRecordTypeId = undefined;
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            const recordTypeInfos = data.recordTypeInfos;

            const recordType = Object.values(recordTypeInfos).find(
                rt => rt.name === this.recordTypeName
            );

            if (recordType) {
                this.recordTypeId = recordType.recordTypeId; 
            } else {
                console.error('Record Type não encontrado.');
            }
        } else if (error) {
            console.error('Erro ao buscar informações do objeto:', error);
        }
    }


    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: ORIGEM_FIELD })
    picklistResultsOrigin({ error, data }) {
        if (data) {
        this.originValues = data.values;
        this.error = undefined;
        this.comboboxOptionsOrigin = this.originValues.map(item => ({
            label: item.label,
            value: item.value
        }));
        this.updateComboboxOptions();
        } else if (error) {
        this.error = error;
        this.originValues = undefined;
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: CANAL_FIELD})
    picklistResultsCanal({ error, data }) {
        if (data) {
        this.canalValues = data.values;
        this.error = undefined;
        this.updateComboboxOptions();
        } else if (error) {
        this.error = error;
        this.canalValues = undefined;
        }
    }

    @wire(getRecord, { recordId: '$clienteId', fields: ACCOUNT_FIELDS })
    wiredCliente({ error, data }) {
        if (data) {
            this.clienteData = data.fields;
        } else if (error) {
            console.error('Erro ao buscar Account:', error);
        }
    }

    @wire(getRecord, { recordId: '$assetId' , fields: ASSET_FIELDS })
    wiredAsset({ error, data }) {
        if (data) {
            this.productId = data.fields.Product2Id.value;
        } else if (error) {
            console.error('Erro ao buscar Asset:', error);
        }      
    }


    @wire(getRecord, { recordId: '$productId', fields: ['Product2.Name'] })
    wiredProduct({ error, data }) {
        if (data) {
            this.nomeProduto = data.fields.Name.value;
            //this.handleConsultarTaxas();
        } else if (error) {
            console.error('Erro ao buscar Produto:', error);
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
            console.log('Area Principal:', this.area);
        } else if (error) {
            this.error = error ;
        }
    }

    async connectedCallback() {
        if (this.recordId) {
            await this.getDadosContaFinanceira();
            await this.getAssetTitular();
        }
        await this.handleAceiteAvaliacao();
    }

    //Busca os dados da conta financeira
    async getDadosContaFinanceira() {
        this.showSpinner();
        try {
            const result = await getContaFinanceira({ recordId: this.recordId });
            this.cpf = result.CPF;
            this.numeroConta = result.NumeroConta;
            this.idEmpresa = result.UnidadeNegocio;
            this.accountId = result.AccountId;
            this.nomeCliente = result.Nome;
            this.statusConta = result.StatusConta;
            //this.DataInicioConta = result.DataInicioConta;
            
            if (this.idEmpresa == "1") {
                this.tipoConta = 'CARREFOUR';
                this.logoTipo = LogoCarrefour;
            } else if (this.idEmpresa == "2") {
                this.tipoConta = 'ATACADÃO';
                this.logoTipo = LogoAtacadao;
            } else if (this.idEmpresa == "6") {
                this.tipoConta = "SAM'S CLUB";
                this.logoTipo = LogoSamsClub;
            }
        } catch (error) {
            console.error('Erro ao buscar dados da conta financeira:', error);
            this.showToastError('Não foi possível carregar os dados!');
        } finally {
            this.closeSpinner(); 
        }
    }

    async getAssetTitular() {
        this.showSpinner();
    
        try {
            const result = await getAssetTitular({ contaFinanceiraId: this.recordId });
            this.assetId = result.AssetId;
        } catch (error) {
            console.error('Erro ao buscar dados do asset titular:', error);
        } finally {
            this.closeSpinner(); 
        }
    }


    //***************ÁREA DE CONSULTAS A API *********************** */
    
    //Consultar dados da avaliação emergencial
    async handleAceiteAvaliacao(){
        this.showSpinner();
        try {
            const result = await getAceiteAvaliacao({
                cpf: this.cpf.replace(".", "").replace(".", "").replace("-", ""),
                numeroConta: this.numeroConta,
                area: this.area,
                canal: 'cockpit'
            });
    
            let parsedResult = JSON.parse(result);
            this.AceiteAvaliacao = parsedResult.acceptEmergencyAssessment;
            this.DataUltimaModificacao = parsedResult.dateLastModifiedEmergencyAssessment;
            this.toggle = this.AceiteAvaliacao;
        } catch (error) {
            this.showToastError('Não foi possível carregar os dados!');
            this.closeQuickAction();
            this.erroAceite = error;
        } finally {
            this.closeSpinner();
        }
    }

    //Consultar taxas da avaliação emergencial
    /*
    async handleConsultarTaxas() {
        this.showSpinner();
        
        const dataFormatada = this.formatarDataParaUS(this.DataInicioConta);

        try {
            const result = await getTaxasAvaliacao({
                cpf: this.cpf.replace(/\./g, "").replace("-", ""), 
                numeroConta: this.numeroConta,
                area: this.area,
                canal: 'cockpit',
                produto: this.nomeProduto,
                dataConta:  dataFormatada
            });
    
            const parsedResult = JSON.parse(result);
            this.taxaEmDia = parsedResult.taxaEmDia;
            this.taxaEmAtraso = parsedResult.taxaEmAtraso;
            this.taxaUltimaFaturaFechada = parsedResult.taxaUltimaFaturaFechada;
            this.indicadorTaxaOverlimitAtiva = parsedResult.indicadorTaxaOverlimitAtiva;
        } catch (error) {
            this.showToastError('Não foi possível carregar os dados das taxas!');
            console.error('Erro ao buscar as taxas da avaliação:', error);
        } finally {
            this.closeSpinner(); 
        }
    }
    */

    async handleConsultarTermo() {
        this.showSpinner();
        try {
            const result = await getTemplateTermo({
                cpf: this.cpf.replace(".","").replace(".","").replace("-",""),
                numeroConta: this.numeroConta,
                area: this.area,
                canal: 'cockpit',
                tipo: this.AceiteAvaliacao ? '53' : '52'
            });
    
          
            const parsedResult = JSON.parse(result);
            let templateHTML = parsedResult.template
            .replace(/<div class="opcaoOverlimit".*?<\/div>/, "")  
            .replace(/\\/g, "") 
            .replace(/style="text-align: center;.*?visibility\s*:\s*hidden"/, 'style="text-align: center;"')  
            .replace('<div class="wrapperImpressao">', '<div class="wrapperImpressao" style="text-align: center;">')  
            .replace('<p>Condições Gerais:</p>', '</br><p style:"margin-top:10px !important;">Condições Gerais:</p>')
            .replace('<div class="opcaoOverlimitAdicionais" style="display:block">','<div class="opcaoOverlimitAdicionais" style="display:none">')
            .replace('<hr>','');
            this.templateTermos = templateHTML;

            if(this.AceiteAvaliacao){
                this.templateTermos = this.templateTermos.replace('<p>Termo de Cancelamento Avaliação Emergencial de Crédito</p>', '<p class="slds-text-align_left slds-text-heading_medium">Termo de cancelamento</p>')
                                                         .replace('<p>Condições Gerais:</p>', '</br><p style:"margin-top:10px !important;">Condições Gerais:</p>');
            }else{
                this.templateTermos = this.templateTermos.replace('<p align="center">Termo de Cadastramento Avaliação Emergencial de Crédito</p>', '<p class="slds-text-align_left slds-text-heading_medium">Termo de adesão</p>')
                                                         .replace('<p class="linhaEscrita">  Condições Gerais:   </p>', '</br><p style:"margin-top:10px !important;">Condições Gerais:</p>');

            }

            this.tipoTemplate = parsedResult.tipo;
            
        } catch (error) {
            this.showToastError('Não foi possível gerar o termo de adesão avaliação emergencial');
            console.error('Erro ao buscar o template do termo:', error);
        } finally {
            this.closeSpinner();
        }
    }
    

    //Gravar avaliação emergencial
    async handleGravarAvaliacao(){
        this.showSpinner();
        try{
            const result = await gravarAvaliacao({
                cpf: this.cpf.replace(".","").replace(".","").replace("-",""),
                numeroConta: this.numeroConta,
                area: this.area,
                canal: 'cockpit',
                idEmpresa: this.idEmpresa,
                Operacao: this.AceiteAvaliacao ? '0':'1'
            });

            const parsedResult = JSON.parse(result);
            this.accountNumber = parsedResult.AccountNumber;
            this.operation = parsedResult.Operation;
            this.errorGravacao = false;
        } catch(error){
           
            this.errorGravacao = true;
            console.log("Error ao gravar a avaliação", error);

        } finally{
            this.closeSpinner();
        }
    }

    //***************FIM ÁREA DE CONSULTAS A API *********************** */

    updateComboboxOptions() {
        if (this.canalValues && this.valueOrigin) {
            const selectedOriginIndex = this.originValues.findIndex(
                item => item.value === this.valueOrigin
            );
    
            this.comboboxOptionsCanal = this.canalValues
                .filter(item => {
                    return item.validFor.includes(selectedOriginIndex);
                })
                .map(item => ({
                    label: item.label,
                    value: item.value
                }));
        } else {
            this.comboboxOptionsCanal = [];
        }
    }



    createCase() {
        // Cria o objeto com os dados a serem inseridos
        const fields = {};
        fields[STATUS_FIELD.fieldApiName] = 'closed';
        fields[ORIGEM_FIELD.fieldApiName] = this.valueOrigin;
        fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
        fields[UNIDADE_NEGOCIO.fieldApiName] = this.idEmpresa;
        fields[CANAL_FIELD.fieldApiName] = this.valueCanal;
        fields[ASSUNTO_FIELD.fieldApiName] = 'Cartão';
        fields[EVENT_FIELD.fieldApiName] = this.AceiteAvaliacao ? 'Desativação de avaliação emergencial de crédito' : 'Ativação de avaliação emergencial de crédito';
        fields[RECORD_TYPE_ID.fieldApiName] = this.recordTypeId;
        fields[CONTA_FINANCEIRA_FIELD.fieldApiName] = this.recordId;

        // Chama o método createRecord
        const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then((caseRecord) => {
                this.caseId = caseRecord.id;
                this.numeroProtocolo = caseRecord.CaseNumber;
            })
            .catch((error) => {
                console.error('Erro ao criar o caso:', error);
            });
    }

    navegateToIncluir(){

        const closeEvent = new CloseActionScreenEvent();
        this.dispatchEvent(closeEvent);
        
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName:"ContaFinanceira__c.IncluirAdicional"
            },
            state: {
                recordId: this.recordId
            }
        });
        
    }

    viewToCase(){
        const closeEvent = new CloseActionScreenEvent();
        this.dispatchEvent(closeEvent);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseId,
                objectApiName: 'Case',
                actionName: 'view'
            },
            state: {
                entityName: 'Case'
            }
        });
    }
    
    handleChangeOrigem(event) {
        this.valueOrigin = event.detail.value;
        this.valueCanal = null;
        this.updateComboboxOptions();
        this.updateProsseguirState();
    }
    
    handleChangeCanal(event) {
        this.valueCanal = event.detail.value;
        this.updateProsseguirState();
    }
    

    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
        this.spinner = false;
    }

    changeToggle(event) {
        this.toggle = event.target.checked;
        this.updateProsseguirState();
    }
    
    updateProsseguirState() {
        const camposPreenchidos = this.valueOrigin != null && this.valueCanal != null;
        const toggleFoiAlterado = this.toggle !== this.AceiteAvaliacao;
        
        this.disabledProsseguir = !(camposPreenchidos && toggleFoiAlterado);
    }
    
    closeQuickAction() {
        const closeEvent = new CloseActionScreenEvent();
        this.dispatchEvent(closeEvent);
    }

    async prosseguirTermos() {
        this.showModalDadosConta = false;
        this.showModalTermos = true;
        await this.handleConsultarTermo();
    }

    async handleVoltarDadosConta() {
        await this.handleAceiteAvaliacao();
        this.showModalTermos = false;
        this.showModalDadosConta = true;
        this.disabledProsseguir = true;

    }

    async prosseguirAlteracao(){
        await this.handleGravarAvaliacao();
        this.showModalTermos = false;
        if(this.errorGravacao === false){
            this.createCase();
            this.showModalAlteracao = true;
        }else{
            if(this.AceiteAvaliacao){
                this.showToastError('Não foi possível gravar cancelamento de avaliação emergencial');
            }else {
                this.showToastError('Não foi possível gravar adesão de avaliação emergencial');
            }
            this.showModalTermos = true;
        }
    }

    formatarDataParaUS(dataBR){
        if (!dataBR) return null;
        const [dia, mes, ano] = dataBR.split('/');
        return `${ano}-${mes}-${dia}`;
    }

    //Mensagens de erro
    showToastError(message){
        const evt = new ShowToastEvent({
            title: 'Erro!',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}