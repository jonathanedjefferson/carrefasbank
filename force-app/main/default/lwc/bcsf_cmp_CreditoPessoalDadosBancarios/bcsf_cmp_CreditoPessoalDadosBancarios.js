import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; 
import NAME_FIELD from '@salesforce/schema/User.Name';

import alterarDadosBancarios from '@salesforce/apex/CreditoPessoalController.alterarDadosBancarios';
import criarCaso from '@salesforce/apex/CreditoPessoalController.criarCaso';

export default class Bcsf_cmp_CreditoPessoalDadosBancarios extends LightningElement {

    /**************************************************
    ***           INPUTS                            ***
    ***************************************************/

    @api detalhesProposta = {};
    @api bancos;
    @api dadosCliente = {};

    /**************************************************
    ***           ESTADOS DE TELA                   ***
    ***************************************************/

    @track labelBotaoVoltar;
    @track labelBotaoAvancar;
    @track assunto;
    @track evento;
    @track step01;
    @track step02;
    @track showVoltar;
    @track spinner;

    opcoesTipoConta = [ 
        { label: 'Corrente', value: 1, nome: 'Corrente'},
        { label: 'Poupança', value: 2, nome: 'Poupança'}
    ];

    opcoesBancos = [];

    /**************************************************
    ***           DADOS                             ***
    ***************************************************/
    
    @track dadosBancarios = {
        codBanco: null,
        nomeBanco: null,
        tipoConta: null,
        agencia: null,
        numeroConta: null,
        digitoConta: null
    };

    contratoRejeitado = {
        idContratoGF: null,
        idPlano: null,
        numeroConta: null,
        numeroContrato: null,
        numeroAutorizacaoTsys: null,
        valorSolicitado: null
    };

    @track tipoContaLabel;
    @track confirmaTitularConta;

    @track origemCaso;
    @track canalCaso;
    @track nomeOperador;
    @track numeroProtocolo;
    @track idCaso;
    @track dataProtocolo;

    @track contratoRejeitado = {};

    /**************************************************
    ***           REATIVOS                          *** 
    ***************************************************/

    get desativarAvancar(){

        const dadosBancarios = this.dadosBancarios;

        const codBancoInvalido = !dadosBancarios.codBanco;

        const tipoContaInvalido = (
            !dadosBancarios.tipoConta && 
            dadosBancarios.tipoConta !== 0
        );

        const agenciaInvalido = (
            !dadosBancarios.agencia ||
            isNaN(dadosBancarios.agencia) ||
            dadosBancarios.agencia > 99999
        );

        const numeroContaInvalido = (
            !dadosBancarios.numeroConta ||
            isNaN(dadosBancarios.numeroConta) ||
            dadosBancarios.numeroConta > 9999999999999
        );

        const digitoContaInvalido = (
            ( dadosBancarios.digitoConta != 0 || dadosBancarios.digitoConta === "") &&
            (
                !dadosBancarios.digitoConta ||
                isNaN(dadosBancarios.digitoConta) ||
                String(dadosBancarios.digitoConta).length > 1
            )
        );

        const confirmaTitularContaInvalido = !this.confirmaTitularConta;

        const origemCasoInvalido = !this.origemCaso;

        const canalCasoInvalido = !this.canalCaso;
        
        return (
            (   
                this.step01 &&
                (
                    codBancoInvalido  ||
                    tipoContaInvalido ||
                    agenciaInvalido   ||
                    numeroContaInvalido ||
                    digitoContaInvalido ||
                    confirmaTitularContaInvalido
                )
            )  ||
            (
                this.step02 &&
                (
                    origemCasoInvalido ||
                    canalCasoInvalido
                )
            )
        );
    }

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    getUserRecord({ error, data }) {
        if (data) {
            this.nomeOperador = data.fields.Name.value;
        } else if (error) {
            this.logError('userRecord', error);
        }
    }
    
    connectedCallback(){
        this.definirValoresDefault();
    }

    definirValoresDefault(){
        this.labelBotaoVoltar = 'Voltar';
        this.labelBotaoAvancar = 'Reenviar';
        this.assunto = 'Crédito Pessoal';
        this.evento = 'Reenvio dos dados bancários';
        this.step01 = true;
        this.showVoltar = true;
        this.dadosAlterados = false;

        const bancosNoProxy = [];
        this.bancos.forEach(banco => {
            bancosNoProxy.push(banco); 
        });

        this.opcoesBancos = bancosNoProxy;

        if(this.detalhesProposta){
            const detalhesProposta = this.detalhesProposta;
            
            this.contratoRejeitado = {
                idContratoGF: 0,
                idPlano: detalhesProposta.codPlano,
                numeroConta: detalhesProposta.numeroContaTsys,
                numeroContrato: detalhesProposta.numeroContrato ? parseInt(detalhesProposta.numeroContrato, 10) : null,
                numeroAutorizacaoTsys: detalhesProposta.numeroAutorizacao ? parseInt(detalhesProposta.numeroAutorizacao, 10) : null,
                valorSolicitado: detalhesProposta.valorSolicitado
            };

            this.tipoContaLabel = this.getLabelPorValor(this.opcoesTipoConta, detalhesProposta.tipoConta);

        }
    }

