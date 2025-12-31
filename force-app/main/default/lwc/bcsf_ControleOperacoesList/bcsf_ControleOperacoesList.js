import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { IsConsoleNavigation, openTab } from 'lightning/platformWorkspaceApi';
import USER_ID from '@salesforce/user/Id';
import CPF_FIELD from '@salesforce/schema/Account.CPF__c';
import DRT_FIELD from '@salesforce/schema/User.DRT__c';
import consultarOperacoes from '@salesforce/apex/BCSF_ControleOperacoesController.consultarOperacoes';
import listagemLojas from '@salesforce/apex/BCSF_ControleOperacoesController.listagemHierarquias';

export default class BCSF_ControleOperacoesList extends LightningElement {

    @api recordId;
    spinner;
    telaTabela = false;
    disabledBtnResize = false;
    canalAPI = 'cockpit'; 
    cpf;
    drt; 
    dataFinal;
    dataInicial;

    @track opcoesLojas = [];
    @track listaOperacoes = [];

    columnsDefault = [
        { label: 'Dt. operação', fieldName: 'dataOperacao', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'dataOperacao' }},  initialWidth: 150},
        { label: 'Empresa', fieldName: 'empresa', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'empresa' }}, initialWidth: 120},
        { label: 'Loja', fieldName: 'loja', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'loja' }}, initialWidth: 120},
        { label: 'CPF', fieldName: 'cpf', type: 'customTextTooltip',  typeAttributes: {value: { fieldName: 'cpf' }}, initialWidth: 120},
        { label: 'Canal', fieldName: 'canal', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'canal' }}, initialWidth: 120},
        { label: 'Ação', fieldName: 'acao', type: 'customTextTooltip', typeAttributes: {value: { fieldName: 'acao' }}, initialWidth: 300},
        { label: 'Usuário', fieldName: 'usuario', type: 'text', initialWidth: 120},
    ];

    @track columns = [...this.columnsDefault];

    @wire(IsConsoleNavigation) isConsoleNavigation;

    @wire(getRecord, { recordId: '$recordId', fields: [CPF_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.cpf = data.fields.CPF__c.value;
        }else if (error) {
            console.log('Erro ao buscar detalhes da conta: ', error);
        }
    }
    
    @wire(getRecord, { recordId: USER_ID, fields: [DRT_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.drt = data.fields.DRT__c.value;
            this.ordemExecucao();
        }else if (error) {
            console.log('Erro ao buscar detalhes: ', error);
        }
    }
    
    async ordemExecucao(){
        await this.ListagemLojas();
        await this.ConsultarOperacoes();
    }

    ListagemLojas(){
        this.spinnerOpen();
        listagemLojas({
            cpf: this.drt?.replace(/[^a-zA-Z0-9]/g, ''),
            canal: this.canalAPI,
            idEmpresa: ''
        }).then((result) => {
            if (result.statusResponse === 'OK') {
                this.opcoesLojas = result.response.map(item => ({
                    label: !item.codigoSitef && item.descricao === 'AcessoFull'? 'TODAS': item.descricao.toUpperCase(),
                    value: !item.codigoSitef && item.descricao === 'AcessoFull'? 'TODAS': item.codigoSitef,
                }));
                this.spinnerClose();
            } else {
                throw new Error("erro ao listar lojas");
            }
        }).catch((error) => {
            this.showToast('','Falha buscar lista de hierarquias.', 'error', true)
            console.log('Erro ao buscar lista de lojas:', error.message);
        });
    }

    ConsultarOperacoes(){
        this.spinnerOpen();
        let loadBody = this.loadBody();
        consultarOperacoes({
            bodyJson: loadBody,
            cpf: this.cpf?.replace(/\D/g, ''),
            canal: this.canalAPI,
            idEmpresa: ''
        }).then((result) => {
            this.telaTabela = false;
            this.disabledBtnResize = true;
            if (result.statusResponse === 'OK' && result.totalItens > 0 ) {
                this.telaTabela = true;
                this.disabledBtnResize = false;
                this.listaOperacoes = result.data.map(item => ({
                    ...item,
                    dataOperacao: this.formatDate(item.dataOperacao),
                    loja: item.loja ? this.getTextLoja(String(item.loja)) : '',
                    cpf: this.formatarCpf(item.cpf),
                    acao: item.acao || '',
                }));
            }else if(result.statusResponse !== 'OK'){
                throw new Error("erro ao listar operações");
            }
            this.spinnerClose();
        }).catch((error) => {
            this.showToast('','Falha buscar lista de operações.', 'error', true)
            console.log('Erro ao buscar lista de operações:', error.message);
        });
    }

    handleBtnResize(){
        this.columns = [...this.columnsDefault];
    }

    handleBtnRefresh(){
        this.disabledBtnResize = true;
        this.ordemExecucao();
    }

    async handleExibirTudo() {
        if (!this.cpf) return;
        if (!this.isConsoleNavigation) return;
        openTab({
            pageReference: {
                type: 'standard__component',
                attributes: {
                    actionName: 'view',
                    componentName: 'c__bcsf_ControleOperacoes',
                },
                state: {
                    c__cpf: this.cpf,
                    c__dataInicial: this.formatDateAPI(this.dataInicial),
                    c__dataFinal: this.formatDateAPI((this.dataFinal)),
                    c__redirecionado: true,
                }
            },
            focus: true,
            label: 'Controle de Operações'
        }).catch((error) => {
            console.log('Erro openTab: '+ error);
        });
    }

    loadBody(){
        this.dataFinal = new Date();
        this.dataInicial = new Date();
        this.dataInicial.setDate(this.dataFinal.getDate() - 90);
        let dados = {
            dataFinal:  this.formatDateAPI(this.dataFinal.toISOString()), 
            dataInicial:  this.formatDateAPI(this.dataInicial.toISOString()),
            cpf: this.cpf?.replace(/\D/g, ''),
            idTipoEvento:  '',
            idEmpresa: '',
            codigoSitef: '',
            pagina: 1,
            tamanhoPagina: 5
        };

        Object.keys(dados).forEach(key => {
            if (dados[key] === null || dados[key] === '' || dados[key] === undefined) {
                delete dados[key];
            }
        });
        return JSON.stringify(dados);
    }

    getTextLoja(idLoja){
        if(!idLoja || idLoja === '-' ) return '-';

        let loja = this.opcoesLojas.find(item => item.value == idLoja);
        return loja ? loja.label : idLoja;
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
        })?.replace(',', '');
    }

    formatDateAPI(dataString){
        let brasil = new Date(dataString.toLocaleString("en-US", { timeZone: "America/Sao_Paulo" }));
        let ano = brasil.getFullYear();
        let mes = String(brasil.getMonth() + 1).padStart(2, '0');
        let dia = String(brasil.getDate()).padStart(2, '0');
        let hora = String(brasil.getHours()).padStart(2, '0');
        let minuto = String(brasil.getMinutes()).padStart(2, '0');
        let segundo = String(brasil.getSeconds()).padStart(2, '0');

        return `${ano}-${mes}-${dia}T${hora}:${minuto}:${segundo}`;
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
}