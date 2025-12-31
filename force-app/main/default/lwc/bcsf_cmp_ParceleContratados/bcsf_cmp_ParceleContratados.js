/* eslint-disable eqeqeq */
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import criarCaso from '@salesforce/apex/BCSF_cmp_ParceleSimularController.criarCaso'
import listarContratados from '@salesforce/apex/BCSF_cmp_ParceleSimularController.listarParceleContratados'
import enviarEmail from '@salesforce/apex/BCSF_cmp_ParceleSimularController.enviarEmail'
import loadAccount from '@salesforce/apex/BCSF_cmp_ParceleSimularController.getContaFinanceira'
import ImgErrorOff from '@salesforce/resourceUrl/ImgErrorOff';

export default class Bcsf_cmp_ParceleContratados extends LightningElement {

    imgEmpty = ImgErrorOff;
    @api recordId;
    @track parceleId;
    @track spinner;
    @track pageOne = true;
    @track pageTwo = false;
    @track footerView = true;
    @track canalCaso = 'Voz';
    @track origemCaso = 'Pós venda';
    @track checkEmailAlternativo;
    @track email;
    @track emailAlternativo;
    @track canalApi = 'cockpit';
    @track disableBtnContinuar = true;
    @track numProtocolo;
    @track parceleFacilId;
    @track caseId;
    @track dataAtual;
    @track alertBloqueio;
    @track alertMessageBloqueio;
    
    
    listContratos = [];

    connectedCallback(){
        this.spinnerOpen();
        this.LoadAccount();
    }

    LoadAccount(){
        loadAccount({
            contaFinanceiraId: this.recordId
        }).then(result => {
            this.cpf = result.CPF.replace(/\D/g, '');
            this.numeroConta = result.NumeroConta;
            this.unidadeNegocio = result.UnidadeNegocio;
            this.accountId = result.AccountId;
            this.email = result.Email;
            if(this.email == '--'){
                this.disableCheckEmailAlternativo = true;
                this.checkEmailAlternativo = true;
            }
            this.ListarContratados();
        }).catch(error =>{
            console.log('Error LoadAccount: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações! da Conta', 'error', true);
        })
    }

    ListarContratados(){
        this.spinnerOpen();
        listarContratados({
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            let codigo = -1;
            if(result.statusAPI == 'OK' && result.parceles.length != 0){
                this.alertBloqueio = result.parcelesComBloqueio == 0 ? false : true;
                this.alertMessageBloqueio = result.parcelesComBloqueio >= 2 ? `Existem ${result.parcelesComBloqueio} parcelamentos com bloqueio sinalizados na tabela.` : `Existe ${result.parcelesComBloqueio} parcelamento com bloqueio sinalizado na tabela.` ;
                this.listContratos = result.parceles.map(item => {
                    codigo++;
                    let dateFormat = item.dataCriacao.split('T')[0] + 'T00:00:00';
                    return { 
                        id: codigo, 
                        dataCriacao: this.formatDate(dateFormat),
                        valorParcela: 'R$ ' + this.formatCurrency(item.valorParcela, false), 
                        parcelaTotal: item.numeroTotalParcelas, 
                        parcelaPagas: item.numeroParcelasPagas, 
                        desbloqueio: item.numeroParcelasParaLiberacaoLimite > 0 ?  item.numeroParcelasParaLiberacaoLimite : '-', 
                        style: item.numeroParcelasParaLiberacaoLimite > 0 ?  'desbloqueioCell columnDefault' : 'columnDefault', 
                        disable: item.parceleFacilId ?  false : true, 
                        parceleId: item.parceleFacilId, 
                        parcelaVencer: item.numeroParcelasRestantes};
                });
            }else{
                this.pageEmpty = true;
                this.footerView = false;
                this.pageOne = false;
            }
            this.spinnerClose();
        }).catch(error =>{
            console.log('Error GetParceleContratados: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao buscar parcelamentos contratdos!', 'error', true);
        })
    }

    EnviarEmail(email, nextPage = false){
        this.spinnerOpen();
        enviarEmail({
            parceleId: this.parceleFacilId, 
            email: email, 
            tipoPagamento: 'default',
            numeroConta: this.numeroConta, 
            cpf: this.cpf, 
            canal: this.canalApi, 
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if(result.statusAPI == 'OK'){
                if(nextPage){
                    this.CriarCaso();
                }else{
                    this.showToast('', 'Email Enviado com sucesso!', 'success', true);
                }
            }else{
                this.showToast('Erro', 'Houve um erro ao enviar e-mail!', 'error', true);
            }
        }).catch(error =>{
            console.log('Error EnviarEmail: '+ error.message);
            this.showToast('Erro', 'Houve um erro enviar email!', 'error', true);
        })
    }

    CriarCaso(){
        criarCaso({
            casoType: 'contratados',
            contaFinanceiraId: this.recordId, 
            accountId: this.accountId, 
            unidadeNegocio: this.unidadeNegocio,  
            Origem: 'Pós Vendas', 
            Canal: 'Voz'
        }).then(result=>{
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.dataAtual = this.formatDate(Date.now()); 
            this.pageTwo = true;
            this.pageOne = false;
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    handleBtnContinuar(){
        if(this.pageOne){
            this.EnviarEmail(this.email, true);
        }else{
            window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
        }
    }

    handleBtnVoltar(){
        this.ListarContratados();
        this.pageTwo = false;
        this.pageOne = true;
    }

    handleCheckEmailAlternativo(event) {
        this.checkEmailAlternativo = event.target.checked;
    }

    handleFieldEmailAlternativo(event){
        this.emailAlternativo = event.target.value;
    }

    handleBtnEnviarEmail(){
        let email
        if(this.checkEmailAlternativo){
            email = this.emailAlternativo;
        }else{
            email = this.email;
        }

        if((this.checkEmailAlternativo && this.emailAlternativo) || (!this.checkEmailAlternativo && this.email)){
            this.EnviarEmail(email);
        }else{
            this.showToast('Erro', 'Informe um e-mail válido', 'error', true);
        }
    }

    handleRadioParcelamento(event){
        this.parceleFacilId = event.target.getAttribute('data-value');
        this.disableBtnContinuar = false;
    }

    formatCurrency(value, inverter = true) {
        if(inverter)
            value = -value;
        return value.toFixed(2).replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }

    formatDate(date, addDia = false) {
        if (!date) return '';
        const dt = new Date(date);
        const day = addDia ? String(dt.getDate()+1).padStart(2, '0') : String(dt.getDate()).padStart(2, '0');
        const month = String(dt.getMonth() + 1).padStart(2, '0');
        const year = dt.getFullYear();
        return `${day}/${month}/${year}`;
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
        }
    }

    spinnerOpen(){
        this.spinner = true;
    }

    spinnerClose(){
        this.spinner = false;
    }
}