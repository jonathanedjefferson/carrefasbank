import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import CreateCaseTDCA from '@salesforce/apex/VarejoCreateCaseController.CreateCaseTDCA';
import GetStaticRessource from '@salesforce/apex/VarejoCreateCaseController.getStaticRessource';

import VAREJO_CASE_ID from "@salesforce/schema/MessagingSession.VarejoCaseId__c";
import BOT_PROTOCOLO from "@salesforce/schema/MessagingSession.Bot_Protocolo_Varejo__c";
import TIPO_PROTOCOLO from "@salesforce/schema/MessagingSession.Tipo_Protocolo_Varejo__c";
import MOTIVO_PROTOCOLO from "@salesforce/schema/MessagingSession.Motivo_Protocolo_Varejo__c";
import CONSIGNMENT_CODE from "@salesforce/schema/MessagingSession.Consignment_Code_Protocolo_Varejo__c";
import NUMERO_PEDIDO from "@salesforce/schema/MessagingSession.Numero_Pedido_Protocolo_Varejo__c";
import EMAIL_PROTOCOLO from "@salesforce/schema/MessagingSession.Email_Protocolo_Varejo__c";
import DESCRICAO_PROTOCOLO from "@salesforce/schema/MessagingSession.DescricaoProtocoloVarejo__c";
import CPF from "@salesforce/schema/MessagingSession.CPF__c";
import BRAND from "@salesforce/schema/MessagingSession.Brand_Protocolo_Varejo__c";
import PRIMEIRO_NOME from "@salesforce/schema/MessagingSession.PrimeiroNome__c";
import SOBRE_NOME from "@salesforce/schema/MessagingSession.Sobrenome__c";
import TELEFONE from "@salesforce/schema/MessagingSession.MessagingEndUser.MessagingPlatformKey";


const FIELDS_MESSAGING = [VAREJO_CASE_ID, BOT_PROTOCOLO, TIPO_PROTOCOLO, MOTIVO_PROTOCOLO, CONSIGNMENT_CODE, NUMERO_PEDIDO, EMAIL_PROTOCOLO, DESCRICAO_PROTOCOLO, CPF, BRAND, PRIMEIRO_NOME, SOBRE_NOME, TELEFONE];

export default class VarejoCreateCase extends LightningElement {
    //#region ########################### VARIAVEIS ###########################
    @api recordId;
    @track spinner = true;
    @track showDetalhes = true;
    @track urlOrgVarejo = '';
    
    @track varejoCaseId = ''; 
    @track botProtocolo = ''; 
    @track tipoProtocolo = ''; 
    @track motivoProtocolo = ''; 
    @track consignmentCode = ''; 
    @track numeroPedido = ''; 
    @track emailProtocolo = ''; 
    @track descricaoProtocolo = ''; 
    @track cpf = ''; 
    @track customerName = ''; 
    @track telephone = ''; 
    @track description = '';
    @track brand = '';
    @track channel = 'WhatsApp';
    

    @track caseNumber = '';
    //#endregion ########################### VARIAVEIS ###########################

    //#region ########################### INICIO ###########################
    @wire(getRecord, { recordId: "$recordId", fields: FIELDS_MESSAGING })
    async GetRecordMessagingSession({error, data}){
        if(data){
            this.varejoCaseId       = getFieldValue(data, VAREJO_CASE_ID);
            this.botProtocolo       = getFieldValue(data, BOT_PROTOCOLO);
            this.tipoProtocolo      = getFieldValue(data, TIPO_PROTOCOLO);
            this.motivoProtocolo    = getFieldValue(data, MOTIVO_PROTOCOLO);
            this.consignmentCode    = getFieldValue(data, CONSIGNMENT_CODE);
            this.numeroPedido       = getFieldValue(data, NUMERO_PEDIDO);
            this.emailProtocolo     = getFieldValue(data, EMAIL_PROTOCOLO);
            this.descricaoProtocolo = getFieldValue(data, DESCRICAO_PROTOCOLO);
            this.cpf                = getFieldValue(data, CPF);
            this.brand              = getFieldValue(data, BRAND);
            this.telephone          = getFieldValue(data, TELEFONE);
            this.customerName       = getFieldValue(data, PRIMEIRO_NOME) + ' ' + getFieldValue(data, SOBRE_NOME);
            
            
            if(this.tipoProtocolo != '' && this.tipoProtocolo != undefined && this.tipoProtocolo != null){
                if (this.varejoCaseId == '' || this.varejoCaseId == undefined || this.varejoCaseId == null) {
                    await this.CreateCase();
                }
            }else{
                this.showDetalhes = false;
            }
            await this.GetStaticRessource(this.varejoCaseId);
            this.spinner = false;
        }else if(error){
            console.log('GetRecordMessagingSession ERROR::: ' + error);
            console.log('GetRecordMessagingSession ERROR::: ' + error.body.message);

        }
    }

    //#endregion ########################### INICIO ###########################

    //#region ########################### CLASSES ###########################
    async CreateCase(){        
        await CreateCaseTDCA({
            messagingId     : this.recordId,
            channel         : this.channel,
            orderNumber     : this.numeroPedido, 
            consignmentCode : this.consignmentCode, 
            document        : this.cpf, 
            emailClient     : this.emailProtocolo, 
            customerName    : this.customerName, 
            telephone       : this.telephone, 
            description     : this.descricaoProtocolo, 
            brand           : this.brand,
            bot             : this.botProtocolo, 
            protocolo       : this.tipoProtocolo, 
            opcao           : this.motivoProtocolo
        }).then(result=>{
            if (result == 'ERROR') {
                this.showDetalhes = false;
                console.log('CreateCase ERROR API:::');
            }else{
                this.varejoCaseId = result;
            }
        }).catch(error=>{
            this.showDetalhes = false;
            console.log('CreateCase ERROR Catch::: ' + error);
            console.log('CreateCase ERROR Catch::: ' + error.body.message);
        });
    }

    async GetStaticRessource(caseId){
        await GetStaticRessource({}).then(result=>{
            this.urlOrgVarejo = JSON.parse(result).OrgVarejoUrl + '/lightning/r/Case/' + caseId + '/view';
        }).catch(error=>{
            console.log('GetStaticRessource ERROR Catch::: ' + error);
            console.log('GetStaticRessource ERROR Catch::: ' + error.body.message);
        });
    }
    //#endregion ########################### API ###########################
}