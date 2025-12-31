import { LightningElement, api, wire } from 'lwc';
import { formatarValor, formatarDataHoraCompleto } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getContaFinanceira from '@salesforce/apex/GestaoLimiteController.obterContaFinanceira';
import criarCaso from '@salesforce/apex/GestaoLimiteController.criarCaso';
import consultarLimite from '@salesforce/apex/GestaoLimiteController.consultarLimite';
import getAssetTitular from '@salesforce/apex/CreditoPessoalController.getAssetTitular';

import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

const columns = [
    { label: 'Data/Hora', fieldName: 'data', fixedWidth: 140, wrapText:true, hideDefaultActions:true},
    { label: 'Status pedido', fieldName: 'statusDescricao', fixedWidth: 145, wrapText:true, hideDefaultActions:true, cellAttributes: {class:{fieldName: 'statusStyle'}}},
    { label: 'Limite atual', fieldName: 'limiteAtual', fixedWidth: 110, wrapText:true, hideDefaultActions:true },
    { label: 'Limite solicitado', fieldName: 'limiteSolicitado', fixedWidth: 115, wrapText:true, hideDefaultActions:true},
    { label: 'Limite concedido', fieldName: 'limiteConcedido', fixedWidth: 115, wrapText:true, hideDefaultActions:true},
    { label: 'Loja', fieldName: 'codigoLoja', wrapText:true, fixedWidth: 100, hideDefaultActions:true, type:'text'},
    { label: 'Atendente', fieldName: 'atendente', wrapText:true, fixedWidth: 155, hideDefaultActions:true}
];

export default class BCSF_GestaoLimiteConsulta extends LightningElement {

    //#region Variaveis 
    spinner = false;
    @api recordId;
    columns = columns;

    showCardPrincipal = false;
    stepOne = false;
    stepTwo = false;
    stepThree = false;
    disableButtonCriarCaso = true;
    listaSolicitacoes = null;
    pagina = 1;
    itensPorPagina= 10;
    totalRegistros=0;
    totalPaginas=1;
    disablePagVoltar;
    disablePagIr;
    mostrarPaginacao;

    numeroConta = '';
    nomeTitular = '';
    cpf = '';
    idEmpresa = null;
    unidadeDescricao = '';
    logoTipo = '';
    statusConta = null;
    accountId = null;
    produto = '--';
    canal = 'cockpit';

    origemValue;
    canalValue;
    numeroCaso = null;
    caseId = null;
    
    //#endregion

    //#region wire's

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    //#endregion

    async connectedCallback() {
        this.showSpinner();
        await this.getContaFinanceira();
        await this.getAssetTitular();
        await this.carregarSolicitacoesLimite();
        this.closeSpinner();
    }

    //#region handle

    handleButtonVoltar() {
        if(this.stepTwo){
            this.stepTwo =  false;
            this.stepOne = true;
        } else {
            this.closeQuickAction();
        }
    }

    async handleButtonProsseguir(){
        if(this.stepOne){
            this.stepOne = false;
            this.stepTwo = true;
            this.stepThree = false;
        } else if(this.stepTwo){
            await this.criarCasoConsultaLimite();
        }
    }

    handleButtonIrCaso(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
    }


    handleChangeOrigem(event) {
        this.origemValue = event.target.value;
        this.canalValue = null;
        this.verifyDisabled();
    }

    handleChangeCanal(event) {
        this.canalValue = event.target.value;
        this.verifyDisabled();
    }
    
    handleChangePagina(event) {
        this.pagina = 1;
        this.itensPorPagina = event.detail.value;
        this.carregarSolicitacoesLimite();
    }

    pagIr(){
        this.pagina = this.pagina + 1;
        this.carregarSolicitacoesLimite();
    }

    pagVoltar(){
        this.pagina = this.pagina - 1;
        this.carregarSolicitacoesLimite();
    }

    getStatus(status){
        let descricaoStatus = '-';
        switch (status) {
            case 2:
                descricaoStatus = 'Em análise';
                break;
            case 3:
                descricaoStatus = 'Concluído / Aprovado';
                break;
            case 4:
                descricaoStatus = 'Concluído / Recusado';
                break;
            case 5:
                descricaoStatus = 'Pendente Alteração Limite';
                break;
            case 6:
                descricaoStatus = 'Cancelado';
                break;
            case 7:
                descricaoStatus = 'Em processamento';
                break;
            case 8:
                descricaoStatus = 'Pendente comprovante renda';
                break;
            case 9:
                descricaoStatus = 'Analisando solicitação';
                break;
            case 10:
                descricaoStatus = 'Sem solicitação';
                break;
            case 11:
                descricaoStatus = 'Aumento recente';
                break;
            case 12:
                descricaoStatus = 'Aumento automático';
                break;
            case 13:
                descricaoStatus = 'Conta recente';
                break;
            case 14:
                descricaoStatus = 'Recusado recente';
                break;
            case 101:
                descricaoStatus = 'Falha comunicação interna motor crédito';
                break;
            case 102:
                descricaoStatus = 'Não mapeado';
                break;
            default:
                descricaoStatus = '-';
                break;
        }

        return descricaoStatus;
    }

