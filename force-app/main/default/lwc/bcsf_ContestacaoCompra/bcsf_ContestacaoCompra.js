import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { EnclosingTabId, getTabInfo, focusTab } from 'lightning/platformWorkspaceApi';

import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/containerSize";

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import getContaFinanceira from '@salesforce/apex/ContestacaoCompraController.getContaFinanceira';
import getListCartoes from '@salesforce/apex/ContestacaoCompraController.getListCartoes';
import getListTransacoes from '@salesforce/apex/ContestacaoCompraController.getListTransacoes';
import bloquearCartao from '@salesforce/apex/ContestacaoCompraController.bloquearCartao';
import createCase from '@salesforce/apex/ContestacaoCompraController.createCase';
import marcarTransacoes from '@salesforce/apex/ContestacaoCompraController.marcarTransacoes';

const columns = [
    { label: 'Data/Hora', fieldName: 'dataTransacao', wrapText:true, hideDefaultActions:true},
    { label: 'Número do cartão', fieldName: 'numeroCartaoOfuscado', wrapText:true, hideDefaultActions:true},
    { label: 'Estabelecimento', fieldName: 'estabelecimento', type: 'button', hideDefaultActions:true, typeAttributes:{label:{fieldName: 'estabelecimento'}, name: 'show_details', variant: 'base'} },
    { label: 'Cód. Autorização ', fieldName: 'codigoTransacao', cellAttributes: { iconName: {fieldName: 'transacaoDuplicada', name: 'Status'}}, hideDefaultActions:true},
    { label: 'Valor', fieldName: 'valorFormatado', wrapText:true, hideDefaultActions:true},
    { label: 'Status transação', fieldName: 'statusTransacao', wrapText:true, hideDefaultActions:true, type:'text', cellAttributes: {class:{fieldName: 'statusStyle'}}},
    { label: 'Entrada', fieldName: 'detalheEntrada', wrapText:true, hideDefaultActions:true},
    { label: 'Meio de pagamento', fieldName: 'meioPagamento', wrapText:true, hideDefaultActions:true, cellAttributes: { iconName: {fieldName: 'statusCartao', name: 'Status'}}},
];

const columnsConfirmar = [
    { label: 'Data e Hora', fieldName: 'dataTransacao', fixedWidth: 135, wrapText:true, hideDefaultActions:true},
    { label: 'Nome', fieldName: 'estabelecimento', wrapText:true, type: 'text', fixedWidth: 135, hideDefaultActions:true },
    { label: 'Cód. Autorização ', fieldName: 'codigoTransacao', cellAttributes: { iconName: {fieldName: 'transacaoDuplicada', name: 'Status'}}, hideDefaultActions:true},
    { label: 'Valor', fieldName: 'valorFormatado', fixedWidth: 135, wrapText:true, hideDefaultActions:true},
    { label: 'Final do cartão', fieldName: 'finalNumeroCartao', fixedWidth: 133, wrapText:true, hideDefaultActions:true},
    { label: 'Entrada', fieldName: 'detalheEntrada', wrapText:true, hideDefaultActions:true},
    { label: 'Meio de pagamento', fieldName: 'meioPagamento', fixedWidth: 135, wrapText:true, hideDefaultActions:true, cellAttributes: { iconName: {fieldName: 'statusCartao', name: 'Status'}}},
    { label: '', fieldName: 'remove', fixedWidth: 40, type: 'button-icon', typeAttributes: {iconName: 'utility:delete', name: 'remove_row', title: '', variant: 'bare', alternativeText: 'remove', disabled: false} }
];

const checkboxOptions = [
    { label: 'Sim', value: 'Sim' },
    { label: 'Não', value: 'Não' },
];

export default class BCSF_ContestacaoCompra extends LightningElement {
    
    //#region Variaveis 
    spinner = false;
    columns = columns;
    columnsConfirmar = columnsConfirmar;
    checkboxOptions = checkboxOptions;
    @wire(EnclosingTabId) tabId;

    @api recordId;
    @api limiteTotal;
    @api limiteDisponivel;
    @track listaTransacoes = [];            // Lista de transações carregadas da API.
    @track selectedIdListaTransacoes = [];  // Lista de transações selecionadas pelo usuário.
    @track selectedListaTransacoes = [];    // Lista de Id das transações selecionadas.

    @track optionsCartoes = [];             // Lista de cartões carregados da API.
    @track cartoesCaso = [];                // Lista de cartões que possuem transações selecionadas.

    @track showModal = false;   // Apresenta modal para confirmar e abrir contestação.
    @track stepOne = false;     // Confirmação das transações selecionadas.
    @track stepTwo = false;     // Abertura do caso de contestação.
    @track stepThree = false;   // Tela de sucesso.

    @track slaCaso = '3 dias úteis';
    @track showDetalheTransacao = false;   // Apresenta detalhes da transação.
    @track transacaoDetalhada = null;           // Transação selecionada para detalhamento.

    @track titularConta = '--';
    @track tipoConta = null;
    @track logoTipo = null;
    @track idEmpresa = null;
    @track accountId = null;
    @track cpf = null;
    @track numeroConta = null;
    @track nomeContaFinanceira = null;

    @track canal = 'cockpit';
    @track areaPrincipal = null;

    // Utilizados no filtro de transações.
    @track dataInicial = null;
    @track dataFinal = null;
    @track valueCartaoSelecionado = null;

