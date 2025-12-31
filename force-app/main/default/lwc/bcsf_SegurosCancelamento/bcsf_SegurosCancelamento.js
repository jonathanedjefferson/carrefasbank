import { api, LightningElement, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import UNIDADE_ATENDIMENTO from '@salesforce/schema/User.UnidadeDeAtendimento__c';
import CANAL_ATENDIMENTO from '@salesforce/schema/User.CanaldeAtendimento__c';
import NAME from '@salesforce/schema/User.Name';
import DRT from '@salesforce/schema/User.DRT__c';


import getMotivosCancelamento from '@salesforce/apex/bcsf_cmp_SegurosController.getMotivosCancelamento'
import getDetalhesSeguro from '@salesforce/apex/bcsf_cmp_SegurosController.historicoCobranca'
import cancelamentoSeguro from '@salesforce/apex/bcsf_cmp_SegurosController.cancelarSeguro'
import criarCaso from '@salesforce/apex/bcsf_cmp_SegurosController.criarCasoCancelamento'
import criarCasoContestar from '@salesforce/apex/bcsf_cmp_SegurosController.criarCasosContestar'

export default class Bcsf_SegurosCancelamento extends LightningElement {

    //Var de tela 
    @api recordId
    @api seguro
    @api dadosCliente;
    @track isOpen = false;
    @track modalDetalhes = false;
    @track modalContestar = false;
    @track pageOneContestar = true;
    @track modalCancelar = false;
    @track pageOneCancelar = true;
    @track pageTwoCancelar = true;
    @track showFieldsCaso = false;
    @track especificarMotivo = false;
    @track disableBtnNext = true;
    @track disableBtnNextContestar = true;
    @track showBtnDetalhes = true;
    @track showStatusParcela = true;
    @track showContestar = true;
    @track spinner = false;
    @track badgeClass = 'badge slds-badge slds-badge_inverse';
    @track badgeText = '--';
    @track dataAtual;
    @track dataAtualFormatada;
    @track showBtnContestar = false;
    @track showBtnCancelar = false;
    @track isFluxoBtnContestarMain = false;
    
    //var cliente, seguro
    @track nomeSeguro = '--';
    @track totalParcelas;
    @track valorMensal = '--';
    @track totalPago = '--';
    @track parcelaAtual = '--';
    @track ultimaCobranca = '-';
    @track proximaCobranca = '--';
    @track valueStatusParcela = '';
    @track dataVencimento = '--';
    @track dataCancelamento = '--';
    @track contratoId = '--';
    @track motivoCancelamento = '--';
    @track seguroCancelado = false;
    @track idAdesao;
    
    //var atendente, caso e api
    @track drt;
    @track areaAtendimento;
    @track canaldAtendimento;
    @track nomeUsuario;
    @track caseIdCancelar;
    @track numProtocoloContestar = '--';
    @track caseIdContestar;
    @track codMotivoSelecionado;
    @track numProtocoloCancelar = '--';
    @track valueMotivoSelecionado;
    @track observacaoCancelar;
    @track canalCasoCancelar;
    @track origemCasoCancelar;
    @track canalCasoContestar;
    @track origemCasoContestar;
    @track especificarMotivoText;
    @track canalAPI = 'cockpit';


    @track listParcelas = [];
    @track listParcelasResponse = [];
    @track listMotivos = [];

    optionsStatusContratados = [
        { label: 'Todos', value: 'Todos' },
        { label: 'Concluída', value: '0' },
        { label: 'Pendente Geração', value: '1' },
        { label: 'Gerada', value: '2' },
        { label: 'Suspensa', value: '3' },
        { label: 'Cancelada', value: '4' },
        { label: 'Reagendada', value: '5' },
        { label: 'Estornada', value: '6' },
        { label: 'Pendente Retorno', value: '7' },
        { label: 'Pendente Retorno Tsys', value: '8' },
        { label: 'Enviado Seguradora', value: '9' },
        { label: 'Excedido Tentativas Envio', value: '10' },
        { label: 'Suspensa por Migração de Produto', value: '11' },
        { label: 'Suspensa por Cancelamento de Produto', value: '12' },
        { label: 'Transação Não Processada Tsys', value: '13' },
        { label: 'Transação Rejeitada Tsys', value: '14' },
        { label: 'Transação com Repique', value: '15' },
        { label: 'Cancelar Seguro', value: '16' },
        { label: 'Matriz Bloqueio Não Encontrada', value: '17' },
        { label: 'Não Postar Matriz de Bloqueio', value: '18' },
        { label: 'Com Erro', value: '99' }
    ];

    listMotivosContestacao = ['alega não ter aderido', 'produto vendido com informações divergentes']


    @wire(getRecord, { recordId: USER_ID, fields: [UNIDADE_ATENDIMENTO, DRT, CANAL_ATENDIMENTO, NAME] }) 
    currentUserInfo({ data }) {
        if (data) {
            this.areaAtendimento = data.fields.UnidadeDeAtendimento__c;
            this.canaldAtendimento = data.fields.CanaldeAtendimento__c;
            this.drt = data.fields.DRT__c.value;
            this.nomeUsuario = data.fields.Name.value;
        }
    }

    connectedCallback(){
        this.dataAtual = new Date()
        this.dataAtual.setHours(this.dataAtual.getHours() - 3);
        this.dataAtualFormatada = this.formatDate(new Date());
        this.dataVencimento = this.formatDate(this.seguro.dataFimVigencia);
        this.nomeSeguro = this.seguro.nomeProduto;
        this.showBtnCancelar = this.seguro.status == 'Ativo';
        this.contratoId = this.seguro.idAdesaoProseg || this.seguro.idAdesaoPdr;
        if(this.seguro.status == 'Cancelado'){
            this.motivoCancelamento = this.seguro.motivoCancelamento == null ? ' ' : this.seguro.motivoCancelamento;
            this.seguroCancelado = true;
            this.showBtnContestar = this.verificarSeguroContestavel();
            this.dataCancelamento = this.formatDate(this.seguro.dataCancelamento);
        }
        this.GetDetalhesSeguros();
    }

    get listMotivosCancelamento() {
        return this.listMotivos;
    }

    get iconName() {
        return this.isOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get seguroFormatado() {
        let numeroSorte = this.seguro.numeroSerie ? ` Série ${this.seguro.numeroSerie} | `: '';
        numeroSorte = this.seguro.numeroSorte ? numeroSorte +`Número: ${this.seguro.numeroSorte}` : numeroSorte;

        const campos = [
            { label: 'Plano e Valor', valor: `${this.seguro.nomePlano}`},
            { label: 'Nº do contrato', valor: this.contratoId },
            { label: 'Certificado / Bilhete', valor: this.seguro.certificado },
            { label: 'Tipo de adesão', valor: this.seguro.tipoadesao },
            { label: 'Nº da sorte', valor:  numeroSorte},
            { label: 'Data de adesão', valor: this.formatDate(this.seguro.dataAdesao) },
            { label: 'Início de vigência', valor: this.formatDate(this.seguro.dataInicioVigencia) },
            { label: 'Fim de vigência', valor: this.formatDate(this.seguro.dataFimVigencia) },
            { label: 'Canal de adesão', valor: this.getCanalInfo(this.seguro.codCanalAdesao, this.seguro.nomeCanalAdesao)},
            { label: 'Vendido por', valor: this.seguro.codigoOperadorVenda },
            { label: 'Data de cancelamento', valor: this.seguro.dataCancelamento ? this.formatDate(this.seguro.dataCancelamento) : '' },
            { label: 'Canal de cancelamento', valor: this.getCanalInfo(this.seguro.codCanalCancelamento, this.seguro.nomeCanalCancelamento) },
            { label: 'Motivo do cancelamento', valor:  this.motivoCancelamento || this.seguro.motivoCancelamento },
            { label: 'Cancelado por', valor: this.seguro.codigoOperadorCancelamento }
        ];

        return campos.filter(item => item.valor !== '' && item.valor !== null && item.valor !== undefined);
    }
    
    GetDetalhesSeguros(){
        this.spinnerOpen();
        getDetalhesSeguro({
            nameAdesao: this.seguro.idAdesaoProseg ? 'IdAdesaoProseg': 'IdAdesaoPdr',
            idAdesao: this.contratoId, 
            idEmpresa: this.dadosCliente.unidadeNegocio, 
            cpf: this.dadosCliente.cpf,
            canal: this.canalAPI 
        }).then((result) => {
            if(result.statusResponse == 'OK'){
                this.valorMensal = this.formatValor(result.valorMensal);
                this.totalPago = this.formatValor(result.totalPago);
                this.ultimaCobranca = result.ultimaCobranca ? this.formatDate(result.ultimaCobranca) : '-';
                this.proximaCobranca = this.formatDate(result.proximaCobranca);
                this.parcelaAtual = result.parcelaAtual > result.parcelas.length ? result.parcelaAtual-1:  result.parcelaAtual;
                this.listParcelasResponse = result.parcelas.map(parcela => {
                    parcela.statusCode = String(parcela.status);
                    parcela.status = this.loadTextStatus(parcela.status);
                    parcela.valor = this.formatValor(parcela.valor);
                    parcela.data = this.formatDate(parcela.data);
                    return parcela;
                })
                let parcelaAtualFields = this.listParcelasResponse.find(parcela => parcela.numero == this.parcelaAtual);
                this.totalParcelas = result.parcelas.length == 0 ? 1 : result.parcelas.length;
                this.listParcelas = this.listParcelasResponse;
                if(!parcelaAtualFields && this.listParcelasResponse.length === 0){
                    this.badgeText = 'Sem cobranças';
                    this.badgeClass = 'badge slds-badge slds-badge_inverse'
                    this.showBtnDetalhes = false;  
                }else if(!parcelaAtualFields && this.listParcelasResponse.length > 0){
                    const parcelaAlternativa = this.loadParcelaAlternativa();
                    this.parcelaAtual = parcelaAlternativa.numero;
                    this.badgeText = parcelaAlternativa.status == 0 ? 'Realizada' : 'Não realizada';
                    this.badgeClass = parcelaAlternativa.status == 0 ? 'badge slds-badge slds-theme_success' : 'badge slds-badge slds-badge_error';
                    this.showStatusParcela = false;
                }else{
                    this.badgeText = parcelaAtualFields.status == 0 ? 'Realizada' : 'Não realizada';
                    this.badgeClass = parcelaAtualFields.status == 0 ? 'badge slds-badge slds-theme_success' : 'badge slds-badge slds-badge_error';
                    this.showStatusParcela = false;
                }
                this.spinnerClose()
            }else{
                throw new Error("Erro ao buscar histórico de seguros");
            }
        }).catch((error) => {
            this.badgeText = 'Erro de carregamento';
            this.badgeClass = 'badge slds-badge slds-theme_error'
            this.showBtnDetalhes = false;
            console.log('Erro getDetalhesSeguro: ', error.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre histórico de seguro!', 'error', true);
        });
    }

    GetMotivosCancelamento(){
        this.spinnerOpen();
        getMotivosCancelamento({
            idEmpresa: this.dadosCliente.unidadeNegocio, 
            cpf: this.dadosCliente.cpf,
            canal: this.canalAPI 
        }).then((result) => {
            if(result.statusResponse == 'OK'){
                this.listMotivos = result.motivos.map(motivo => {
                    return {
                        label: motivo.descricao,
                        value: motivo.descricao,
                        id: motivo.codigoMotivo
                    }
                });
                this.modalCancelar = true;
            }else{
                throw new Error("Erro ao buscar os motivos de cancelamento");
            }
            this.spinnerClose();
        }).catch((error) => {
            console.log('Erro getMotivosCancelamento: ', error.message);
            this.showToast('Erro', 'Houve um erro ao buscar os motivos de cancelamento do seguro!', 'error', true);
        });
    }

    CancelamentoSeguro(){
        this.spinnerOpen();
        const contrato = this.loadContrato()
        cancelamentoSeguro({
            contrato: JSON.stringify(contrato)
        }).then((result) => {
            if(result.statusResponse == 'OK'){
                this.CriarCaso();
            }else{
                this.spinnerClose();
                throw new Error("Erro ao buscar ao cancelar seguro");
            }
        }).catch((error) => {
            console.log('Erro ao cancelar seguro: ',error.message)
            this.showToast('Erro', 'Houve um erro ao cancelar o seguro!', 'error', true);
        });
    }

    CriarCaso(){
        this.spinnerOpen();
        const seguroFormatado = this.loadSeguro();
        criarCaso({
            contaFinanceiraId: this.recordId, 
            accountId: this.dadosCliente.accountId, 
            unidadeNegocio: this.dadosCliente.unidadeNegocio,  
            Origem: this.origemCasoCancelar, 
            Canal: this.canalCasoCancelar,
            observacao: this.observacaoCancelar ? this.observacaoCancelar : '',
            outroMotivo: this.especificarMotivoText ? this.especificarMotivoText : '',
            seguro: seguroFormatado
        }).then(result=>{
            this.numProtocoloCancelar = result.CaseNumber;
            this.caseIdCancelar = result.Id;
            this.pageOneCancelar = false;
            this.pageTwoCancelar = true;
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    CriarCasoContestar(){
        this.spinnerOpen();
        const segurosFormatados = this.loadSeguros();
        criarCasoContestar({
            contaFinanceiraId: this.recordId, 
            accountId: this.dadosCliente.accountId, 
            unidadeNegocio: this.dadosCliente.unidadeNegocio,  
            Origem: this.origemCasoContestar, 
            Canal: this.canalCasoContestar,
            seguros: segurosFormatados
        }).then(result=>{
            this.numProtocoloContestar = result.CaseNumber;
            this.caseIdContestar = result.Id;
            this.pageOneContestar = false;
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    handleBtnDetalhes(){
        this.modalDetalhes = true;
    }

    handleFecharModalDetalhes(){
        this.modalDetalhes = false;
    }

    handleFecharModalCancelar(){
        this.modalCancelar = false;
        this.resetModal();
    }

    handleBtnVoltarContestar(){
        if(this.isFluxoBtnContestarMain){
            this.modalCancelar = false;
            this.modalContestar = false;
            this.isFluxoBtnContestarMain = false;
        }else{
            this.modalCancelar = true;
            this.modalContestar = false;
        }
    }

    handleFecharModalContestar(){
        this.modalCancelar = false;
        this.modalContestar = false;
        this.pageOneContestar = true;
        this.canalCasoContestar = '';
        this.origemCasoContestar = '';
        this.numProtocoloContestar = '--';
        this.caseIdContestar = '';
        this.resetModal();
    }

    handleBtnNextContestar(){
        this.pageOneContestar = false;
    }

    handleBtnNext(){
        if(this.modalCancelar){
            if(this.pageOneCancelar){
                this.CancelamentoSeguro();
            }else if (this.pageTwoCancelar){
                window.location.href = '/lightning/r/Case/'+ this.caseIdCancelar +'/view';
            }
        }

        if(this.modalContestar){
            if (this.pageOneContestar) {
                this.CriarCasoContestar();
            } else {
                window.location.href = '/lightning/r/Case/'+ this.caseIdContestar +'/view';
            }
        }
    }

    handleBtnCancelamento(){
        this.GetMotivosCancelamento();
    }

    handleBtnContestar(){
        this.modalContestar = true;
        this.modalCancelar = false;
    }

    handleBtnContestarMain(){
        this.modalContestar = true;
        this.isFluxoBtnContestarMain = true;
    }

    handleFieldOrigemCaso(event){
        if(this.modalCancelar){
            this.origemCasoCancelar = event.target.value;
            this.validateBtnNextCancelar();
        }
        
        if(this.modalContestar){
            this.origemCasoContestar = event.target.value;
            this.validateBtnNextContestar();
        }
    }

    handleFieldCanalCaso(event){
        if(this.modalCancelar){
            this.canalCasoCancelar = event.target.value;
            this.validateBtnNextCancelar();
        }
        
        if(this.modalContestar){
            this.canalCasoContestar = event.target.value;
            this.validateBtnNextContestar();
        }
    }

    handleChangeObservacaoCancelar(event){
        this.observacaoCancelar = event.target.value;
    }
    

    handleChangeEspecificarMotivo(event){
        this.especificarMotivoText = event.target.value;
        this.validateBtnNextCancelar();
    }

    handleChangeMotivo(event){
        this.valueMotivoSelecionado = event.target.value;
        this.motivoCancelamento = event.target.value;
        this.codMotivoSelecionado = this.listMotivosCancelamento.find(option => option.value == this.valueMotivoSelecionado).id;
        this.showFieldsCaso = true;
        this.especificarMotivo = this.valueMotivoSelecionado.toLowerCase() == 'outros';
        this.showContestar = this.listMotivosContestacao.includes(this.valueMotivoSelecionado.toLowerCase());
        this.validateBtnNextCancelar();
    }

    loadTextStatus(codigo) {
        const item = this.optionsStatusContratados.find(opt => opt.value === String(codigo));
        return item ? item.label : '--';
    }

    loadSeguro(){
        const retorno = {nome: this.seguro.nomeProduto, contrato: this.contratoId, motivo: this.motivoCancelamento};
        return JSON.stringify(retorno);
    }

    loadSeguros(){
        const retorno = [{nome: this.seguro.nomeProduto, contrato: this.contratoId, motivo: this.motivoCancelamento}];
        return JSON.stringify(retorno);
    }

    loadContrato(){
        return {
            "idAdesao": this.contratoId,
            "nomeAdesao": this.seguro.idAdesaoProseg ? 'idAdesaoProseg': 'idAdesaoPdr',
            "dataCancelamento": this.dataAtual.toISOString(),
            "codMotivoCancelamento": this.codMotivoSelecionado,
            "codigoCanalCancelamento": this.areaAtendimento.value,
            "nomeCanalCancelamento": this.truncateString(this.areaAtendimento.displayValue, 20),
            "codigoUsuarioCancelamento": this.drt,
            "nomeUsuarioCancelamento": this.nomeUsuario,
            "comentarioCancelamento": this.observacaoCancelar ? this.observacaoCancelar:'',
            "cpf": this.dadosCliente.cpf,
            "unidadeNegocio": this.dadosCliente.unidadeNegocio,
            "canal": this.canalAPI
        }
    }

    loadParcelaAlternativa(){
        return this.listParcelasResponse.find(parcela => {
                return parcela.data === this.ultimaCobranca;
            });
    }
    
    truncateString(value, maxLength = 20) {
        if (!value) return '';
        return value.length > maxLength ? value.substring(0, maxLength) : value;
    }

    getCanalInfo(codigo, nome) {
        return [codigo, nome].filter(valor => valor).join(' - ');
    }

    verificarSeguroContestavel(){
        let retorno = false;
        if(this.listMotivosContestacao.includes(this.seguro.motivoCancelamento == ' ' || this.seguro.motivoCancelamento == undefined ? '' : this.seguro.motivoCancelamento.toLowerCase().trim())){
            const hoje = new Date();
            const dataItem = new Date(this.seguro.dataCancelamento);
            const dataLimite = new Date(dataItem);
            dataLimite.setFullYear(dataLimite.getFullYear() + 5);
            retorno = hoje < dataLimite;
        }
        return retorno;
    }

    validateBtnNextCancelar(){
        this.disableBtnNext = true;
        if(this.valueMotivoSelecionado && this.canalCasoCancelar && this.origemCasoCancelar){
            this.disableBtnNext = false;
            if(this.especificarMotivo && !this.especificarMotivoText){
                this.disableBtnNext = true;
            }
        }
    }
    
    validateBtnNextContestar(){
        this.disableBtnNextContestar = true;
        if(this.canalCasoContestar && this.origemCasoContestar){
            this.disableBtnNextContestar = false;
        }
    }

    handleStatusParcelas(event){
        this.valueStatusParcela = event.target.value;
        if(this.valueStatusParcela != 'Todos'){
            this.listParcelas = this.listParcelasResponse.filter(item => item.statusCode == this.valueStatusParcela)
        }else{
            this.listParcelas = this.listParcelasResponse
        }
    }

    resetModal(){
        this.valueMotivoSelecionado = '';
        this.canalCasoCancelar = '';
        this.origemCasoCancelar = '';
        this.especificarMotivoText = '';
        this.observacaoCancelar = '';
        this.especificarMotivo = false;
        this.pageTwoCancelar = false;
        this.pageOneCancelar = true;
        this.disableBtnNext = true;
        this.isFluxoBtnContestarMain = false;
    }
    
    formatValor(valor){
        return Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL'
        }).format(valor);
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

    formatDate(date) {
        const data = new Date(date);
        const dia = String(data.getDate()).padStart(2, '0');
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const ano = data.getFullYear();
        return `${dia}/${mes}/${ano}`;
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

    spinnerClose(){
        this.spinner = false;
    }

    spinnerOpen(){
        this.spinner = true;
    }

}