import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import calloutDetalhesFatura from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.buscarDetalhesFatura';
import calloutDetalhesFaturaAberta from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.buscarDetalhesFaturaAberta';
import abriFatura from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.downloadFatura';
import getFaturasId from '@salesforce/apex/BCSF_CLS_CalloutFaturasController.getListaFaturas';
import obterResumoFaturaMes from '@salesforce/apex/ResumoFaturaController.obterResumoFaturaMes';

export default class Bcsf_cmp_detalhes_faturaV2 extends LightningElement {

    @api fatura;
    @api columns;
    @api cliente_infos;
    @api is_fatura_aberta;

    @track spinner = false;
    @track section = [];
    @track botao_limpar_bloq = true;
    @track linhas_selecionadas_bu = [];
    @track setSelectedRows = [];
    @track detalhes;
    @track pagamentoEfetuado = {};

    @track isTipoFaturaCarregado = false;
    @track tipoFaturaClass;
    @track tipoFatura;

    @track reasonCode_selecionaveis = ['nrev', 'pint', 'olmt', 'mntf', 'isop', 'carv', 'care','aior','bior','mora','mult'];

    get sectionLabel(){
        return this.is_fatura_aberta ? 'Fatura Aberta' : this.fatura.dados.mesRef;
    }

    get valorFatura(){
        return this.fatura.dados.valorFatura.valor;
    }

    connectedCallback(){
        if(this.is_fatura_aberta) {
            this.fetchDetalhesFaturaAberta();
            this.tipoFaturaClass = 'tagTipoFatura tipoFatura_0';
            this.tipoFatura = 'Aberta';
            this.isTipoFaturaCarregado = true;
        }
    }

    handleSectionToggle(event) {
        console.debug(event.detail.openSections);
        this.section = event.detail.openSections;
        if(!this.is_fatura_aberta && !this.isTipoFaturaCarregado){
            this.obterResumoFaturaMes(this.fatura.dados.mesAno);
            console.log('Mes Ano :', this.fatura.dados.mesAno);
        }
    }

    @api
    limparSelecao(){
        this.setSelectedRows = [];
        this.botao_limpar_bloq = true;

        this.sendEvent_attLinhasResumo([], this.linhas_selecionadas_bu);
        this.linhas_selecionadas_bu = [];
    }

    fetchDetalhes() {

        if(this.is_fatura_aberta){
            this.fetchDetalhesFaturaAberta();
        } else{
            const [dd, mm, yyyy] = this.fatura.dados.dataVencimento.split("/");
            const data_formatada = `${mm}-${yyyy}`;
    
            calloutDetalhesFatura({ 
                numeroConta: this.cliente_infos.numeroConta, 
                dataVencimento: data_formatada, 
                cpfCliente: this.cliente_infos.cpfCliente, 
                unidadeNegocio: this.cliente_infos.unidadeNegocio,
                canal: 'cockpit'
            }).then(result => {
                let infos = JSON.parse(JSON.stringify(result));
                
                if(!infos[0].faturaIndisponivel){
                    infos.forEach(inf => {
                        inf.selecionavel = this.reasonCode_selecionaveis.includes(inf.reasonCode);
                        inf.agrupamentoLancamentos.forEach(agrup => {
                            agrup.selecionavel = this.reasonCode_selecionaveis.includes(agrup.descricaoLancamento.reasonCode);
                        });
                        inf.valor = this.inverteValor(inf.valor);
                        if(inf.dataTransacao) inf.dataTransacaoFormatada = this.formatDate(inf.dataTransacao.toString().slice(0,10));
                        if(inf.numeroCartao) inf.numeroCartao = inf.numeroCartao != this.cliente_infos.numeroConta ? this.formatarCartao(inf.numeroCartao) : null;
                        this.setPagamentoEfetuado(this.fatura.dados.creditos);
                        inf.dataVencimentoFatura = this.fatura.dados.dataVencimentoOriginal;
                        inf.numeroConta = this.cliente_infos.numeroConta;
                    });

                    this.detalhes = this.agruparPorDescricaoGrupo(infos).sort(this.orderByDataTransacao_Cresc);
                }
    
                this.section = [this.sectionLabel];
            })
        }
    }