    // Utilizados na tela de detalhe da transação.
    @track numeroCartaoSelecionado = null;
    @track statusCartaoSelecionado = null;
    @track nomeReduzidoCartaoSelecionado = null;

    @track transacaoDiferentesCartoes = false;  // Ao trocar de cartão indica se houve selecão em outro cartão.
    @track pagina = 1;
    @track tamanhoPagina = 10;
    @track totalPagina;
    @track totalItens;
    @track disablePagVoltar = true;
    @track disablePagIr = true;
    @track comRetorno = false;
    @track semRetorno = false;
    @track erroRetorno = false;

    // Dados do caso
    @track eventoValue = null;
    @track origemValue = null;
    @track canalValue = null;
    @track tipoReclamacaoValue = null;
    @track consultaRealizadaEthoca = null;
    @track valueDescricao = null;
            
    @track cartoesBloqueados = [];
    @track cartoesJaBloqueados = [];
    @track cartoesNaoBloqueados = [];
    @track displaycartoesBloqueados = false;
    @track displaycartoesJaBloqueados = false;
    @track displaycartoesNaoBloqueados = false;
    @track numeroCaso = null;
    @track caseId = null;
    @track abrirSegundaViaCartao = false;
    closeModalComponent = true;

    @track labelContestarButton = 'Contestar compra';
    disableButtonContestar = true;
    disableButtonProsseguir = true;
    disableButtonFinalizar = true;

    urlTabelaRecusas = 'http://10.105.250.136/intranet_2010/nova_intranet/nova_versao/Intranet2018/portal_de_procedimentos/paginas/atendimento/cartao/tb_recusa.html';
    //#endregion

