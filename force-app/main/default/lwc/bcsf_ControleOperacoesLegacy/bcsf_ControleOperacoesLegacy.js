import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';

import USER_ID from '@salesforce/user/Id'; 
import USER_DRT from '@salesforce/schema/User.DRT__c';
import styles from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import imagemHome from '@salesforce/resourceUrl/imagemConsultarProposta';
import imagemFalhaAPI from '@salesforce/resourceUrl/imagemFalhaAPI';
import ImgErrorOff from '@salesforce/resourceUrl/ImgErrorOff';
import listagemLojas from '@salesforce/apex/BCSF_ControleOperacoesLegacyController.listagemHierarquias';
import listagemTipoEventos from '@salesforce/apex/BCSF_ControleOperacoesLegacyController.listagemTipoEventos';
import consultarOperacoes from '@salesforce/apex/BCSF_ControleOperacoesLegacyController.consultarOperacoes';
import getAccount from '@salesforce/apex/BCSF_ControleOperacoesLegacyController.getAccount';

export default class BCSF_ControleOperacoesLegacy extends LightningElement {
    spinner;
    telaHome = true;
    telaListagem = false;
    modalDetalhes = false;
    telaFalhaAPI = false;
    telaListaVazia = false;
    showBtnFalhaAPI = false;
    disableActions = false;
    disableBtnExport = true;
    paginaAtual = 1;
    totalPaginas = 0;
    totalItens = 0;
    imagemHome = imagemHome;
    imagemFalhaAPI = imagemFalhaAPI;
    ImgErrorOff = ImgErrorOff;
    itensPorPagina = '10';
    drtUser = '';

    /* variaveis campos */
    loja; 
    empresaField;
    transacao;
    usuarioField;
    cpfField;
    cpfErro;
    datasErro;
    dataFinal;
    dataInicio;
    canalAPI = 'cockpit'

    /* variaveis de detalhes */
    dataHora = '-';
    cpf = '-';
    nomeCliente = '-';
    canal = '-';
    empresa = '-';
    regional = '-';
    usuario = '-';
    assunto = '-';
    
    @track extensoes = []
    @track opcoesTransacoes = [];
    @track opcoesLojas = [];
    @track listaOperacoes = [];

