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
import getContaFinanceira from '@salesforce/apex/InclusaoAdicionalController.getContaFinanceira';
import solicitarCartaoAdicional from '@salesforce/apex/InclusaoAdicionalController.solicitarCartaoAdicional';
import createCaseSolicitarAdicional from '@salesforce/apex/InclusaoAdicionalController.createCaseSolicitarAdicional';

const OPTIONS_GENERO = [
    { label: 'MASCULINO'    , value: 'M' },
    { label: 'FEMININO'     , value: 'F' },
];

export default class BCSF_InclusaoAdicional extends LightningElement {

    date = new Date();
    month = (this.date.getMonth() + 1) < 10 ? '0'+(this.date.getMonth() + 1) : (this.date.getMonth() + 1);
    day = this.date.getDate()  < 10 ? '0' + this.date.getDate() : this.date.getDate();
    @track dateToday = this.day + '/' + this.month + '/' + this.date.getFullYear();
    
    //#region Variaveis 
    spinner = false;
    closeModalComponent = true;
    abrirAlteracaoCadastral = false;
    sucessoInclusao = false;
    titleErro = '';
    msgErro = '';
    caseId = null;
    numeroCaso = null;

    @api recordId;
    @track optionsGenero = OPTIONS_GENERO;
    
    @track showCardPrincipal = false;
    @track stepOne = true;
    @track stepTwo = false;
    @track stepThree = false;

    @track nome = '--';
    @track unidadeDescricao = null;
    @track logoTipo = null;
    @track statusConta = '--';

    @track cep = '--';
    @track logradouro = '--';
    @track numeroEndereco = '--';
    @track complemento = '--';
    @track bairro = '--';
    @track cidade = '--';
    @track estado = '--';
    @track telefone = '--';
    @track dataNascimentoAdicionalDesc = null;
    @track sexoAdicionalDesc = null;

    areaPrincipal = null;
    numeroConta = null;
    cpf = null;
    idEmpresa = null;
    accountId = null;
    cpfAdicional = '';
    nomeAdicional = null;
    sexoAdicional = null;
    dataNascimentoAdicional = null;
    campoDataNascimentoValido = false;
    campoNomeAdicionalValido = false;
    campoSexoAdicionalValido = false;
    campoCPFAdicionalValido = false;

    @track origemValue;
    @track canalValue;
    
    @track disableButtonSalvar = true;
    @track disableButtonProsseguir = true;

    //#endregion

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

    connectedCallback() {
        this.showSpinner();
        this.getDadosContaFinanceira();
        this.closeSpinner();
    }

    getDadosContaFinanceira() {
        getContaFinanceira({ recordId: this.recordId })
            .then(result => {
                this.cpf = result.CPF;
                this.numeroConta = result.NumeroConta;
                this.idEmpresa = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.nome = result.Nome;
                this.statusConta = result.StatusConta;
                this.tipoProduto = result.TipoConta;

                this.cep = result.CEP;
                this.logradouro = result.Rua;
                this.numeroEndereco = result.NumeroCasa;
                this.complemento = result.Complemento;
                this.bairro = result.Bairro;
                this.cidade = result.Cidade;
                this.estado = result.Estado;
                this.telefone = result.Telefone;

                if (this.idEmpresa == "1") {
                    this.unidadeDescricao = 'CARREFOUR';
                    this.logoTipo = LogoCarrefour;
                } else if (this.idEmpresa == "2") {
                    this.unidadeDescricao = 'ATACADÃO';
                    this.logoTipo = LogoAtacadao;
                }else if (this.idEmpresa == "6"){
                    this.unidadeDescricao = "SAM'S CLUB";
                    this.logoTipo = LogoSamsClub;
                }

                this.showCardPrincipal = true;
            })
            .catch(error => {
                console.log(error);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', 'dismissible', true);
            });
    }

   //#region métodos handle

    handleButtonCancelar() {
        this.closeQuickAction();
    }

    handleButtonVoltar() {
        this.stepTwo =  false;
        this.stepOne = true;

        this.canalValue = null;
        this.origemValue = null;
        this.verifyDisabled();
    }