    async alterarDadosBancarios(){
        try {
            const result = await alterarDadosBancarios({
                canal: 'Cockpit',
                cpf: this.dadosCliente.cpf,
                unidadeNegocio: this.dadosCliente.unidadeNegocio,
                numeroConta: this.dadosCliente.numeroConta,
                idProposta: this.detalhesProposta.idProposta,
                dadosBancarios: this.dadosBancarios,
                contratoRejeitado: this.contratoRejeitado
            });
    
        
            if (result.statusAPI === 'OK') {

                if(result.resultadoRevisao == true){
                    await this.finalizarSolicitacao();
                }else{
                    throw new Error('API não conseguiu realizar a alteração!');
                }
            } else {
                throw new Error('API ERRO: CP - Revisar Dados Bancários');
            }
            
        } catch (error) {
            this.showToast('Ocorreu um erro inesperado ao tentar alterar os dados!', '', 'error');
            this.logError('alterarDadosBancarios', error);
        }
        
    }

    async criarProtocolo(){

        const caso = {
            "accountId": this.dadosCliente.contaPessoalId,
            "status": 'Closed',
            "assunto": 'Credito Pessoal',
            "evento": this.evento,
            "origem": this.origemCaso,
            "contaFinanceiraId": this.dadosCliente.contaFinanceiraId,
            "unidadeNegocio": this.dadosCliente.unidadeNegocio,
            "tipo": 'Execução',
            "canal": this.canalCaso,
            "prioridade": 'Medium'
        };

        await criarCaso({
            inputs: caso
        }).then((result) => {
            this.numeroProtocolo = result.CaseNumber;
            this.idCaso = result.Id;
            this.dataProtocolo = this.obterDataHora();
        }).catch(error => {
            this.showToast('Houve um erro ao Criar Caso', '', 'error', false);
            this.logError('criarProtocolo', error);
        });
    }

    async finalizarSolicitacao(){
        await this.criarProtocolo();
        this.step02 = false;
        this.showVoltar = false;
        this.step03 = true;
        this.labelBotaoAvancar = 'Finalizar';
    }


    async handleBancoAlterado(event){
        const codBanco = event.target.value;
        this.dadosBancarios.codBanco = codBanco;
        this.dadosBancarios.nomeBanco = this.getLabelPorValor(this.opcoesBancos, codBanco);
    }

    handleTipoContaAlterado(event){
        const tipoConta = parseInt(event.target.value, 10)
        this.dadosBancarios.tipoConta = tipoConta;
        this.tipoContaLabel = this.getLabelPorValor(this.opcoesTipoConta, tipoConta);
    }

    handleAgenciaAlterado(event){
        const valor = event.target.value;
        if (valor !== "" && !isNaN(valor)) { 
            this.dadosBancarios.agencia = parseInt(valor, 10);
        } else {
            this.dadosBancarios.agencia = valor;
        }
    }

    handleNumeroContaAlterado(event){
        const valor = event.target.value;
        if (valor !== "" && !isNaN(valor)) { 
            this.dadosBancarios.numeroConta = parseInt(valor, 10);
        } else {
            this.dadosBancarios.numeroConta = valor;
        }
    }

    handleDigitoContaAlterado(event){
        const valor = event.target.value;
        if (valor !== "" && !isNaN(valor)) { 
            this.dadosBancarios.digitoConta = parseInt(valor, 10);
        } else {
            this.dadosBancarios.digitoConta = valor;
        }
    }

    handleConfirmaTitular(event){
        this.confirmaTitularConta = event.target.checked;
    }

    handleOrigemAlterada(event){
        this.origemCaso = event.target.value;
    }

    handleCanalAlterado(event){
        this.canalCaso = event.target.value;
    }

   async handleAvancar(){
        if(this.step01){
            this.step01 = false;
            this.labelBotaoAvancar = 'Confirmar o reenvio';
            this.step02 = true;
            console.log(JSON.stringify(this.dadosCliente))
        } else if(this.step02){
            this.showSpinner();
            await this.alterarDadosBancarios();
            this.closeSpinner();
        } else if(this.step03){
            this.closeQuickAction();
        }
    }

    handleVoltar(){
        if(this.step01){
            this.closeQuickAction();
        } else if(this.step02){
            this.step02 = false;
            this.labelBotaoAvancar = 'Reenviar';
            this.step01 = true;
        }
    }

    getLabelPorValor(listaOpcoes, valor) {
        const opcao = listaOpcoes.find(opcao => opcao.value === valor);
        return opcao ? opcao.nome : null;
    }

    showSpinner(){
        this.spinner = true;
    }
    
    closeSpinner(){
        this.spinner = false;
    }
    
    showToast(titulo, mensagem, variante) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    

    obterDataHora() {
        const agora = new Date();
    
        const dia = String(agora.getDate()).padStart(2, '0');
        const mes = String(agora.getMonth() + 1).padStart(2, '0'); 
        const ano = agora.getFullYear();
    
        const horas = String(agora.getHours()).padStart(2, '0');
        const minutos = String(agora.getMinutes()).padStart(2, '0');
    
        return `${dia}/${mes}/${ano} - ${horas}:${minutos}`;
    }

    closeQuickAction() {   
        if(this.step03){
            this.dispatchEvent(new CustomEvent('reloadparent'))
        }
        
        this.dispatchEvent(new CustomEvent('closemodal'))
    }

    logError(metodo, error) {
        if (error) {
            console.error('componente => ', 'Bcsf_cmp_CreditoPessoalDadosBancarios'); 
            console.error('metodo => ', metodo); 
            console.error('erro => ', error);  
            if(error.body){
                console.error('error.body.exceptionType => ', error.body.exceptionType);
                console.error('error.body.message => ', error.body.message);
                console.error('error.body.stackTrace => ', error.body.stackTrace);
            }else{
                console.error('error.name => ' + error.name );
                console.error('error.message => ' + error.message );
                console.error('error.stack => ' + error.stack );
            }
           
        }
    }

}