    columns = [
        { label: 'Dt. operação', fieldName: 'dataOperacao', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'dataOperacao' }}},
        { label: 'Empresa', fieldName: 'empresa', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'empresa' }}},
        { label: 'Loja', fieldName: 'loja', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'loja' }}},
        { label: 'CPF', type: 'button', fieldName: 'cpf',  typeAttributes: { label: { fieldName: 'cpf' }, name: 'handleRowClick', variant: 'base'}, wrapText:true},
        { label: 'Canal', fieldName: 'canal', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'canal' }}},
        { label: 'Ação', fieldName: 'acao', type: 'customTextTooltip',  initialWidth: 400, typeAttributes: {value: { fieldName: 'acao' }}},
        { label: 'Usuário', fieldName: 'usuario', type: 'text' }
    ];
    
    opcoesEmpresas = [
        { label: 'TODAS', value: 'TODAS' },
        { label: 'ATACADÃO', value: '2' },
        { label: 'CARREFOUR', value: '1' },
        { label: 'SAMS CLUB', value: '6' },
    ]; 

    opcoesItensPorPagina = [
        { label: '5', value: '5' },
        { label: '10', value: '10' },
        { label: '20', value: '20' }
    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.cpfField = currentPageReference.state.c__cpf;
            this.dataInicio = currentPageReference.state.c__dataInicial;
            this.dataFinal = currentPageReference.state.c__dataFinal;
            this.redirecionado = currentPageReference.state.c__redirecionado;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USER_DRT] })
    getUserRecord({ error, data }) {
        if (data) {
            this.drtUser = data.fields.DRT__c.value;
            this.ListagemLojas();
        } else if (error) {
            this.erroListasPickist();
            console.log('getUserRecord', error);
        }
    }

    renderedCallback(){
        Promise.all([
            loadStyle(this, styles)
        ]).catch(error => {
            console.log("Error rendered: " + error.body.message);
        });
    }

    ListagemLojas(){
        this.spinnerOpen();
        listagemLojas({
            cpf: this.drtUser.replace(/[^a-zA-Z0-9]/g, ''),
            canal: this.canalAPI,
            idEmpresa: ''
        }).then((result) => {
            if (result.statusResponse === 'OK') {
                this.opcoesLojas = result.response.map(item => ({
                    label: !item.codigoSitef && item.descricao === 'AcessoFull'? 'TODAS': item.descricao.toUpperCase(),
                    value: !item.codigoSitef && item.descricao === 'AcessoFull'? 'TODAS': item.codigoSitef,
                }));
                this.ListagemTipoEventos();
            } else {
                throw new Error("erro ao listar lojas");
            }
        }).catch((error) => {
            this.erroListasPickist();
            this.showToast('','Falha buscar lista de hierarquias.', 'error', true)
            console.log('Erro ao buscar lista de lojas:', error.message);
        });
    }

    ListagemTipoEventos(){
        this.spinnerOpen();
        listagemTipoEventos({
            cpf: this.drtUser.replace(/[^a-zA-Z0-9]/g, ''),
            canal: this.canalAPI,
            idEmpresa: ''
        }).then((result) => {
            if (result.statusResponse === 'OK') {
                this.opcoesTransacoes = result.response.map(item => ({
                    label: item.nome,
                    value: item.id,
                }));
                this.opcoesTransacoes = [ {label: 'TODAS', value: 'TODAS'}, ...this.opcoesTransacoes]
                this.spinnerClose();
                if(this.redirecionado) this.callConsultarOperacoes();
            } else {
                throw new Error("erro ao listar tipo de eventos");
            }
        }).catch((error) => {
            this.erroListasPickist();
            this.showToast('','Falha buscar lista de tipo de eventos.', 'error', true)
            console.log('Erro ao buscar lista de tipo de eventos:', error.message);
        });
    }

    ConsultarOperacoes(){
        this.spinnerOpen();
        let loadBody = this.loadBody();
        consultarOperacoes({
            bodyJson: loadBody,
            cpf: this.cpfField?.replace(/\D/g, ''),
            canal: this.canalAPI,
            idEmpresa: this.empresaField
        }).then((result) => {
            if (result.statusResponse === 'OK' && result.totalItens > 0 ) {
                this.disableBtnExport = false;
                this.totalItens = result.totalItens;
                this.totalPaginas = Math.ceil(result.totalItens / this.itensPorPagina);
                this.paginaAtual = result.pagina;
                this.telaListagem = true;
                this.listaOperacoes = result.data.map(item => ({
                    ...item,
                    dataOperacao: this.formatDate(item.dataOperacao),
                    loja:  item.loja ? this.getTextLoja(String(item.loja)) : '-',
                    cpf: this.formatarCpf(item.cpf),
                    acao: item.acao || '',
                }));
            }else if(result.statusResponse === 'OK' && result.totalItens ==  0){
                this.telaListaVazia = true;
            } else {
                throw new Error("erro ao listar operações");
            }
            this.spinnerClose();
        }).catch((error) => {
            this.telaFalhaAPI = true;
            this.showBtnFalhaAPI = true;
            this.showToast('','Falha buscar lista de operações.', 'error', true)
            console.log('Erro ao buscar lista de operações:', error.message);
        });
    }

    GetAccount(){
        this.spinnerOpen();
        let listaCPF =  [ this.cpf, this.cpf.replace(/\D/g, '') ]
        getAccount({
            cpfList: listaCPF
        }).then((result) => {
            this.nomeCliente = result ? result.Name : '-';
            this.spinnerClose();
        }).catch((error) => {
            this.nomeCliente = '-';
            this.showToast('','Falha buscar conta.', 'error', true)
            console.log('Erro ao buscar conta:', error.message);
        });
    }
    
    handleRowClick(event) {
        const linha = event.detail.row;
        this.dataHora = linha.dataOperacao;
        this.cpf = linha.cpf;
        this.canal = linha.canal;
        this.empresa = linha.empresa;
        this.canal = linha.canal;
        this.regional = linha.loja;
        this.usuario = linha.usuario;
        this.assunto = this.getTextAcao(linha.acao, linha.evento);
        this.extensoes = linha.conteudos.map((item, index) => ({id: index+1, texto: this.getTextExtensoes(item.conteudoAuditoria)}));
        this.modalDetalhes = true;
        this.GetAccount();
    }

    handleBtnBuscar(){
        this.paginaAtual = 1;
        const validado = this.validarFields();
        if(validado){ 
            this.callConsultarOperacoes();
        }
    }

    callConsultarOperacoes(){
        this.telaHome = false;
        this.telaFalhaAPI = false;
        this.telaListaVazia = false;
        this.telaListagem = false;
        this.redirecionado = false;
        this.disableBtnExport = true;
        this.ConsultarOperacoes();
    }

    handleCloseModal(){
        this.modalDetalhes = false;
    } 

    handleItensPorPagina(event) {
        this.itensPorPagina = event.detail.value;
        this.paginaAtual = 1;
        this.ConsultarOperacoes();
    }

    handlePaginaAnterior() {
        if (this.paginaAtual > 1) {
            this.paginaAtual--;
            this.ConsultarOperacoes();
        }
    }

    handlePaginaProxima() {
        if (this.paginaAtual < this.totalPaginas) {
            this.paginaAtual++;
            this.ConsultarOperacoes();
        }
    }

    handleData(event) {
        const name = event.target.name;
        this[name] = event.target.value;
        this.validarPeriodo();
    }

    handleFieldsPicklist(event){
        const name = event.target.name;
        this[name] = event.detail.value;
    }

    handleFieldsText(event){
        const name = event.target.name;
        this[name] = event.target.value;
    }

    handleBtnResetFields(){
        this.dataInicio = null;
        this.dataFinal = null;
        this.cpfField = null;
        this.transacao = null;
        this.loja = null;
        this.empresaField = null;
        this.usuarioField = null;
    }

    getTextLoja(idLoja){
        if(!idLoja || idLoja === '-' ) return '-';

        let loja = this.opcoesLojas.find(item => item.value == idLoja);
        return loja ? loja.label : idLoja;
    }

    getTextAcao(acao, codigo){
        if(acao && !codigo)
            return acao;

        if(!acao && codigo)
            return `(${codigo.replace(/[()]/g, '')})`;

        if(acao && codigo)
            return `${acao} (${codigo.replace(/[()]/g, '')})`;

        return '-';
    }

    getTextExtensoes(texto){
        let regex = /^Conteúdo:\d+:\s*/;
        
        if (regex.test(texto)) {
            texto = texto.replace(regex, "");
        }
        return texto.trim()
    }

    getDatasAPI(dataInicialStr, dataFinalStr){
        const temHora = (data) => /T\d{2}:\d{2}/.test(data);
    
        if (temHora(dataInicialStr) && temHora(dataFinalStr)) {
            this.dataFinal = dataFinalStr
            this.dataInicio = dataInicialStr
            return;
        }
        let hojeBrasil = new Date();
        let dataFinal = new Date(dataFinalStr.split("T")[0]+'T00:00:00');
        let dataInicial = new Date(dataInicialStr.split("T")[0]+'T00:00:00');
        let diffDias = Math.floor((dataFinal - dataInicial) / (1000 * 60 * 60 * 24));

        if (dataFinal.getFullYear() === hojeBrasil.getFullYear() &&
            dataFinal.getMonth() === hojeBrasil.getMonth() &&
            dataFinal.getDate() === hojeBrasil.getDate() && diffDias >= 90){
            hojeBrasil = this.formatDateAPI(hojeBrasil.toISOString());
            this.dataFinal = this.dataFinal.split("T")[0] +'T'+ hojeBrasil.split("T")[1];
            this.dataInicio = this.dataInicio.split("T")[0] +'T'+ hojeBrasil.split("T")[1];
            return;
        }
        this.dataFinal = dataFinalStr.split("T")[0] + 'T23:59:59.000Z';
        this.dataInicio = dataInicialStr.split("T")[0] + 'T00:00:00.000Z';
    }

    loadBody(){
        this.getDatasAPI(this.dataInicio, this.dataFinal);
        let dados = {
            dataFinal: this.dataFinal,
            dataInicial: this.dataInicio,
            cpf: this.cpfField?.replace(/\D/g, ''),
            idTipoEvento:  this.transacao  === 'TODAS' ? '' : this.transacao,
            idEmpresa: this.empresaField === 'TODAS' ? '' : this.empresaField,
            codigoSitef: this.loja === 'TODAS' ? '' : this.loja,
            operador: this.usuarioField,
            pagina: this.paginaAtual,
            tamanhoPagina: this.itensPorPagina
        };

        Object.keys(dados).forEach(key => {
            if (dados[key] === null || dados[key] === '' || dados[key] === undefined) {
                delete dados[key];
            }
        });

        return JSON.stringify(dados);
    }

    validarFieldCPF(event){
        let valor = event.target.value.replace(/[^a-zA-Z0-9]/g, '');
        if(!valor){
            this.cpfErro = '';
            return
        }
        if (/[a-zA-Z]/.test(event.target.value)) {
            this.cpfErro = 'O CPF não pode conter letras.';
            return;
        }
        if (valor.length !== 11) {
            this.cpfErro = 'O CPF deve conter exatamente 11 dígitos.';
            return;
        }
        this.cpfErro = '';
        this.cpfField = this.formatarCpf(valor);
    }

    validarPeriodo() {
        if (!this.dataInicio || !this.dataFinal) return;
        const inicio = new Date(this.dataInicio);
        const fim = new Date(this.dataFinal);
        const diffMs = fim - inicio;
        const diffDias = Math.floor(diffMs / (1000 * 60 * 60 * 24));
        this.datasErro = diffDias > 90;
    }

    validarFields(){
        if(this.cpfErro){
            this.showToast('', this.cpfErro, 'error');
            return false
        }
        if(this.datasErro){
            this.showToast('', 'Só é possível buscar as propostas em um intervalo máximo de 90 dias', 'error');
            return false
        }
        this.loja = !this.loja && this.cpfField  ? 'TODAS' : this.loja;
        this.transacao = !this.transacao && this.cpfField ? 'TODAS' : this.transacao;
        this.empresaField = !this.empresaField && this.cpfField ? 'TODAS' : this.empresaField;
        return true
    }

    formatarCpf(valor) {
        if (valor?.length !== 11 || !valor) return valor;
        valor?.replace(/\D/g, '')
        return valor?.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
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

    formatDateAPI(data){
        let brasil = new Date(data.toLocaleString("en-US", { timeZone: "America/Sao_Paulo" }));
        let ano = brasil.getFullYear();
        let mes = String(brasil.getMonth() + 1).padStart(2, '0');
        let dia = String(brasil.getDate()).padStart(2, '0');
        let hora = String(brasil.getHours()).padStart(2, '0');
        let minuto = String(brasil.getMinutes()).padStart(2, '0');
        let segundo = String(brasil.getSeconds()).padStart(2, '0');
        return `${ano}-${mes}-${dia}T${hora}:${minuto}:${segundo}`;
    }

    erroListasPickist(){
        this.disableActions = true;
        this.telaFalhaAPI = true;
        this.telaHome = false;
    }

    showToast(titulo, mensagem, variante, close = false) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if(close){
            this.spinnerClose();
        }
    }

    spinnerOpen(){
        this.spinner = true;
    }

    spinnerClose(){
        this.spinner = false;
    }

    exportarTabela() {
        const dados = this.listaOperacoes;
        let doc;

        const colunas = [
            'Dt. operacao',
            'Empresa',
            'Loja',
            'CPF',
            'Canal',
            'Acao',
            'Usuario',
        ];

        colunas.forEach(element => {
            doc += element + ','
        });
        doc += '\n';

        dados.forEach(registro => {
            doc += registro.dataOperacao + ',';
            doc += registro.empresa + ',';
            doc += registro.loja + ',';
            doc += registro.cpf + ',';
            doc += registro.canal + ',';
            doc += registro.acao + ',';
            doc += registro.usuario + ',';
            doc += '\n';
        });
        doc = doc.replaceAll('undefined','');

        let element = 'data:text/csv;charset=utf-8,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'operacoes.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

}