    handleButtonReiniciar() {
        this.cpfAdicional = '';
        this.nomeAdicional = null;
        this.sexoAdicional = null;
        this.dataNascimentoAdicional = null;
        this.campoDataNascimentoValido = false;
        this.campoNomeAdicionalValido = false;
        this.campoSexoAdicionalValido = false;
        this.campoCPFAdicionalValido = false;
        this.origemValue = false;
        this.canalValue = false;
        this.sucessoInclusao = false;
        this.disableButtonSalvar = true;
        this.disableButtonProsseguir = true;

        this.stepOne = true;
        this.stepTwo = false;
        this.stepThree = false;
    }

    async handleButtonSalvar(event) {
        this.showSpinner(); 
        await this.solicitarCartaoAdicional();
        
        if(this.sucessoInclusao){
            await this.CriarCaso();
            this.stepTwo = false;
            this.stepThree = true;
        } else {
            this.showToast(this.titleErro, this.msgErro, 'error', 'dismissible', false);
        }

        this.closeSpinner();
    }

    handleButtonIrCaso(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
    }

    handleChangeOrigem(event){
        this.origemValue = event.target.value;
        this.canalValue = null;
        this.verifyDisabled();
    }
    handleChangeCanal(event){
        this.canalValue = event.target.value;
        if(this.canalValue === ''){
            this.canalValue = null;
        }
        this.verifyDisabled();
    }

    handleButtonAlteracaoCadastral(event) {
        this.showCardPrincipal = false;
        this.abrirAlteracaoCadastral = true;
    }

    //#endregion

