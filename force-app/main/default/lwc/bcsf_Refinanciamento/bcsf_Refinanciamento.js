import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import getContaFinanceira from '@salesforce/apex/RefinanciamentoController.GetContaFinanceira';
import getDadosContratoOriginal from '@salesforce/apex/RefinanciamentoController.GetDadosContratoOriginal';
import criarPropostaRefinanciamento from '@salesforce/apex/RefinanciamentoController.CriarPropostaRefinanciamento';
import calcularSimulacaoRefinanciamento from '@salesforce/apex/RefinanciamentoController.CalcularSimulacaoRefinanciamento';
import gravarSimulacaoRefinanciamento from '@salesforce/apex/RefinanciamentoController.GravarSimulacaoRefinanciamento';
import finalizarSimulacaoRefinanciamento from '@salesforce/apex/RefinanciamentoController.FinalizarSimulacaoRefinanciamento';
import getDadosBancariosDesembolso from '@salesforce/apex/RefinanciamentoController.GetDadosBancariosDesembolso';
import gravarDadosBancariosAlternativos from '@salesforce/apex/RefinanciamentoController.GravarDadosBancariosAlternativos';
import criarCaso from '@salesforce/apex/RefinanciamentoController.CriarCaso';
import criarConsignado from '@salesforce/apex/RefinanciamentoController.CriarConsignado';


export default class Bcsf_Refinanciamento extends LightningElement {
    @track spinner = false;
    @track step01 = true;
    @track step02 = false;
    @track step03 = false;
    @track step04 = false;
    @track podeCriarCaso = false;
    @track podeCriarConsignado = false;
    @track dateToday = '--';
    @track hourToday = '--';

    @track canal = 'cockpit';
    @track area = '';
    @track labelButtonVoltar = 'Voltar';
    @track labelButtonAvancar = 'Continuar';
    @track disableButtonAvancar = false;

    @track valueOrigem = 'Consignado';
    @track valueCanal  = 'Voz';
    @track valueTelefone;
    @track usarMargem  = true;

    @track valuePickListParcelas = null;
    @track pickListParcelas = [];
    @track pickListParcelasBackup = [];
    @track ListDetalhesPorParcela = [];

    @track inputValorTroco = null;
    @track valueTrocoMaximo = '--';
    @track valorTroco = null;
    @track receberTrocoMaximo = true;
    @track inputTrocoDisabled = false;
    @track msgErroTroco = false;
    @track showTroco = false;
    @track btnTrocoCheked = true;

    @track instituicaoBancariaAtual = '--';
    @track agenciaBancariaAtual = '--';
    @track contaBancariaAtual = '--';
    @track instituicaoBancariaAlternativa = null;
    @track agenciaBancariaAlternativa = null;
    @track contaBancariaAlternativa = null;
    
    @track valorTotalAtual = '--';
    @track taxaMensal = '--';
    @track valorParcela = '--';
    @track parcelasPagas = '--';
    @track valorQuitado = '--';
    @track saldoDevedor = '--';
    @track statusContrato = '--';
    @track idProposta = '--';
    @track quantidadeTotalParcelasContratado = '--';
    @track requestGravarSimulacao = '--';
    @track inputInfoConsignado = {};
    @track linkFinalizacaoRefinanciamento = '--';    
    @track novoValorTotal = '--';
    @track novaTaxa = '--';
    @track novaParcela = '--';
    
    @track nome = '--';
    @track cpf = '--';
    @track dataNascimento = '--';
    @track statusConta = '--';
    @track numeroConta = '--';
    @track telefone = '--';
    @track celularSeguro = '--';
    @track unidadeNegocio = '--';
    @track accountId = '--';
    @track numeroContrato = '--';
    @track email = '--';
    
//#region #################### INICIALIZAÇÃO ####################
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    } 
    
    async connectedCallback() { 
        this.showSpinner();
        await this.ObterDadosContaFinanceira();
        await this.ObterDadosContrato();
        await this.CriarPropostaRefinanciamento();
        await this.CalcularSimulacaoRefinanciamento();
        await this.getValuesNovoRefinanciamento(true);
        this.closeSpinner();
    }

