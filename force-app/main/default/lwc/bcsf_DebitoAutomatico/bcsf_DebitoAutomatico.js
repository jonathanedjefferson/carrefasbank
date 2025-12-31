import { LightningElement, track,api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getContaFinanceira from '@salesforce/apex/DebitoAutomaticoController.getContaFinanceira';
import getBancos from '@salesforce/apex/DebitoAutomaticoController.getBancos';
import getStatus from '@salesforce/apex/DebitoAutomaticoController.consultarDebitoAutomatico';
import cadastrarDebito from '@salesforce/apex/DebitoAutomaticoController.cadastrarDebitoAutomatico';
import removerDebito from '@salesforce/apex/DebitoAutomaticoController.removerDebitoAutomatico';
import criarCaso from '@salesforce/apex/DebitoAutomaticoController.criarCaso';


export default class Bcsf_DebitoAutomatico extends LightningElement {

    @api recordId;

    @track buttonAvancar = 'Prosseguir';
    @track buttonVoltar = 'Cancelar';
    @track disableButtonAvancar = true;
    @track disableButtonVoltar = false;
    @track disableNomeCorrentista = true;
    @track disableBanco = false;
    @track disableAgencia = false;
    @track disableNumeroConta = false;
    @track disabelDebitoPosVencimento = false;
    @track disableChequeEspecial = false;
    @track checkedToggle = false;
    @track step01 = false;
    @track step02 = false;
    @track step03 = false;
    @track showAvisoAtivacao = true;
    @track showAvisoDesativacao =  false;
    @track funcionarioBanco = false;
    @track showDetails = false;
    @track isDebitoAtivo = false;
    @track edicaoDebito = false;
    @track desativarDebito = false;
    @track showAlertaAtivacao = true;
    @track showAlertaDesativacao = false;
    @track showResumo = true;
    @track showIconeAguardando = true;
    @track showIconeConcluido = false;
    @track showToggle = true;
    @track showButonAvancar = true;
    @track spinner = false;
    @track showHeaderBU = false;
    @track loadComponent = false;

    //dados debito
    @track bancoCliente;
    @track nomeBancoCliente;
    @track agenciaCliente;
    @track numeroContaBancoCliente;
    @track tipoDebitoCliente;
    @track tipoPagamento;
    @track aceitaChequeEspecial;
    @track aceitarPagamentoPosVencimento;

    //dados originais de debito
    @track bancoClienteOriginal;
    @track agenciaClienteOriginal;
    @track numeroContaBancoClienteOriginal;
    @track tipoPagamentoOriginal;

    @track nomeTitular;
    @track tipoConta;
    @track logoTipo;
    @track numeroContaCliente;
    @track UnidadeNegocio;
    @track cpfCliente;

    //dadosCaso
    @track origemCaso;
    @track idConta;
    @track canalCaso;
    @track tipoCaso;
    @track eventoCaso;
    @track numeroCaso;
    @track protocolo;
    @track idCaso;
    @track assuntoCaso = 'Débito automático'

    optionsBanco = [];

    @track tipoDebito;


    get options() {
        return [
            { label: 'Sim', value: 'Sim'},
            { label: 'Não', value: 'Não' },
        ];
    }
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback(){
        this.showSpinner(true);
        this.getInfosContaFinanceira();
        this.getInfosBancos();
    }

    getInfosContaFinanceira(){
        getContaFinanceira({
            recordId: this.recordId
        }).then( async result => {
            this.nomeTitular = result.Nome;
            this.numeroContaCliente = result.NumeroConta;
            this.cpfCliente = result.CPF.replace(/\D/g, '');
            this.UnidadeNegocio = result.UnidadeNegocio;
            this.idConta = result.AccountId;
            await this.getLogo(result.UnidadeNegocio);
            await this.getStatusDebito();
        }).catch(error => {
            if (error && error.body && error.body.message) {
                console.log('Erro getInfosContaFinanceira: ' + error.body.message);
            } else {
                console.log('Erro desconhecido: ', error);
            }
            this.showToast('Falha ao realizar a solicitação', 'Houve um comporamento inesperado do sistema, tente novamente em instantes.', 'error', true);
        });
    }

    getLogo(unidade){
        switch(unidade){
            case "1":
                this.tipoConta = 'CARREFOUR';
                this.logoTipo = LogoCarrefour;
                break;
            case "2":
                this.tipoConta = 'ATACADÃO';
                this.logoTipo = LogoAtacadao;
                break;
            case "6":
                this.tipoConta = "SAM'S CLUB";
                this.logoTipo = LogoSamsClub;
                break;
        }
    }

    getInfosBancos() {
        getBancos().then(result => {
            let opcoesBancoMdt = this.optionsBanco = result.map(item =>{
                let label = item.Label + ' ' + item.Codigo_Banco__c;
                return  { label: label, value: item.Codigo_Banco__c.toString() }
            });
            this.optionsBanco = opcoesBancoMdt;
        }).catch((error) => {
            if (error && error.body && error.body.message) {
                console.log('Erro getInfosBancos: ' + error.body.message);
            } else {
                console.log('Erro desconhecido: ', error);
            }
        });
    }

    getStatusDebito(){
        getStatus({
            cpf: this.cpfCliente,
            numeroConta: this.numeroContaCliente,
            nomeCorrentista: this.nomeTitular,
            idEmpresa: this.UnidadeNegocio,
            canal: 'Cockpit',
        }).then(result => {
            this.loadComponent = true;
            if(result.tipoDebito == 1){
                this.step01 = true;
                this.showHeaderBU = true;
                this.isDebitoAtivo = true;
                this.checkedToggle = true;
                this.showDetails = true;
                this.setTipoPagamento(result.tipoPagamento);
                this.agenciaCliente = result.nrBancoAgencia.split('-')[1];
                this.numeroContaBancoCliente = result.numeroContaBancaria;
                this.bancoCliente = this.optionsBanco.find(option => option.value.replace(/^0+/, '') === result.nrBancoAgencia.split('-')[0]).value; // replace remove 0 na esquerda da string 
                this.nomeBancoCliente = this.optionsBanco.find(option => option.value.replace(/^0+/, '') === result.nrBancoAgencia.split('-')[0]).label; // replace remove 0 na esquerda da string
                this.tipoPagamento = result.tipoPagamento;

                this.bancoClienteOriginal = this.bancoCliente;
                this.agenciaClienteOriginal = this.agenciaCliente;
                this.numeroContaBancoClienteOriginal = this.numeroContaBancoCliente;
                this.tipoPagamentoOriginal = this.tipoPagamento;
            } else if(result.tipoDebito == 3){
                this.step01 = false;
                this.funcionarioBanco = true;
                this.showButonAvancar = false;
                this.showHeaderBU = true;
                this.buttonVoltar = 'Voltar';            
            } else{
                this.showHeaderBU = true;
                this.step01 = true;
            }
            this.showSpinner(false);
        }).catch((error) => {
            if (error && error.body && error.body.message) {
                console.log('Erro getStatusDebito: ' + error.body.message);
            } else {
                console.log('Erro desconhecido: ', error);
            }
            this.showToast('Falha ao realizar a solicitação', 'Houve um comporamento inesperado do sistema, tente novamente em instantes.', 'error', true);
        });
    }

    cadastrarDebitoAutomatico(){
        cadastrarDebito({
            cpf: this.cpfCliente,
            numeroConta: this.numeroContaCliente,
            nomeCorrentista: this.nomeTitular,
            codigoBanco: this.bancoCliente.toString().replace(/^0+/, ''), // replace remove 0 na esquerda da string
            numeroAgencia: this.agenciaCliente.toString(),
            numeroContaBancaria: this.numeroContaBancoCliente.toString(),
            tipoPagamento: this.tipoPagamento,
            idEmpresa: this.UnidadeNegocio,
            canal: 'Cockpit'
        }).then(result => {
            if(result){
                this.eventoCaso = this.edicaoDebito ? 'Alterar débito automático' : 'Cadastrar débito automático';   
                this.criarCasoSolicitacao();
            }else{
                this.showToast('Falha ao realizar a solicitação', 'Houve um comporamento inesperado do sistema, tente novamente em instantes.', 'error', true);
            }
        }).catch((error) => {
            if (error && error.body && error.body.message) {
                console.log('Erro cadastrarDebitoAutomatico: ' + error.body.message);
            } else {
                console.log('Erro desconhecido: ', error);
            }
            this.showToast('Falha ao realizar a solicitação', 'Houve um comporamento inesperado do sistema, tente novamente em instantes.', 'error', true);
        });
    }

    removerDebitoAutomatico(){
        removerDebito({
            cpf: this.cpfCliente,
            numeroConta: this.numeroContaCliente,
            nomeCorrentista: this.nomeTitular,
            codigoBanco: this.bancoCliente.toString().replace(/^0+/, ''), // replace remove 0 na esquerda da string
            numeroAgencia: this.agenciaCliente.toString(),
            numeroContaBancaria: this.numeroContaBancoCliente.toString(),
            tipoPagamento: this.tipoPagamento,
            idEmpresa: this.UnidadeNegocio,
            canal: 'Cockpit'
        }).then(result => {
            if(result){
                this.eventoCaso = 'Cancelar débito automático';
                this.criarCasoSolicitacao();
            }else{
                this.showToast('Falha ao realizar a solicitação', 'Houve um comporamento inesperado do sistema, tente novamente em instantes.', 'error', true);
            }
        }).catch((error) => {
            if (error && error.body && error.body.message) {
                console.log('Erro removerDebitoAutomatico: ' + error.body.message);
            } else {
                console.log('Erro desconhecido: ', error);
            }
            this.showToast('Falha ao realizar a solicitação', 'Houve um comporamento inesperado do sistema, tente novamente em instantes.', 'error', true);
        });
    }

    criarCasoSolicitacao(){
        criarCaso({
            origem: this.origemCaso,
            contaFinanceiraId: this.recordId, 
            accountId: this.idConta,
            unidadeNegocio: this.UnidadeNegocio, 
            canal: this.valueCanal,
            tipo: 'Execução',
            assunto: this.assuntoCaso,
            evento: this.eventoCaso
        }).then((result) => {
            this.numeroCaso = result.CaseNumber;
            this.idCaso = result.Id;
            this.dataProtocolo = this.getDate();
            this.step02 = false;
            this.step03 = true;
            this.buttonAvancar = 'Ir para o caso';
            this.buttonVoltar = 'Fechar';
            this.showSpinner(false);
        }).catch(error => {
            if (error && error.body && error.body.message) {
                console.log('Erro criarCasoSolicitacao : ' + error.body.message);
            } else {
                console.log('Erro desconhecido: ', error);
            }
            this.showToast('Falha ao realizar a solicitação', 'Houve um comporamento inesperado do sistema, tente novamente em instantes.', 'error', true);
        });
    }

    setTipoPagamento(tipoPagamento){
        switch(tipoPagamento){
            case "d":
                this.aceitaChequeEspecial = 'Não';
                this.aceitarPagamentoPosVencimento = 'Não';
                break;
            case "o":
                this.aceitaChequeEspecial = 'Sim';
                this.aceitarPagamentoPosVencimento = 'Não';
                break;
            case "p":
                this.aceitaChequeEspecial = 'Não';
                this.aceitarPagamentoPosVencimento = 'Sim';
                break;
            case "q":
                this.aceitaChequeEspecial = 'Sim';
                this.aceitarPagamentoPosVencimento = 'Sim';
                break;
        }
    }

    getDate() {
        const today = new Date();
        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const year = today.getFullYear();

        return `${day}/${month}/${year}`;
    }

    checkTipoPagamento(){
        if(this.aceitarPagamentoPosVencimento && this.aceitaChequeEspecial){
            if(this.aceitarPagamentoPosVencimento == 'Não' && this.aceitaChequeEspecial == 'Não'){
                this.tipoPagamento = 'd';
            } else if(this.aceitarPagamentoPosVencimento == 'Não' && this.aceitaChequeEspecial == 'Sim'){
                this.tipoPagamento = 'o';
            } else if(this.aceitarPagamentoPosVencimento == 'Sim' && this.aceitaChequeEspecial == 'Não'){
                this.tipoPagamento = 'p';
            } else if(this.aceitarPagamentoPosVencimento == 'Sim' && this.aceitaChequeEspecial == 'Sim'){
                this.tipoPagamento = 'q';
            }
        }
    }
    
    hangleToggle(event){
        if(event.target.checked){
            this.showDetails = true;
            this.checkedToggle = true;
            if(this.isDebitoAtivo) this.controllFieldsDetails(false); this.showAvisoDesativacao = false;
            this.desativarDebito = false;
            this.showResumo = true;
            this.showAlertaAtivacao = true;
            this.showAlertaDesativacao = false;
            this.showIconeAguardando = true;
            this.showIconeConcluido = false;
            this.showAlertaDesativado = false;
            this.showAvisoAtivacao = true;
            this.listenProsseguir();
        }else{
            this.checkedToggle = false;
            if(this.isDebitoAtivo){
                this.controllFieldsDetails(true);
                this.showAvisoDesativacao = true;
                this.showAvisoAtivacao = false;
                this.showResumo = false;
                this.desativarDebito = true;
                this.showAlertaAtivacao = false;
                this.showAlertaDesativacao = true;
                this.showIconeAguardando = false;
                this.showIconeConcluido = true;
                this.showAlertaDesativado = true;
            }else{
                this.showDetails = false
            }
            this.listenProsseguir();
        };

    }

    // true = disabled false = enabled
    controllFieldsDetails(state){
        this.disableBanco = state;
        this.disableAgencia = state;
        this.disableNumeroConta = state;
        this.disabelDebitoPosVencimento = state;
        this.disableChequeEspecial = state;
    }

    handleBancoChange(event){
        this.bancoCliente = event.detail.value;
        this.nomeBancoCliente = this.optionsBanco.find(option => option.value === this.bancoCliente).label;
        this.listenProsseguir();
    }

    handleAgenciaAltrada(event){
        this.agenciaCliente = event.target.value;
        this.listenProsseguir();
    }

    handleNumeroContaAlterado(event){
        this.numeroContaBancoCliente = event.target.value;
        this.listenProsseguir();
    }

    handleAutorizaCobrancaAlterado(event){
        this.aceitarPagamentoPosVencimento = event.target.value;
        this.checkTipoPagamento();
        this.listenProsseguir();
    }
    
    handleAutorizaChequeAlterado(event){
        this.aceitaChequeEspecial = event.target.value;
        this.checkTipoPagamento();
        this.listenProsseguir();
    }

    handleOrgemAlterado(event){
        this.origemCaso = event.target.value;
        this.listenProsseguir();
    }

    handleCanalAlterado(event){
        this.canalCaso = event.target.value;
        this.listenProsseguir();
    }

    handleProsseguir(){
        if(this.step01){
            this.step01 = false;
            this.step02 = true;
            this.showHeaderBU = false;
            this.buttonVoltar = 'Voltar';
            this.buttonAvancar = 'Finalizar';
            this.listenProsseguir();
        }else if(this.step02){
            this.showSpinner(true);
            if(this.desativarDebito){
                this.removerDebitoAutomatico();
            } else{
                this.cadastrarDebitoAutomatico();
            }
            this.listenProsseguir();
        } else{
            window.location.href = '/lightning/r/Case/'+ this.idCaso +'/view';
        }
    }

    handleButtonVoltar(){
        if(this.step02){
            this.step02 = false;
            this.step01 = true;
            this.showHeaderBU = true;
            this.buttonAvancar = 'Prosseguir';
            this.buttonVoltar = 'Cancelar';
            this.listenProsseguir();
        } else{
            this.closeQuickAction();
        }
    }

    listenProsseguir(){
        if(this.step01){
            const numberRegex = /^\d+$/;

            const areRequiredFieldsFilled =     this.bancoCliente &&
                                                this.tipoPagamento &&
                                                (this.agenciaCliente && numberRegex.test(this.agenciaCliente)) &&
                                                (this.numeroContaBancoCliente && numberRegex.test(this.numeroContaBancoCliente));

            if(areRequiredFieldsFilled){
                const hasChanges =  (this.bancoCliente !== this.bancoClienteOriginal) ||
                                    (this.agenciaCliente !== this.agenciaClienteOriginal) ||
                                    (this.numeroContaBancoCliente !== this.numeroContaBancoClienteOriginal) ||
                                    (this.tipoPagamento !== this.tipoPagamentoOriginal);
                                
                this.edicaoDebito = hasChanges && this.isDebitoAtivo ?  true : false;

                this.disableButtonAvancar = hasChanges || this.desativarDebito ? false : true;
            }else{
                this.disableButtonAvancar = true;
            }
        } else if(this.step02){
            this.disableButtonAvancar = this.origemCaso && this.canalCaso ? false : true;
        }
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

    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent())
    }

    showSpinner(show){
        this.spinner = show ? true: false;
    }

}