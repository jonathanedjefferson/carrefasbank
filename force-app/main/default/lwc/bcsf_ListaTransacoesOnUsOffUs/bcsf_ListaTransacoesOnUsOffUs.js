import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';

import getContaFinanceira from '@salesforce/apex/BCSF_ReimpressaoSenhaController.getContaFinanceira';
import getListCartoes from '@salesforce/apex/BCSF_TransacoesOnUsOffUsController.getListCartoes';
import GetAutorizacoesOnUsOffUs from '@salesforce/apex/BCSF_TransacoesOnUsOffUsController.GetAutorizacoesOnUsOffUs';
import StatusCode from '@salesforce/schema/Contract.StatusCode';

const columns = [
    {
        label: '', fieldName: 'index',
        hideLabel: true,
        hideDefaultActions: true,
        fixedWidth: 50,
        initialWidth: 50,
        cellAttributes: { alignment: 'center' },
    },
    { label: 'Data/Hora', fieldName: 'dateTransacao' },
    { label: 'Número do Cartão', fieldName: 'numeroCartaoOfuscado' },
    { label: 'Estabelecimento', fieldName: 'estabelecimento', type: 'button', typeAttributes:{label:{fieldName: 'estabelecimento'}, name: 'show_details', variant: 'base'} },
    { label: 'Cód. Autorização ', fieldName: 'codigo', cellAttributes: { iconName: {fieldName: 'transacaoDuplicada', name: 'Status'}}},
    { label: 'Valor', fieldName: 'valor' },
    { label: 'Status transação', fieldName: 'statusTransacao', type:'text', cellAttributes: {class:{fieldName: 'statusStyle'}}},
    { label: 'Status autorização', fieldName: 'traducaoStatusAutorizacao'},
    { label: 'Meio de pagamento', fieldName: 'meioPagamento', cellAttributes: { iconName: {fieldName: 'statusCartao', name: 'Status'}}},
];


export default class BCSF_lista_assets extends LightningElement {
    get formattedData(){
        return this.listaTransacoes.map(row => {
            let statusStyle = row.statusTransacao.includes('Transação negada') ? 'slds-text-color_error slds-text-title_bold' : '';
            let statusCodigo = row.codigo === '071165' ? 'utility:ribbon' : '';
            let corIcone = row.statusTransacao === '51 - Transação negada' ? '.iconAtencao' : 'slds-text-color_success slds-text-title_bold';

            return { ...row, statusStyle: statusStyle, statusCodigo: statusCodigo, corIcone: corIcone};
        });
    }

    //#region Variaveis
    spinner = false;
    areaPrincipal = null;
    listaTransacoes = [];
    buttons = [];
    columns = columns;

    @track mostrarPaginacao = false;
    @track modalContacless = false;
    @track modalAtivarInativar = false;
    closeModalComponent = true;

    @api recordId;
    @api limiteTotal;
    @api limiteDisponivel;
    @track quantidadeAtivos = 0;
    @track item = 'items';
    @track abrirCaso = false;
    @track stepOne = false;
    @track stepTwo = false;
    @track stepThree = false;
    @track stepCaseTwo = false;
    @track stepTransacaoTwo = false;
    @track iconeTransacaoDuplicada;
    @track tamanhoPagina = 10;
    @track pagina = 1;
    @track totalPagina;
    @track totalItens;
    @track disablePagVoltar = true;
    @track disablePagIr = true;
    @track retorno = false;
    @track retornoErro = false;
    @track semRetorno = false;
    @track btnCaso = false;

    @track cartaoOptions;
    @track valueCartao;
    @track valueTipo;
    @track tipoTransacao = null;
    @track tipoPagamento = 0;
    @track nomeCartao;
    @track numeroCartaoOfuscado;
    @track tipoCartao;
    @track alterarStatus;
    @track nomeCartaoAlterar;
    @track nomeCompleto;
    @track nomeCompletoParts;
    @track statusCartao;
    @track titularApresentar;
    @track cartaoTitular = [];
    @track ehPrimario;

    //Informações do Cliente
    @track area;
    @track canal = 'cockpit';
    @track cep;
    @track rua;
    @track numero;
    @track complemento;
    @track bairro;
    @track cidade;
    @track estado;
    @track numeroConta;
    @track numeroCartaoSerno;
    @track contaFinanceira;
    @track unidadeNegocio;
    @track accountId;
    @track cpf;
    @track dataNascimento;
    @track today;

