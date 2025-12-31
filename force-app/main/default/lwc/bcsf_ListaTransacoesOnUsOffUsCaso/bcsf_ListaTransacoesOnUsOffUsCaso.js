import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getContaFinanceira from '@salesforce/apex/BCSF_CancelamentoContaController.getContaFinanceira';
import createCase from '@salesforce/apex/BCSF_TransacoesOnUsOffUsController.createCase';
import createCaseCancelamentoOffUs from '@salesforce/apex/BCSF_TransacoesOnUsOffUsController.createCaseCancelamentoOffUs';
import createCaseCancelamentoOnUs from '@salesforce/apex/BCSF_TransacoesOnUsOffUsController.createCaseCancelamentoOnUs';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import USER_ID from '@salesforce/user/Id';

export default class Bcsf_ListaTransacoesOnUsOffUsCaso extends LightningElement {
    //#region ######### VARIAVEIS ##########
    spinner = false;
    logoTipo;
    caseId;
    cartaoAtivo = true;
    valorNumerico = 0;

    @track eventoCancelamento = false;
    @track eventoCancelamentoOnUs = false;
    @track eventoCancelamentoOffUs = false;
    @track isProdutoNaoEntregue;
    @track recebeuProduto;
    @track mercadoriaDevolvida;
    @track isMercadoriaDevolvida = false;
    @track estabelecimentoFechou = null;
    @track isEstabelecimentoAberto = null;
    @track isContatoEstabelecimento = false;
    @track motivoCancelamento = null;
    @track classificarRelatar = null;
    @track enderecoEntrega = null;
    @track dataPrometidaEntrega = null;
    @track dataDevolucao = null;
    @track possuiVoucher = null;
    @track estornoMais15dias = null;
    @track contatoRealizado = null;
    @track qualCanal = null;
    @track dataContatoEstabelecimento = null;
    @track protocoloNomeAtendente = null;
    @track valorCancelamento = null;
    @track dataAjuste = null;
    @track description = null;
    @track mostrarNomeFila = false;

    @api recordId;
    @api numeroCartaoOfuscado;
    @api nomeCartao;
    @api statusCartao;
    @api dateTransacao;
    @api estabelecimento;
    @api valor;
    @api codigo;
    @api statusTransacao;
    @api traducaoRecusa;
    @api ramoAtividade;
    @api cidade;
    @api pais;
    @api quantidadeParcelas;
    @api tipoTransacao;
    @api tipoPagamento;
    @api limiteTotal;
    @api limiteDisponivel;
    @api codigoEntrada;
    @api detalheEntrada;
    @api meioPagamento;
    @api titularApresentar;
    @api transacaoDuplicada;
    @api codigoRecusa;

    @track disableButton = true;
    @track disableBtnFinalizar = true;
    @track buttonPross = true;
    @track copyPagamento;
    @track copyFinanceiro;
    @track copyCartao;

    @api stepOne = false;
    @api stepTwo = false;
    @api stepThree = false;
    @api stepCaseTwo = false;
    @api stepTransacaoTwo = false;
    @track stepTransacaoDuplicada = false;
    @track stepFour = false;
    @track apresentarTabela = false;
    @track cartaoAtualizado = false;
    @track novoStatusCartao = null;
    @track quantCartao = 0;
    @track showCardPrincipal = true;
    @track showButtonProsseguir = true;
    @track valueCartoes = null;
    @track numeroCartao = null;
    @track numeroSerno = null;
    @track valueStatusCartoes = null;
    @track newValueStatus = null;
    @track valueOrigem = null;
    @track valueCanal = null;
    @track valueAssunto = null;
    @track valueEvento = null;
    @track valueNomeFila = null;
    @track unidadeNegocio = null;
    @track accountId = null;
    @track accountId = null;
    @track valorLimiteDisponivel = null;
    @track valorLimiteTotal = null;
    @track numeroCartaoSerno = null;
    @track dataAtual = new Date();
    @track selectedCard = null;
    @track selectedCardLabel = null;

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
    @track ehAtivo = null;
    @track situacaoCartao = null;

    @track statusContaInfo = 'Informação indisponível';
    @track statusCartaoInfo = 'Informação indisponível';
    @track Area = null;
    @track canal = 'cockpit';
    @track transacaoNegada = false;

    optionsCartoes = [];
    listaCartoes = [];
    numProtocolo;

