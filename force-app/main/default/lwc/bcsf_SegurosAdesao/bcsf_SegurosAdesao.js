import { LightningElement, track, api, wire } from 'lwc';
import { createMessageChannel, publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import BCSF_SEGUROS_MC from '@salesforce/messageChannel/BCSF_Seguros__c';
import NAME from '@salesforce/schema/User.Name';
import USER_NAME from '@salesforce/schema/User.Username';
import USER_EMAIL from '@salesforce/schema/User.Email';
import adesaoSeguros from '@salesforce/apex/bcsf_cmp_SegurosController.adesaoSeguros'
import criarCaso from '@salesforce/apex/bcsf_cmp_SegurosController.criarCaso'
import userId from '@salesforce/user/Id';
import USER_UNIDADE from '@salesforce/schema/User.UnidadeDeAtendimento__c';


export default class Bcsf_SegurosAdesao extends LightningElement {
    channel;
    btnMaisIconName = 'utility:add';
    btnMaisLabel = 'Ver mais';
    FIELDS = [USER_NAME, USER_EMAIL];
    
    recordId;
    @api dadosCliente;
    @api seguro;
    @api unidadeAtendimento;
    @api nomeUnidadeAtendimento;

    //var api e case
    userNameLogin;
    userName;
    userEmail;
    caseId;
    @track valueCanal;
    @track valueOrigem;
    @track numProtocolo = "--"
    userUnidadeAtendimento;
    displayValueUnidade;

    //var layout
    @track disableBtnFinalizar = true;
    @track disabledBtnContratar;
    @track disabledFieldNumber = false;
    @track disableAddres = false;
    @track usarEndereco = true;
    @track mostrarAlert = true;
    @track tipoSorte = false;
    @track tipoVida = false;
    @track tipoEndereco = false;
    @track modalContratar = false;
    @track spinner = false;
    
    //Var modal
    @track telaModalOne = true;
    @track telaModalTwo = false;
    @track disableBtnVoltar = false;
    @track currentStep = '1';
    
    // var dados cliente
    accountId;
    dataNascimento;
    sexo;
    nomeMae;
    dddTelefone; 
    telefone;
    email;
    numeroCartao;
    nomePlano;
    @track rua;
    @track numero;
    @track complemento;
    @track bairro;
    @track cidade;
    @track estado;
    @track cep;
    @track cpf;
    @track numeroConta;
    @track unidadeNegocio;
    @track nomeCliente;
    
    //var endereço layout
    @track numeroValue;
    @track complementoValue;
    @track bairroValue;
    @track cidadeValue;
    @track estadoValue;
    @track cepValue;
    @track estadoValue;
    @track cpfValue;
    @track numeroContaValue;
    @track unidadeNegocioValue;
    @track accountIdValue;
    @track possuiNumero
    @track coberturaView = true;
    @track btnVerMais = true;
    @track dataFormatada;
    
    //var fields seguro
    idPlano;
    idSeguro;
    @track nomeSeguro;
    @track nomeSeguroUppercase;
    @track valorSeguro;
    @track valuePlano;
    @track placePlano;
    @track descricaoSeguro;
    @track descricaoValorSeguro;
    @track descricaoSelecaoSeguro;
    @track quantValue = 1;
    @track confirmarEndereco;
    @track planoResumo;

    // Listas
    @track coberturasFixas = [];
    @track coberturas = [];
    optionsPlano = []
    @track optionsQuant = [];
    optionsEstados = [
        { label: 'Acre', value: 'AC' },
        { label: 'Alagoas', value: 'AL' },
        { label: 'Amapá', value: 'AP' },
        { label: 'Amazonas', value: 'AM' },
        { label: 'Bahia', value: 'BA' },
        { label: 'Ceará', value: 'CE' },
        { label: 'Distrito Federal', value: 'DF' },
        { label: 'Espírito Santo', value: 'ES' },
        { label: 'Goiás', value: 'GO' },
        { label: 'Maranhão', value: 'MA' },
        { label: 'Mato Grosso', value: 'MT' },
        { label: 'Mato Grosso do Sul', value: 'MS' },
        { label: 'Minas Gerais', value: 'MG' },
        { label: 'Pará', value: 'PA' },
        { label: 'Paraíba', value: 'PB' },
        { label: 'Paraná', value: 'PR' },
        { label: 'Pernambuco', value: 'PE' },
        { label: 'Piauí', value: 'PI' },
        { label: 'Rio de Janeiro', value: 'RJ' },
        { label: 'Rio Grande do Norte', value: 'RN' },
        { label: 'Rio Grande do Sul', value: 'RS' },
        { label: 'Rondônia', value: 'RO' },
        { label: 'Roraima', value: 'RR' },
        { label: 'Santa Catarina', value: 'SC' },
        { label: 'São Paulo', value: 'SP' },
        { label: 'Sergipe', value: 'SE' },
        { label: 'Tocantins', value: 'TO' }
    ];

   

    @wire(MessageContext)
    messageContext

    @wire(getRecord, { recordId: userId, fields: [USER_NAME, USER_EMAIL, NAME, USER_UNIDADE]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.userNameLogin = data.fields.Username.value;
            this.userName = data.fields.Name.value;
            this.userEmail = data.fields.Email.value;
            this.userUnidadeAtendimento = data.fields.UnidadeDeAtendimento__c.value;
            this.displayValueUnidade = data.fields.UnidadeDeAtendimento__c.displayValue;
            this.handleUnidadeAtendimento();
        } else if (error) {
            this.error = error ;
        }
    }

    connectedCallback(){
        this.carregarDadosCliente();
        this.carregarDadosSeguro();
        this.channel = createMessageChannel(BCSF_SEGUROS_MC);
        this.carregarEndereco();
    }

    AdesaoSeguro(){
        let body = this.carregarBodyAdesao();
        adesaoSeguros({
            idEmpresa: this.unidadeNegocio,
            canal: 'cockpit',
            cpf: this.cpf,
            body: JSON.stringify(body)
        }).then(result=>{
            if(result.statusAPI == "OK"){
                if(result.mensagem == "Ades�o Realizada com Sucesso..."){
                    this.CriarCaso();
                }else{
                    console.log('Seguro existente:', result.mensagem);
                    this.showToast('Erro', 'Cliente da conta não é elegível para o seguro selecionado, pois já existe essa adesão!', 'warning', true);
                }
            }else{
                console.log('Erro adesão seguros');
                this.showToast('Erro', 'Houve um erro ao gerar adesão do seguro!', 'error', true);
            }
        }).catch(error=>{
            console.log('Erro adesão seguros: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao gerar adesão do seguro!', 'error', true);
        });
    }

    CriarCaso(){
        criarCaso({
            contaFinanceiraId: this.recordId, 
            accountId: this.accountId, 
            unidadeNegocio: this.unidadeNegocio,  
            Origem: this.valueOrigem, 
            Canal: this.valueCanal
        }).then(result=>{
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.dataFormatada = this.formatDateTime(new Date());
            this.currentStep = '2';
            this.telaModalOne = false;
            this.telaModalTwo = true;
            this.disableBtnVoltar = true;
            this.SpinnerToggle();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    //#region handle metodos
    handleCheckEnderecocharAlert(){
        this.mostrarAlert = false;
    }

    handleGetScript() {
        const message = {
            messageToSend: this.nomeSeguro
        };
        publish(this.messageContext, BCSF_SEGUROS_MC, message).catch(error=>{
            console.log('Erro getSCript: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar Script!', 'error', true);
        });
    }

    handleBtnVoltar(){
        if(this.telaModalOne){
            this.fecharModal();
            this.currentStep = '1';
        }else if(this.telaModalTwo){
            this.telaModalTwo = false;
            this.telaModalOne = true;
        }
    }

    handleBtnProximo(){
        this.SpinnerToggle();
        this.AdesaoSeguro();
    }
    
    handlerBtnContratar(){
        this.modalContratar = true;
    }

    handleCheckEndereco(event) {
        this.usarEndereco = event.target.checked;
        if (this.usarEndereco || !this.confirmarEndereco) {
            this.disableAddres = true;
            this.disabledFieldNumber = true;
            this.ruaValue = this.rua;
            this.numeroValue = this.numero;
            this.complementoValue = this.complemento;
            this.bairroValue = this.bairro;
            this.cidadeValue = this.cidade;
            this.estadoValue = this.estado;
            this.cepValue = this.cep;
            this.cpfValue = this.cpf;
            this.numeroContaValue = this.numeroConta;
            this.unidadeNegocioValue = this.unidadeNegocio;
            this.accountIdValue = this.accountId;
        } else {
            this.disableAddres = false;
            this.disabledFieldNumber = false;
            this.ruaValue = '';
            this.numeroValue = '';
            this.complementoValue = '';
            this.bairroValue = '';
            this.cidadeValue = '';
            this.estadoValue = '';
            this.cepValue = '';
            this.cpfValue = '';
            this.numeroContaValue = '';
            this.unidadeNegocioValue = '';
            this.accountIdValue = '';
        }
        this.checarValoresVar();
    }

    handlePicklistUF(event){
        this.estadoValue = event.detail.value;
        this.checarValoresVar();
    }

    handleFieldPlano(event){
        this.valorSeguro = event.detail.value;
        this.descricaoValorSeguro = this.descricaoValorSeguro.replace(this.valorSeguro, event.detail.value);
        this.coberturasFixas = this.optionsPlano.find(option => option.value == this.valorSeguro).cobertura;
        this.idPlano = this.optionsPlano.find(option => option.value == this.valorSeguro).idPlano;
        this.coberturas = this.coberturasFixas.slice(0, 2).map(produto => {return produto;});
        this.btnMaisIconName = 'utility:add';
        this.btnMaisLabel = 'Ver mais';
        this.planoResumo = this.optionsPlano.find(option => option.value == this.valorSeguro).label.split('-')[0];
    }

    handleChangeOrigem(event){
        this.valueOrigem = event.detail.value;
        this.checarValoresCase();
    }

    handleChangeCanal(event){
        this.valueCanal = event.detail.value;
        this.checarValoresCase();
    }

    handlePicklistQuant(event) {
        this.quantValue = event.detail.value;
        let valorFixo = this.valorParcela.replace('R$ ', '').replace(',', '.'); 
        let resultado = valorFixo * parseInt(this.quantValue); 
        this.valorSeguro = ' R$ ' + resultado.toFixed(2).replace('.', ','); 
    }

    handleCEPChange(event) {
        this.cepValue = event.target.value;
        this.checarValoresVar();
    }

    handleRuaChange(event) {
        this.ruaValue = event.target.value;
        this.checarValoresVar();
    }

    handleNumeroChange(event) {
        this.numeroValue = event.target.value;
        this.checarValoresVar();
    }

    handleComplementoChange(event) {
        this.complementoValue = event.target.value;
        this.checarValoresVar();
    }

    handleBairroChange(event) {
        this.bairroValue = event.target.value;
        this.checarValoresVar();
    }

    handleCidadeChange(event) {
        this.cidadeValue = event.target.value;
        this.checarValoresVar();
    }

    handleCheckNumero(event) {
        this.possuiNumero = event.target.checked;
        this.disabledFieldNumber = this.possuiNumero;
        this.numeroValue = '';
        this.checarValoresVar();
    }
    handleViewCobertura(){
        if (this.btnMaisIconName == 'utility:add') {
            this.coberturas = this.coberturasFixas;
            this.btnMaisIconName = 'utility:dash';
            this.btnMaisLabel = 'Menos';
        } else {
            this.coberturas = this.coberturasFixas.slice(0, 2).map(produto => {return produto;});
            this.btnMaisIconName = 'utility:add';
            this.btnMaisLabel = 'Ver mais';
        }
    }

    handleUnidadeAtendimento() {
        if(this.userUnidadeAtendimento){
            this.unidadeAtendimento = this.userUnidadeAtendimento;
            this.nomeUnidadeAtendimento = this.displayValueUnidade;
            this.checarValoresVar();
        }else{
            this.showToast('Erro', 'Usuário sem unidade de atendimento cadastrada.', 'error', false);
        }   
    }
    //#endregion

    carregarBodyAdesao(){
        let dataAtual = new Date();
        let body = {
            "adesao":{
            "idAdesao":0,
            "data": dataAtual.toISOString(),
            "respostas":[
                
            ],
            "dadosMeioPagamento":{
                "idMeioPagamento":9,
                "tipo":"Cartao"
            },
            "dadosVenda":{
                "assinaturaDigital":"Nao",
                "codCanalVenda": this.unidadeAtendimento,
                "codLoja": this.unidadeAtendimento,
                "codVendedor": this.userNameLogin,
                "email": this.userEmail,
                "nomeLoja": this.nomeUnidadeAtendimento, 
                "nomeVendedor": this.userName,
                "tipoEnvio":2,
                "tipoVenda":1
            },
            "dadosCliente":{
                "cpf": this.cpf,
                "codProfissaoPR":"",
                "dddCelular": this.dddTelefone, 
                "dddComercial": this.dddTelefone, 
                "dddResidencial": this.dddTelefone, 
                "dataExpedicaoRG": this.formatDate(this.dadosCliente.dataNascimento),
                "dataNascimento": this.formatDate(this.dadosCliente.dataNascimento),
                "descProfissao":"",
                "email": this.email,
                "estadoCivil":0,
                "estadoCivilDesc":"",
                "naturalidade":"Brasileiro",
                "nome": this.nomeCliente,
                "nomeMae": this.nomeMae,
                "sexo": this.sexo, 
                "telefoneCelular": this.telefone,
                "telefoneComercial": this.telefone,
                "telefoneResidencial": this.telefone,
            },
            "dadosCartao":{
                "bandeira":"",
                "dataValidade":"",
                "diaFechamentoFatura":1,
                "diaVencimentoFatura":1,
                "nomeCartao": this.nomeCliente,
                "numeroCartao":"",
                "numeroConta": this.numeroConta
            },
            "enderecoCliente":{
                "bairro": this.bairro,
                "cep": this.cep.replace(/\D/g, ''),
                "cidade": this.cidade,
                "complemento":this.complemento,
                "endereco": this.rua,
                "numero": this.numero.toString(),
                "siglaEstado": this.estado,
                "tipoEndereco":0,
                "flagRisco": "N"
            },
            "enderecoCobranca":{
                "bairro": this.bairro,
                "cep": this.cep.replace(/\D/g, ''),
                "cidade": this.cidade,
                "complemento":this.complemento,
                "endereco": this.rua,
                "numero": this.numero.toString(),
                "siglaEstado": this.estado,
                "tipoEndereco":1,
                "flagRisco": "N"
            },
            "dadosPlano":{
                "idPlano":parseInt(this.idPlano),
                "emitirCertificadoAutomaticamente":"N",
                "nomePlano": this.nomePlano
            },
            "dadosProduto":{
                "codProdutoPR":0,
                "idProduto": parseInt(this.idSeguro),
                "nomeProduto": this.nomeSeguro,
                "imprimeCerfificadoAposAdesao":true,
                "qtdMaximaContratosVendaNova": this.quantValue
            },
            "traceAdesao":{
                "operacao":1,
                "regiao":"Brasil",
                "cpf": this.cpf,
                "email": this.email,
                "ip":"",
                "url":"",
                "token":"",
                "sessao":"",
                "idSistema":2,
                "idFluxo":6,
                "nomeDoBrowser":"",
                "versaoDoBrowser":"",
                "canal": this.unidadeAtendimento,
                "idPlano":parseInt(this.idPlano),
                "eventos":[
                
                ]
            }
            }
        };
        if(this.tipoEndereco){
            body.adesao.enderecoRisco = {
                        "bairro": this.bairroValue,
                        "cep": this.cepValue.replace(/\D/g, ''),
                        "cidade": this.cidadeValue,
                        "complemento":this.complementoValue,
                        "endereco": this.ruaValue,
                        "numero": this.numeroValue.toString(),
                        "siglaEstado": this.estadoValue,
                        "tipoEndereco":3,
                        "flagRisco":"S"
                    }
        };

        return body;
    }

    async carregarDadosCliente(){
        this.recordId = this.dadosCliente.idContafinanceira;
        this.rua = this.dadosCliente.rua;
        this.numero = this.dadosCliente.numero;
        this.complemento = this.dadosCliente.complemento;
        this.bairro = this.dadosCliente.bairro;
        this.cidade = this.dadosCliente.cidade;
        this.estado = this.dadosCliente.estado;
        this.cep = this.dadosCliente.cep;
        this.cpf = this.dadosCliente.cpf;
        this.numeroConta = this.dadosCliente.numeroConta;
        this.unidadeNegocio = this.dadosCliente.unidadeNegocio;
        this.accountId = this.dadosCliente.accountId;
        this.nomeCliente = this.dadosCliente.nomeCliente;
        this.numeroCartao = this.dadosCliente.cartao;
        this.sexo = this.dadosCliente.sexo;
        this.nomeMae = this.dadosCliente.nomeMae;
        this.dataNascimento = this.dadosCliente.dataNascimento;
        this.email = this.dadosCliente.email;
        await this.formatTelefone(this.dadosCliente.telefone);
    }

    carregarDadosSeguro(){
        this.idSeguro = this.seguro.codigoProduto;
        this.nomeSeguro = this.seguro.nomeProduto;
        this.nomeSeguroUppercase = this.nomeSeguro.toUpperCase();
        this.descricaoSeguro = this.seguro.apresentacao?.descricao ?? '';
        this.descricaoSelecaoSeguro = this.seguro.apresentacao?.descricaoSelecaoPlano ?? '';
        this.descricaoValorSeguro = this.seguro.apresentacao?.descricaoValor ?? '';
    
        this.idPlano = this.seguro?.coberturasPlano?.[0]?.idPlano ?? null;
        this.nomePlano = this.seguro?.coberturasPlano?.[0]?.nomePlano ?? '';
        this.coberturasFixas = this.seguro?.coberturasPlano?.[0]?.cobertura ?? [];
        this.coberturas = this.coberturasFixas.slice(0, 2).map(produto => { return produto; });
        this.btnVerMais = this.coberturasFixas.length > 2;
    
        this.confirmarEndereco = this.seguro.configuracao?.confirmaEndereco ?? false;
    
        let tipoSeguro = this.seguro.configuracao?.consultaCardEspecial;
    
        if(tipoSeguro == 'qtdNumerosSorte'){
            this.tipoSorte = true;
            let number = this.seguro.quantidadePermitida ?? 0;
            for(let i = 1; i <= number; i++) {
                this.optionsQuant.push({ label: i.toString(), value: i.toString() });
            }
        }else if(tipoSeguro == 'nenhum'){
            this.tipoVida = true;
        }else if(tipoSeguro == 'endereco'){
            if(this.confirmarEndereco){
                this.disabledBtnContratar = true;
                this.tipoEndereco = true;
            }
        }
    
        let opcoes = [];
        (this.seguro?.coberturasPlano ?? []).forEach(item =>{
            opcoes.push({
                label: item.nomePlano + ' - ' + item.valorParcela + ' / mês', 
                value: item.valorParcela,
                cobertura: item.cobertura,
                idPlano: item.idPlano
            });
        });
    
        this.optionsPlano = opcoes;
    
        this.placePlano = this.optionsPlano?.[0]?.label ?? '';
        this.valorSeguro = this.optionsPlano?.[0]?.value ?? null;
        this.valorParcela = this.optionsPlano?.[0]?.value ?? null;
    
        this.descricaoValorSeguro =
            this.descricaoValorSeguro.replace('%VALOR%', this.valorSeguro ?? '');
    
        this.tipoVida = (this.seguro?.coberturasPlano?.length ?? 0) > 1;
        this.planoResumo = this.optionsPlano?.[0]?.label?.split('-')?.[0] ?? '';
    }
    

    carregarEndereco(){
        this.disableAddres = true;
        this.disabledFieldNumber = true;
        this.ruaValue = this.rua;
        this.numeroValue = this.numero;
        this.complementoValue = this.complemento;
        this.bairroValue = this.bairro;
        this.cidadeValue = this.cidade;
        this.estadoValue = this.estado;
        this.cepValue = this.cep;
        this.cpfValue = this.cpf;
        this.numeroContaValue = this.numeroConta;
        this.unidadeNegocioValue = this.unidadeNegocio;
        this.accountIdValue = this.accountId;
        this.checarValoresVar();
    }

    checarValoresVar() {
        if (!this.cepValue ||
            !this.ruaValue ||
            (!this.numeroValue && !this.possuiNumero) ||
            !this.bairroValue ||
            !this.cidadeValue ||
            !this.estadoValue ||
            !this.unidadeAtendimento) {
            this.disabledBtnContratar = true;
        } else {
            this.disabledBtnContratar = false;
        }
    }

    checarValoresCase(){
        if(this.valueCanal && this.valueOrigem){
            this.disableBtnFinalizar = false;
        }else{
            this.disableBtnFinalizar = true;
        }
    }

    formatDateTime(date) {
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0'); 
        const year = date.getFullYear();
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');

        return `${day}/${month}/${year} - ${hours}:${minutes}`;
    }

    formatDate(dateString) {
        const [yearOriginalDate, monthOriginalDate, dayOriginalDate] = dateString.split('-');

        const date = new Date(dateString);
        //const day = String(date.getDate()).padStart(2, '0');
        const day = String(dayOriginalDate).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        
        return `${day}/${month}/${year}`;
    }

    formatTelefone(numeroContato){
        let cleaned = ('' + numeroContato).replace(/\D/g, '');
        let numeroFormatado = cleaned.match(/^(?:(\d{2,3})(\d{2})(\d{8,9}))|(?:(\d{2})(\d{8,9}))|(\d{8,9})$/);
        if (numeroFormatado) {
            if (numeroFormatado[1]) {
                // Caso DDI, DDD e número de telefone
                this.dddTelefone = numeroFormatado[2];
                this.telefone = numeroFormatado[3];
            } else if (numeroFormatado[4]) {
                // Caso DDD e número de telefone
                this.dddTelefone = numeroFormatado[4];
                this.telefone = numeroFormatado[5];
            } else {
                // Caso somente número de telefone
                this.dddTelefone = " ";
                this.telefone = numeroFormatado[6];
            }
        }
    }

    fecharModal() {
        this.telaModalOne = true;
        this.telaModalTwo = false;
        this.disableBtnVoltar = false;
        this.currentStep = '1';
        this.modalContratar = false;
    }

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
            this.spinner = false;
            this.modalContratar = false;
        }
    }

    irCase(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
    }

}