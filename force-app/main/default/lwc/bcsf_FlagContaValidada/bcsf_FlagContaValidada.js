import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';
import USER_ID from '@salesforce/user/Id';

export default class Bcsf_FlagContaValidada extends LightningElement {

    @api recordId;
    @track contaValidada;
    @track isNull;
    @track tempo;
    @track allowListProfiles = [];
    @track userProfileName;
    @track dataLimite;
    @track atendente;
    connectedCallback() {
        this.buscarDadosValidacao();
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
            console.log('Opa')
            if (this.atendente == undefined || this.dataLimite == undefined) {
                console.log('Atendente ou Data Limite indefinidos');
                this.isNull = null
            } else {
                this.validarTempoExpirado(this.dataLimite);

            }

        } catch (error) {
            console.error('❌ Erro ao buscar dados:', error);
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

        // console.log(`🕒 Diferença em minutos: ${diferencaMinutos.toFixed(2)}`);
        console.log('Atendente: ' + this.atendente);
        console.log('Tempo Limite (minutos): ' + this.tempo);
        console.log('diferencaMinutos: ' + diferencaMinutos);
        console.log('Tempo: ' + this.tempo);


        if (this.tempo && diferencaMinutos <= this.tempo && this.atendente == USER_ID) {
            this.isNull = false;
            this.contaValidada = true;
            console.log('conta dentro do intervalode tempo ' + this.isNull);
            return;
        } else {
            this.isNull = false;
            this.contaValidada = false;
            this.showToast('', 'Por favor, NÃO realize alterações cadastrais , desbloqueios  ou Consultas ao código de rastreio neste atendimento.', 'warning', true);
            return;
        }

    }
    showToast(titulo, mensagem, variante) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}