    //#region métodos Toast, Spinner e verify
    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante, mode, closeModal) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            messageData: [],
            variant: variante,
            mode: mode
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            this.closeQuickAction();
        }
    }

    @api closeParentComponent;
    closeQuickAction() {
        if (this.closeParentComponent) {
            this.abrirAlteracaoCadastral = false;
            this.dispatchEvent(new CustomEvent('closeparentmodal'));
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    //#endregion

    async solicitarCartaoAdicional() {        
        await solicitarCartaoAdicional({
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            canal: 'cockpit',
            area: this.areaPrincipal,
            sistema: 'cockpit',
            idEmpresa: this.idEmpresa,
            cpfAdicional: this.cpfAdicional.replaceAll('.', '').replaceAll('-', ''),
            nomeAdicional: this.nomeAdicional,
            sexoAdicional: this.sexoAdicional,
            dataNascimentoAdicional: this.dataNascimentoAdicional
        }).then(result => {
            
            this.sucessoInclusao = false;
            if (result == null || result.statusAPI === 'ERROR'){
                this.titleErro =  'Ocorreu um erro na solicitação.';
            } else {
                if(result.statusAPI == 'OK') {
                    this.sucessoInclusao = true;  
                } else {
                    this.msgErro = result.mensagem;
                }
            }
        }).catch(error => {
            console.log(error);
        });
    }

    async CriarCaso() {
        await createCaseSolicitarAdicional({
            canal: this.canalValue,
            origem: this.origemValue,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa
        }).then(result => {
            if (result){
                this.numeroCaso = result.CaseNumber;
                this.caseId = result.Id;   
            }
        }).catch(error => {
            console.log(error);
            this.showToast('Erro', 'Houve um erro ao criar Caso.', 'error', 'dismissible', true);
        });
    }

    irParaConfirmacao(){
        this.disableButtonSalvar = true;
        this.stepOne = false;
        this.stepTwo = true;
    }

    verifyDisabled(){
        if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null || this.canalValue == undefined) {
            this.disableButtonSalvar = true;
        } else {
            this.disableButtonSalvar = false;
        }
    }

    handlerField(event){
        try {
            let idCampo = event.target.id;
            let valorCampo = event.target.value != null ? event.target.value.trim().toUpperCase() : '';
            let numeroApenas = this.returnApenasNumero(valorCampo);
            let specialCharPattern = /[^a-zA-Z0-9áéíóúÁÉÍÓÚãõÃÕâêîôûÂÊÎÔÛàèìòùÀÈÌÒÙäëïöüÄËÏÖÜçÇ\s]/;
            let temCaracterEspecial = specialCharPattern.test(valorCampo);
            let input = event.target;

            if (idCampo.includes('dataNascimentoAdicional')) {
                if (numeroApenas.length == 8) {
                    let dataCorrente =  new Date();
                    dataCorrente.setFullYear(dataCorrente.getFullYear() - 18);
                    var dataNascimento = new Date(valorCampo + 'T03:00:00');

                    let ehMaior = dataNascimento <= dataCorrente;
                    this.dataNascimentoAdicional = valorCampo;
                    this.dataNascimentoAdicionalDesc = this.formatDate(dataNascimento);
                    if (ehMaior) {
                        input.setCustomValidity('');
                        this.campoDataNascimentoValido = true;
                    }else{
                        input.setCustomValidity('O adicional deve ser maior de 18 anos.');
                        this.campoDataNascimentoValido = false;
                    }
                }else{
                    input.setCustomValidity('Sua entrada não corresponde ao formato permitido DD/MM/AAAA');
                    this.campoDataNascimentoValido = false;
                }
            } else if (idCampo.includes('sexoAdicional')) {
                this.campoSexoAdicionalValido = true;
                this.sexoAdicionalDesc = valorCampo === 'M' ? 'MASCULINO' : 'FEMININO';
                this.sexoAdicional = valorCampo;
            } else if(idCampo.includes('nomeAdicional')) {
                if(temCaracterEspecial || numeroApenas.length > 0){
                    input.setCustomValidity('Não pode conter caracteres especiais ou números.');
                    this.campoNomeAdicionalValido = false;
                } else {
                    let valorNome = valorCampo.split(' ');
                    let nomeIncompleto = false;
                    if(valorNome.length < 2){
                        nomeIncompleto = true;
                    }

                    valorNome.forEach(item => {
                        if(item.trim() === ''){
                            nomeIncompleto = true;
                        }
                    });

                    this.nomeAdicional = valorCampo;
                    
                    if(nomeIncompleto){
                        input.setCustomValidity('Obrigatório nome e sobrenome.');
                        this.campoNomeAdicionalValido = false;
                    } else {
                        input.setCustomValidity('');
                        this.campoNomeAdicionalValido = true;
                    }
                }
            }

            this.disableButtonProsseguir = !this.campoCPFAdicionalValido || !this.campoDataNascimentoValido
                || !this.campoNomeAdicionalValido || !this.campoSexoAdicionalValido; 
        } catch (error) {
            console.log('ERROR handlerField: ' + error);   
            
        }
    }

    handlerCPF(event){
        try {
            let valueInput = this.returnApenasNumero(event.detail.value);
            let input = event.target;
            
            if (valueInput.length > 3 && valueInput.length < 7) {
                this.cpfAdicional = valueInput.replace(/(\d{3})/, '$1.');
            }else if (valueInput.length >= 7 && valueInput.length < 10) {
                this.cpfAdicional = valueInput.replace(/(\d{3})(\d{3})/, '$1.$2.');
            }else if (valueInput.length == 10 || valueInput.length == 11) {
                this.cpfAdicional = valueInput.replace(/(\d{3})(\d{3})(\d{3})/, '$1.$2.$3-');
            }
            
            let cpfValido = this.validarCPF(valueInput);
            this.campoCPFAdicionalValido = cpfValido;

            if (cpfValido) {
                input.setCustomValidity('');
            }else{
                input.setCustomValidity('CPF incorreto, tente novamente.');
            }

            this.disableButtonProsseguir = !this.campoCPFAdicionalValido || !this.campoDataNascimentoValido
                || !this.campoNomeAdicionalValido || !this.campoSexoAdicionalValido; 
        } catch (error) {
            console.log('ERROR handlerCPF: ' + error);   
        }
    }

    returnApenasNumero(valor){
        return valor.replace(/\D/g, '');
    }

    formatDate(data){
        var dia = data.getDate();
        var mes = data.getMonth() + 1;
        var ano = data.getFullYear();

        if(dia < 10) dia  = '0' + dia;
        if(mes < 10) mes  = '0' + mes;
        
        return dia + '/' + mes + '/' + ano;
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

}