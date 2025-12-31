import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAccount from '@salesforce/apex/bcsf_cmp_SegurosController.getAccount'
import getContaFinanceira from '@salesforce/apex/BCSF_ReimpressaoSenhaController.getContaFinanceira';
import getSeguros from '@salesforce/apex/bcsf_cmp_SegurosController.getSeguros'
import getSegurosContratados from '@salesforce/apex/bcsf_cmp_SegurosController.getSegurosContratados'


export default class Bcsf_cmp_seguros extends LightningElement {

    
    @api recordId;

    //var layout e informações api
    @track listViewRecomendados = false;
    @track listViewOutros = false;
    @track spinner = false;
    @track canalAPI = 'cockpit';
    @track valueStatusContratados;
    @track buscaContratados = '';
    @track loadTab = false
    @track showCmpContestar = false;
    
    // Var de dados cliente
    @track cep;
    @track cpf;
    @track rua;
    @track numero;
    @track complemento;
    @track bairro;
    @track estado;
    @track cidade;
    @track unidadeAtendimento;
    @track nomeUnidadeAtendimento;

    //Lista de dados
    @track dadosCliente = {};
    @track seguros = [];
    @track segurosFiltrados = [];
    @track segurosContratados = [];
    @track segurosContratadosFiltrados = [];
    @track segurosOutros = [];
    @track segurosOutrosFiltrados = [];
    @track segurosContratadosResponse;
    @track segurosContestar;

    optionsStatusContratados = [
        { label: '--Nenhum', value: '' },
        { label: 'Ativo', value: 'Ativo' },
        { label: 'Expirado', value: 'Expirado' },
        { label: 'Cancelado', value: 'Cancelado' }
        ];
    
    listMotivosContestacao = ['alega não ter aderido', 'produto vendido com informações divergentes']
    /*optionsUnidade = [
        { label: 'Atendimento Tamboré', value: '3333333301' },
        { label: 'Atendimento Nivel II', value: '9999999915' },
        { label: 'Pós Venda Atacadão', value: '3333333307' },
        { label: 'Atendimento SAC Services', value: '3333333320' },
        { label: 'Retenção Atendimento Services', value: '3333333323' },
        { label: 'Atendimento Chat DVA', value: '3333333332' },
        { label: 'Atendimento Chat Sams', value: '3333333347' },
        { label: 'Atendimento Services', value: '9999999911' }
        ];*/

    connectedCallback(){
        this.SpinnerToggle();
        this.GetContaFinanceira();
    }
    
