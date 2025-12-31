import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';

import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';

import alterarDadosCadastrais from '@salesforce/apex/AlteracaoCadastralController.AlterarDadosCadastrais';
import getAvaliacaoAlteracaoCadastral from '@salesforce/apex/AlteracaoCadastralController.GetAvaliacaoAlteracaoCadastral';
import updateCaseAvaliacao from '@salesforce/apex/AlteracaoCadastralController.UpdateCaseAvaliacao';

const OPTIONS = [
    { label: 'Sim', value: 'Sim' },
    { label: 'Não', value: 'Não' },
];

export default class AvaliacaoAlteracaoCadastral extends LightningElement {
    @api recordId;
    spinner = false;
    @api IdFormsAvaliacao = '';
    @track showInfo = true;
    @track showEditForm = false;
    @track showModal = false;
    @track disableFinalizar = true;
    @track step01 = false;
    @track step02 = false;
    
    @track MudouCPF = false;
    @track TelefoneContato = '';
    @track SolicitacaoCartao = '';
    @track CPF = '';
    @track Complemento = '';
    @track Cidade = '';
    @track Email = '';
    @track CEP = '';
    @track NumeroCasa = '';
    @track Bairro = '';
    @track UF = '';
    @track IdConta = '';
    @track IdContaFinanceira = '';
    @track IdCaso = '';
    @track avaliacaoJson = '';
    @track Rua = '';
    @track TelefoneResidencial = '';
    @track TelefoneCelular = '';
    @track TelefoneCelularOrign = '';
    @track SolicitacaoCartao = '';
    
    options01 = OPTIONS;
    options02 = OPTIONS;
    options03 = OPTIONS;
    @track StatusSolicitacao = '--';
    valueIncidenciaFraude = '';
    valueFalouLGPD = '';
    valueProtocoloIndevido = '';
    valueDescricao = '';
    
    canal = 'cockpit';
    @track bodyRequestAlterarDados = {};

//#region ######################################## INICIALIZAÇÃO ########################################
    @wire(getRecord, { recordId: "$recordId", fields: [CASE_NUMBER]}) 
    currentCaseInfo({error, data}) {
        if (data) {
            this.CaseNumber = data.fields.CaseNumber.value;
        } else if (error) {
            console.log('ERROR WIRE: ' + error);
            this.error = error ;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error ;
        }
    }