    getStatusStyle(status){
        let styleStatus = '';
        switch (status) {
            case 3:
                styleStatus = 'slds-text-color_success slds-text-title_bold';
                break;
            case 4:
                styleStatus = 'slds-text-color_error slds-text-title_bold';
                break;
            default:
                styleStatus = 'slds-text-title_bold';
                break;
        }
        return styleStatus;
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

    async handleButtonHistoricoLimite(){
        this.showSpinner();
        this.pagina = 1;
        this.itensPorPagina = 10;
        this.stepThree = false;
        await this.carregarSolicitacoesLimite();
        this.closeSpinner();
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

    verifyDisabled(){
        if (this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null  || this.canalValue == undefined) {
                this.disableButtonCriarCaso = true;
        } else {
            this.disableButtonCriarCaso = false;
        }
    }

    get today(){
        let date = new Date();
        let month = (date.getMonth() + 1) < 10 ? '0'+(date.getMonth() + 1) : (date.getMonth() + 1);
        let day = date.getDate()  < 10 ? '0' + date.getDate() : date.getDate();
        return day + '/' + month + '/' + date.getFullYear();
    }


    get quantidadePag() {
        return [
            { label: '10', value: '10' },
            { label: '20', value: '20' },
            { label: '30', value: '30' },
        ];
    }

    //#region chamadas controller

    async getContaFinanceira(){
        try {
            const result = await getContaFinanceira({ recordId: this.recordId });
            this.cpf = result.CPF;
            this.nomeTitular = result.Nome;
            this.numeroConta = result.NumeroConta;
            this.idEmpresa = result.UnidadeNegocio;
            this.accountId = result.AccountId;
            this.statusConta = result.StatusConta;
            this.tipoConta = result.TipoConta;
    
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
        } catch (error) {
            console.log(error);
            this.showToast('Erro', 'Houve um erro ao buscar informações da Conta Financeira.', 'error', true);
        }
    }

    async getAssetTitular(){
        await getAssetTitular({ 
            idContaFinanceira: this.recordId 
        })
        .then(result => {
            this.produto = result.TipoProduto;
        })
        .catch(error => {
            this.showToast('Erro ao obter cartão', 'Ocorreu um erro inesperado ao obter dados do cartão!', 'error');
            logError('obeterContaFinanceira', error);
        });
    }

    async carregarSolicitacoesLimite() {
        this.showSpinner();

        await consultarLimite({
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            unidadeNegocio: this.idEmpresa,
            canal: this.canal,
            pagina: this.pagina,
            itensPorPagina: this.itensPorPagina
        }).then(result => {
            if (result != null && result.statusAPI == 'OK') {
                
                if(result.retornoSolicitacaoAumentoLimiteCockpit.length == 0) {
                    this.showToast('Nenhum histórico de limite foi encontrado', 'Nenhum pedido de limite foi solicitado nos últimos meses.', 'warning', 'sticky', true);
                    this.closeQuickAction();
                    this.closeSpinner();
                    return;
                }

                this.pagina = result.paginaAtual;
                this.itensPorPagina = result.itensPorPagina;
                this.totalRegistros = result.totalRegistros;
                this.totalPaginas = result.totalPaginas;

                let solicitacoes = [];
                result.retornoSolicitacaoAumentoLimiteCockpit.forEach(item => {
                    solicitacoes.push(
                        {
                            data: formatarDataHoraCompleto(item.data),
                            status: item.status,
                            statusDescricao: this.getStatus(item.status),
                            limiteAtual: formatarValor(item.limiteAtual),
                            limiteSolicitado: formatarValor(item.limiteSolicitado),
                            limiteConcedido: formatarValor(item.limiteConcedido),
                            codigoLoja: item.codigoLoja,
                            atendente: item.atendente,
                            statusStyle: this.getStatusStyle(item.status)
                        }
                    );
                });

                this.listaSolicitacoes = solicitacoes;
                this.disablePagVoltar = this.pagina > 1 ? false : true;
                this.disablePagIr = this.pagina != this.totalPaginas? false : true;
                this.showCardPrincipal = true;
                this.stepOne = true;
            } else {
                this.showToast('Nenhum histórico de limite foi encontrado', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', 'sticky', true);
                this.closeQuickAction();
            }
        }).catch(error => {
            console.log(error);
            this.showToast('Nenhum histórico de limite foi encontrado', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', 'sticky', true);
            this.closeQuickAction();
        });

        this.closeSpinner();
    }

    async criarCasoConsultaLimite() {
        this.showSpinner();
        await criarCaso({
            canal: this.canalValue,
            origem: this.origemValue,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa,
            evento: "Consulta de histórico"
        }).then(result => {
            if (result){
                this.stepOne = false;
                this.stepTwo = false;
                this.stepThree = true;
                this.numeroCaso = result.CaseNumber;
                this.caseId = result.Id;   
                this.closeSpinner();
            }
        }).catch(error => {
            console.log(error);
            this.closeSpinner();
            this.showToast('Erro', 'Houve um erro ao criar Caso.', 'error', 'dismissible', true);
        });
    }
}