//#endregion

//#region #################### QUERYS / DML ####################
    async ObterDadosContaFinanceira(){
        await getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(result => {
            try {
                this.cpf                = result.CPF;
                this.nome               = result.Nome;
                this.email              = result.Email;
                this.accountId          = result.AccountId;
                this.statusConta        = result.StatusConta;
                this.numeroConta        = result.NumeroConta;
                this.celularSeguro      = result.CelularSeguro;
                this.dataNascimento     = result.DataNascimento;
                this.unidadeNegocio     = result.UnidadeNegocio;
                this.numeroContrato     = result.NumeroContrato;

                if (result.Celular.length == 13) {
                    this.telefone = `+${result.Celular.substring(0, 2)} (${result.Celular.substring(2, 4)}) ${result.Celular.substring(4, 9)}-${result.Celular.substring(9)}`;
                } else if (result.Celular.length == 11) {
                    this.telefone = `(${result.Celular.substring(0, 2)}) ${result.Celular.substring(2, 7)}-${result.Celular.substring(7)}`;
                } else {
                    this.telefone = result.Celular;
                }
            } catch (error) {
                console.log('Erro catch() getContaFinanceira: '+ error);   
                console.dir(error);
                this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getContaFinanceira: '+ error);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }

    async CriarCaso(){
        await criarCaso({
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            origem: this.valueOrigem,
            canal: this.valueCanal
        }).then(result => {
            if (result != null) {
                this.podeCriarConsignado = true;
                this.numeroProtocolo = result.CaseNumber
                this.caseId = result.Id;
                
                let date = new Date();
                let month = (date.getMonth() + 1) < 10 ? '0'+(date.getMonth() + 1) : (date.getMonth() + 1);
                this.dateToday = date.getDate() + '/' + month + '/' + date.getFullYear();
                this.hourToday = date.getHours() + ':' + date.getMinutes();
            }
        }).catch(error => {
            console.log('Erro criarCaso: ' + error.body.message);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }

    async CriarConsignado(){
        await criarConsignado({
            contaFinanceiraId : this.recordId, 
            accountId : this.accountId, 
            caseId : this.caseId, 
            unidadeNegocio : this.unidadeNegocio, 
            inputInfoConsignado : JSON.stringify(this.inputInfoConsignado),
            telefone: this.valueTelefone ? '55' + this.valueTelefone.replace(/\D/g, '') : null
        }).then(result => {
            if (result != null) {
                this.step03 = false;
                this.step04 = true;
                this.closeSpinner();
            }
        }).catch(error => {
            console.log('Erro criarConsignado: ' + error);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }
//#endregion

//#region #################### CHAMADAS API ####################
    async ObterDadosContrato(){
        await getDadosContratoOriginal({
            canal :             this.canal,
            cpf :               this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroContrato :    this.numeroContrato,
            unidadeNegocio :    this.unidadeNegocio
        }).then(result=>{
            try {
                if (result.StatusAPI == 'OK') {
                    this.statusContrato                         = result.statusContrato;
                    this.quantidadeTotalParcelasContratado      = result.quantidadeTotalParcelas;
                    this.taxaMensal                             = parseFloat(result.taxaJurosMensal).toFixed(2) + '% ao mês';                
                    this.parcelasPagas                          = result.quantidadeParcelasPagas + ' de ' + result.quantidadeTotalParcelas;                
                    this.valorQuitado                           = this.formatMoeda(result.valorPago);                
                    this.valorTotalAtual                        = this.formatMoeda(result.valorContratado);                
                    this.saldoDevedor                           = this.formatMoeda(result.valorPresenteContrato);                
                    this.valorParcela                           = this.formatMoeda(result.valorParcelaContratado);
                }else if (result.StatusAPI == 'ERROR MESSAGE') {
                    console.log('Erro API getDadosContratoOriginal');   
                    this.showToast('Ocorreu um problema em nosso sistema', result.mensagem, 'error', true);
                }else{
                    console.log('Erro API getDadosContratoOriginal');   
                    this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() getDadosContratoOriginal: '+ error);  
                console.dir(error); 
                this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getDadosContratoOriginal: '+ error.body.message);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }

    async CriarPropostaRefinanciamento(){
        await criarPropostaRefinanciamento({
            cpf:            this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal:          this.canal,
            unidadeNegocio: this.unidadeNegocio,
            email:          this.email,
            numeroContrato: this.numeroContrato
        }).then(result=>{
            try {
                if (result.StatusAPI == 'OK') {
                    this.idProposta = result.idProposta;
                }else if (result.StatusAPI == 'ERROR MESSAGE') {
                    console.log('Erro API criarPropostaRefinanciamento');   
                    this.showToast('Ocorreu um problema em nosso sistema', result.mensagem.split('- Id Proposta')[0], 'error', true);
                }else{
                    console.log('Erro API criarPropostaRefinanciamento');   
                    this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() criarPropostaRefinanciamento: '+ error);  
                console.dir(error); 
                this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
            }
        }).catch(error => {
            console.log('Erro criarPropostaRefinanciamento: '+ error.body.message);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }

    async CalcularSimulacaoRefinanciamento(){
        this.pickListParcelas = [];
        await calcularSimulacaoRefinanciamento({
            cpf :                   this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal :                 this.canal, 
            unidadeNegocio :        this.unidadeNegocio, 
            idProposta :            this.idProposta, 
            usarMargem :            this.usarMargem, 
            receberTroco :          this.receberTrocoMaximo, 
            quantidadeParcelas :    null, 
            valorTroco :            this.inputValorTroco
        }).then(result=>{
            try {
                if (result.StatusAPI == 'OK') {
                    result.ListOpcoesParcelas.forEach(item => {
                        const parcela           = {label: item, value: item};
                        this.pickListParcelas   = [ ...this.pickListParcelas, parcela];
                    });    

                    this.ListDetalhesPorParcela = result.ListDetalhesPorParcela;
                    if (this.valuePickListParcelas == null || !result.ListOpcoesParcelas.includes(this.valuePickListParcelas)) {
                        this.valuePickListParcelas = result.ListOpcoesParcelas[result.ListOpcoesParcelas.length - 1];
                    }
                }else if (result.StatusAPI == 'ERROR MESSAGE') {
                    console.log('Erro API calcularSimulacaoRefinanciamento');    
                    this.showToast('Ocorreu um problema em nosso sistema', result.mensagem.replace(this.idProposta, ''), 'error', true);
                }else{
                    console.log('Erro API calcularSimulacaoRefinanciamento');   
                    this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() calcularSimulacaoRefinanciamento: '+ error);  
                console.dir(error); 
                this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
            }
        }).catch(error => {
            console.log('Erro calcularSimulacaoRefinanciamento: '+ error.body.message);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }

    async GravarSimulacaoRefinanciamento(){
        await gravarSimulacaoRefinanciamento({
            cpf :               this.cpf.replaceAll('.', '').replaceAll('-', ''), 
            canal :             this.canal, 
            unidadeNegocio :    this.unidadeNegocio, 
            bodyRequestJson :   JSON.stringify(this.requestGravarSimulacao)
        }).then(result=>{
            try {
                if (result.StatusAPI == 'ERROR') {
                    console.log('Erro API gravarSimulacaoRefinanciamento');   
                    this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
                }else if (result.StatusAPI == 'ERROR MESSAGE') {
                    console.log('Erro API gravarSimulacaoRefinanciamento');    
                    this.showToast('Ocorreu um problema em nosso sistema', result.mensagem.replace(this.idProposta, ''), 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() gravarSimulacaoRefinanciamento: '+ error);  
                console.dir(error); 
                this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
            }
        }).catch(error => {
            console.log('Erro gravarSimulacaoRefinanciamento: '+ error.body.message);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }

    async FinalizarSimulacaoRefinanciamento(){
        await finalizarSimulacaoRefinanciamento({
            cpf:                this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal:              this.canal, 
            unidadeNegocio:     this.unidadeNegocio, 
            idProposta:         this.idProposta
        }).then(result=>{
            try {
                if (result.StatusAPI == 'OK') {
                    this.linkFinalizacaoRefinanciamento = result.link;
                    this.inputInfoConsignado.LinkRefinanciamento = result.link;
                    this.podeCriarCaso = true;
                }else if (result.StatusAPI == 'ERROR MESSAGE') {
                    console.log('Erro API finalizarSimulacaoRefinanciamento');     
                    this.showToast('Ocorreu um problema em nosso sistema', result.mensagem.replace(this.idProposta, ''), 'error', true);
                }else{
                    this.podeCriarCaso = false;
                    console.log('Erro API finalizarSimulacaoRefinanciamento');   
                    this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() finalizarSimulacaoRefinanciamento: '+ error);  
                console.dir(error); 
                this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
            }
        }).catch(error => {
            console.log('Erro finalizarSimulacaoRefinanciamento: '+ error.body.message);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }

    async ObterDadosBancariosDesembolso(){
        await getDadosBancariosDesembolso({
            cpf :               this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal :             this.canal, 
            unidadeNegocio :    this.unidadeNegocio, 
            idProposta :        this.idProposta
        }).then(result=>{
            try {
                if (result.StatusAPI == 'OK') {
                    this.instituicaoBancariaAtual   = result.banco;
                    this.contaBancariaAtual         = result.conta;
                    this.agenciaBancariaAtual       = result.agencia;
                }else if (result.StatusAPI == 'ERROR MESSAGE') {
                    console.log('Erro API getDadosBancariosDesembolso');     
                    this.showToast('Ocorreu um problema em nosso sistema', result.mensagem.replace(this.idProposta, ''), 'error', true);
                }else{
                    console.log('Erro API getDadosBancariosDesembolso');   
                    this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() getDadosBancariosDesembolso: '+ error);  
                console.dir(error); 
                this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getDadosBancariosDesembolso: '+ error.body.message);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }

    async GravarDadosBancariosAlternativos(){
        gravarDadosBancariosAlternativos({
            cpf :                               this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal :                             this.canal, 
            unidadeNegocio :                    this.unidadeNegocio, 
            idProposta :                        this.idProposta, 
            instituicaoBancariaAlternativa :    this.instituicaoBancariaAlternativa.replace(/\D/g, ''), 
            agenciaBancariaAlternativa :        this.agenciaBancariaAlternativa.replace(/\D/g, ''), 
            contaBancariaAlternativa :          this.contaBancariaAlternativa.replace(/\D/g, '')
        }).then(result=>{
            try {
                if (result.StatusAPI == 'ERROR') {
                    console.log('Erro API gravarDadosBancariosAlternativos');   
                    this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
                }else if (result.StatusAPI == 'ERROR MESSAGE') {
                    console.log('Erro API gravarDadosBancariosAlternativos');   
                    this.showToast('Ocorreu um problema em nosso sistema', result.mensagem.replace(this.idProposta, ''), 'error', true);
                }
            } catch (error) {
                console.log('Erro catch() gravarDadosBancariosAlternativos: '+ error);  
                console.dir(error); 
                this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
            }
        }).catch(error => {
            console.log('Erro gravarDadosBancariosAlternativos: '+ error.body.message);
            console.dir(error);
            this.showToast('Ocorreu um problema em nosso sistema', 'Por este motivo não foi possível gerar o protocolo de alteração. Por favor, repita a operação e tente novamente', 'error', true);
        });
    }
//#endregion
   
//#region  ################### METODOS HANDLE ####################
    handleChangeQtdParcelas(event){      
        this.valuePickListParcelas = parseInt(event.detail.value);
        this.getValuesNovoRefinanciamento(false);        
        this.msgErroTroco = false;
        this.disableButtonAvancar = false;
    }
    async handleBtnMargem(event){
        this.showSpinner()
        this.usarMargem = event.target.checked;
        this.receberTrocoMaximo = true;
        if (this.usarMargem) {
            this.btnTrocoCheked = true;
        }

        await this.CalcularSimulacaoRefinanciamento();
        await this.getValuesNovoRefinanciamento(false);
        this.closeSpinner();
    }

    async handleBtnTroco(event){
        this.showSpinner()
        this.btnTrocoCheked = event.target.checked;
        this.inputTrocoDisabled = !this.btnTrocoCheked;
        this.receberTrocoMaximo = this.btnTrocoCheked;
        this.inputInfoConsignado.TrocoRefinanciamento = this.btnTrocoCheked;
        this.msgErroTroco = false;
        this.usarMargem = this.btnTrocoCheked

        if (this.btnTrocoCheked) {
            this.requestGravarSimulacao.valorTroco = this.valorTrocoMaximo;
            this.inputInfoConsignado.ValorTrocoRefinanciamento  = this.valorTrocoMaximo;
        }else{
            this.inputValorTroco = 0;  
            this.requestGravarSimulacao.valorTroco = 0;
            this.inputInfoConsignado.ValorTrocoRefinanciamento = 0;
        }

        await this.CalcularSimulacaoRefinanciamento();
        await this.getValuesNovoRefinanciamento(false);
        this.closeSpinner();
    }

    handleValorTroco(event){
        try {
            let valorCampo = event.detail.value;
            let ultimoCaracter = valorCampo.split('')[valorCampo.split('').length-1];
            let ehCaracter = JSON.stringify(parseInt(ultimoCaracter)) == 'null' ? true : false;
            this.disableButtonAvancar = valorCampo == this.valorTrocoMaximo ? false : true;

            if (valorCampo <= this.valorTrocoMaximoOriginal && valorCampo >= 0 && !ehCaracter) {
                this.requestGravarSimulacao.valorTroco = event.detail.value;
                this.inputInfoConsignado.ValorTrocoRefinanciamento = event.detail.value;
                this.msgErroTroco = false;
                this.inputValorTroco = valorCampo;
            }else if (!ehCaracter || ultimoCaracter == '.'){
                this.valorMsgErro = valorCampo < 0 ? 'Não é possível seguir com um valor menor que R$ 0,00' : 'Não é possível seguir com um valor maior que ' + this.formatMoeda(this.valorTrocoMaximoOriginal);
                this.msgErroTroco = ultimoCaracter == '.' ? false : true;

                event.detail.value = this.inputValorTroco;
            }else{
                event.detail.value = this.inputValorTroco;
            }
        } catch (error) {
            console.log('ERROR handleValorTroco: ' + error);   
        }
    }

    async handleOnFocusOut(){
        this.showSpinner();
        if (!this.msgErroTroco && this.inputValorTroco != this.valorTrocoMaximo) {
            if (this.inputValorTroco == this.valorTrocoMaximoOriginal) {
                this.receberTrocoMaximo = true;
                this.usarMargem = true;
            }else{
                this.usarMargem = false;
                this.receberTrocoMaximo = false;
            }
            await this.CalcularSimulacaoRefinanciamento();
            await this.getValuesNovoRefinanciamento(false);
            this.disableButtonAvancar =  false;
        }
        this.closeSpinner();
    }

    handlePhoneChange(event) {
        let value = event.target.value.replace(/\D/g, '');
        value = value.substring(0, 11);

        if (value.length > 7) {
            let size = value.length - 7;
            const regex = new RegExp(`(\\d{${2}})(\\d{${5}})(\\d{${size}})`);
            value = value.replace(regex, '($1) $2-$3');
        } else if (value.length > 2) {
            value = value.replace(/(\d{2})(\d{0,5})/, '($1) $2');
        } else if (value.length > 0) {
            value = value.replace(/(\d{0,2})/, '($1');
        }

        this.valueTelefone = value;
    }

    async handleBtnProsseguir(){
        if (this.step01) {
            this.showSpinner();
            await this.ObterDadosBancariosDesembolso();
            await this.GravarSimulacaoRefinanciamento();
            
            this.step01 = false;
            this.step02 = true;
            this.closeSpinner();
        }else if (this.step02) {
            this.step01 = false;
            this.step02 = false;
            this.step03 = true;
            this.closeSpinner();
        }else if (this.step03) {
            if (this.invalidPhoneInput()) {
                return;
            }

            this.showSpinner();
            // if(this.verifyAlterarDadosBancarios()){
            //     await this.GravarDadosBancariosAlternativos();
            // }
            await this.FinalizarSimulacaoRefinanciamento();
            if (this.podeCriarCaso) {
                await this.CriarCaso();
                await this.CriarConsignado();
            }
            this.labelButtonAvancar = 'Finalizar';
            this.labelButtonVoltar = 'Fechar';
        }
        else if (this.step04) {
            this.IrCaso();
        }
    }
    
    handleButnVoltar(){
        if (this.step01) {
            this.closeQuickAction();
        } else if (this.step02) {
            this.step01 = true;
            this.step02 = false;
            this.disableButtonAvancar = false;
        } else if (this.step03) {
            this.step02 = true;
            this.step03 = false;
        } else if (this.step04) {
            this.closeQuickAction();
        }
    }

    handleInstituicaoAlternativa(event){
        try {
            let inputValue = event.target.value;

            if (inputValue.length != 0) {
                let ultimoCaracter = inputValue.split('')[inputValue.split('').length-1];
                let ehCaracter = JSON.stringify(parseInt(ultimoCaracter)) == 'null' ? true : false;
    
                if (!ehCaracter) {
                    this.instituicaoBancariaAlternativa = inputValue;
                }else{
                    event.target.value = this.instituicaoBancariaAlternativa;
                }
            }else{
                this.instituicaoBancariaAlternativa = null;
            }
            
        } catch (error) {
            console.log('ERROR handleInstituicaoAlternativa: ' + error);   
        }
    }
    
    handleagenciaBancariaAlternativa(event){
        let inputValue = event.target.value;

        if (inputValue.length != 0) {
            let ultimoCaracter = inputValue.split('')[inputValue.split('').length-1];
            let ehCaracter = JSON.stringify(parseInt(ultimoCaracter)) == 'null' ? true : false;

            if (!ehCaracter || ultimoCaracter == '-') {
                let apenasNumero = inputValue.replace(/\D/g, '');
        
                let numeroApenasReverso = this.reverseString(apenasNumero);
                let ultimosDoisNumeros = this.reverseString(`${numeroApenasReverso.substring(0, 1)}-`);

                this.agenciaBancariaAlternativa = apenasNumero.slice(0, -1) + ultimosDoisNumeros;
            }else{
                event.target.value = this.agenciaBancariaAlternativa;
            }
        }else{
            this.agenciaBancariaAlternativa = null;
        }
    }
    
    handlecontaBancariaAlternativa(event){
        let inputValue = event.target.value;
        if (inputValue.length != 0) {
            let ultimoCaracter = inputValue.split('')[inputValue.split('').length-1];
            let ehCaracter = JSON.stringify(parseInt(ultimoCaracter)) == 'null' ? true : false;

            if (!ehCaracter) {
                let apenasNumero = inputValue.replace(/\D/g, '');
        
                let numeroApenasReverso = this.reverseString(apenasNumero);
                let ultimosDoisNumeros = this.reverseString(`${numeroApenasReverso.substring(0, 2)}-`);
                
                this.contaBancariaAlternativa = apenasNumero.slice(0, -2) + ultimosDoisNumeros;
            }else{
                event.target.value = this.contaBancariaAlternativa;
            }
        }else{
            this.contaBancariaAlternativa = null;
        }
    }
    
    async getValuesNovoRefinanciamento(primeiraChamada){
        await this.ListDetalhesPorParcela.forEach(item => {
            if (primeiraChamada) {
                let valorTroco = item.ValorTroco == 0 ? null : item.ValorTroco;
                let option = {valorTrocoMaximo: valorTroco, qtdParcelas: item.QuantidadeDeParcelas};
                this.pickListParcelasBackup.push(option); 
            }
            
            if (item.QuantidadeDeParcelas == this.valuePickListParcelas) {
                this.novaTaxa               = parseFloat(item.NovaTaxa).toFixed(2) + '% ao mês';
                this.novoValorTotal         = this.formatMoeda(item.NovoValorTotal);
                this.novaParcela            = this.formatMoeda(item.NovoValorParcela);

                if (primeiraChamada) {
                    this.btnTrocoCheked     = item.ValorTroco == 0 ? false : true; 
                    this.showTroco          = item.ValorTroco == 0 ? false : true; 
                }

                this.valorTrocoMaximo       = item.ValorTroco == null ? 0 : item.ValorTroco;
                this.inputValorTroco        = item.ValorTroco == null ? 0 : item.ValorTroco;

                this.inputTrocoDisabled     = !this.btnTrocoCheked;
                this.receberTrocoMaximo     = !this.btnTrocoCheked;
                this.requestGravarSimulacao = item.requestGravarSimulacao;

                this.inputInfoConsignado.NomeCliente                        = this.nome;
                this.inputInfoConsignado.Telefone                           = this.telefone.replace(/\D/g, '');
                this.inputInfoConsignado.NumeroContrato                     = this.numeroContrato;
                this.inputInfoConsignado.ValorTotalRefinanciamento          = this.novoValorTotal;
                this.inputInfoConsignado.NovaTaxaRefinanciamento            = this.novaTaxa;
                this.inputInfoConsignado.NovaParcelaRefinanciamento         = this.novaParcela;
                this.inputInfoConsignado.IdOfertaRefinanciemento            = this.idProposta;
                this.inputInfoConsignado.QuantidadeParcelasRefinanciamento  = item.QuantidadeDeParcelas;
                this.inputInfoConsignado.TrocoRefinanciamento               = this.btnTrocoCheked;
                this.inputInfoConsignado.ValorTrocoRefinanciamento          = this.valorTroco;
            }
        });

        await this.pickListParcelasBackup.forEach(item =>{
            if (item.qtdParcelas == this.valuePickListParcelas) {
                // this.valorTrocoMaximo = item.valorTrocoMaximo;
                this.valorTrocoMaximoOriginal = item.valorTrocoMaximo;
            }
        })
    }
//#endregion

//#region #################### INTERAÇÕES COM O USUÁRIO ####################
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
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            this.closeQuickAction();
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    IrCaso(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
    }

    verifyAlterarDadosBancarios(){
        if (this.agenciaBancariaAlternativa     == null || this.agenciaBancariaAlternativa     == undefined || this.agenciaBancariaAlternativa     == '' || this.agenciaBancariaAlternativa     == '--' || this.agenciaBancariaAlternativa     == '-' ||
            this.instituicaoBancariaAlternativa == null || this.instituicaoBancariaAlternativa == undefined || this.instituicaoBancariaAlternativa == '' || this.instituicaoBancariaAlternativa == '--' || this.instituicaoBancariaAlternativa == '-' ||
            this.contaBancariaAlternativa       == null || this.contaBancariaAlternativa       == undefined || this.contaBancariaAlternativa       == '' || this.contaBancariaAlternativa       == '--' || this.contaBancariaAlternativa       == '-'
        ) {
            return false;
        }else{
            return true;
        }
    }

    invalidPhoneInput() {
        if (!this.valueTelefone) {
            this.showToast('Telefone de contato inválido', 'Insira um telefone válido e tente novamente', 'error');
            return true;
        }

        let rawPhone = this.valueTelefone.replace(/\D/g, '');

        if (rawPhone.length < 11) {
            this.showToast('Telefone de contato inválido', 'Insira um telefone válido e tente novamente', 'error');
            return true;
        }

        return false;
    }

    formatMoeda(valor){
        return parseFloat(valor).toLocaleString('pt-BR', {
            style: 'currency',
            currency: 'BRL'
        });
    }

    reverseString(str) {
        let splitString = str.split('');
        let reverseArray = splitString.reverse();
        let joinArray = reverseArray.join('');
        return joinArray;
    }
//#endregion
}