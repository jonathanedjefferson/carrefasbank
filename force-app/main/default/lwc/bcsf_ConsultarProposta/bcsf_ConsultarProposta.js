import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import USER_ID from '@salesforce/user/Id';
import USERPROFILE_ID from '@salesforce/schema/User.Profile.Name';

import styles from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import imagemHome from '@salesforce/resourceUrl/imagemConsultarProposta';
import imagemEmpty from '@salesforce/resourceUrl/imagemEmptyConsultarProposta';
import getAcessoPerfil from '@salesforce/apex/BCSF_ConsultarPropostaController.getAcessoPerfil';
import getListParametrosProposta from '@salesforce/apex/BCSF_ConsultarPropostaController.getListParametrosProposta';
import criarCasoConsulta from '@salesforce/apex/BCSF_ConsultarPropostaController.criarCasoConsulta';
import criarCasoPropostaRecusada from '@salesforce/apex/BCSF_ConsultarPropostaController.criarCasoPropostaRecusada';
import consultarPropostas from '@salesforce/apex/BCSF_ConsultarPropostaController.consultarPropostas';
import consultarHistorico from '@salesforce/apex/BCSF_ConsultarPropostaController.consultarHistoricoProposta';

const columns = [
    { label: 'Criação', fieldName: 'CriacaoFormatada', type: 'datetime', sortable: true, wrapText:true},
    { label: 'Proposta', type: 'button', typeAttributes: { label: { fieldName: 'Proposta' }, name: 'abrirProposta', variant: 'base'}, wrapText:true},
    { label: 'Nome do titular', fieldName: 'NomeTitular', type: 'text', wrapText:true},
    { label: 'Atualização status', fieldName: 'AtualizacaoStatus', type: 'datetime', wrapText:true },
    { label: 'Status', fieldName: 'Status', type: 'text', cellAttributes: { class: { fieldName: 'statusClass' }}, wrapText:true},
    { label: 'Loja', fieldName: 'Loja', type: 'text', wrapText:true },
    { label: 'Modalidade', fieldName: 'Modalidade', type: 'text', wrapText:true },
    { label: 'Embossing', fieldName: 'Embossing', type: 'text', wrapText:true },
];

export default class Bcsf_ConsultarProposta extends LightningElement {

    
    // Variaveis de Layout
    columns = columns;
    sortBy = 'CriacaoFormatada';
    sortDirection = 'asc';
    imagemHome = imagemHome;
    imagemEmpty = imagemEmpty;
    @track spinner = false;
    @track telaHome = true;
    @track telaEmpty = false;
    @track telaListagem = false;
    @track erroFieldData = false;
    @track modalHistoricoProposta = false;
    @track modalCasoConsultaProposta = false;
    @track modalCasoPropostaRecusada = false;
    @track telaOneCasoProposta = true;
    @track telaTwoCasoProposta = false;
    @track telaTreeCasoProposta = false;
    @track labelBtnNextCasoProposta = 'Prosseguir';
    @track labelBtnFecharCasoProposta = 'Fechar';
    @track disabledBtnNextConsulta = true;
    @track telaOneCasoPropostaRecusada = true;
    @track telaTwoCasoPropostaRecusada = false;
    @track telaTreeCasoPropostaRecusada = false;
    @track labelBtnNextCasoRecusa = 'Prosseguir';
    @track labelBtnFecharCasoRecusa = 'Fechar';
    @track disabledBtnNextRecusa = true;
    @track showDadosCompletos = false;
    @track showDadosMinimos = true;
    @track showErrorAlert = false;
    
    // Variaveis de informações 
    cpf;
    recordId;
    nomeCliente;
    perfil;
    acessoPerfil;
    @track numeroProposta = '-';
    @track statusProposta = '-';
    @track classStatusProposta = '-';
    @track codigoOcorrencia;
    @track descricaoOcorrencia;
    @track showDetalhesOcorrencia = false;
    @track emailProposta = '-';
    @track telefoneProposta = '-';
    @track cep = '-';
    @track endereco = '-';
    @track numeroEndereco = '-';
    @track complemento = '-';
    @track bairro = '-';
    @track cidade = '-';
    @track uf = '-';
    @track tipoLoja = '-';
    @track numProtocoloConsulta = '-';
    @track numProtocoloPropostaRecusada = '-';
    @track caseIdConsultar = '-';
    @track caseIdPropostaRecusada = '-';
    @track fieldDescricao;
    @track fieldPicklistStatus;
    @track fieldPicklistModalidade;