    //#region wire's
    @wire(CurrentPageReference)
    pagRef;

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
    //#region connectedCallback 
    async connectedCallback() {
        loadStyle(this, modal);
        this.recordId = this.pagRef.state.c__recordId;
        this.limiteTotal = this.pagRef.state.c__limiteTotal;
        this.limiteDisponivel = this.pagRef.state.c__limiteDisponivel;

        await getContaFinanceira({ recordId: this.recordId })
            .then(result => {
            
                this.cpf = result.CPF;
                this.numeroConta = result.NumeroConta;
                this.idEmpresa = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.titularConta = result.Nome;
                this.nomeContaFinanceira = result.NomeConta;
                
                if (this.idEmpresa == "1") {
                    this.tipoConta = 'CARREFOUR';
                    this.logoTipo = LogoCarrefour;
                } else if (this.idEmpresa == "2") {
                    this.tipoConta = 'ATACADÃO';
                    this.logoTipo = LogoAtacadao;
                }else if (this.idEmpresa == "6"){
                    this.tipoConta = "SAM'S CLUB";
                    this.logoTipo = LogoSamsClub;
                }
        
                this.carregarCartoes();
            })
            .catch(error => {
                console.log(error);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true, 'dismissible');
            });
    }

    //#endregion
    //#region métodos handle
    handleChangeCartaoSelecionado(event) {
        let count = 0;
        let cartaoAnterior = this.numeroCartaoSelecionado;
        for (let i = 0; i < this.selectedListaTransacoes.length; i++) {
            if(this.selectedListaTransacoes[i].cartaoSelecionado === cartaoAnterior){
                count++;
            }
        }

        this.valueCartaoSelecionado = event.detail.value;
        this.optionsCartoes.forEach(item => {
            if(item.value === this.valueCartaoSelecionado){
                this.numeroCartaoSelecionado = item.numeroCartao;
                this.statusCartaoSelecionado = item.statusCartao;
                this.nomeReduzidoCartaoSelecionado = item.nomeReduzido;
            } else if (count > 0 && item.numeroCartao === cartaoAnterior){
                item.label =  item.labelInicial + ' (' + count + ')';
            } else if (count == 0 && item.numeroCartao === cartaoAnterior){
                item.label =  item.labelInicial;
            }
        });

        this.optionsCartoes = [...this.optionsCartoes];
        this.carregarTransacoes();
    }

    handleDataInicial(event){
        this.dataInicial = event.detail.value;
    }

    handleDataFinal(event){
        this.dataFinal = event.detail.value;
    }

    handleRecarregarTransacoes(){
        // Consulta limitada no intervalo de 90 dias
        const datFinal = new Date(this.dataFinal);
        const datInicial = new Date(this.dataInicial);
        const timeDiff = datFinal.getTime() - datInicial.getTime();
        const dayDiff = timeDiff / (1000 * 3600 * 24);

        if(this.dataFinal == null || this.dataInicial == null){
            this.showToast('Erro', 'Período inicial e período final são obrigatórias.', 'error', true, 'dismissible');
        } else if(datFinal < datInicial) {
            this.showToast('Erro', 'Data final deve ser maior que data inicial.', 'error', true, 'dismissible');
        } else if(dayDiff > 90){
            this.showToast('Erro', 'Não é possível consultar mais que 90 dias', 'error', true, 'dismissible');
        } else {
            this.pagina = 1;
            this.carregarTransacoes();
        }
    }

    // Contestação através do modal de detalhes da transação
    handleButtonContestarCompra(event) {
        let indexTransacaoDetalhada = this.transacaoDetalhada.index;
        let index = this.selectedIdListaTransacoes.findIndex(function(transacaoIndex) {
            return transacaoIndex == indexTransacaoDetalhada
        });

        if(index == -1){
            this.selectedListaTransacoes.push(this.transacaoDetalhada);
            this.selectedIdListaTransacoes.push(indexTransacaoDetalhada);
            this.atualizarLabelButtonContestar();
        }

        this.showDetalheTransacao = false;
        this.stepOne = true;
        this.selectedListaTransacoes = [...this.selectedListaTransacoes];
        this.selectedIdListaTransacoes = [...this.selectedIdListaTransacoes];
        this.disableButtonProsseguir = false;
        this.getSLACaso();
    }

    handleContestarCompra(event){
        this.showDetalheTransacao = false;
        this.showModal = true;
        this.stepOne = true;
        this.selectedListaTransacoes = [...this.selectedListaTransacoes];
        this.disableButtonProsseguir = false;
        this.getSLACaso();
    }
    
    getSLACaso(){  
        this.slaCaso = '3 dias úteis';     
        this.selectedListaTransacoes.forEach(item => {
            if(item.meioPagamento !== 'Virtual' || item.tipoTransacao === 'ON-US'){
                this.slaCaso = '5 dias úteis';
            }
        });
    }

    handleButtonProsseguir(event) {
        if(this.stepOne && this.selectedListaTransacoes.length > 0){            
            this.tipoCaso = 'RPA';
            let listaCartoes = [];
            this.cartoesCaso = [];
            
            this.selectedListaTransacoes.forEach(item => {
                if(item.meioPagamento !== 'Virtual' || item.tipoTransacao === 'ON-US'){
                    this.tipoCaso = 'MANUAL';
                }

                let indexCartao = listaCartoes.findIndex(function(cartao) {
                    return cartao == item.numeroCartaoOfuscado
                });

                if(indexCartao == -1) {
                    listaCartoes.push(item.numeroCartaoOfuscado);
                }
            });

            this.optionsCartoes.forEach(item => {
                let indexCartao = listaCartoes.findIndex(function(cartao) {
                    return cartao == item.numeroCartao
                });

                if(indexCartao !== -1){
                    this.cartoesCaso.push(item);
                }
            });
            
            this.origemValue = null;
            this.canalValue = null;
            this.tipoReclamacaoValue = null;
            this.consultaRealizadaEthoca = null;
            this.disableButtonFinalizar = true;
            this.stepOne = false; 
            this.stepTwo = true;

            this.eventoValue =  'Contestação';
            if(this.tipoCaso === 'RPA'){
                this.eventoValue = 'Não reconhece compra';
            }
        }
    }

    closeModal(event){
        if(this.stepThree){
            this.resetModuloContestacao();
        }
        this.stepOne = false;
        this.stepTwo = false;
        this.stepThree = false;
        this.showModal = false;
        this.abrirSegundaViaCartao = false;
    }

    handleButtonVoltar(event) {
        if(this.showDetalheTransacao){
            this.showDetalheTransacao = false;
            this.showModal = false; 
        } else if(this.stepOne){
            // Atualiza o número de transações no label do cartão, caso alguma tenha sido removida.
            this.atualizarLabelCartoes();
            this.stepOne = false;
            this.showModal = false; 
        } else if(this.stepTwo){
            this.stepOne = true;
            this.stepTwo = false;
        }  else {
            this.closeQuickAction();
        }
    }

    handleButtonFinalizar(event){
        this.showSpinner();

        if(this.tipoCaso === 'RPA'){
            // Caso todas as transações sejam virtuais e do tipo ON-US realizamos o bloqueio dos cartões.
            const funcs = this.cartoesCaso.map((cartao, index) =>
                this.bloquearCartao( cartao.value, 'UIND', index)
            );

            Promise.allSettled(funcs)
                .then(results => {
                    console.log('>>>>> ' + JSON.stringify(results));
                    this.CriarCaso();
            }).catch(error => {
                console.log('Bloqueio de cartões: ' + error);
            });
        } else {
            this.CriarCaso();
        }

    }

    handleButtonSegundaViaCartao(event){
        this.resetModuloContestacao();
        this.stepOne = false;
        this.stepTwo = false;
        this.stepThree = false;
        this.showModal = false;
        this.abrirSegundaViaCartao = true;
        this.showToast('Solicitação de contestação criada. Protocolo ' + this.numeroCaso, 'Cartões utilizados na compra foram bloqueados. {0}', 'success', false, 'sticky');

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

    handleChangeEthoca(event){
        this.consultaRealizadaEthoca = event.target.value;
        if(this.consultaRealizadaEthoca === ''){
            this.consultaRealizadaEthoca = null;
        }
        this.verifyDisabled();
    }

    handleChangeTipoReclamacao(event){
        this.tipoReclamacaoValue = event.target.value;
        if(this.tipoReclamacaoValue === ''){
            this.tipoReclamacaoValue = null;
        }
        this.verifyDisabled();
    }

    handleDescricao(event){
        this.valueDescricao = event.target.value;
    }

    handleInfoCartao(event){
        let name = event.target.name;
        let dataId = event.target.dataset.id;
        let value = event.target.value;

        if(dataId){
            for (let i = 0; i < this.cartoesCaso.length; i++) {
                if(this.cartoesCaso[i].value === dataId){
                    if(name === 'CartaoRoubado'){
                        this.cartoesCaso[i].cartaoRoubado = value;
                        
                        if(value === 'Sim'){
                            this.cartoesCaso[i].clienteComCartao = 'Não';
                            this.cartoesCaso[i].disableClienteComCartao = true;
                        } else if(!this.cartoesCaso[i].ehVirtual){
                            // Se cartão virtual não deve habilitar
                            this.cartoesCaso[i].disableClienteComCartao = false;
                        }
                    } else if(name === 'ClienteComCartao'){
                        this.cartoesCaso[i].clienteComCartao = value;
                    }
                }
            }

            this.cartoesCaso = [... this.cartoesCaso];
        }

        this.verifyDisabled();
    }

    abrirDetalhesTransacao(event){
        if(event.detail.action.name === 'show_details'){
            this.transacaoDetalhada = event.detail.row;
            this.transacaoNegada = this.transacaoDetalhada.statusTransacao.includes('Transação negada');
            this.showModal = true;
            this.showDetalheTransacao = true;
        }
    }

    updateSelectedList(event) {
        let indexTransacao = -1;
        switch (event.detail.config.action) {
            case 'selectAllRows':
                this.removeTransacoesCartao(this.numeroCartaoSelecionado);
                for (let i = 0; i < event.detail.selectedRows.length; i++) {
                    this.selectedListaTransacoes.push(event.detail.selectedRows[i]);
                    this.selectedIdListaTransacoes.push(event.detail.selectedRows[i].index);
                }
                break;
            case 'deselectAllRows':
                this.removeTransacoesCartao(this.numeroCartaoSelecionado);
                break;
            case 'rowSelect':
                indexTransacao = this.listaTransacoes.findIndex(function(transacao) {
                    return transacao.index == event.detail.config.value
                });

                if(indexTransacao > -1){
                    this.selectedListaTransacoes.push(this.listaTransacoes[indexTransacao]);
                    this.selectedIdListaTransacoes.push(this.listaTransacoes[indexTransacao].index);
                }
                break;
            case 'rowDeselect':
                indexTransacao = this.selectedListaTransacoes.findIndex(function(transacao) {
                    return transacao.index == event.detail.config.value
                });
                
                if (indexTransacao > -1) {
                    this.selectedListaTransacoes.splice(indexTransacao, 1);
                    this.selectedIdListaTransacoes.splice(indexTransacao, 1);
                }
                break;
            default:
                break;
        }

        this.atualizarLabelButtonContestar();
    }

    removeTransacoesCartao(numeroCartao){
        let tempList = [], tempIdList = [];

        for (let i = 0; i < this.selectedListaTransacoes.length; i++) {
            if(this.selectedListaTransacoes[i].cartaoSelecionado !== numeroCartao){
                tempList.push(this.selectedListaTransacoes[i]);
                tempIdList.push(this.selectedListaTransacoes[i].index);
            }
        }
        
        this.selectedListaTransacoes = [... tempList];
        this.selectedIdListaTransacoes = [... tempIdList];
    }

    handleRowAction(event) {
        const row = event.detail.row;
        switch (event.detail.action.name) {
            case 'remove_row':
                this.removeItem(row.index);
                break;
            default:
        }
    }

    removeItem(rowId) {
        let rowIndex = this.selectedListaTransacoes.findIndex(function(transacao) {
            return transacao.index == rowId
        });

        if (rowIndex !== -1) {
            this.selectedListaTransacoes.splice(rowIndex, 1);
            this.selectedIdListaTransacoes.splice(rowIndex, 1);
            this.selectedListaTransacoes = [...this.selectedListaTransacoes];
            this.selectedIdListaTransacoes = [...this.selectedIdListaTransacoes];
            this.atualizarLabelButtonContestar();
        }

        if(this.selectedListaTransacoes.length == 0){
            // caso remover todas as transações fecha o modal.
            this.atualizarLabelCartoes();
            this.transacaoDiferentesCartoes = false;
            this.closeModal();
            this.showToast('Solicitação de contestação cancelada', 'Todas as compras foram removidas da solicitação, selecione as compras desejadas caso o cliente queira prosseguir.', 'info', false, 'sticky');
        } else {
            this.atualizaMsgTransacoes();
            this.getSLACaso();
        }
    }

    //#endregion

    //#region métodos Toast, Spinner e verify
    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante, closeModal, mode) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            messageData: [
                {
                    url: '/lightning/r/Case/'+ this.caseId +'/view',
                    label: 'Clique aqui caso queira conferir o caso.'
                },
            ],
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
            this.abrirSegundaViaCartao = false;
            this.dispatchEvent(new CustomEvent('closeparentmodal'))
        }else{
            this.abrirSegundaViaCartao = false;
            this.closeSpinner();
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    //#endregion

    //#region Chamadas de API
    carregarCartoes() {
        this.showSpinner();
        getListCartoes({
            numeroConta: this.numeroConta,
            idEmpresa: this.idEmpresa,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal: this.canal
        }).then(result => {
            try {
                this.valueCartaoSelecionado = null;
                if (result != null && result.length > 0) {
                    let opcoes = [];

                    result.forEach(item => {
                        let rotulo = item.ehVirtual ? 'Cartão Virtual - Final ' : 'Cartão Físico - Final ';
                        rotulo += item.numeroCartao.split('.')[3];
                        rotulo += ' - ' + item.nomePortador;
                        rotulo += item.tipoTitularidade === 'TITULAR' ? ' (Titular)' : ' (Adicional)';

                        opcoes.push(
                            {   
                                label: rotulo, 
                                value: item.id,
                                numeroCartao: item.numeroCartao,
                                statusCartao : item.statusCartao,
                                nomeReduzido: item.nomePortador,
                                labelInicial: rotulo,
                                ehTitular : item.tipoTitularidade === 'TITULAR',
                                ehPrimario : item.ehPrimario,
                                ehVirtual: item.ehVirtual,
                                cartaoRoubado: '',
                                clienteComCartao: item.ehVirtual ? 'Não' : '',
                                disableClienteComCartao: item.ehVirtual,
                                cartaoBloqueado: false
                            }
                        );
                    });
                    
                    this.optionsCartoes = opcoes;

                    for (let i = 0; i < this.optionsCartoes.length; i++){
                        if(this.optionsCartoes[i].ehTitular && this.optionsCartoes[i].ehPrimario){
                            this.valueCartaoSelecionado = this.optionsCartoes[i].value;
                            this.numeroCartaoSelecionado = this.optionsCartoes[i].numeroCartao;
                            this.statusCartaoSelecionado = this.optionsCartoes[i].statusCartao;
                            this.nomeReduzidoCartaoSelecionado = this.optionsCartoes[i].nomeReduzido;
                            this.titularCartaoSelecionado = this.optionsCartoes[i].ehTitular;
                            break;
                        }
                    }
                    
                    let ultimos90Dias = new Date();
                    ultimos90Dias.setDate(ultimos90Dias.getDate() - 90);
                    this.dataInicial = this.formatYYYYMMDD(ultimos90Dias);
                    let dataCorrente = new Date();
                    this.dataFinal = this.formatYYYYMMDD(dataCorrente);

                    if(this.valueCartaoSelecionado == null){
                        this.closeSpinner();
                    } else {
                        this.carregarTransacoes();
                    }
                } else {
                    this.showToast('Falha na listagem de cartões', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', true, 'dismissible');
                    this.closeSpinner();
                }
            } catch (error) {
                console.log('error: ' + error);
            }
        }).catch(error => {
            this.showToast('Falha na listagem de cartões', 'Houve um comportamento inesperado no sistema, tente novamente em instantes.', 'error', true, 'dismissible');
            this.closeSpinner();
        });
    }

    async carregarTransacoes() {
        this.showSpinner();

        await  getListTransacoes({
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            unidadeNegocio: this.idEmpresa,
            canal: this.canal,
            numeroCartaoSerno: this.valueCartaoSelecionado.replaceAll('2-', ''),
            dataInicial: this.dataInicial,
            dataFinal: this.dataFinal,
            tamanhoPagina: this.tamanhoPagina,
            pagina: this.pagina
        }).then(result => {

            if (result != null && result.statusAutorizacao == 'OK') {
                
                if(result.data.length == 0) {
                    this.semRetorno = true;
                    this.erroRetorno = false;
                    this.comRetorno = false;
                    this.closeSpinner();
                    return;
                }

                this.pagina = result.pagina;
                this.tamanhoPagina = result.tamanhoPagina;
                this.totalItens = result.totalItens;

                let autorizacaoDuplicada = {};
                result.data.forEach(item => {
                    if (item.codigo != null && autorizacaoDuplicada[item.codigo]) {
                        autorizacaoDuplicada[item.codigo]++;
                    } else {
                        autorizacaoDuplicada[item.codigo] = 1;
                    }
                });

                let controlePagina = this.totalItens;
                this.totalPagina = 1;
                for (let i = 0; i < controlePagina; i++){
                    if(i > this.tamanhoPagina) {
                        this.totalPagina ++;
                        controlePagina = controlePagina - result.tamanhoPagina;
                    }
                }

                let index = 0;
                let transacoesCartao = [];
                result.data.forEach(item => {
                    if (index < this.tamanhoPagina) {
                        index++;
                        
                        let finalNumeroCartao = item.numeroCartao?.substring(12);
                        let dataTransacao = new Date(item.data);
                        let dataFormatada = this.formatarData(dataTransacao);
                        let dataTransacaoISO = this.getDateISOFormat(dataTransacao);
                        let valorFormatado = item.valor.toLocaleString('pt-br',{style: 'currency', currency: 'BRL'});
                        let iconeTransacaoDuplicada = '';
                        let isTransacaoDuplicada = false;
                        let iconeStatusCartao;
                        let tipoPagamento;
                        let numeroCartaoOfuscado = item.numeroCartao.substring(0, 4) + '.XXXX.XXXX.' + finalNumeroCartao;
                        let detEstabelecimento = 'Transação de serviço';
                        let detRamoAtividade = item.ramoAtividade ? ' - ' + item.ramoAtividade : '';
                        let detCodigoRamoAtividade = item.codigoRamoAtividade ? item.codigoRamoAtividade : ' - ';
                        
                        if (item.estabelecimento){
                            detEstabelecimento = item.estabelecimento;
                        }
                        
                        isTransacaoDuplicada = autorizacaoDuplicada[item.codigo] > 1;
                        if (isTransacaoDuplicada){
                            iconeTransacaoDuplicada = 'utility:warning';
                        }
                        
                        if (item.meioPagamento === 'Virtual'){
                            iconeStatusCartao = 'custom:custom68';
                        } else if (item.meioPagamento === 'Cartão'){
                            item.meioPagamento = 'Cartão físico';
                            iconeStatusCartao = 'custom:custom40';
                        } else if (item.meioPagamento === 'Contactless'){
                            iconeStatusCartao = 'custom:custom30';
                        }
                        
                        if (item.quantidadeParcelas > 1 && item.valor != 0){
                            tipoPagamento = 'Pagamento parcelado';
                        } else if (item.valor != 0) {
                            tipoPagamento = 'Pagamento à vista';
                        } else {
                            tipoPagamento = ' - ';
                        }

                        let codigoEntrada = '-';
                        let detalheEntrada = '-';
                        if(item.codigoEntrada){
                            codigoEntrada = item.codigoEntrada;
                            detalheEntrada = codigoEntrada;

                            if(item.detalheEntrada){
                                detalheEntrada = detalheEntrada + ' - ' + item.detalheEntrada;
                            }
                        }

                        let status = '-';
                        this.optionsCartoes.forEach(item => {
                            if(item.numeroCartao === numeroCartaoOfuscado){
                                status = item.statusCartao;
                                return false;
                            }
                        });

                        transacoesCartao.push(
                            {
                                index: finalNumeroCartao + '_' + dataTransacao.getTime(),
                                dataTransacao: dataFormatada.split(',').join(''),
                                dataTransacaoISO: dataTransacaoISO,
                                codigoTransacao: item.codigo ? item.codigo : '-',
                                valorFormatado: valorFormatado,
                                valor: item.valor,
                                quantidadeParcelas: item.quantidadeParcelas ? item.quantidadeParcelas : '-',
                                codigoResposta: item.codigoResposta,
                                detalheResposta: item.detalheResposta,
                                estabelecimento: detEstabelecimento,
                                codigoRamoAtividade: item.codigoRamoAtividade ? item.codigoRamoAtividade : ' - ',
                                cidade: item.cidade ? item.cidade : ' - ',
                                codigoPais: item.codigoPais,
                                pais: item.pais,
                                tipoTransacao: item.tipoTransacao ? item.tipoTransacao : '-',
                                codigoRecusa: item.codigoRecusa,
                                traducaoRecusa: item.traducaoRecusa ? item.traducaoRecusa : '-',
                                codigoEntrada: codigoEntrada,
                                detalheEntrada: detalheEntrada,
                                meioPagamento: item.meioPagamento ? item.meioPagamento : '-',
                                traducaoStatusAutorizacao: item.traducaoStatusAutorizacao ? item.traducaoStatusAutorizacao : '-',
                                numeroCartaoOfuscado: numeroCartaoOfuscado,
                                status: status,
                                statusCartao: iconeStatusCartao,
                                isTransacaoDuplicada: isTransacaoDuplicada,
                                transacaoDuplicada: iconeTransacaoDuplicada,
                                statusTransacao: item.codigoResposta + ' - ' + item.detalheResposta,
                                ramoAtividade: detCodigoRamoAtividade + detRamoAtividade,
                                tipoPagamento: tipoPagamento,
                                finalNumeroCartao: finalNumeroCartao,
                                cartaoSelecionado: this.numeroCartaoSelecionado
                            }
                        );
                    }
                });

                this.listaTransacoes = transacoesCartao;
                this.listaTransacoes = [...this.formatTransacoes()];
                this.selectedIdListaTransacoes = [...this.selectedIdListaTransacoes];
                
                this.disablePagVoltar = this.pagina > 1 ? false : true;
                this.disablePagIr = this.tamanhoPagina * this.pagina < this.totalItens ? false : true;
                this.mostrarPaginacao = true;
                this.semRetorno = false;
                this.erroRetorno = false;
                this.comRetorno = true;
            } else {
                this.semRetorno = false;
                this.erroRetorno = true;
                this.comRetorno = false;
            }
        }).catch(error => {
            console.log('Erro carregarTransacoes: ' + error);
        });

        this.atualizaMsgTransacoes();
        this.closeSpinner();
    }

    async bloquearCartao(numeroSerno, novoStatusCartao, indexCartao){

        /** 
         *  Quando um cartão físico é reemitido, o novo cartão herda o sernoId do cartão antigo.
         * E o novo cartão passa a listar as transações do cartão antigo.
         * Nesse cenário o cartão antigo já foi bloqueado, não precisando bloquear o cartão da transação novamente.
        **/

        return await bloquearCartao({
            idEmpresa: this.idEmpresa, 
            sistema: this.canal, 
            canal: this.canal, 
            area: this.areaPrincipal,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''), 
            numeroConta: this.numeroConta, 
            numeroCartaoSerno: numeroSerno, 
            novoStatus: novoStatusCartao
        }).then(result => {
            let numeroCartao = this.cartoesCaso[indexCartao].numeroCartao;
            if(result === 'OK'){
                this.cartoesBloqueados.push('Cartão ' + numeroCartao);
                this.displaycartoesBloqueados = true;
                this.cartoesCaso[indexCartao].cartaoBloqueado = true;
            } else if(result === 'ERRO_PERFILIZACAO'){
                this.cartoesJaBloqueados.push('Cartão ' + numeroCartao);
                this.displaycartoesJaBloqueados = true;
                this.cartoesCaso[indexCartao].cartaoBloqueado = true;
            } else {
                this.cartoesNaoBloqueados.push('Cartão ' + numeroCartao);
                this.displaycartoesNaoBloqueados = true;
                this.cartoesCaso[indexCartao].cartaoBloqueado = false;
            }
        }).catch(error => {
            let numeroCartao = this.cartoesCaso[indexCartao].numeroCartao;
            this.cartoesNaoBloqueados.push('Cartão ' + numeroCartao);
            this.displaycartoesNaoBloqueados = true;
            cartao.cartaoBloqueado = false;
            console.log('bloquearCartao:' + error);
        });
    }
    //#endregion
    //#region Métodos de apoio
    formatTransacoes(){
        return this.listaTransacoes.map(row => {
            let statusStyle = row.statusTransacao.includes('Transação negada') ? 'slds-text-color_error slds-text-title_bold' : '';
            let statusCodigo = row.codigoTransacao === '071165' ? 'utility:ribbon' : '';
            return { ...row, statusStyle: statusStyle, statusCodigo: statusCodigo};
        });
    }

    formatarData(date){
        return new Intl.DateTimeFormat('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        }).format(date)
    }

    get quantidadePag() {
        return [
            { label: '10', value: '10' },
            { label: '20', value: '20' },
            { label: '30', value: '30' },
        ];
    }
    
    handleChangePagina(event) {
        this.pagina = 1;
        this.tamanhoPagina = event.detail.value;
        this.carregarTransacoes();
    }

    handleCopy(event) {

        let dados = '';
        let tipoDados = event.target.name;
        if(tipoDados === 'dadosCartao'){
            dados = 'Cartão: ' + this.transacaoDetalhada.numeroCartaoOfuscado + 
                ' | Nome reduzido: ' + this.nomeReduzidoCartaoSelecionado + 
                ' | Status Cartão: ' + this.transacaoDetalhada.status 
                + ' | Tipo de conta: ' + this.tipoConta;
        } else if(tipoDados === 'dadosTransacao'){
            dados = 'Cód. Autorização: ' + this.transacaoDetalhada.codigoTransacao + 
                ' | Data/Hora: ' + this.transacaoDetalhada.dataTransacao +
                ' | Estabelecimento: ' + this.transacaoDetalhada.estabelecimento + 
                ' | Valor total: ' + this.transacaoDetalhada.valorFormatado + 
                ' | Status transação: ' + this.transacaoDetalhada.statusTransacao + 
                ' | Detalhe recusa: ' + this.transacaoDetalhada.traducaoRecusa + 
                ' | Ramo atividade: ' + this.transacaoDetalhada.ramoAtividade + 
                ' | Cidade: ' + this.transacaoDetalhada.cidade + 
                ' | País: ' + this.transacaoDetalhada.pais + 
                ' | Meio de pagamento: ' + this.transacaoDetalhada.meioPagamento + 
                ' | Entrada: ' + this.transacaoDetalhada.detalheEntrada +
                ' | Tipo: ' + this.transacaoDetalhada.tipoPagamento +
                ' | Parcelas: ' + this.transacaoDetalhada.quantidadeParcelas +
                ' | Tipo Transação: ' + this.transacaoDetalhada.tipoTransacao;
        } else if(tipoDados === 'codigoTransacao'){
            dados = this.transacaoDetalhada.codigoTransacao;
        } else if (tipoDados === 'dadosFinanceiros'){
            dados = 'Limite total: ' + this.limiteTotal + ' | Limite disponível: ' + this.limiteDisponivel;
        }

        const textarea = document.createElement('textarea');
        textarea.value = dados;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
    }

    redirecionarTabelaRecusa(){
        window.open(this.urlTabelaRecusas);
    }

    pagIr(){
        this.pagina = this.pagina + 1;
        this.carregarTransacoes();
    }

    pagVoltar(){
        this.pagina = this.pagina - 1;
        this.carregarTransacoes();
    }

    get direcionarFilaManual(){
        return this.tipoCaso == 'MANUAL';
    }

    get today(){
        let date = new Date();
        let month = (date.getMonth() + 1) < 10 ? '0'+(date.getMonth() + 1) : (date.getMonth() + 1);
        let day = date.getDate()  < 10 ? '0' + date.getDate() : date.getDate();
        return day + '/' + month + '/' + date.getFullYear();
    }

    get showButtonVoltar(){
        return this.stepOne || this.stepTwo;
    }

    formatYYYYMMDD(date){
        let month = (date.getMonth() + 1) < 10 ? '0'+(date.getMonth() + 1) : (date.getMonth() + 1);
        let day = date.getDate()  < 10 ? '0' + date.getDate() : date.getDate();
        return date.getFullYear() + '-' + month + '-' + day;
    }

    atualizarLabelButtonContestar(){
        if(this.selectedListaTransacoes.length > 0 ) {
            this.disableButtonContestar = false
            this.labelContestarButton = 'Contestar compra (' + this.selectedListaTransacoes.length + ')';
        } else {
            this.labelContestarButton = 'Contestar compra';
            this.disableButtonContestar = true;
        }
    }

    atualizarLabelCartoes(){      

        this.optionsCartoes.forEach(item => {
            let count = 0;
            for (let i = 0; i < this.selectedListaTransacoes.length; i++) {
                if(this.selectedListaTransacoes[i].numeroCartaoOfuscado === item.numeroCartao){
                    count++;
                }
            }
            if(count > 0){
                item.label =  item.labelInicial + ' (' + count + ')';
            } else {
                item.label =  item.labelInicial;
            }
        });

        this.optionsCartoes = [...this.optionsCartoes];
    }

    verifyDisabled(){

        let dadosCartaoPendente = false;
        for (let i = 0; i < this.cartoesCaso.length; i++) {
            if(this.cartoesCaso[i].cartaoRoubado === '' || this.cartoesCaso[i].clienteComCartao === ''){
                dadosCartaoPendente = true;
                break;
            }
        }
        
        if (dadosCartaoPendente || 
            this.origemValue == null || this.origemValue == undefined ||
            this.canalValue == null  || this.canalValue == undefined  ||
            this.consultaRealizadaEthoca == null  || this.consultaRealizadaEthoca == undefined  ||
            this.selectedListaTransacoes.length == 0 || 
            (this.tipoCaso === 'MANUAL' && this.tipoReclamacaoValue == null) ) {
                this.disableButtonFinalizar = true;
        } else {
            this.disableButtonFinalizar = false;
        }
    }

    CriarCaso() {
        let evento =  'Contestação';
        if(this.tipoCaso === 'RPA'){
            evento = 'Não reconhece compra';
        }

        let numeroConta = this.numeroConta;
        let transacoesContestacao = [];

        this.selectedListaTransacoes.forEach(item => {
            let cartao = this.cartoesCaso.find(option => option.numeroCartao == item.numeroCartaoOfuscado);
            if(cartao){
                transacoesContestacao.push({
                    numeroConta: numeroConta,
                    numeroCartaoOfuscado: item.numeroCartaoOfuscado.replaceAll('.', ''),
                    idCartaoSerno: cartao.value,
                    dataTransacao: item.dataTransacao,
                    dataTransacaoISO: item.dataTransacaoISO,
                    codigoTransacao: item.codigoTransacao,
                    valor: item.valor,
                    codigoEntrada: item.codigoEntrada,
                    cartaoBloqueado: cartao.cartaoBloqueado,
                    cartaoRoubado: cartao.cartaoRoubado,
                    clienteCartao: cartao.clienteComCartao
                });
            }
        });

        createCase({
            evento: evento,
            origem: this.origemValue,
            canal: this.canalValue,
            tipoReclamacao: this.tipoReclamacaoValue,
            consultaEthoca: this.consultaRealizadaEthoca,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa,
            descricao: this.valueDescricao,
            transacoesContestadasJson: JSON.stringify(transacoesContestacao),
        }).then(caso => {
            this.stepTwo = false;
            this.stepThree = true;
            this.numeroCaso = caso.CaseNumber;
            this.caseId = caso.Id;

            // Se o caso for tratado no RPA, deverá ser feita a marcação na Paytrue.
            if(this.tipoCaso === 'RPA'){
                console.log('Início marcação.');
                console.log(JSON.stringify(transacoesContestacao));
                marcarTransacoes({
                    canal: this.canal, 
                    idEmpresa: this.idEmpresa, 
                    cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''), 
                    tipoReclamacao: this.tipoReclamacaoValue,
                    transacoesContestadasJson: JSON.stringify(transacoesContestacao),
                }).then(result => {
                    console.log('Fim marcação. ' + JSON.stringify(result));
                }).catch(error => {
                    console.log('marcarTransacoes: ' + error);
                });
            }
            
            this.closeSpinner();
        }).catch(error => {
            console.log('createCase: ' + error);
            this.closeSpinner();
            this.showToast('Solicitação de contestação cancelada', 'Houve um erro não criação do caso.', 'error', true, 'dismissible');
        })
        
    }

    leftPadData(info){
        let infoString = '' + info;
        if(infoString.length < 2){
            return '0' + infoString;
        }
        return infoString;
    }

    getDateISOFormat(dataOriginal){
        let dataFormatted = '' + dataOriginal.getFullYear() + this.leftPadData(dataOriginal.getMonth() + 1) 
            + this.leftPadData(dataOriginal.getDate()) + this.leftPadData(dataOriginal.getHours()) + this.leftPadData(dataOriginal.getMinutes()) + this.leftPadData(dataOriginal.getSeconds());
        return dataFormatted;
    }

    async voltarTabContaFinanceiraHandler() {
        if (!this.tabId) {
            return;
        }

        const tabInfo = await getTabInfo(this.tabId);
        const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
        await focusTab(primaryTabId);
    }

    atualizaMsgTransacoes(){
        this.transacaoDiferentesCartoes = false;
        for (let i = 0; i < this.selectedListaTransacoes.length; i++) {
            if(this.numeroCartaoSelecionado != this.selectedListaTransacoes[i].cartaoSelecionado){
                this.transacaoDiferentesCartoes = true;
                break;
            }
        }
    }

    resetModuloContestacao(){
        this.optionsCartoes.forEach(item => {
            item.label = item.labelInicial;
        });
        this.optionsCartoes = [... this.optionsCartoes];

        this.stepTwo = false;
        this.selectedIdListaTransacoes = [];
        this.selectedListaTransacoes = [];
        this.cartoesCaso = [];
        this.cartoesJaBloqueados = [];
        this.cartoesBloqueados = [];
        this.cartoesNaoBloqueados = [];
        this.displaycartoesBloqueados = false;
        this.displaycartoesJaBloqueados = false;
        this.displaycartoesNaoBloqueados = false;
        this.labelContestarButton = 'Contestar compra';
        this.disableButtonContestar = true;
        this.transacaoDiferentesCartoes = false;
    }
}