    fetchDetalhesFaturaAberta() {

        calloutDetalhesFaturaAberta({ 
            numeroConta: this.cliente_infos.numeroConta,
            cpfCliente: this.cliente_infos.cpfCliente, 
            unidadeNegocio: this.cliente_infos.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            let infos = JSON.parse(JSON.stringify(result));

        if(!infos[0].faturaIndisponivel){
            infos.forEach(inf => {
                inf.selecionavel = this.reasonCode_selecionaveis.includes(inf.reasonCode);
                inf.agrupamentoLancamentos.forEach(agrup => {
                    agrup.selecionavel = this.reasonCode_selecionaveis.includes(agrup.descricaoLancamento.reasonCode);
                });
                inf.valor = this.inverteValor(inf.valor);
                if(inf.dataTransacao) inf.dataTransacaoFormatada = this.formatDate(inf.dataTransacao.toString().slice(0,10));
                if(inf.numeroCartao) inf.numeroCartao = inf.numeroCartao != this.cliente_infos.numeroConta ? this.formatarCartao(inf.numeroCartao) : null;
                inf.dataVencimentoFatura = this.fatura.dados.dataVencimentoOriginal;
                inf.numeroConta = this.cliente_infos.numeroConta;
            });

            this.detalhes = this.agruparPorDescricaoGrupo(infos).sort(this.orderByDataTransacao_Cresc);
        }
        
            this.section = [this.sectionLabel];
        })
    }

    GetFaturasId(){
        this.spinner = true;
        getFaturasId({
            numeroConta: this.cliente_infos.numeroConta,
            cpfCliente: this.cliente_infos.cpfCliente,
            unidadeNegocio: this.cliente_infos.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if(result.length > 0){
                const objetoEncontrado = result.find(obj => obj.data == this.fatura.dados.dataVencimentoOriginal);
                if(objetoEncontrado){
                    this.AbriFatura(objetoEncontrado.idFatura);
                }else{
                    this.showToast('Alert', 'O arquivo PDF da fatura não está disponivel', 'warning', true);
                }
            }
        }).catch(error =>{
            this.showToast('Erro', 'Houve um erro ao buscar Id da Fatura', 'error', true);
            console.log('Erro: '+error.message);
        });
        setTimeout(() => this.spinner = false, 5000);
    }