    // Listas
    @track historicoProposta =[] 
    @track data = [];
    @track statusPicklist = []
    @track modalidadePicklist = []

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.cpf = currentPageReference.state.c__cpf;
            this.recordId = currentPageReference.state.c__accountId;
            this.nomeCliente = currentPageReference.state.c__nome;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USERPROFILE_ID]}) 
    userDetails({error, data}) {
        if (data) {
            this.perfil = data.fields.Profile.value.fields.Name.value;
            this.GetAcessoPerfil();
        } else if (error) {
            console.log("Error ao identificar perfil: " + JSON.stringify(error));
        }
    }

    renderedCallback(){
        Promise.all([
            loadStyle(this, styles)
        ]).catch(error => {
            console.log("Error rendered: " + error.body.message);
        });
    }
    
    get sortedData() {
        return [...this.data].sort((a, b) => {
            let v1 = a.CriacaoOriginal;
            let v2 = b.CriacaoOriginal;
            return this.sortDirection === 'asc' ? v1.localeCompare(v2) : v2.localeCompare(v1);
        });
    }

    connectedCallback(){
        this.dataAtual = new Date();
        this.dataAtualFormatada = this.formatDate(new Date()).split(' ')[0];
    }

    GetAcessoPerfil(){
        this.spinnerOpen();
        getAcessoPerfil({
            label: this.perfil
        }).then((result) => {
            this.acessoPerfil = result.Acesso__c;
            this.GetListParametrosProposta();
        }).catch((error) => {
            console.log('Erro validar ao permissão: ', error.message);
            this.showToast('Erro', 'Houve um erro ao validar permissão!', 'error', true);
        });
    }

    GetListParametrosProposta(){
        getListParametrosProposta({
        }).then((result) => {
            this.statusPicklist = result.filter(item => item.TipoParametro__c === 'Status').map(item => ({
                label: item.Label__c,
                value: item.Valor__c
            }));
            this.statusPicklist = this.ordenarPicklist(this.statusPicklist)

            this.modalidadePicklist = result.filter(item => item.TipoParametro__c === 'Modalidade').map(item => ({
                label: item.Label__c,
                value: item.Valor__c
            }));
            this.modalidadePicklist = this.ordenarPicklist(this.modalidadePicklist)
            this.spinnerClose();
        }).catch((error) => {
            console.log('Erro validar ao permissão: ', error.message);
            this.showToast('Erro', 'Houve um erro ao validar permissão!', 'error', true);
        });
    }

    ConsultarPropostas(){
        this.spinnerOpen();
        consultarPropostas({
            cpf: this.cpf.replace(/[.\-]/g, '').replace(/^0+/, ''),
            status: this.fieldPicklistStatus,
            modalidade: this.fieldPicklistModalidade,
            dataInicio: `${this.dataInicial} 00:00:00`,
            dataFim: `${this.dataFinal} 00:00:00`,
            canal: 'cockpit'
        }).then(result=>{
            if(result.statusResponse === 'OK' && result.propostas){
                this.telaHome = false;
                this.telaEmpty = false;
                this.telaListagem = true;
                const propostaComTitular = result.propostas.find(item => item.nomeTitular);
                this.nomeCliente = propostaComTitular ? propostaComTitular.nomeTitular : '-';
                this.data = result.propostas.map(item => this.loadItemProposta(item));
            }else if(result.statusResponse === 'OK' && !result.propostas){
                this.telaHome = false;
                this.telaEmpty = true;
                this.telaListagem = false;
            }else if(result.statusResponse === '400' && result.messageError){
                const erroFieldData = result.messageError[0].toLowerCase().includes('data');
                this.showToast('', result.messageError[0].split(':')[1].trim(), 'error', true);
                this.showErrorData(erroFieldData);
            }else{
                throw new Error("erro ao listar propostas");
            }
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro ao buscar: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao ao buscar propostas!', 'error', true);
        })
    }

    ConsultarHistorico(){
        this.spinnerOpen();
        consultarHistorico({
            numeroProposta: this.numeroProposta, 
            cpf: this.cpf.replaceAll('.','').replaceAll('-',''),
            canal: 'cockpit'
        }).then(result=>{
            if(result.statusResponse === 'OK') {
                const ultimoStatusProposta = result.historicoProposta[result.historicoProposta.length - 1];
                this.historicoProposta = result.historicoProposta.map((item, index) => ({...item, id: index, data: this.formatDate(item.dataMovimentacao)}))
                this.modalHistoricoProposta = true;
                this.emailProposta = this.validarDadosUnico(ultimoStatusProposta.email);
                this.telefoneProposta = this.formatDadosComplementares(ultimoStatusProposta.ddd, ultimoStatusProposta.telefone);
                this.showDadosMinimos = !this.statusProposta.toLowerCase().includes('cancelada');
                this.showDadosCompletos = !this.statusProposta.toLowerCase().includes('cancelada') && this.statusProposta.toLowerCase().includes('dados completos');
                this.showErrorAlert = false;
                this.showDetalhesOcorrencia = false;
                const status = this.statusProposta.toLowerCase();
                if(status.includes('rejeitada') || status.includes('reprovada')){
                    this.showDetalhesOcorrencia = true;
                    this.codigoOcorrencia = ultimoStatusProposta.ocorrenciaHistorioDto.codigo ? ultimoStatusProposta.ocorrenciaHistorioDto.codigo : '-';
                    this.descricaoOcorrencia = ultimoStatusProposta.ocorrenciaHistorioDto.descricao ? ultimoStatusProposta.ocorrenciaHistorioDto.descricao : '-';
                    this.showErrorAlert = this.codigoOcorrencia === '-' || this.descricaoOcorrencia === '-' ? true : false;
                }
                if(ultimoStatusProposta.enderecoHistoricoDto){
                    this.cep = this.formatCEP(ultimoStatusProposta.enderecoHistoricoDto.cep);
                    this.endereco = this.validarDadosUnico(ultimoStatusProposta.enderecoHistoricoDto.endereco);
                    this.numeroEndereco = this.validarDadosUnico(ultimoStatusProposta.enderecoHistoricoDto.numero);
                    this.complemento = this.validarDadosUnico(ultimoStatusProposta.enderecoHistoricoDto.complemento);
                    this.bairro = this.validarDadosUnico(ultimoStatusProposta.enderecoHistoricoDto.bairro);
                    this.cidade = this.validarDadosUnico(ultimoStatusProposta.enderecoHistoricoDto.cidade)
                    this.uf = this.validarDadosUnico(ultimoStatusProposta.enderecoHistoricoDto.uf);
                }
            }else {
                throw new Error("erro ao buscar histórico");
            } 
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro consultarHistorico: '+ error.message);
            this.showToast('', 'Não foi possível carregar os dados do histórico da proposta', 'error', true);
        })
    }

    CriarCasoConsulta(){
        this.spinnerOpen();
        criarCasoConsulta({
            nomeCliente: this.nomeCliente, 
            cpf: this.cpf,
            accountId: this.recordId,
            origem: this.origemCasoConsulta,
            canal: this.canalCasoConsulta
        }).then(result=>{
            this.numProtocoloConsulta = result.CaseNumber;
            this.caseIdConsulta = result.Id;
            this.telaTwoCasoProposta = false;
            this.telaTreeCasoProposta = true;
            this.labelBtnNextCasoProposta = 'Ir para o caso';
            this.labelBtnFecharCasoProposta = 'Fechar';
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    CriarCasoPropostaRecusada(){
        this.spinnerOpen();
        criarCasoPropostaRecusada({
            nomeCliente: this.nomeCliente, 
            cpf: this.cpf,
            accountId: this.recordId,
            origem: this.origemCasoRecusa,
            canal: this.canalCasoRecusa,
            descricao: this.fieldDescricao
        }).then(result=>{
            this.numProtocoloPropostaRecusada = result.CaseNumber;
            this.caseIdPropostaRecusada = result.Id;
            this.telaTwoCasoPropostaRecusada = false;
            this.telaTreeCasoPropostaRecusada = true;
            this.labelBtnNextCasoRecusa = 'Ir para o caso';
            this.labelBtnFecharCasoRecusa = 'Fechar';
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    handleBtnBuscar(){
        if(this.dataInicial && this.dataFinal && this.fieldPicklistStatus && this.fieldPicklistModalidade && !this.erroFieldData){
            this.ConsultarPropostas();
        }else if(this.erroFieldData){
            this.showErrorData(this.erroFieldData);
            this.showToast('', 'Preencha todos os campos!', 'error');
        }else{
            this.showToast('', 'Preencha todos os campos!', 'error');
        }
    }

    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
    }

    handleAbriProposta(event){
        const linha = event.detail.row;
        this.numeroProposta = linha.Proposta;
        this.statusProposta =  linha.Status;
        this.tipoLoja = linha.Loja;
        this.classStatusProposta= this.loadClassStatusCaso(linha.Status);

        if (this.acessoPerfil === 'Consultar detalhes') {
            this.ConsultarHistorico();
        }else if (this.acessoPerfil === 'Criar caso de consulta') {
            this.modalCasoConsultaProposta = true;
        }else{
            this.showToast('', 'Não é possivel realizar essa ação', 'error');
        }
        
        /* if (this.acessoPerfil === 'Criar caso de recusa de crédito') {
            if(this.statusProposta.toLowerCase().includes('rejeitada') || this.statusProposta.toLowerCase().includes('reprovada')){
                this.modalCasoPropostaRecusada = true;
            }else{
                this.showToast('', 'Não é possivel realizar essa ação', 'error');
            }
        } */

    }

    handleDataInicial(event) {
        this.dataInicial = event.target.value;
        this.validarPeriodo();
    }
    
    handleDataFinal(event) {
        this.dataFinal = event.target.value;
        this.validarPeriodo();
    }

    handleCloseModal(){
        this.modalHistoricoProposta = false;
        this.modalCasoConsultaProposta = false;
        this.modalCasoPropostaRecusada = false;
        this.telaOneCasoProposta = true;
        this.telaTwoCasoProposta = false;
        this.telaTreeCasoProposta = false;
        this.labelBtnNextCasoProposta = 'Prosseguir';
        this.labelBtnFecharCasoProposta = 'Fechar';
        this.telaOneCasoPropostaRecusada = true;
        this.telaTwoCasoPropostaRecusada = false;
        this.telaTreeCasoPropostaRecusada = false;
        this.labelBtnNextCasoRecusa = 'Prosseguir';
        this.labelBtnFecharCasoRecusa = 'Fechar';
        this.fieldDescricao = '';
        this.disabledBtnNextRecusa = true;
    }

    handleBtnNextCasoConsulta(){
        if(this.telaOneCasoProposta){
            this.telaOneCasoProposta = false;
            this.telaTwoCasoProposta = true;
            this.labelBtnNextCasoProposta = 'Finalizar';
            this.labelBtnFecharCasoProposta = 'Voltar';
        }else if(this.telaTwoCasoProposta){
            this.CriarCasoConsulta();
        }else{
            window.location.href = '/lightning/r/Case/'+ this.caseIdConsulta +'/view';
        }
    }

    handleBtnCloseCasoConsulta(){
        if(this.telaTwoCasoProposta){
            this.telaOneCasoProposta = true;
            this.telaTwoCasoProposta = false;
            this.labelBtnNextCasoProposta = 'Prosseguir';
            this.labelBtnFecharCasoProposta = 'Fechar';
        }else{
            this.handleCloseModal();
        }
    }

    handleBtnNextCasoRecusa(){
        if(this.telaOneCasoPropostaRecusada){
            this.telaOneCasoPropostaRecusada = false;
            this.telaTwoCasoPropostaRecusada = true;
            this.labelBtnNextCasoRecusa = 'Finalizar';
            this.labelBtnFecharCasoRecusa = 'Voltar';
        }else if(this.telaTwoCasoPropostaRecusada){
            this.CriarCasoPropostaRecusada();
        }else{
            window.location.href = '/lightning/r/Case/'+ this.caseIdPropostaRecusada +'/view';
        }
    }

    handleBtnCloseCasoRecusa(){
        if(this.telaTwoCasoPropostaRecusada){
            this.telaOneCasoPropostaRecusada = true;
            this.telaTwoCasoPropostaRecusada = false;
            this.labelBtnNextCasoRecusa = 'Prosseguir';
            this.labelBtnFecharCasoRecusa = 'Fechar';
        }else{
            this.handleCloseModal();
        }
    }

    handleFielStatus(event){
        this.fieldPicklistStatus = event.detail.value;
    }

    handleFielModalidade(event){
        this.fieldPicklistModalidade= event.detail.value;
    }

    handleFielDescricao(event){
        this.fieldDescricao = event.detail.value;
        this.validarfieldsCasoRecusa();
    }

    handleOrigemCasoConsulta(event){
        this.origemCasoConsulta =  event.detail.value;
        this.validarfieldsCasoConsulta();
    }

    handleCanalCasoConsulta(event){
        this.canalCasoConsulta =  event.detail.value;
        this.validarfieldsCasoConsulta();
    }

    handleOrigemCasoRecusa(event){
        this.origemCasoRecusa =  event.detail.value;
        this.validarfieldsCasoRecusa();
    }

    handleCanalCasoRecusa(event){
        this.canalCasoRecusa =  event.detail.value;
        this.validarfieldsCasoRecusa();
    }

    loadClassStatus(status){
        const frase = status? status.toLowerCase() : '';
        if (frase.includes('aprovada') || frase.includes('concluída')) {
            return 'slds-text-color_success slds-text-title_bold'
        }

        if (frase.includes('rejeitada')) {
            return 'slds-text-color_error slds-text-title_bold'
        }
        return 'slds-text-title_bold'
    }

    loadClassStatusCaso(status){
        const frase = status? status.toLowerCase() : '';
        if (frase.includes('aprovada') || frase.includes('concluída')) {
            return 'slds-text-color_success valueDados'
        }

        if (frase.includes('rejeitada')) {
            return 'slds-text-color_error valueDados'
        }
        return 'valueDados'
    }

    loadItemProposta(item) {
        return {
            Criacao: item.dataCriacao,
            CriacaoFormatada: this.formatDate(item.dataCriacao),
            AtualizacaoStatus: this.formatDate(item.dataCriacao),
            CriacaoOriginal: item.dataCriacao,
            Proposta: item.numeroProposta,
            NomeTitular: item.nomeTitular,
            Status: item.status,
            Loja: item.loja,
            Modalidade: item.modalidade,
            Embossing: item.embossing ? 'Sim' : 'Não',
            statusClass: this.loadClassStatus(item.status)
        };
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

    formatCEP(cep){
        if (!cep) return '-';
        cep = cep.toString().replace(/\D/g, '');    
        cep = cep.padStart(8, '0');     
        return cep.replace(/(\d{5})(\d{3})/, '$1-$2');
    }

    formatDadosComplementares(dado, dadoComplementar){
        let retorno;
        if(dado){
            retorno = dado;
        }
        if(dadoComplementar){
            retorno = retorno + ' ' + dadoComplementar;
        }
        if(!retorno){
            retorno = '-'
        }

        return retorno;
    }

    validarPeriodo() {
        this.erroFieldData = false;
        if(!this.dataInicial || !this.dataFinal) {
            this.erroFieldData = true;
        }

        if(this.dataInicial && this.dataFinal) {
            this.showErrorData(this.erroFieldData);
        }
    }

    validarfieldsCasoConsulta(){
        this.disabledBtnNextConsulta = true;
        if(this.canalCasoConsulta && this.origemCasoConsulta){
            this.disabledBtnNextConsulta = false;
        }
    }

    validarfieldsCasoRecusa(){
        this.disabledBtnNextRecusa = true;
        if(this.canalCasoRecusa && this.origemCasoRecusa && this.fieldDescricao){
            this.disabledBtnNextRecusa = false;
        }
    }

    validarDadosUnico(dado){
        if(dado){
            return dado;
        }
        return '-';
    }

    ordenarPicklist(lista) {
        if (!Array.isArray(lista)) {
            return [];
        }
        const itemTodos = lista.find(item => item.label === 'Todos');
        const restantes = lista.filter(item => item.label !== 'Todos');
        return itemTodos ? [itemTodos, ...restantes] : lista;
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
            this.spinnerClose();
        }
    }

    showErrorData(erro){
        const inputInicial = this.template.querySelector('[data-id="dataInicial"]');
        const inputFinal = this.template.querySelector('[data-id="dataFinal"]');
        inputInicial.setCustomValidity('');
        inputFinal.setCustomValidity('');

        if(erro){
            inputInicial.setCustomValidity(' ');
            inputFinal.setCustomValidity(' ');
        }
        inputInicial.reportValidity();
        inputFinal.reportValidity();
    }

    spinnerClose(){
        this.spinner = false;
    }

    spinnerOpen(){
        this.spinner = true;
    }
}