    GetContaFinanceira(){
        getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then( result => {
            try {
                this.dadosCliente = {
                    rua: result.Rua,
                    numero: result.Numero,
                    complemento: result.Complemento,
                    bairro: result.Bairro,
                    cidade: result.Cidade,
                    estado: result.Estado,
                    cpf: result.CPF.replace(/\D/g, ''),
                    cep: result.CEP,
                    numeroConta: result.NumeroConta,
                    idContafinanceira: this.recordId,
                    unidadeNegocio: result.UnidadeNegocio,
                    accountId: result.AccountId,
                    email: result.Email,
                    telefone: result.Telefone
                };
                this.GetAccount();
            } catch (error) {
                console.log('Erro catch() getContaFinanceira: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getContaFinanceira: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }

    GetAccount(){
        getAccount({
            accountId: this.dadosCliente.accountId
        }).then(result => {
            try {
                this.dadosCliente.sexo = result.Sexo__c;
                this.dadosCliente.dataNascimento = result.DataNascimento__c;
                this.dadosCliente.nomeMae = result.NomeMae__c;
                this.loadTab = true;
                this.GetSegurosContratados();
            } catch (error) {
                console.log('Erro catch() getAccount: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getAccount: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta!', 'error', true);
        });
    }

    GetSegurosContratados(){
        getSegurosContratados({
            idEmpresa: this.dadosCliente.unidadeNegocio, 
            cpf: this.dadosCliente.cpf,
            canal: this.canalAPI 
        }).then( result => {
            try {
                this.segurosContratadosResponse = result;
                if(result.statusResponse == 'OK'){
                    this.segurosContratados = result.adesoes.map(produto => {
                        produto.ativo = produto.status === 'Ativo';
                        produto.key = produto.idAdesaoProseg || produto.idAdesaoPdr;
                        return produto;});
                    this.segurosContratadosFiltrados = [...this.segurosContratados];
                    this.ordenarAdesoes();
                    this.SpinnerToggle();
                }else{
                    throw new Error("status error");
                }
            } catch (error) {
                console.log('Erro getSegurosContratados: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getSegurosContratados: '+ error);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre os Seguros contratados!', 'error', true);
        });
    }

    GetSeguros(){
        let produtos = [];
        getSeguros({
            idEmpresa: this.dadosCliente.unidadeNegocio, 
            canal: this.canalAPI, 
            cpf: this.dadosCliente.cpf, 
            numeroConta: this.dadosCliente.numeroConta, 
            listIdDeProdutos: produtos
        }).then( result => {
            try {
                this.dadosCliente.nomeCliente = result.nome;
                this.dadosCliente.cartao = result.cartao;
                this.seguros = result.produtos.slice(0, 3).map(produto => {return produto;});
                this.segurosFiltrados = [...this.seguros];

                this.segurosOutros = result.produtos.slice(3).map(produto => {return produto;});
                this.segurosOutrosFiltrados = [...this.segurosOutros];

                this.listViewRecomendados = true;
                this.listViewOutros = this.segurosOutros.length > 0 ? true : false;
                this.SpinnerToggle();
            } catch (error) {
                console.log('Erro catch() getSeguros: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getSeguros: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre os Seguros!', 'error', true);
        });
    }
    
    GetSegurosContestar(){
        getSegurosContratados({
            idEmpresa: this.dadosCliente.unidadeNegocio, 
            cpf: this.dadosCliente.cpf,
            canal: this.canalAPI 
        }).then( result => {
            try {
                this.segurosContratadosResponse = result;
                if(result.statusResponse == 'OK'){
                    this.loadSegurosContestado(result);
                    this.spinner = false;
                }else{
                    throw new Error("status error");
                }
            } catch (error) {
                console.log('Erro getSegurosContestados: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getSegurosContestados: '+ error);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre os Seguros contestados!', 'error', true);
        });
    }

    handleBuscaChange(event) {
        const busca = event.target.value.toLowerCase();
        this.seguros = this.segurosFiltrados.filter(seguro =>
            seguro.nomeProduto.toLowerCase().includes(busca)
        );

        this.segurosOutros = this.segurosOutrosFiltrados.filter(seguro =>
            seguro.nomeProduto.toLowerCase().includes(busca)
        );
    }

    handleBuscaContratadosChange(event) {
        this.buscaContratados = event.target.value.toLowerCase();
        if (this.valueStatusContratados) {
            this.segurosContratados = this.segurosContratadosFiltrados.filter(seguro =>
                seguro.nomeProduto.toLowerCase().includes(this.buscaContratados) && seguro.status == this.valueStatusContratados);
        } else {
            this.segurosContratados = this.segurosContratadosFiltrados.filter(seguro =>
                seguro.nomeProduto.toLowerCase().includes(this.buscaContratados));
        }
        this.ordenarAdesoes();
    }

    handleStatuCancelamento(event) {
        this.valueStatusContratados = event.target.value;

        if (this.buscaContratados && this.valueStatusContratados) {
            this.segurosContratados = this.segurosContratadosFiltrados.filter(seguro =>
                seguro.nomeProduto.toLowerCase().includes(this.buscaContratados) && seguro.status == this.valueStatusContratados);
        } else if(!this.valueStatusContratados) {
            this.segurosContratados = this.segurosContratadosFiltrados.filter(seguro =>
                seguro.nomeProduto.toLowerCase().includes(this.buscaContratados));
        }else{
            this.segurosContratados = this.segurosContratadosFiltrados.filter(seguro =>
                seguro.status == this.valueStatusContratados);
        }
        this.ordenarAdesoes();
    }

    handleActive(event) {
        const tabSelected = event.target.value;
        if(this.loadTab){
            this.SpinnerToggle()
            if(tabSelected === 'contratados'){
                this.GetSegurosContratados();
            }
            if(tabSelected === 'disponivel'){
                this.GetSeguros();
            }
            if(tabSelected === 'contestar'){
                this.GetSegurosContestar();
            }
        }
    }

    loadSegurosContestado(result){
        const hoje = new Date();
        const cancelados = result.adesoes.filter(item => item.status === "Cancelado");
        const motivosValidos = cancelados.filter(item => (this.listMotivosContestacao.includes(item.motivoCancelamento.toLowerCase().trim())));
        const dentroDoPeriodo = motivosValidos.filter(item => {
            const dataItem = new Date(item.dataCancelamento);
            const dataLimite = new Date(dataItem);
            dataLimite.setFullYear(dataLimite.getFullYear() + 5);
            return hoje < dataLimite;
        });

        this.segurosContestar = dentroDoPeriodo;
        this.showCmpContestar = this.segurosContestar.length > 0;
        if(!this.showCmpContestar){
            this.showToast('', 'Nenhum seguro foi encontrado para contestar, tente novamente mais tarde!', 'warning', true);
        }
    }

    /*handleUnidadeAtendimento(event) {
        this.unidadeAtendimento = event.target.value;
        this.nomeUnidadeAtendimento = this.optionsUnidade.find(option => option.value == this.unidadeAtendimento).label;
        let cmpChilds = this.template.querySelectorAll('c-bcsf_-seguros-adesao')
        for(let child of cmpChilds){
            child.handleUnidadeAtendimento( {idUnidade: this.unidadeAtendimento, nomeUnidade: this.nomeUnidadeAtendimento});
        }
    }*/

    SpinnerToggle(){
        this.spinner = !this.spinner;
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
            this.SpinnerToggle();
            this.listViewRecomendados = false;
        }
    }

    ordenarAdesoes() {
        const ordenarPorDataFinal = (lista) => {
            return lista.sort((a, b) => new Date(b.dataFimVigencia) - new Date(a.dataFimVigencia));
        };

        const ordenarPorDataIncio = (lista) => {
            return lista.sort((a, b) => new Date(b.dataInicioVigencia) - new Date(a.dataInicioVigencia));
        };

        const ativos = ordenarPorDataIncio(this.segurosContratados.filter((item) => item.status === 'Ativo'));
        const expirados = ordenarPorDataFinal(this.segurosContratados.filter((item) => item.status === 'Expirado'));
        const cancelados = ordenarPorDataFinal(this.segurosContratados.filter((item) => item.status === 'Cancelado'));

        this.segurosContratados = [...ativos, ...expirados, ...cancelados];
    }
}