    // Retorno API
    @track dataTransacao;
    @track codigo;
    @track valor;
    @track quantidadeParcelas;
    @track valorParcelado;
    @track codigoResposta;
    @track detalheResposta;

    @track codigoRamoAtividade;
    @track ramoAtividade;
    @track cidade;
    @track codigoPais;
    @track pais;
    @track tipoTransacao;
    @track codigoRecusa;
    @track traducaoRecusa;
    @track codigoEntrada;
    @track meioPagamento;
    @track detalheEntrada;
    @track statusAutorizacao;
    @track traducaoStatusAutorizacao;
    @track codContaFinanceira;

    @track transacaoSelecionada = {};
    @track actionName;
    @track linha;

    //#endregion

    //#region wire's
    @wire(CurrentPageReference)
    pagRef;

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.recordId = this.pagRef.state.c__recordId;
        this.limiteTotal = this.pagRef.state.c__limiteTotal;
        this.limiteDisponivel = this.pagRef.state.c__limiteDisponivel;
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth()+1).padStart(2,'0');
        const day = String(date.getDate()).padStart(2,'0');
        this.dataFinal = `${year}-${month}-${day}`;
        const inicialDate = new Date();
        inicialDate.setDate(inicialDate.getDate() - 90);
        const inicialYear = inicialDate.getFullYear();
        const inicialMonth = String(inicialDate.getMonth()+1).padStart(2,'0');
        const inicialDay = String(inicialDate.getDate()).padStart(2,'0');
        this.dataInicial = `${inicialYear}-${inicialMonth}-${inicialDay}`;

        this.showSpinner();
        getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(result => {
            try {
                this.numeroConta = result.NumeroConta;
                this.unidadeNegocio = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.cep = result.CEP;
                this.rua = result.Rua;
                this.numero = result.Numero;
                this.complemento = result.Complemento;
                this.bairro = result.Bairro;
                this.cidade = result.Cidade;
                this.estado = result.Estado;
                this.cpf = result.CPF;
                this.dataNascimento = result.DataNascimento;
                this.contaFinanceira = result.contaFinanceiraId;
                this.codContaFinanceira = result.NomeConta;
                this.GetListCartoes();

            } catch (error) {
                console.log('Erro catch() getContaFinanceira: ' + error);
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getContaFinanceira: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
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

    //#endregion
    get transacaoOptions() {
        return [
            { label: 'ON-US', value: 'onUs' },
            { label: 'OFF-US', value: 'offUs' },
        ];
    }

    handleCartao(event) {
        this.valueCartao = event.detail.value;
        this.nomeCartao = this.cartaoOptions.find(option => option.value == this.valueCartao).nomePortador;
        this.numeroCartaoOfuscado = this.cartaoOptions.find(option => option.value == this.valueCartao).numberCartao;
        this.tipoCartao = this.cartaoOptions.find(option => option.value == this.valueCartao).tipoCartao;
        this.numeroCartaoSerno = this.cartaoOptions.find(option => option.value == this.valueCartao).numeroCartaoSerno;
        this.statusCartao = this.cartaoOptions.find(option => option.value == this.valueCartao).status;
        this.titularApresentar = this.cartaoOptions.find(option => option.value == this.valueCartao).titular;
    }

    handleDataInicial(event){
        this.dataInicial = event.detail.value;
    }

    handleDataFinal(event){
        this.dataFinal = event.detail.value;
    }

    GetListCartoes() {
        getListCartoes({
            numeroConta: this.numeroConta,
            idEmpresa: this.unidadeNegocio,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            canal: this.canal

        }).then(result => {
            if (result.data != null) {
                this.cartaoOptions = result.data.clientePorConta.contaCartao.contratos[0].cartoes.map(item => ({
                    label: `Cartão ${item.ehVirtual ? "Virtual" : "Físico"} - Final ${item.numeroCartao.slice(-4)} - ${item.nomePortador} ${item.tipoTitularidade === "TITULAR" ? " - (Titular)" : " - (Adicional)"}`,
                    value: `${item.numeroCartao}`,
                    tipoCartao: `${item.ehVirtual ? "Virtual" : "Físico"}`,
                    numberCartao: `${item.numeroCartao}`,
                    nomePortador: `${item.nomePortador}`,
                    tipoTitularidade: `${item.tipoTitularidade}`,
                    ehPrimario: `${item.ehPrimario}`,
                    numeroCartaoSerno: `${item.id}`,
                    status: `${item.statusCartao}`,
                    titular: `${item.tipoTitularidade === "TITULAR" ? "Titular" : "Adicional"}`
                }));

                for (let i = 0; i < this.cartaoOptions.length; i++){
                    if(this.cartaoOptions[i].titular === 'Titular' && this.cartaoOptions[i].ehPrimario == 'true'){
                        this.value = this.cartaoOptions[i].value;
                        this.numeroCartaoSerno = this.cartaoOptions[i].numeroCartaoSerno;
                        this.numeroCartaoOfuscado = this.cartaoOptions[i].numberCartao;
                        this.statusCartao = this.cartaoOptions[i].status;
                        this.nomeCartao = this.cartaoOptions[i].nomePortador;
                        this.ehPrimario = this.cartaoOptions[i].ehPrimario;
                        this.titularApresentar = this.cartaoOptions[i].titular;
                        this.carregarTransacoes();
                        break;
                    }
                }

                if (this.cartaoOptions.length == 0) {
                    this.showToast('Erro', 'Esta conta financeira não possui cartões.', 'error', true);
                    this.closeSpinner();
                }
            } else {
                this.showToast('Erro', 'Esta conta financeira não possui cartões.', 'error', true);
                this.closeSpinner();
            }

        }).catch(error => {
            console.log('Erro getListCartoes: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar cartões!', 'error', true);
            this.closeSpinner();
        });
    }


    carregarTransacoes() {
        this.showSpinner();
        GetAutorizacoesOnUsOffUs({
            NumeroConta: this.numeroConta,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.canal,
            numeroCartaoSerno: this.numeroCartaoSerno,
            CPF: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            dataFinal: this.dataFinal,
            dataInicial: this.dataInicial,
            tamanhoPagina: this.tamanhoPagina,
            pagina: this.pagina

        }).then(result => {
            this.retorno = true;
            this.btnCaso = true;
            this.semRetorno = false;
            this.retornoErro = false;
            if (result.statusAutorizacao == 'OK' && result.data.length > 0) {
                let transacoesCartao = [];
                var index = 0;
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

                    if(i > this.tamanhoPagina){
                        this.totalPagina ++
                        controlePagina = controlePagina - result.tamanhoPagina;
                    }
                }

                result.data.forEach(item => {
                    if (index < this.tamanhoPagina) {
                        index++;
                        let indexN = index + ((this.pagina -1) * 10);
                        let dataFormatada = this.formatarData(new Date(item.data));
                        let valorFormatado = item.valor.toLocaleString('pt-br',{style: 'currency', currency: 'BRL'});
                        let valorParceladoFormatado = item.valorParcelado ? item.valorParcelado.toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}) : '-';
                        let detCodigoRamoAtividade = item.codigoRamoAtividade ? item.codigoRamoAtividade : ' - ';
                        let detRamoAtividade = item.ramoAtividade ? ' - ' + item.ramoAtividade : '';
                        let detEstabelecimento;
                        let iconeStatusCartao;

                        if (item.estabelecimento){
                            detEstabelecimento = item.estabelecimento;
                        } else {
                            detEstabelecimento = 'Transação de serviço';
                        }

                        if (autorizacaoDuplicada[item.codigo] > 1){
                            this.iconeTransacaoDuplicada = 'utility:warning';
                        } else this.iconeTransacaoDuplicada = '';

                        if (item.meioPagamento == 'Virtual'){
                            iconeStatusCartao = 'custom:custom68';

                        }else if (item.meioPagamento == 'Cartão'){
                            item.meioPagamento = 'Cartão físico';
                            iconeStatusCartao = 'custom:custom40';

                        }else if (item.meioPagamento == 'Contactless'){
                            iconeStatusCartao = 'custom:custom30';
                        }

                        if (item.quantidadeParcelas > 1 && item.valor != 0){
                            this.tipoPagamento = 'Pagamento parcelado';
                        } else if (item.valor != 0) {
                            this.tipoPagamento = 'Pagamento à vista';
                        } else {
                            this.tipoPagamento = ' - ';
                        }

                            transacoesCartao.push(
                                {
                                    index: indexN,
                                    dateTransacao: dataFormatada.split(',').join(''),
                                    codigo: item.codigo ? item.codigo : '-',
                                    valor: valorFormatado,
                                    quantidadeParcelas: item.quantidadeParcelas ? item.quantidadeParcelas : '-',
                                    valorParcelado: valorParceladoFormatado ? ' ('+valorParceladoFormatado+')' : '',
                                    codigoResposta: item.codigoResposta,
                                    detalheResposta: item.detalheResposta,
                                    estabelecimento: detEstabelecimento,
                                    codigoRamoAtividade: item.codigoRamoAtividade ? item.codigoRamoAtividade : ' - ',
                                    ramoAtividade: item.ramoAtividade,
                                    cidade: item.cidade ? item.cidade : ' - ',
                                    codigoPais: item.codigoPais,
                                    pais: item.pais,
                                    tipoTransacao: item.tipoTransacao ? item.tipoTransacao : '-',
                                    codigoRecusa: item.codigoRecusa,
                                    traducaoRecusa: item.traducaoRecusa ? ' - ' + item.traducaoRecusa : '',
                                    codigoEntrada: item.codigoEntrada ? item.codigoEntrada : '',
                                    meioPagamento: item.meioPagamento ? item.meioPagamento : '-',
                                    detalheEntrada: item.detalheEntrada ? ' - ' + item.detalheEntrada : '',
                                    statusAutorizacao: result.statusAutorizacao,
                                    traducaoStatusAutorizacao: item.traducaoStatusAutorizacao ? item.traducaoStatusAutorizacao : '-',
                                    numeroCartaoOfuscado: this.numeroCartaoOfuscado,
                                    statusCartao: iconeStatusCartao,
                                    transacaoDuplicada: this.iconeTransacaoDuplicada,
                                    statusTransacao: item.codigoResposta + ' - ' + item.detalheResposta,
                                    ramoAtividade: detCodigoRamoAtividade + detRamoAtividade,
                                    tipoPagamento: this.tipoPagamento,
                                }
                            );
                      
                    }
                });

                this.listaTransacoes = transacoesCartao;
                
                if(this.pagina > 1){
                    this.disablePagVoltar = false;
                }else{
                    this.disablePagVoltar = true;
                }

                if(this.tamanhoPagina * this.pagina < this.totalItens){
                    this.disablePagIr = false;
                }else{
                    this.disablePagIr = true;
                }

                this.mostrarPaginacao = true;
                this.closeSpinner();
            } else if (result.statusAutorizacao == 'OK' && result.data.length == 0) {
                this.semRetorno = true;
                this.retorno = false;
                this.retornoErro = false;
                this.btnCaso = false;
                this.closeSpinner();
            } else {
                this.retornoErro = true;
                this.btnCaso = true;
                this.semRetorno = false;
                this.retorno = false;
                this.closeSpinner();
            }
        }).catch(error => {
            console.log('carregarAtivos: ' + error);
            this.closeSpinner();
        });
    }

    pagIr(){
        this.pagina = this.pagina + 1;
        this.buscarCompras();
    }
    pagVoltar(){
        this.pagina = this.pagina - 1;
        this.buscarCompras();
    }

    abrirCasoSimples(){
        this.stepOne = false;
        this.stepTwo = true;
        this.stepCaseTwo = true;
        this.stepThree = false;
        this.abrirCaso = true;
    }

    @api closeParentComponent;
    closeQuickAction() {
        console.log('Fechar X');
        this.abrirCaso = false;
        if (this.closeParentComponent) {
            this.dispatchEvent(new CustomEvent('closeparentmodal'))
        } else {
            document.body.removeAttribute('style', 'overflow: hidden;');
        }
    }

    fecharCasoSimples() {
        this.abrirCaso = false;
    }

    abrirModalCaso(event){
        console.log('Inside abrirModalCaso---> ');
            // document.body.setAttribute('style');
            this.actionName = event.detail.action.name;
            this.linha = event.detail.row;

            if(this.actionName === 'show_details'){
                this.transacaoSelecionada = this.linha;
                this.stepOne = true;
                this.stepTwo = false;
                this.stepCaseTwo = false;
                this.stepThree = false;
                this.abrirCaso = true;
            }
    }

    fecharModalCaso() {
        document.body.removeAttribute('style', 'overflow: hidden;');
        this.abrirCaso = false;
    }

    handleBuscarCompras(){
        this.pagina = 1;
        this.buscarCompras();
    }

    buscarCompras() {
        const datFinal = new Date(this.dataFinal);
        const datInicial = new Date(this.dataInicial);
        const timeDiff = datFinal.getTime() - datInicial.getTime();
        const dayDiff = timeDiff / (1000 * 3600 * 24);

        if(dayDiff > 90){
            this.showToast('Erro', 'Não é possível consultar mais que 90 dias', 'error', true);
        } else {
            this.carregarTransacoes();
        }
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

    diaAtual(){
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth()+1).padStart(2,'0');
        const day = String(date.getDate()).padStart(2,'0');
        this.today = '${year}-${month}-${day}';
    }
}