    async connectedCallback() { 
        console.log('ConnectedCallback - bcsf_AvaliacaoAlteracaoCadastral');
        this.showSpinner();
        await this.getAvaliacaoAlteracaoCadastral();
        this.closeSpinner();
    }
//#endregion 

//#region ######################################## QUERY / DML ########################################
    async getAvaliacaoAlteracaoCadastral(){
        this.showSpinner();
        await getAvaliacaoAlteracaoCadastral({
            caseId: this.recordId
        }).then(result => {
            try {
                if (result != null) {
                    this.CPFCliente                 = result.CPFCliente             == '--' ? ''   : result.CPFCliente;
                    this.IdFormsAvaliacao           = result.IdAvaliacao            == '--' ? null : result.IdAvaliacao;
                    this.TelefoneContato            = result.TelefoneContato        == '--' ? null : `(${result.TelefoneContato.substring(2, 4)}) ${result.TelefoneContato.substring(4, 9)}-${result.TelefoneContato.substring(9)}`;
                    this.SolicitacaoCartao          = result.SolicitacaoCartao      == '--' ? null : result.SolicitacaoCartao;
                    this.MudouCPF                   = result.MudouCPF               == '--' ? null : result.MudouCPF;
                    this.CPF                        = result.CPF                    == '--' ? null : result.CPF;
                    this.Complemento                = result.Complemento            == '--' ? null : result.Complemento;
                    this.Cidade                     = result.Cidade                 == '--' ? null : result.Cidade;
                    this.Email                      = result.Email                  == '--' ? null : result.Email;
                    this.CEP                        = result.CEP                    == '--' ? null : result.CEP;
                    this.NumeroCasa                 = result.NumeroCasa             == '--' ? null : result.NumeroCasa;
                    this.Bairro                     = result.Bairro                 == '--' ? null : result.Bairro;
                    this.UF                         = result.UF                     == '--' ? null : result.UF;
                    this.IdConta                    = result.IdConta                == '--' ? null : result.IdConta;
                    this.IdContaFinanceira          = result.IdContaFinanceira      == '--' ? null : result.IdContaFinanceira;
                    this.IdCaso                     = result.IdCaso                 == '--' ? null : result.IdCaso;
                    this.NumeroConta                = result.NumeroConta            == '--' ? null : result.NumeroConta;
                    this.UnidadeNegocio             = result.UnidadeNegocio         == '--' ? null : result.UnidadeNegocio;
                    this.Rua                        = result.Rua                    == '--' ? null : result.Rua;
                    this.TelefoneResidencial        = result.TelefoneResidencial    == '--' ? null : `(${result.TelefoneResidencial.substring(2, 4)}) ${result.TelefoneResidencial.substring(4, 9)}-${result.TelefoneResidencial.substring(9)}`;
                    this.TelefoneCelular            = result.TelefoneCelular        == '--' ? null : `(${result.TelefoneCelular.substring(2, 4)}) ${result.TelefoneCelular.substring(4, 9)}-${result.TelefoneCelular.substring(9)}`;
                    this.SolicitacaoCartao          = result.SolicitacaoCartao      == '--' ? null : result.SolicitacaoCartao;

                    this.TelefoneContatoInfo    = result.TelefoneContato != '--' ? `(${result.TelefoneContato.substring(2, 4)}) ${result.TelefoneContato.substring(4, 9)}-${result.TelefoneContato.substring(9)}` : '--'; 
                    this.ComplementoInfo        = result.Complemento;
                    this.EmailInfo              = result.Email;
                    this.BairroInfo             = result.Bairro;
                    this.SolicitacaoCartaoInfo  = result.SolicitacaoCartao;
                    this.CidadeInfo             = result.Cidade;
                    this.CEPInfo                = result.CEP;
                    this.UFInfo                 = result.UF;
                    this.RuaInfo                = result.Rua;
                    this.NumeroCasaInfo         = result.NumeroCasa;

                    this.avaliacaoJson              = result;
                    console.log('TESTE: ' + this.TelefoneCelular);
                }
            } catch (error) {
                console.log('ERROR catch() getAvaliacaoAlteracaoCadastral: '+ error);   
                this.showToast('ERRO', 'Houve um erro ao buscar informações!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getAvaliacaoAlteracaoCadastral: '+ error.body.message);
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
        });
        this.closeSpinner();
    }

    async updateCaseAvaliacao(){
        this.showSpinner();
        await updateCaseAvaliacao({
            accId               : this.IdConta,
            cfId                : this.IdContaFinanceira,
            caseId              : this.recordId,
            description         : this.valueDescricao,
            avaliacaoid         : this.IdFormsAvaliacao, 
            statusAv            : this.StatusSolicitacao, 
            incidenciaFraude    : this.valueIncidenciaFraude == 'Sim' ? true : false, 
            falouLGPD           : this.valueFalouLGPD == 'Sim' ? true : false, 
            protIndevido        : this.valueProtocoloIndevido == 'Sim' ? true : false,
            mudouCPF            : this.MudouCPF,
            avaliacaoJson       : JSON.stringify(this.avaliacaoJson)
        }).then(() => {
            
        }).catch(error => {
            console.log('Erro updateCase: '+ error.body.message);
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao realizar operação!', 'error', true);
        });
        this.closeSpinner();
    }
//#endregion

//#region ######################################## CHAMADAS API ########################################
    async alterarDadosCadastrais(){
        await alterarDadosCadastrais({
            cpf                 : this.returnApenasNumero(this.CPFCliente), 
            idEmpresa           : this.UnidadeNegocio, 
            canal               : this.canal, 
            numeroConta         : this.NumeroConta, 
            area                : this.area, 
            sistema             : this.area, 
            bodyRequest         : JSON.stringify(this.bodyRequestAlterarDados)
        }).then(result => {
            try {
                if (result) {
                    this.podeCriarCaso = true;
                }else{
                    console.log('Erro else - alterarDadosCadastrais: ');
                    this.showToast('Erro', 'Houve um erro ao realizar operação!', 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() alterarDadosCadastrais: '+ error);   
                this.showToast('Erro', 'Houve um erro ao realizar operação!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro alterarDadosCadastrais: '+ error.body.message);
            console.dir(error);
            this.showToast('Erro', 'Houve um erro ao realizar operação!', 'error', true);
        });
    }
//#endregion 

//#region ######################################## METODOS HANDLRES ########################################
    async handleEdit(){
        this.showEditForm = !this.showEditForm;
        this.showInfo = !this.showInfo;
    }
    
    async handleSave(){
        this.showSpinner();

        await setTimeout(() =>{
            this.getAvaliacaoAlteracaoCadastral();
            this.showEditForm = !this.showEditForm;
            this.showInfo = !this.showInfo;
            this.closeSpinner();
        }, "1000");
    }

    async finalizar(){
        if (this.step01) {
            this.showSpinner();
            if (this.StatusSolicitacao == 'Aprovado' && !this.MudouCPF) {
                await this.alterarDadosCadastrais();
            }
            await this.updateCaseAvaliacao();
            this.step01 = false;
            this.step02 = true;
            this.closeSpinner();
        }else if(this.step02){
            this.step02 = false;
            this.closeModal();
            this.updateComponents();
        }
    }

    handleAprovar(){
        this.StatusSolicitacao = 'Aprovado';
        this.abrirModal();
        this.MontarJson();
    }
    
    handleReprovar(){
        this.StatusSolicitacao = 'Reprovado';
        this.abrirModal();
    }

    abrirModal(){
        this.step01 = true;
        this.step02 = false;
        this.showModal = true;
    }

    handleBtnRadio(event){
        let valueBtn = event.target.value;
        let idCampo = event.target.id;

        if (idCampo.includes('valueIncidenciaFraude')) {
            this.valueIncidenciaFraude = valueBtn;
        }else if (idCampo.includes('valueFalouLGPD')) {
            this.valueFalouLGPD = valueBtn;
        }else if (idCampo.includes('valueProtocoloIndevido')) {
            this.valueProtocoloIndevido = valueBtn;
        }
        this.verifyDisable();
    }

    handleDescricao(event){
        this.valueDescricao = event.target.value;
        this.verifyDisable();
    }

    async updateComponents(){
        await this.dispatchEvent(new RefreshEvent());
    }

    MontarJson(){
        let Cliente = {};
        
        let DadosGerais = {};
        let Contrato = {};
        let Documentos = {};
        let Endereco = {};
        let Contato = {};
        let Consentimentos = {};
        
        DadosGerais.sobrenome           = null;
        DadosGerais.primeiroNome        = null;
        DadosGerais.dataNascimento      = null;
        DadosGerais.sexo                = null;
        DadosGerais.naturalidade        = null;
        DadosGerais.estadoCivil         = null;
        DadosGerais.nomeMae             = null;
        
        Contrato.numeroConta            = this.NumeroConta;
        Documentos.rg                   = null;
        
        Endereco.cep                    = this.CEP;
        Endereco.logradouro             = this.Rua;
        Endereco.numero                 = this.NumeroCasa;
        Endereco.complemento            = this.Complemento;
        Endereco.bairro                 = this.Bairro;
        Endereco.cidade                 = this.Cidade;
        Endereco.uf                     = this.UF;
        
        Contato.dddTelefoneResidencial  = this.TelefoneResidencial  == null ? null : this.returnApenasNumero(this.TelefoneResidencial).substring(0, 2);
        Contato.telefoneResidencial     = this.TelefoneResidencial  == null ? null : this.returnApenasNumero(this.TelefoneResidencial);
        Contato.dddTelefoneCelular      = this.TelefoneCelular      == null ? null : this.returnApenasNumero(this.TelefoneCelular).substring(0, 2);
        Contato.telefoneCelular         = this.TelefoneCelular      == null ? null : this.returnApenasNumero(this.TelefoneCelular).substring(2);
        Contato.email                   = this.Email;
        
        Consentimentos.aceiteRecebimentoEmail           = null;
        Consentimentos.indicadorAceiteAtualizacaoLimite = null;
        
        
        Cliente.dadosGerais         = DadosGerais;
        Cliente.contrato            = Contrato;
        Cliente.documentos          = Documentos;
        Cliente.endereco            = Endereco;
        Cliente.contato             = Contato;
        Cliente.consentimentos      = Consentimentos;
        
        this.bodyRequestAlterarDados.cliente = Cliente;
    }

//#endregion

//#region ######################################## INTERAÇÕES COM O USUÁRIO ########################################
    showToast(titulo, mensagem, variante, closeModal) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        this.showModal = !closeModal;
    }

    showSpinner() {
        this.spinner = true;
    }

    closeSpinner() {
        this.spinner = false;
    }

    closeModal(){
        this.showModal = false;
        this.valueIncidenciaFraude = '';
        this.valueFalouLGPD = '';
        this.valueProtocoloIndevido = '';
        this.valueDescricao = '';
    }

    verifyDisable(){
        if (this.valueIncidenciaFraude  == '' || this.valueIncidenciaFraude  == null || this.valueIncidenciaFraude  == undefined ||
            this.valueFalouLGPD         == '' || this.valueFalouLGPD         == null || this.valueFalouLGPD         == undefined ||
            this.valueProtocoloIndevido == '' || this.valueProtocoloIndevido == null || this.valueProtocoloIndevido == undefined ||
            this.valueDescricao         == '' || this.valueDescricao         == null || this.valueDescricao         == undefined) {
            this.disableFinalizar = true;
        }else{
            this.disableFinalizar = false;
        }
    }

    returnApenasNumero(valor){
        return valor.replace(/\D/g, '');
    }
//#endregion
}