import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import getAssetTitular from '@salesforce/apex/AlteracaoCadastralController.getAssetTitular';
import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import CANAL_ATENDIMENTO from '@salesforce/schema/User.CanaldeAtendimento__c';

import getContaFinanceira from '@salesforce/apex/BCSF_CancelamentoContaController.getContaFinanceira';
import createCaseCodigoRastreio from '@salesforce/apex/BCSF_SegundaViaCartaoController.createCaseCodigoRastreio';
import getListRastreioCartao from '@salesforce/apex/BCSF_SegundaViaCartaoController.getListRastreioCartao';
import GetAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';

export default class BCSF_CodigoRastreio extends LightningElement {

    spinner = false;
    optionsCartoes = [];
    listaCodigosRastreio;
    @api recordId;

    @track tempo;
    @track allowListProfiles = [];
    @track userProfileName;
    @track dataLimite;
    @track atendente;

    @track statusCartaoPrimario;
    @track showCardPrincipal = false;
    @track numeroConta = '';
    @track cpf = '';
    @track codigoRastreio = '-';
    @track urlRastreio = '';
    @track dataEmissao = '-';
    @track idEmpresa = null;
    @track accountId = null;
    @track canal = 'cockpit';
    @track areaPrincipal = null;
    @track canalAtendimento = null;
    @track valueCartaoSelecionado = null;
    @track valueNumeroCartao = null;
    @track temCodigoRastreio = true;
    @track RespostaIP = '';
    @track tempo;
    @track dataLimite;
    @track atendente;

    @track statusConta;
    @track ContaCartaoNORM;