    AbriFatura(idFatura){
        abriFatura({
            numeroConta: this.cliente_infos.numeroConta,
            cpfCliente: this.cliente_infos.cpfCliente,
            idFatura: idFatura,
            unidadeNegocio: this.cliente_infos.unidadeNegocio,
            canal: 'cockpit'
        }).then((result) => {
            console.log('cehgou: '+JSON.stringify(result));
            
            if(result.statusReponse == "OK"){
                const byteCharacters = atob(result.conteudo);
                const byteNumbers = Array.from(byteCharacters).map(char => char.charCodeAt(0));
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], { type: 'application/pdf' });
                const pdfUrl = URL.createObjectURL(blob);
                const link = document.createElement('a');
                link.href = pdfUrl;
                link.target = '_blank';
                link.click();
                setTimeout(() => URL.revokeObjectURL(pdfUrl), 5000);                
            }
        }).catch(error =>{
            this.showToast('Erro', 'Houve um erro ao renderizar PDF', 'error', true);
            console.log('Erro: '+error.message);
        });
    }
    orderByDataTransacao_Cresc(a,b){
        if(a.dataTransacao == b.dataTransacao) return 0;
    
        return a.dataTransacao < b.dataTransacao ? -1 : 1;
    }

    setPagamentoEfetuado(pagamento){
        if(!pagamento || this.is_fatura_aberta) return;

        this.pagamentoEfetuado = pagamento;
    }

    inverteValor(valor){
        return valor * (-1);
    }

    formatDate(date){
        if(!date) return null;

        const [yyyy, mm, dd] = date.split('-');

        return `${dd}/${mm}/${yyyy}`;
    }

    agruparPorDescricaoGrupo(collection_lancamentos){
        let lancamentos = [];

        collection_lancamentos.forEach(lancamento => {
            if(lancamento.agrupamentoLancamentos.length > 0){
                const agrupamento = lancamento.agrupamentoLancamentos;

                agrupamento.forEach(agrup => {
                    agrup.valor = this.inverteValor(agrup.descricaoLancamento.valor.valor);
                    agrup.dataTransacaoFormatada = this.formatDate(agrup.data.toString().slice(0,10));
                    if(agrup.numeroCartao) agrup.numeroCartao = agrup.numeroCartao != this.cliente_infos.numeroConta ? this.formatarCartao(agrup.numeroCartao) : null;
                });
    

                const summary = {
                    _children: agrupamento,
                    descricao: lancamento.descricao,
                    dataTransacao: lancamento.dataTransacao,
                    dataTransacaoFormatada: lancamento.dataTransacaoFormatada,
                    numeroCartao: lancamento.numeroCartao,
                    selecionavel: false,
                    idTransacao: 'summary_' + lancamento.idTransacao,
                    valor: lancamento.valor
                };
    
                lancamentos.push(summary);
            }
        });

        if(lancamentos.length === 0) return collection_lancamentos;

        const lancamentoSemGrupo = collection_lancamentos.filter(lancamento => lancamento.agrupamentoLancamentos.length === 0);
        
        lancamentoSemGrupo.forEach(lancamento => {
            lancamentos.push(lancamento);
        });

        return lancamentos;
    }

    removeUnselectableRows(rows){
        this.setSelectedRows = [];

        rows.forEach(row => {
            if(row.selecionavel) this.setSelectedRows = [...this.setSelectedRows, row.idTransacao];
        });
    }


    onRowSelection(event){
        this.removeUnselectableRows(event.detail.selectedRows);
        
        const linhasSelecionadas = event.detail.selectedRows.filter(row => row.selecionavel === true);
        
        this.botao_limpar_bloq = linhasSelecionadas.length < 1;

        let linhasRemovidas = [];

        this.linhas_selecionadas_bu.forEach(linhaBU => {
            const findLinha = linhasSelecionadas.find(linha => linha.reasonCode === linhaBU.reasonCode && linha.idTransacao === linhaBU.idTransacao) 
            
            if(!findLinha) linhasRemovidas.push(linhaBU);
        });

        this.linhas_selecionadas_bu = [...linhasSelecionadas];

        this.sendEvent_attLinhasResumo(linhasSelecionadas, linhasRemovidas);
    }

    sendEvent_attLinhasResumo(linhasSelecionadas, linhasRemovidas){
        const event = new CustomEvent('updateResumo', {
            detail: {
                linhasSelecionadas: linhasSelecionadas,
                linhasRemovidas: linhasRemovidas
            },
            bubbles: true
        });

        this.dispatchEvent(event);
    }

    formatarCartao(numeroCartao){
        let numero = numeroCartao.toString();
        let numeroFormatado = 'xxxxxxxxxxxx' + numero.slice(12);
        return numeroFormatado;
    }

    async obterResumoFaturaMes(mesAno) {
        await obterResumoFaturaMes({
            numeroConta: this.cliente_infos.numeroConta,
            mesAno : mesAno,
            cpf: this.cliente_infos.cpfCliente.replaceAll('.', '').replaceAll('-', ''),
            unidade: this.cliente_infos.unidadeNegocio,
            canal: 'cockpit'
        }).then(result => {
            if (result != null && result.StatusAPI === 'OK') {
                var fatura = result.fatura;
                this.tipoFatura = fatura.tipoFatura;
                this.tipoFaturaClass = 'tagTipoFatura tipoFatura_' + fatura.idTipoFatura;
                this.isTipoFaturaCarregado = true;
            } else {
                console.log('Não foi possível carregar status de pagamento.');
            };
        }).catch(error => {
            console.log('Não foi possível carregar status de pagamento.', error.message);
        })
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