    //#endregion 

    //#region ########## CARREGAMENTO DE DATA OPTIONS ##########

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && !this.recordId) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.Area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.showSpinner();
        this.disableButton = this.cmpFalecimento != true ? true : false;
        getContaFinanceira({ contaFinanceiraId: this.recordId })
            .then(result => {
                this.nome = result.Nome;
                this.numeroConta = result.NumeroConta;
                this.cpf = result.CPF;
                this.dataNascimento = result.DataNascimento;
                this.unidadeNegocio = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.statusConta = result.StatusConta;
                this.dataAtual = this.dataAtual.toLocaleDateString();

                if (result.UnidadeNegocio == "1") {
                    this.tipoConta = 'CARREFOUR';
                    this.logoTipo = LogoCarrefour;
                } else if (result.UnidadeNegocio == "2") {
                    this.tipoConta = 'ATACADÃO';
                    this.logoTipo = LogoAtacadao;
                } else if (result.UnidadeNegocio == "6") {
                    this.tipoConta = "SAM'S CLUB";
                    this.logoTipo = LogoSamsClub;
                }

                // Para a abertura de caso sem transação.
                this.assunto = 'Compra';

                if(this.stepOne){
                    this.copyFinanceiro = 'Limite total: ' + this.limiteTotal + ' | Limite disponível: ' + this.limiteDisponivel;
                    this.copyPagamento = 'Cód. Autorização: ' + this.codigo + 
                                        ' | Data/Hora: ' + this.dateTransacao +
                                        ' | Estabelecimento: ' + this.estabelecimento + 
                                        ' | Valor total: ' + this.valor + 
                                        ' | Status transação: ' + this.statusTransacao + 
                                        ' | Detalhe recusa: ' + this.traducaoRecusa + 
                                        ' | Ramo atividade: ' + this.ramoAtividade + 
                                        ' | Cidade: ' + this.cidade + 
                                        ' | País: ' + this.pais + 
                                        ' | Meio de pagamento: ' + this.meioPagamento + 
                                        ' | Entrada: ' + this.codigoEntrada + this.detalheEntrada +
                                        ' | Tipo: ' + this.tipoPagamento +
                                        ' | Parcelas: ' + this.quantidadeParcelas +
                                        ' | Tipo Transação: ' + this.tipoTransacao;
                    this.copyCartao = 'Cartão: ' + this.numeroCartaoOfuscado + ' | Nome reduzido: ' + this.nomeCartao + ' | Status Cartão: ' + this.statusCartao + ' | Tipo de conta: ' + this.tipoConta;
    
                    if(this.valor){
                        this.valorNumerico = this.valor.replace('R$', '').trim();
                    }

                    if(this.transacaoDuplicada != ''){
                        this.stepTransacaoDuplicada = true;
                    }
                    if(this.statusTransacao.includes('Transação negada')){
                        this.transacaoNegada = true;
                        this.apresentarTabela = true;
                    }
                }
                this.closeSpinner();
            })
            .catch(error => {
                console.log('Erro getContaFinanceira: ' + error.body.message);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
                this.closeSpinner();
            });
    }
    //#endregion 

    handleCopy(event) {
        this.copy = event.target.value;

        const formattedText = this.copy;
        const textarea = document.createElement('textarea');
        textarea.value = formattedText;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
        
    }

    redirecionarTabelaRecusa(){
        window.open('http://10.105.250.136/intranet_2010/nova_intranet/nova_versao/Intranet2018/portal_de_procedimentos/paginas/atendimento/cartao/tb_recusa.html');
    }

    //#region ########## HANDLER PICKLISTS ##########

    handleChangeOrigem(event) {
        this.valueOrigem = event.detail.value;
        this.mostrarNomeFila = this.valueOrigem !== 'Lojas';
        this.verifyFinalizar();
    }

    handleChangeCanal(event) {
        this.valueCanal = event.detail.value;
        this.verifyFinalizar();
    }

    handleChangeAssunto() {
        this.verifyFinalizar();
    }

    handleChangeEvento(event) {
        this.valueEvento = event.detail.value;

        var evento = this.valueEvento.toLowerCase();
        this.motivoCancelamento = null;
        this.classificarRelatar = null;
        this.recebeuProduto = null;
        this.possuiVoucher = null;
        this.estornoMais15dias = null;
        this.estabelecimentoAberto = null;
        this.description = null;
        this.isContatoEstabelecimento = null;
        this.isProdutoNaoEntregue = null;
        this.isMercadoriaDevolvida = null;
        this.mercadoriaDevolvida = null;
        this.recebeuProduto = null;
        this.dataAjuste = null;
        this.valorCancelamento = null;

        if('cancelamento de compra off-us' === evento){

            if(this.stepCaseTwo){
                this.valueEvento = "";
                this.showToast('Abertura de protocolo', 'Para evento Cancelamento de Compra Off-Us selecionar uma transação.', 'warning', false);
            } else {
                this.eventoCancelamento = true;
                this.eventoCancelamentoOffUs = true;
                this.eventoCancelamentoOnUs = false;
            }
        } else  if('cancelamento de compras on-us' === evento){
            this.eventoCancelamento = true;
            this.eventoCancelamentoOffUs = false;
            this.eventoCancelamentoOnUs = true;
        } else {
            this.eventoCancelamento = false;
        }
        this.verifyFinalizar();
    }

    handleChangeEstabelecimentoFechou(event) {
        this.estabelecimentoAberto = event.detail.value;
        this.isContatoEstabelecimento = null;
        this.contatoRealizado = null;
        this.qualCanal = null;
        this.dataContatoEstabelecimento = null;
        this.protocoloNomeAtendente = null;

        if('Sim' === this.estabelecimentoAberto){
            this.isEstabelecimentoAberto = false;
        } else if('Não' === this.estabelecimentoAberto){
            this.isEstabelecimentoAberto = true;
        } else {
            this.isEstabelecimentoAberto = null;
        }

        this.verifyFinalizar();
    }

    handleChangeContatoComEstabelecimento(event) {
        this.contatoRealizado = event.detail.value;
        this.qualCanal = null;
        this.dataContatoEstabelecimento = null;
        this.protocoloNomeAtendente = null;

        if('Sim' === this.contatoRealizado){
            this.isContatoEstabelecimento = true;
        } else if('Não' === this.contatoRealizado){
            this.isContatoEstabelecimento = false;
        } else {
            this.isContatoEstabelecimento = null;
        }

        this.verifyFinalizar();
    }

    handleChangeRecebeuProduto(event) {
        this.recebeuProduto = event.detail.value;
        this.enderecoEntrega = null;
        this.dataPrometidaEntrega = null;
        this.dataDevolucao = null;

        if('Não' === this.recebeuProduto){
            this.isProdutoNaoEntregue = true;
            this.isMercadoriaDevolvida = null;
            this.mercadoriaDevolvida = null;
        } else if('Sim' === this.recebeuProduto){
            this.isProdutoNaoEntregue = false;
        } else {
            this.isProdutoNaoEntregue = null;
        }

        this.verifyFinalizar();
    }

    handleChangeNomeFila(event) {
        this.valueNomeFila = event.detail.value;
        this.verifyFinalizar();
    }

    handleChangeMercadoriaDevolvida(event) {
        this.mercadoriaDevolvida = event.detail.value;
        this.dataDevolucao = null;

        if('Sim' === this.mercadoriaDevolvida){
            this.isMercadoriaDevolvida = true;
        } else if('Não' === this.mercadoriaDevolvida){
            this.isMercadoriaDevolvida = false;
        } else {
            this.isMercadoriaDevolvida = null;
        }

        this.verifyFinalizar();
    }

    handleChangeCaseField(event){
        try {
            let idCampo = event.target.id;

            if (idCampo.includes('MotivoCancelamento__c')) {
                this.motivoCancelamento = event.detail.value;
            } else if (idCampo.includes('ClassificarRelatar__c')) {
                this.classificarRelatar = event.detail.value;
            } else if (idCampo.includes('EnderecoEntrega__c')) {
                this.enderecoEntrega = event.target.value;
            } else if (idCampo.includes('DataPrometidaEntrega__c')) {
                this.dataPrometidaEntrega = event.target.value;
            } else if (idCampo.includes('DataDevolucao__c')) {
                this.dataDevolucao = event.target.value;
            } else if (idCampo.includes('PossuiVoucher__c')) {
                this.possuiVoucher = event.detail.value;
            } else if (idCampo.includes('EstornoMais15Dias__c')) {
                this.estornoMais15dias = event.detail.value;
            } else if (idCampo.includes('EstabelecimentoFechou__c')) {
                this.estabelecimentoAberto = event.detail.value;
            } else if (idCampo.includes('QualCanal__c')) {
                this.qualCanal = event.detail.value;
            } else if (idCampo.includes('DataContatoComEstabelecimento__c')) {
                this.dataContatoEstabelecimento = event.target.value;
            } else if (idCampo.includes('ProtocoloNomeAtendente__c')) {
                this.protocoloNomeAtendente = event.target.value;
            } else if (idCampo.includes('ValorCancelamento__c')) {
                this.valorCancelamento = event.target.value;
            } else if (idCampo.includes('DataAjuste__c')) {
                this.dataAjuste = event.target.value;
            } else if (idCampo.includes('Description')) {
                this.description = event.target.value;
            }
            
            this.verifyFinalizar();
        } catch (error) {
            console.log('ERROR handleChangeCaseField: ' + error);   
            this.disableBtnFinalizar = true;
        }
    }

    verifyFinalizar(){
        if(this.stepTwo){
            this.disableBtnFinalizar = true;
            const canalValido = this.valueOrigem === 'Lojas' ? true : !this.valueCanal;
            if(this.eventoCancelamento){
                if(this.valueOrigem && (this.valueCanal || canalValido)
                    && (this.valueAssunto || canalValido) && this.valueEvento
                    && this.motivoCancelamento){
                    if(this.eventoCancelamentoOffUs 
                        && this.isProdutoNaoEntregue != null && this.isEstabelecimentoAberto != null 
                        && this.classificarRelatar && this.possuiVoucher && this.estornoMais15dias){
                        this.disableBtnFinalizar = false;

                        if(this.isProdutoNaoEntregue && (!this.enderecoEntrega || !this.dataPrometidaEntrega)){
                            this.disableBtnFinalizar = true;
                        }

                        if(this.isEstabelecimentoAberto) {
                            if(this.isContatoEstabelecimento == null) {
                                this.disableBtnFinalizar = true;
                            } else if (this.isContatoEstabelecimento && (!this.qualCanal 
                                || !this.dataContatoEstabelecimento || !this.protocoloNomeAtendente)){
                                    this.disableBtnFinalizar = true;
                            }
                        }

                        if( (!this.isProdutoNaoEntregue && this.isMercadoriaDevolvida == null) || (!this.isProdutoNaoEntregue
                            && this.isMercadoriaDevolvida && !this.dataDevolucao)){
                            this.disableBtnFinalizar = true;
                        }
                    } else if((this.eventoCancelamentoOnUs && this.dataAjuste && this.valorCancelamento) && (this.valueNomeFila || canalValido)){
                        let valorCancelamento = this.valorCancelamento.replace(',', '');
                        if(valorCancelamento > 0){
                            this.disableBtnFinalizar = false;
                        }
                    }
                }
            } else {
                console.log('no else');
                // Fluxo de abertura de caso geral, sem transação específica.
                if(this.valueOrigem && (this.valueCanal || this.valueOrigem == 'Lojas')
                    && this.valueAssunto && this.valueEvento) {
                    this.disableBtnFinalizar = false;
                }
            }
        }
    }

    //#endregion 

    //#region ########## BUTTONS ##########

    handleProsseguir(event) {
        if (this.stepOne == true) {
            this.currentStep = '2';
            this.stepOne = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.stepFour = this.cartaoAtivo;
            this.disableButton = false;
            this.showButtonProsseguir = false;
        } else if (this.stepTwo == true) {
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.stepFour = this.cartaoAtivo;
            this.disableButton = false;
        }
    }

    handleButtonVoltar(event) {
        if (this.stepTwo == true) {
            this.currentStep = '1';
            this.disableButton = true;
            this.stepOne = true;
            this.stepTwo = false;
            this.stepThree = false;
            this.stepFour = false;
            this.showCardPrincipal = true;
            this.showButtonProsseguir = true;

        } else if (this.stepThree == true) {
            this.currentStep = '1';
            this.disableButton = true;
            this.stepOne = true;
            this.stepTwo = false;
            this.stepThree = false;
            this.stepFour = false;
            this.showCardPrincipal = true;
            this.showButtonProsseguir = true;
        }
    }

    irCase() {
        window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
    }
    //#endregion 

    //#region ########## DML/QUERY ##########
    CreateCase() {
        this.showSpinner();
        createCase({
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal,
            assunto: this.valueAssunto,
            evento: this.valueEvento

        }).then(result => {
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepCaseTwo = false;
            this.stepTransacaoTwo = false;
            this.stepThree = true;
            this.disableButton = true;
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.closeSpinner();
        }).catch(error => {
            console.log('Erro createCase: ' + error);
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
        });
        this.handleProsseguir();
    }

    CreateCaseOffUs() {
        this.showSpinner();
        createCaseCancelamentoOffUs({
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal,
            assunto: 'Compra',
            evento: 'Cancelamento De Compra Off-Us',
            motivoCancelamento: this.motivoCancelamento, 
            numeroAutorizacao: this.codigo, 
            dataTransacao: this.dateTransacao ? this.dateTransacao : null,
            valorCompra: this.valorNumerico ? this.valorNumerico.replace('.', '').replace(',', '.') : 0,
            classificarRelatar: this.classificarRelatar, 
            recebeuProduto: this.recebeuProduto, 
            enderecoEntrega: this.enderecoEntrega, 
            dataEntrega: this.dataPrometidaEntrega ? this.dataPrometidaEntrega : null,
            mercadoriaDevolvida: this.mercadoriaDevolvida, 
            dataDevolucao: this.dataDevolucao ? this.dataDevolucao : null,  
            possuiVoucher: this.possuiVoucher,  
            fezEstorno: this.estornoMais15dias, 
            estabelecimentoFechou: this.estabelecimentoAberto,  
            fezContato: this.contatoRealizado,
            qualCanal: this.qualCanal,  
            dataContato: this.dataContatoEstabelecimento ? this.dataContatoEstabelecimento : null, 
            protocoloEstabelecimento: this.protocoloNomeAtendente,  
            descricao: this.description
        }).then(result => {
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepCaseTwo = false;
            this.stepTransacaoTwo = false;
            this.stepThree = true;
            this.disableButton = true;
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.closeSpinner();
        }).catch(error => {
            console.log('Erro createCaseOffUs: ' + error.message);
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
        });
        this.handleProsseguir();
    }

    CreateCaseOnUs() {
        this.showSpinner();
        createCaseCancelamentoOnUs({
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal,
            assunto: 'Desacordo Comercial',
            evento: 'Cancelamento de compras On-us',
            motivoCancelamento: this.motivoCancelamento, 
            numeroAutorizacao: this.codigo, 
            dataTransacao: this.dateTransacao ? this.dateTransacao : null,
            valorCompra: this.valorNumerico ? this.valorNumerico.replace('.', '').replace(',', '.') : 0,
            valorCancelamento: this.valorCancelamento, 
            quantidadeParcelas : this.quantidadeParcelas, 
            dataAjuste: this.dataAjuste, 
            estabelecimento: this.estabelecimento, 
            codigoPlano: this.quantidadeParcelas,
            numeroCartao: this.numeroCartaoOfuscado,
            descricao: this.description,
            nomeFila: this.valueNomeFila
        }).then(result => {
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepCaseTwo = false;
            this.stepTransacaoTwo = false;
            this.stepThree = true;
            this.disableButton = true;
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.closeSpinner();
        }).catch(error => {
            console.log('Erro createCaseOnfUs: ' + error.message);
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
        });
        this.handleProsseguir();
    }

    handleCriarCaso(){
        this.showSpinner();

        if(this.tipoTransacao === 'ON-US'){
            this.assunto = 'Desacordo Comercial';
            this.valueAssunto = 'Desacordo Comercial';
        } else {
            this.assunto = 'Compra';
            this.valueAssunto = 'Compra';      
        }
        this.stepOne = false;
        this.stepTwo = true;
        this.stepTransacaoTwo = true;
        this.stepThree = false;
        this.closeSpinner();
    }

    handleVoltar(){
        this.stepOne = true;
        this.stepTwo = false;
        this.stepTransacaoTwo = false;
        this.stepThree = false;
    }

    handleFinalizarCaso(){
        if(this.eventoCancelamentoOffUs){
            this.CreateCaseOffUs();
        } else if (this.eventoCancelamentoOnUs) {
            this.CreateCaseOnUs();
        } else {
            this.CreateCase();
        }
        this.stepOne = false;
        this.stepTwo = false;
        this.stepTransacaoTwo = false;
        // this.stepThree = true;
    }

    //#region ########## INTERAÇÕES COM USUÁRIO ##########

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