import { LightningElement, wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id'; 
import USER_DRT from '@salesforce/schema/User.DRT__c';
import USER_UNIDADE from '@salesforce/schema/User.UnidadeDeAtendimento__c';
import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getContaFinanceira from '@salesforce/apex/BCSF_cmp_SMSControleController.getContaFinanceira';
import getCartaoTitular from '@salesforce/apex/BCSF_cmp_SMSControleController.getCartao';
import consultarContratos from '@salesforce/apex/BCSF_cmp_SMSControleController.consultarContratos';
import adesaoContrato from '@salesforce/apex/BCSF_cmp_SMSControleController.adesaoContrato';
import cancelarContrato from '@salesforce/apex/BCSF_cmp_SMSControleController.cancelarContrato';
import motivosCancelamento from '@salesforce/apex/BCSF_cmp_SMSControleController.motivosCancelamento';
import criarCaso from '@salesforce/apex/BCSF_cmp_SMSControleController.criarCaso';

export default class Bcsf_cpm_SMSControle extends LightningElement {

    // var layout
    spinner;
    fluxoAdesao;
    fluxoCancelar;
    fluxoOcorrencia;
    fluxoAnterior;
    fluxoContestar;
    pageContratar;
    pageCancelar;
    pageContestar;
    pageConfirmarContrato;
    pageCasoGerado;
    podeRegistrarOcorr = true;
    contratoMaisRecente;
    produtoDisponivel;
    possuiSMS;
    disabledBtnPross;
    labelBtnPross = 'Contratar';
    labelBtnVoltar = 'Voltar';
    titlePage = 'SMS Controle Total';

    // var caso/API
    eventoCaso;
    origemCaso;
    canalCaso;
    userUnidadeAtendimento
    drtUser;
    motivoCancelamentoField;
    motivoCancelamentoLabel;
    possuiContestacaoField = 'false';
    descricaoField;
    motivoRegistroField;

    // var detalhes da contratação
    planoValor;
    celularSMSControle;
    celularCadastro;
    numeroContrato;
    tipoAdesao;
    dataAdesao;
    inicioVigencia;
    fimVigencia;
    canalAdesao;
    lojaAdesao;
    vendedor;
    motivoCancelamento;
    dataCancelamento;
    canalCancelamento;
    lojaCancelamento;
    canceladoPor;
    
    // var detalhes conta
    nomeCliente;
    logoEmpresa;
    idEmpresa;
    nomeEmpresa;
    cpfCliente;
    numeroConta;
    statusConta;
    celularSeguro;
    sufixoCartao;

    motivoCancelamentoOptions = [];
    /* motivoRegistroOptions = [
        { label: 'Cartão não pertence ao cliente', value: 'Cartão não pertence ao cliente' },
        { label: 'Mensagens incompletas', value: 'Mensagens incompletas' },
        { label: 'Não recebe SMS', value: 'Não recebe SMS' },
        { label: 'SMS fora do horário comercial', value: 'SMS fora do horário comercial' },
        { label: 'Outros Motivos	', value: 'Outros Motivos	' },
    ]; */

    possuiContestacaoOptions = [
        { label: 'Sim', value: 'true' },
        { label: 'Não', value: 'false' }
    ];

    get input() {
        return {
            cpfCliente: this.cpfCliente.replace(/\D/g, ''),
            canal: 'cockpit',
            canalAtendimento: this.userUnidadeAtendimento,
            loja: this.userUnidadeAtendimento,
            drt: this.drtUser,
            idEmpresa: this.idEmpresa,
            idAdesao: this.numeroContrato,
            idProduto: this.produtoDisponivel?.idProduto,
            codMotivoCancelar: this.motivoCancelamentoField,
            contestado: this.possuiContestacaoField,
            sufixoCartao: this.sufixoCartao,
            numeroConta: this.numeroConta
        };
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USER_DRT, USER_UNIDADE] })
    getUserRecord({ error, data }) {
        if (data) {
            this.drtUser = data.fields.DRT__c.value;
            this.userUnidadeAtendimento = data.fields.UnidadeDeAtendimento__c.value;
        } else if (error) {
            console.log('getUserRecord', error);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.GetContaFinanceira();
        }
    }

    GetContaFinanceira(){
        this.spinnerOpen();
        getContaFinanceira({
            IdConta:  this.recordId
        }).then((result) => {
            if (result) {
                this.celularSeguro = result.CelularSeguro__c;
                this.numeroCelular = this.formatarTelefone(result.Telefone__c);
                this.cpfCliente = this.formatarCPF(result.NomeCliente__r.CPF__c);
                this.nomeCliente = result.NomeCliente__r.Name;
                this.numeroConta = result.NumeroConta__c;
                this.statusConta = result.StatusConta__c;
                this.idEmpresa = result.UnidadeNegocio__c;
                this.getLogo(this.idEmpresa);
                this.GetCartaoTitular();
            } else {
                throw new Error("erro ao consultar API");
            }
        }).catch((error) => {
            this.showToast('','Não foi possível buscar as informações da Conta', 'error', true);
            console.log('Erro ao buscar informações da conta:', error.message);
        });
    }
    
    GetCartaoTitular(){
        this.spinnerOpen();
        getCartaoTitular({
            IdConta:  this.recordId
        }).then((result) => {
            if (result) {
                this.sufixoCartao = String(result.NumeroCartao__c).slice(-4);
                this.ConsultarContratos();
            } else {
                throw new Error("erro ao consultar API");
            }
        }).catch((error) => {
            this.showToast('','Não foi possível buscar as informações da Conta', 'error', true);
            console.log('Erro ao buscar informações da conta:', error.message);
        });
    }

    ConsultarContratos(){
        this.spinnerOpen();
        consultarContratos({
            input:  JSON.stringify(this.input) 
        }).then((result) => {
            if (result.statusResponse === 'OK') {
                this.getInfoContrato(result);
                this.spinnerClose();
            } else {
                throw new Error("erro ao consultar API");
            }
        }).catch((error) => {
            this.showToast('','Não foi possível consultar o status do SMS Controle Total.', 'error', true);
            console.log('Erro ao consultar contratos:', error.message);
        });
    }

    MotivosCancelamento(){
        this.spinnerOpen();
        motivosCancelamento({
            cpfCliente: this.input.cpfCliente,
            canal: this.input.canal,
            idEmpresa: this.input.idEmpresa
        }).then((result) => {
            if (result.statusResponse === 'OK') {
                this.motivoCancelamentoOptions = result.motivos.map(item => ({
                    label: item.descricao,
                    value: item.idmotivo,
                }));
                this.pageConfirmarContrato = true;
                this.pageCancelar = false;
                this.podeRegistrarOcorr = false;
                this.labelBtnPross = 'Confirmar';
                this.titlePage = 'Cancelar Serviço: SMS Controle Total';
                this.validarBtnPross();
                this.spinnerClose();
            } else {
                throw new Error("erro ao consultar API");
            }
        }).catch((error) => {
            this.showToast('','Não foi possível efetuar o cancelamento do SMS Controle Total.', 'error', true)
            console.log('Erro ao buscar lista de motivos:', error.message);
        });
    }

    AdesaoContrato(){
        this.spinnerOpen();
        adesaoContrato({
            input:  JSON.stringify(this.input) 
        }).then((result) => {
            if (result === 'OK') {
                this.CriarCaso();
            } else if(result === 'sem celular seguro'){
                this.showToast('','A adesão para este cliente está indisponível por não possuir celular seguro.', 'error', true);
            } else {
                throw new Error("erro ao consultar API");
            }
        }).catch((error) => {
            this.showToast('','Não foi possível efetuar a adesão do SMS Controle Total.', 'error', true);
            console.log('Erro ao aderir contrato:', error.message);
        });
    }

    CancelarContrato(){
        this.spinnerOpen();
        cancelarContrato({
            input:  JSON.stringify(this.input) 
        }).then((result) => {
            if (result) {
                this.CriarCaso();
            } else {
                throw new Error("erro ao consultar API");
            }
        }).catch((error) => {
            this.showToast('','Não foi possível efetuar o cancelamento do SMS Controle Total.', 'error', true);
            console.log('Erro ao cancelar contrato:', error.message);
        });
    }
    
    CriarCaso(){
            this.spinnerOpen();
            criarCaso({
                telefone: this.numeroCelular,
                contaFinanceiraId: this.recordId, 
                accountId: this.accountId, 
                evento: this.eventoCaso,
                unidadeNegocio: this.idEmpresa, 
                cpf: this.cpfCliente,
                origem: this.origemCaso,
                canal: this.canalCaso,
                descricao: this.descricaoField,
                motivoCancelar: this.motivoCancelamentoLabel
            }).then(result=>{
                this.numProtocolo = result.CaseNumber;
                this.caseId = result.Id;
                this.pageCasoGerado = true;
                this.pageConfirmarContrato = false;
                this.labelBtnVoltar = 'Fechar';
                this.labelBtnPross = 'Ir para o caso';
                this.dataAtualFormatada = this.formatDate(new Date()).split(' ')[0];
                this.spinnerClose();
            }).catch(error=>{
                this.showToast('', 'Não foi possível carregar as informações', 'error', true);
                console.log('Erro CriarCaso: '+ error.message);
            });
        }

    getInfoContrato(result){
        if (result.contratos.length > 0) {
            let contratos = result.contratos.filter(c => c.status === "A");
            let possuiContratoAtivo = contratos.length > 0;
            contratos = possuiContratoAtivo ? contratos : result.contratos;

            this.contratoMaisRecente = contratos?.reduce((maisRecente, atual) => {
                    const dataMaisRecente = new Date(maisRecente.dataAdesao);
                    const dataAtual = new Date(atual.dataAdesao);
                    return dataAtual > dataMaisRecente ? atual : maisRecente;
            });
            this.planoValor = this.contratoMaisRecente.planoValor;
            this.celularSMSControle = this.formatarTelefone(this.contratoMaisRecente.celularSMSControleTotal);
            this.celularCadastro = this.formatarTelefone(this.contratoMaisRecente.celularCadastro);
            this.numeroContrato = this.contratoMaisRecente.numeroContrato;
            this.tipoAdesao = this.contratoMaisRecente.tipoAdesao;
            this.dataAdesao = this.formatDate(this.contratoMaisRecente.dataAdesao).split(' ')[0];
            this.inicioVigencia = this.formatDate(this.contratoMaisRecente.inicioVigencia).split(' ')[0];
            this.fimVigencia = this.formatDate(this.contratoMaisRecente.fimVigencia).split(' ')[0];
            this.canalAdesao = this.contratoMaisRecente.canalAdesao;
            this.lojaAdesao = this.contratoMaisRecente.lojaAdesao;
            this.vendedor = this.contratoMaisRecente.vendidoPor;
            this.eventoCaso = 'Cancelamento de SMS Controle Total';
            this.textCasoGerado = 'O cancelamento do SMS Controle total foi realizado!';
            this.fluxoCancelar = true;
            this.pageCancelar = true;

            if(!possuiContratoAtivo){
                this.eventoCaso = 'Adesão de SMS Controle Total';
                this.textCasoGerado = 'Adesão do SMS Controle Total realizado!';
                this.fluxoCancelar = false;
                this.pageCancelar = false;
                this.fluxoContestar = true;
                this.pageContestar = true;
                this.motivoCancelamento = this.contratoMaisRecente.motivoCancelamento;
                this.dataCancelamento = this.formatDate(this.contratoMaisRecente.dataCancelamento).split(' ')[0];
                this.canalCancelamento = this.contratoMaisRecente.canalCancelamento;
                this.lojaCancelamento = this.contratoMaisRecente.lojaCancelamento;
                this.canceladoPor = this.contratoMaisRecente.canceladoPor;
            }
        }

        if(result.produtos && (!this.contratoMaisRecente || this.contratoMaisRecente.status !== 'A')){
            if(!this.celularSeguro){
                this.showToast('','A adesão para este cliente está indisponível por não possuir celular seguro.', 'error', true);
            }

            this.produtoDisponivel = result.produtos.find(c => c.situacao.trim() === "Venda Disponível");
            if(this.produtoDisponivel){
                this.possuiSMS = result.contratos.lenght > 0;
                this.fluxoAdesao = true;
                this.pageContratar = !this.pageContestar;
                this.eventoCaso = 'Adesão de SMS Controle Total';
                this.textCasoGerado = 'Adesão do SMS Controle Total realizado!';
            }else{
                this.showToast('','Cliente não possui contratos disponíveis.', 'error', true);
            }
        }
    }

    getLogo(unidade){
        if (unidade === "1") {
            this.nomeEmpresa = 'CARREFOUR';
            this.logoEmpresa = LogoCarrefour;
        } else if (unidade === "2") {
            this.nomeEmpresa = 'ATACADÃO';
            this.logoEmpresa = LogoAtacadao;
        }else if (unidade === "6"){
            this.nomeEmpresa = "SAM'S CLUB";
            this.logoEmpresa = LogoSamsClub;
        }
    }

    handleBtnOcorrencia(){
        this.fluxoAnterior = this.fluxoAdesao? 'adesao' : 'cancelar';
        this.labelBtnPross = 'Registrar ocorrência';
        this.titlePage = 'Ocorrência SMS Controle Total';
        this.eventoCaso = 'Ocorrência de SMS Controle Total';
        this.textCasoGerado = 'Ocorrência registrada!';
        this.fluxoOcorrencia = true;
        this.fluxoCancelar = false
        this.fluxoAdesao = false
        this.pageConfirmarContrato = true;
        this.pageContratar = false;
        this.pageCancelar = false;
        this.podeRegistrarOcorr = false;
        this.validarBtnPross();
    }

    handleBtnPross(){
        if(this.pageContratar || this.pageContestar){
            this.pageConfirmarContrato = true;
            this.pageContratar = false;
            this.pageContestar = false;
            this.podeRegistrarOcorr = false;
            this.labelBtnPross = 'Finalizar contratação';
            this.titlePage = 'Contratar Serviço: SMS Controle Total';
        }else if(this.pageCancelar){
            this.MotivosCancelamento();
        }else if(this.fluxoCancelar && this.pageConfirmarContrato){
            this.CancelarContrato();
        }else if(this.fluxoAdesao && this.pageConfirmarContrato){
            this.AdesaoContrato();
        }else if(this.fluxoOcorrencia && this.pageConfirmarContrato){
            this.CriarCaso();
        }else{
            window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
        }
        this.validarBtnPross();
    }

    handleBtnVoltar(){
        if(this.fluxoAdesao && this.pageConfirmarContrato) {
            this.pageContratar = !this.fluxoContestar;
            this.pageContestar = this.fluxoContestar;
            this.podeRegistrarOcorr = true;
            this.pageConfirmarContrato = false;
            this.labelBtnPross = 'Contratar';
            this.titlePage = 'SMS Controle Total';
        }else if(this.fluxoCancelar && this.pageConfirmarContrato) {
            this.pageCancelar = true;
            this.podeRegistrarOcorr = true;
            this.pageConfirmarContrato = false;
            this.titlePage = 'SMS Controle Total';
            this.motivoCancelamentoLabel = '';
            this.motivoCancelamentoField = '';
            this.descricao = '';
        }else if(this.fluxoOcorrencia && this.pageConfirmarContrato) {
            this.voltarFluxoAnterior();
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        this.validarBtnPross();
    }

    handleField(event) {
        const name = event.target.name;
        this[name] = event.target.value;
        this.validarBtnPross();

        if (name === 'motivoCancelamentoField') {
            this.motivoCancelamentoLabel = this.motivoCancelamentoOptions.find(option => option.value == this.motivoCancelamentoField).label;
        }
    }

    validarBtnPross(){
        this.disabledBtnPross = true;
        if(this.fluxoAdesao && this.pageConfirmarContrato && this.origemCaso && this.canalCaso){
            this.disabledBtnPross = false;
            return;
        }

        if(this.fluxoCancelar && this.pageConfirmarContrato && this.motivoCancelamentoField && this.possuiContestacaoField && this.origemCaso && this.canalCaso){
            this.disabledBtnPross = false;
            return;
        }

        if(this.fluxoOcorrencia && this.motivoRegistroField && this.origemCaso && this.canalCaso){
            this.disabledBtnPross = false;
            return;
        }

        if(this.pageContratar || this.pageCasoGerado || this.pageCancelar || this.pageContestar){
            this.disabledBtnPross = false;
            return;
        }

    }

    voltarFluxoAnterior(){
        this.podeRegistrarOcorr = true;
        this.pageConfirmarContrato = false;
        this.titlePage = 'SMS Controle Total';
        this.labelBtnPross = 'Contratar';
        this.motivoRegistroField = '';
        this.descricao = '';
        if (this.fluxoAnterior === 'cancelar') {
            this.fluxoCancelar = true;
            this.pageCancelar = true;
            this.eventoCaso = 'Cancelamento de SMS Controle Total';
            this.textCasoGerado = 'O cancelamento do SMS Controle total foi realizado!';
        }else{
            this.pageContratar = true;
            this.fluxoAdesao = true;
            this.eventoCaso = 'Adesão de SMS Controle Total';
            this.textCasoGerado = 'Adesão do SMS Controle Total realizado!';
        }
    }

    formatarCPF(cpf) {
        if (!cpf) return '';

        const cpfNumeros = cpf.replace(/\D/g, '');
        if (cpfNumeros.length !== 11) {
            return cpf; 
        }

        return cpfNumeros.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    }
    
    formatarTelefone(telefone) {
        if (!telefone) return '';

        const numeros = telefone.replace(/\D/g, '');

        if (/^\+55 \d{2} \d{5}-\d{4}$/.test(telefone) || /^\(\d{2}\) \d{4,5}-\d{4}$/.test(telefone)) {
            return telefone;
        }

        if (numeros.length === 13) {
            const ddi = numeros.substring(0, 2);
            const ddd = numeros.substring(2, 4);
            const primeiro = numeros.length === 13 ? numeros.substring(4, 9) : numeros.substring(4, 8);
            const segundo = numeros.substring(9);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }

        if (numeros.length === 11) {
            const ddd = numeros.substring(0, 2);
            const primeiro = numeros.substring(2, 7);
            const segundo = numeros.substring(7);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }

        if (numeros.length === 10) {
            const ddd = numeros.substring(0, 2);
            const primeiro = numeros.substring(2, 6);
            const segundo = numeros.substring(6);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }
        return telefone;
    }

    formatDate(dataString) {
        if (!dataString) return '';
        const data = new Date(dataString);
        return data.toLocaleString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        }).replace(',', '');
    }

    showToast(titulo, mensagem, variante, close) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if(close){
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    spinnerOpen(){
        this.spinner = true;
    }

    spinnerClose(){
        this.spinner = false;
    }

}