    //
    // ---------------------- WIRES ----------------------
    //
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL, CANAL_ATENDIMENTO] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.areaPrincipal = data.fields.AreaPrincipal__c.value;
            this.canalAtendimento = data.fields.CanaldeAtendimento__c.value;
        } else if (error) {
            this.error = error;
        }
    }

   @track tempo;
    @track allowListProfiles = [];
    @track userProfileName;
    @track dataLimite;
    @track atendente;


    //
    // ---------------------- MÉTODOS APEX ----------------------
    //
    async getAssetTitular() {
        try {
            const result = await getAssetTitular({ idContaFinanceira: this.recordId });
            this.statusCartaoPrimario = result.Status;
        } catch (error) {
            console.log('Erro getAssetTitular', error);
        }
    }

    handleContaValidada() {
               console.log('handleContaValidada')
               // const buscarHref = window.location.href;
               // const validado = buscarHref.includes('c__validado=true')
               //     ? true
               //     : buscarHref.includes('c__validado=false')
               //         ? false
               //         : false;
       
               const ContaCartaoNORM = this.statusCartaoPrimario === this.statusConta &&
                   this.statusCartaoPrimario === 'NORM';
               console.group('Opa')
               console.log('cartaoAtivo ' + this.cartaoAtivo)
               console.log('statusCartaoPrimario ' + this.statusCartaoPrimario);
               // console.log('StatusConta ' + this.statusConta);
               // console.log('ContaCartaoNORM ' + ContaCartaoNORM);
               // console.log('validado ' + validado);
               console.groupEnd();
       
       
               if (this.cartaoAtivo) return;
               if (this.allowListProfiles.includes(this.userProfileName)) {
                   switch (ContaCartaoNORM) {
                       case true:
       
                           this.buscarDadosValidacao();
       
                           break;
                       case false:
                           break;
                   }
               }
       
           }
           validarTempoExpirado(dataLimiteStr) {
               if (!dataLimiteStr) {
                   console.warn('⚠️ Data limite não informada.');
                   return;
               }
               const dataLimite = new Date(dataLimiteStr);
               const agora = new Date();
               const diferencaMinutos = (agora.getTime() - dataLimite.getTime()) / (1000 * 60);
       
            //    console.log(`🕒 Diferença em minutos: ${diferencaMinutos.toFixed(2)}`);
       
               if (this.tempo && diferencaMinutos >= this.tempo || this.atendente !== USER_ID) {
                   this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
                   console.log('✅ Dentro do tempo limite. Fechando modal...');
                   this.closeQuickAction();
               } else {
                   console.log('⛔ Fora do tempo limite. Mantendo modal aberto.');
               }
           }
          
           async buscarDadosValidacao() {
               try {
                   const result = await GetAllValidationData({
                       contaFinanceiraId: this.recordId,
                       userId: USER_ID
                   });
       
                   this.tempo = result.tempoLimite;
                   this.allowListProfiles = result.perfisBypass;
                   this.userProfileName = result.perfilUsuario;
                   this.dataLimite = result.dataLimiteDesbloqueio;
                   this.atendente = result.ultimoOperador;
                //    console.group('Dados de Validação:');
                //    console.log('Tempo Limite:', this.tempo);
                //    console.log('Perfis com Bypass:', this.allowListProfiles);
                //    console.log('Perfil do Usuário Atual:', this.userProfileName);
                //    console.log('Data Limite de Desbloqueio:', this.dataLimite);
                //    console.log('Último Operador:', this.atendente);
                //    console.groupEnd();
                   if (this.atendente == undefined || this.dataLimite == undefined) {
                       this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
                       console.log('Fechando modal por falta de dados de validação...');
                       this.dispatchEvent(new CloseActionScreenEvent());
                   }else{
                        this.validarTempoExpirado(this.dataLimite);
                   }
       
               } catch (error) {
                   console.error('❌ Erro ao buscar dados:', error);
               }
           }

    //
    // ---------------------- connectedCallback ----------------------
    //
    async connectedCallback() {

        


        try {
            const result = await getContaFinanceira({ contaFinanceiraId: this.recordId });

            this.cpf = result.CPF;
            this.numeroConta = result.NumeroConta;
            this.idEmpresa = result.UnidadeNegocio;
            this.accountId = result.AccountId;
            this.statusConta = result.StatusConta;

            this.carregarCartoesCodigoRastreio();

        } catch (error) {
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        }


        await this.getAssetTitular();


        this.ContaCartaoNORM =
            this.statusCartaoPrimario === this.statusConta &&
            this.statusCartaoPrimario === 'NORM';

        this.handleContaValidada();
    }

    //
    // ---------------------- RASTREIO ----------------------
    //
    atualizaDadosRastreio() {
        if (this.codigoRastreio == '') {
            this.codigoRastreio = '-';
            this.temCodigoRastreio = false;
        } else {
            this.temCodigoRastreio = true;
        }
    }

    handleCopyCodigoRastreio() {
        const dummyInput = document.createElement('input');
        document.body.appendChild(dummyInput);
        dummyInput.value = this.codigoRastreio;
        dummyInput.select();
        document.execCommand('copy');
        document.body.removeChild(dummyInput);
    }

    handleChangeCartaoSelecionado(event) {
        this.valueNumeroCartao = event.detail.value;
        this.codigoRastreio = '';
        this.urlRastreio = '';
        this.dataEmissao = '';

        this.listaCodigosRastreio.forEach(item => {
            if (item.value == this.valueNumeroCartao) {
                this.codigoRastreio = item.codigoRastreio;
                this.urlRastreio = item.urlRastreio;
                this.dataEmissao = item.dataEmissao;
            }
        });

        this.atualizaDadosRastreio();
    }

    handleAbrirRastreio() {
        this.CriarCaso();
        window.open(this.urlRastreio, '_blank').focus();
    }

    handleButtonVoltar() {
        this.closeQuickAction();
    }

    //
    // ---------------------- SPINNER / TOAST ----------------------
    //
    showSpinner() { this.spinner = true; }
    closeSpinner() { this.spinner = false; }

    showToast(titulo, mensagem, variante, closeModal) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if (closeModal) this.closeQuickAction();
    }

    @api closeParentComponent;
    closeQuickAction() {
        if (this.closeParentComponent) {
            this.dispatchEvent(new CustomEvent('closeparentmodal'));
        } else {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    //
    // ---------------------- LISTA DE CARTÕES ----------------------
    //
    carregarCartoesCodigoRastreio() {
        this.showSpinner();

        getListRastreioCartao({
            canal: this.canal,
            area: this.areaPrincipal,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            idEmpresa: this.idEmpresa
        }).then(result => {

            if (result.StatusAPI == 'OK' && result.postagemResponse.length > 0) {

                let opcoes = [];
                let index = 0;

                result.postagemResponse.forEach(item => {
                    opcoes.push({
                        label: item.nomeTitular + ' - (' + item.dataCriacaoCartao.replaceAll('-', '/') + ')',
                        value: item.numeroCartao,
                        codigoRastreio: item.codigoRastreio,
                        urlRastreio: item.urlRastreio,
                        dataEmissao: item.dataCriacaoCartao.replaceAll('-', '/')
                    });

                    if (index === 0) {
                        this.valueCartaoSelecionado = item.numeroCartao;
                        this.codigoRastreio = item.codigoRastreio;
                        this.urlRastreio = item.urlRastreio;
                        this.dataEmissao = item.dataCriacaoCartao.replaceAll('-', '/');
                        index++;
                    }
                });

                this.optionsCartoes = opcoes;
                this.listaCodigosRastreio = opcoes;
                this.atualizaDadosRastreio();
                this.showCardPrincipal = true;

            } else {
                this.showToast(
                    'Nenhum código de rastreio disponível',
                    'Nenhum cartão foi enviado nos últimos 90 dias.',
                    'warning',
                    true
                );
            }

            this.closeSpinner();

        }).catch(error => {
            this.closeSpinner();
            this.showToast(
                'Erro',
                'Houve um comportamento inesperado no sistema, tente novamente em instantes.',
                'error',
                true
            );
        });
    }

    //
    // ---------------------- CRIAR CASO ----------------------
    //
    CriarCaso() {
        createCaseCodigoRastreio({
            origem: this.areaPrincipal,
            idOperador: USER_ID,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.idEmpresa,
            canal: this.canalAtendimento
        }).catch(error => {
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
        });
    }

}