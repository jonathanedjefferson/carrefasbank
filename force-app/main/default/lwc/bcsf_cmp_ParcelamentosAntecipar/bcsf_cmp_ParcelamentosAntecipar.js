import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import simularAntecipacoes from '@salesforce/apex/AntecipacaoParcelasController.simularAntecipacoes';
import anteciparParcelas from '@salesforce/apex/AntecipacaoParcelasController.anteciparParcelas';
import enviarEmail from '@salesforce/apex/AntecipacaoParcelasController.enviarEmailAlternativo';
import obterDadosPagamentoAvulso from '@salesforce/apex/AntecipacaoParcelasController.obterDadosPagamentoAvulso';
import criarCaso from '@salesforce/apex/AntecipacaoParcelasController.criarCaso';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

export default class Bcsf_cmp_ParcelamentosAntecipar extends LightningElement {
     
    @api dadosUsuario;           
    @api dadosCliente;
    @api parcelamentosParaSimular;
    @api temParcelaPostada;

    @track labelValorTotalAntecipacaoComDesconto;
    @track quantidadeParcelasAntecipadas;
    @track valorTotalAntecipado = {};
    @track descontoTotal = {};
    @track valorTotalComDesconto = {};
    @track listaSimulacoesRealizadas = []
    @track listaSimulacoesComFalha = [];

    @track opcoesParcelaPostada = [
        { label: 'Sim', value: 'Sim', checked: false},
        { label: 'Não', value: 'Não', checked: false}
    ];

    @track opcoesFormaPagamento = [
        {label: 'Pagamento com Pix', value: 'Pix', disabled: false, disponivel: true, checked: false},
        {label: 'Pagamento com boleto avulso', value: 'Boleto', disabled: false, disponivel: true, checked: false},
        {label: 'Pagamento fatura em aberto', value: 'Fatura', disabled: false, disponivel: true, checked: false},
    ];

    @track exibirModalAntecipacao = false;
    @track spinner = false;
    @track step01 = false;
    @track step02 = false;
    @track erroTodasAsParcelasSimuladas = false;
    @track tipoConta;
    @track logoTipo;
    @track titularConta;
    @track exibirAlertaSimulacoesComErro = false;
    @track exibirAlertaAntecipacaoCredito = false;
    @track labelBotaoVoltar = 'Voltar';
    @track labelBotaoAvancar = 'Contratar';
    @track enviarEmailAlternativo = false;
    @track desativarBotaoProsseguir = true;
    @track desativarBotaoVoltar = false;
    @track exibirBotaoProsseguir = true;
    @track exibirIconeSucesso = true;
    @track erroAoGerarDadosPagamento = false;
    @track  desativarBotaoEnviarEmail = true;
    @track activeSection = '';
    @track exibirErroAntecipar = false;
    @track exibirAlertaAdesoesComErro = false;
    @track exibirDadosParaPagamento = false;
    @track exibirAlertaPagamento = false;
    @track exibirEroAntecipar = false;
    @track exibirBoxEmail = false
    @track incluirPdfBoleto = false;
    @track tipoPagamento;
    @track prosseguirComParcelasPostadas;
    @track origemCasoDisabled = false;
    @track canalCasoDisabled = true;
    @track formaPagamentoErroMsg;

    @track origemCaso;
    @track canalCaso;
    @track assuntoCaso = 'Pagamento';
    @track eventoCaso = 'Antecipação de parcelas';
    @track numeroProtocolo = '--';
    @track casoCriado = false;
    @track idCaso;
    @track prazoEnvio = 'Imediato';
    @track modoEnvio = 'E-mail';
    @track dataProtocolo = '--';
    @track tituloAccordionAntecipacoes;
    @track tituloEnvioDoEmail = 'O código de pagamento e o contrato foram enviados para o endereço de e-mail de cadastro:';
    @track tituloSolicitacao = 'Solicitação realizada!';
    @track tituloPagamento;
    @track codigoPagamentoTitulo;
    @track labelBotaoCopiar;
    @track mensagemAlertaRealizarPagamento;
    @track mensagemSucessoCopiar;
    @track fraseEnviarEmailAlternativo;
    @track pagamentoPorBoleto = false;
    @track codigoPagamento;
    @track valorPagamentoFormatado;
    @track vencimentoPagamento;
    @track labelGerarFormaPagamentoNovamente;
    @track labelAlterarFormaPagamento;
    @track emailAlternativo;
    @track fileBase64;


    @track listaParcelamentosParaAntecipar = [];

    // dados da antecipacao realizada
    @track listaAdesoesRealizadas = [];
    @track listaAdesoesComFalha = [];
    @track valorTotalComDescontoAntecipacaoMultipla;
    @track antecipacaoMultiplaId;


    async connectedCallback() {
        this.showSpinner();
        this.obterLogo(this.dadosCliente.unidadeNegocio);
        this.titularConta = this.dadosCliente.titularConta;
        this.realizarSimulacao();
    }

    async realizarSimulacao(){
        await simularAntecipacoes({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpfCliente,
            unidadeNegocio : this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            cpfDrtOperador: this.dadosUsuario.cpfDrtOperador,
            perfilOperador: this.dadosUsuario.perfilOperador, 
            parcelamentos: JSON.stringify(this.parcelamentosParaSimular)
        }).then(result => {

            if(result.statusAPI == 'OK' ||  result.statusAPI == 'ERRO_TRATADO'){

                if(result.statusAPI == 'OK'){

                    this.quantidadeParcelasAntecipadas = result.quantidadeParcelasAntecipadas;
                    this.valorTotalAntecipado = {...result.valorTotalAntecipado , valor: this.formatarValor(result.valorTotalAntecipado.valor)};
                    this.descontoTotal = {...result.descontoTotal , valor: this.formatarValor(result.descontoTotal.valor)};
                    this.valorTotalComDesconto = {...result.valorTotalComDesconto , valor: this.formatarValor(result.valorTotalComDesconto.valor)};

                    this.labelValorTotalAntecipacaoComDesconto = this.quantidadeParcelasAntecipadas > 1 ? 'Valor total das antecipações com desconto' : 'Valor total da antecipação com desconto';
   
                    result.simulacoes.forEach(simulacao => {
                        if(simulacao.categoria == 'CreditoPessoal'){
                            this.exibirAlertaAntecipacaoCredito = true;
                        }
                    })

                    if(result.status != 'Sucesso'){
                        this.exibirAlertaSimulacoesComErro = true;
                        this.activeSection = 'sectionSimulacoes';
                    }

                    this.opcoesFormaPagamento = this.opcoesFormaPagamento.map(fomaPagmento => {
                        if(fomaPagmento.value == 'Boleto'){
                            return{
                                ...fomaPagmento,
                                disabled: result.tiposPagamentoDisponiveis.boleto ? false : true,
                                disponivel:  result.tiposPagamentoDisponiveis.boleto
                            }
                        } else if(fomaPagmento.value == 'Pix'){
                            return{
                                ...fomaPagmento,
                                disabled: result.tiposPagamentoDisponiveis.pix ? false : true,
                                disponivel:  result.tiposPagamentoDisponiveis.pix
                            }
                        }
                        return fomaPagmento;
                    });

                    this.listaSimulacoesRealizadas = result.simulacoes.map(simulacao => {

                        let parcelamento = {
                            idParcelamento: simulacao.serno,
                            parcelas: simulacao.parcelasAntecipaveis.map(parcela =>  parcela.numeroParcela),
                            descontoSimulado: simulacao.desconto.valor
                        }
    
                        this.listaParcelamentosParaAntecipar = [...this.listaParcelamentosParaAntecipar, parcelamento];
    
                        return {
                            serno: simulacao.serno,
                            descricaoCompra: simulacao.descricaoCompra,
                            dataCompra: this.formatarDataDDMMYYYY(simulacao.dataCompra),
                            quantidadeParcelasAntecipadas: simulacao.parcelasAntecipaveis.length,
                            periodoAntecipado: simulacao.periodoAntecipado,
                            valorTotal: `${simulacao.valorTotalParcelas.moeda} ${this.formatarValor(simulacao.valorTotalParcelas.valor)}`,
                            desconto: `${simulacao.desconto.moeda} ${this.formatarValor(simulacao.desconto.valor)}`,
                            valorTotalComDesconto: `${simulacao.valorTotalParcelasAntecipacao.moeda} ${this.formatarValor(simulacao.valorTotalParcelasAntecipacao.valor)}`
                        }
    
                    });

                    this.listaSimulacoesComFalha = result.simulacoesComFalha.map(simulacao =>{
                        return {
                            serno: simulacao.serno,
                            descricaoCompra: simulacao.descricaoCompra,
                            dataCompra: this.formatarDataDDMMYYYY(simulacao.dataCompra),
                            descricaoErro: simulacao.descricaoErro
                        }
                    });

                    this.erroTodasAsParcelasSimuladas = false;
                    this.exibirModalAntecipacao = true;
                    this.step01 = true;

                } else{

                    this.listaSimulacoesComFalha = result.simulacoesComFalha.map(simulacao =>{
                        return {
                            serno: simulacao.serno,
                            descricaoCompra: simulacao.descricaoCompra,
                            dataCompra: this.formatarDataDDMMYYYY(simulacao.dataCompra),
                            descricaoErro: simulacao.descricaoErro
                        }
                    })
                    this.exibirBotaoProsseguir = false;
                    this.erroTodasAsParcelasSimuladas = true;
                    this.exibirModalAntecipacao = true;

                }
                
                this.handleSucessoSimulacao();

            }else{

                this.fecharModal();
                this.handleErroSimulacao();

            }

            this.closeSpinner();

        }).catch(error => {

            this.fecharModal();
            this.handleErroSimulacao();
            this.closeSpinner();

            this.logError('realizarSimulacao', error);
            
        });
    }

    async realizarAntecipacao(){

        this.showSpinner();

        await anteciparParcelas({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpfCliente,
            unidadeNegocio : this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            cpfDrtOperador: this.dadosUsuario.cpfDrtOperador,
            perfilOperador: this.dadosUsuario.perfilOperador, 
            parcelamentos: JSON.stringify(this.listaParcelamentosParaAntecipar),
            tipoPagamento: this.tipoPagamento,
            incluirPdfBoleto: this.incluirPdfBoleto
        }).then(result => {
            if(result.statusAPI == 'OK' || result.statusAPI == 'ERRO_TRATADO'){

                if(result.statusAPI == 'OK'){

                    this.antecipacaoMultiplaId = result.antecipacaoMultiplaId;
                    this.valorTotalComDescontoAntecipacaoMultipla = result.valorTotalComDesconto;
                    this.valorPagamentoFormatado =  `${result.valorTotalComDesconto.moeda} ${this.formatarValor(result.valorTotalComDesconto.valor)}`
                    this.exibirBoxEmail = true;
                    this.tituloSolicitacao = this.tipoPagamento == 'Fatura' ? 'Solicitação realizada. O valor da  antecipação será somado ao mínimo da fatura.' : 'Solicitação realizada!';
                    this.exibirIconeSucesso = true;
                    this.exibirEroAntecipar = false;
                    this.tituloAccordionAntecipacoes = 'Detalhes de todas as compras antecipadas';

                    if(result.status != 'Sucesso'){
                        this.exibirAlertaAdesoesComErro = true;
                        this.activeSection = 'sectionAdesoes';
                        this.tituloAccordionAntecipacoes = 'Detalhes de todas as parcelas simuladas';
                    }

                    this.listaAdesoesRealizadas = result.adesoes.map(adesao => {
                        return {
                            serno: adesao.serno,
                            descricaoCompra: adesao.descricao,
                            dataCompra: this.formatarDataDDMMYYYY(adesao.dataCompra),
                            quantidadeParcelasAntecipadas: adesao.parcelas.length,
                            periodoAntecipado: adesao.periodoAntecipado,
                            valorTotal: this.formatarValorComReal(adesao.valorAntecipado),
                            desconto: this.formatarValorComReal(adesao.desconto),
                            valorTotalComDesconto: this.formatarValorComReal(adesao.valorComDesconto)
                        }
                    });
    
                    this.listaAdesoesComFalha = result.adesoesComFalha.map(adesao =>{
                        return {
                            serno: adesao.serno,
                            descricaoCompra: adesao.descricao,
                            dataCompra: this.formatarDataDDMMYYYY(adesao.dataCompra),
                            descricaoErro: adesao.descricaoErro
                        }
                    })
    
                    if(this.tipoPagamento != 'Fatura'){
                        if(result.boleto && this.tipoPagamento == 'Boleto'){
                            this.codigoPagamento = result.boleto.linhaDigitavel;
                            this.vencimentoPagamento = this.formatarDataDDMMYYYY(result.boleto.dataVencimento);
                            this.exibirDadosParaPagamento = true;
                            this.exibirAlertaPagamento = true;
                            this.fileBase64 = result.boleto.pdf;
                        }else if(result.pix && this.tipoPagamento == 'Pix'){
                            this.codigoPagamento = result.pix.copiaCola;
                            this.vencimentoPagamento = this.formatarDataDDMMYYYY(result.pix.dataVencimento);
                            this.exibirDadosParaPagamento = true;
                            this.exibirAlertaPagamento = true;
                        }else{
                            this.tituloEnvioDoEmail = 'O contrato foi enviado via e-mail';
                            this.erroAoGerarDadosPagamento = true;
                            this.exibirDadosParaPagamento = false;
                        }
                    }

                }else{

                    this.listaAdesoesComFalha = result.adesoesComFalha.map(adesao =>{
                        return {
                            serno: adesao.serno,
                            descricaoCompra: adesao.descricao,
                            dataCompra: this.formatarDataDDMMYYYY(adesao.dataCompra),
                            descricaoErro: adesao.descricaoErro
                        }
                    });
                        
                    this.exibirDadosParaPagamento = false;
                    this.exibirBoxEmail = false;
                    this.exibirEroAntecipar = true;
                    this.tituloSolicitacao = 'Erro na solicitação!';
                    this.exibirIconeSucesso = false;

                }

            } else{

                this.exibirDadosParaPagamento = false;
                this.exibirBoxEmail = false;
                this.exibirEroAntecipar = true;
                this.tituloSolicitacao = 'Erro na solicitação!';
                this.exibirIconeSucesso = false;
                
            }

            this.finalizarSolicitacao();

        }).catch(error => {
            this.closeSpinner();
            this.showToast('Erro', 'Houve uma falha ao realizar a antecipação!', 'error', false);
            this.logError('realizarAntecipacao', error);
        })
    }

    async finalizarSolicitacao(){

        if(!this.casoCriado){
            await criarCaso({
                accountId: this.dadosCliente.contaPessoalId,
                status: 'Closed',
                assunto: this.assuntoCaso,
                evento: this.eventoCaso,
                origem: this.origemCaso,
                contaFinanceiraId: this.dadosCliente.contaFinanceiraId,
                unidadeNegocio: this.dadosCliente.unidadeNegocio,
                tipo: 'Execução',
                canal: this.canalCaso,
            }).then((result) => {
                this.numeroProtocolo = result.CaseNumber;
                this.idCaso = result.Id;
                this.casoCriado = true;
                this.dataProtocolo = this.getDate();
            }).catch(error => {
                this.desativarBotaoProsseguir = true;
                this.showToast('Erro', 'Houve um erro ao Criar Caso', 'error', false);
                this.logError('finalizarSolicitacao', error);
            });
        }

        this.labelBotaoAvancar = 'Ir para caso';
        this.labelBotaoVoltar = 'Fechar';
        this.step02 = true;
        this.step01 = false;

        this.dispatchEvent(new CustomEvent('solicitacaorealizada'));

        this.closeSpinner();
    }

    async handleEnviarEmail(){

        this.showSpinner();

        await enviarEmail({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpfCliente,
            unidadeNegocio : this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            cpfDrtOperador: this.dadosUsuario.cpfDrtOperador,
            perfilOperador: this.dadosUsuario.perfilOperador, 
            antecipacaoMultiplaId: this.antecipacaoMultiplaId,
            emailDestinatario: this.emailAlternativo,
            tipoPagamento: this.tipoPagamento
        }).then(result => {
            if(result.statusAPI == 'OK'){
                this.showToast('', 'Email enviado com sucesso!', 'success', false);
            }else{
                this.showToast('Erro', 'Falha na API ao enviar email!', 'error', false);
            }
            this.closeSpinner();
        }).catch(error =>{
            this.showToast('Erro', 'Falha no sistema ao enviar email!', 'error', false);
            this.closeSpinner();
            this.logError('enviarEmail', error);
        })

    }

    async gerarDadosParaPagamento(){

        this.showSpinner();

        await obterDadosPagamentoAvulso({
            canal: 'Cockpit',
            cpf: this.dadosCliente.cpfCliente,
            unidadeNegocio : this.dadosCliente.unidadeNegocio,
            numeroConta: this.dadosCliente.numeroConta,
            cpfDrtOperador: this.dadosUsuario.cpfDrtOperador,
            perfilOperador: this.dadosUsuario.perfilOperador, 
            antecipacaoId: this.antecipacaoMultiplaId,
            tipoPagamento: this.tipoPagamento,
            valor: this.valorTotalComDescontoAntecipacaoMultipla.valor,
            incluirPdfBoleto: this.incluirPdfBoleto
        }).then(result => {
            if(result.statusAPI == 'OK'){

                this.setDetalhesPagamento();
                
                if(this.tipoPagamento == 'Boleto'){
                    this.codigoPagamento = result.boleto.linhaDigitavel;
                    this.vencimentoPagamento = this.formatarDataDDMMYYYY(result.boleto.dataVencimento);
                    this.fileBase64 = result.boleto.pdf;
                }

                if(this.tipoPagamento == 'Pix'){
                    this.codigoPagamento = result.pix.copiaCola;
                    this.vencimentoPagamento = this.formatarDataDDMMYYYY(result.pix.dataVencimento);
                }

                this.erroAoGerarDadosPagamento = false;
                this.exibirDadosParaPagamento = true;
                this.showToast('', 'Dados de pagamento gerados com sucesso.', 'success', false);
            }else{
                this.showToast('Erro', 'Houve erro ao gerar os dados para pagamento.', 'error', false);
            }
        }).catch(error =>{
            this.showToast('Erro', 'Houve erro ao gerar os dados para pagamento.', 'error', false);
            this.logError('obterDadosPagamentoAvulso', error);
        });

        this.closeSpinner();

    }
    
    obterLogo(unidade){
        switch(unidade){
            case '1':
                this.tipoConta = 'CARREFOUR';
                this.logoTipo = LogoCarrefour;
                break;
            case '2':
                this.tipoConta = 'ATACADÃO';
                this.logoTipo = LogoAtacadao;
                break;
            case '6':
                this.tipoConta = "SAM'S CLUB";
                this.logoTipo = LogoSamsClub;
                break;
            default:
                console.log('logo não encontrada para a unidade de negócio: ' + unidade);
        }
    }
    
    handleCopiarResumoSimulacao(){
        try{
            let texto = '';

            texto += `Quantidade total de parcelas antecipadas: ${this.quantidadeParcelasAntecipadas}\n`;
            texto += `Valor total antecipado: ${this.valorTotalAntecipado.moeda} ${this.valorTotalAntecipado.valor}\n`;
            texto += `Desconto total: ${this.descontoTotal.moeda} ${this.descontoTotal.valor}\n`;
            texto += `${this.labelValorTotalAntecipacaoComDesconto}: ${this.valorTotalAntecipado.moeda} ${this.valorTotalAntecipado.valor}\n`;
            
            const textarea = document.createElement('textarea');
            textarea.value = texto;
            document.body.appendChild(textarea);
            textarea.select();
            document.execCommand('copy');
            document.body.removeChild(textarea);

            this.showToast('Resumo copiado!', '', 'success', false);
        } catch (error) {
            this.showToast('Erro', 'Erro ao copiar resumo', 'Error', false);
            this.logError('handleCopiarResumoSimulacao', error);
        }
    }

    hadleProsseguirComParcelaPostada(event){
        const opcaoSelecionada = event.target.value;
        this.prosseguirComParcelasPostadas = opcaoSelecionada;

        this.opcoesParcelaPostada = this.opcoesParcelaPostada.map(opcao => {
            if(opcao.value == opcaoSelecionada){
                return {...opcao, checked: true}
            }
            return {...opcao, checked: false}
        });

        this.opcoesFormaPagamento = this.opcoesFormaPagamento.map(opcao => {

            if(opcaoSelecionada == 'Não'){
                return {
                    ...opcao,
                    disabled: true
                }
            }

            return {
                ...opcao,
                disabled: opcao.disponivel ? false : opcao.disabled
            }
            
        });

        if(opcaoSelecionada == 'Não'){
            this.origemCasoDisabled = true;
            this.canalCasoDisabled = true;
        }else{
            this.origemCasoDisabled = false;
            this.canalCasoDisabled  = this.origemCaso ? false : true;
        }

        this.listenProsseguir();
    }

    hadleSelecionarFormaPagamento(event){
        this.tipoPagamento = event.target.value;
        this.opcoesFormaPagamento = this.opcoesFormaPagamento.map(opcao => {
            if(opcao.value == event.target.value){
                return {...opcao, checked: true}
            }
            return {...opcao, checked: false}
        })
        this.listenProsseguir();
    }

    handleOrigemAlterada(event){
        this.origemCaso = event.target.value;

        if(this.origemCaso){
            this.canalCasoDisabled = false;
        }else{
            this.canalCasoDisabled = true;
        }

        this.listenProsseguir();
    }

    handleCanalAlterado(event){
        this.canalCaso = event.target.value;
        this.listenProsseguir();
    }
    
    handleEnviarEmailAlternativo(event){
        this.enviarEmailAlternativo = event.target.checked;
    }

    handleAlterarEmailEnvio(event){
        this.emailAlternativo = event.target.value;
        this.listenProsseguir();
    }

    handleGerarDadosPagamentoNovamente(){
        this.gerarDadosParaPagamento();
    }

    handleAlterarPagamento(){
        if(this.tipoPagamento == 'Pix'){
            this.tipoPagamento = 'Boleto';
        } else if(this.tipoPagamento == 'Boleto'){
            this.tipoPagamento = 'Pix';
        }
        this.gerarDadosParaPagamento();
    }

    handleOpenPdf() {
        if(this.fileBase64){
            const byteCharacters = atob(this.fileBase64);
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
    }

    handleCopiarDadosDePagamento(){
        try{
            let texto = '';

            texto += `${this.codigoPagamentoTitulo}:\n`;
            texto += `${this.codigoPagamento}\n\n`;
            texto += `Valor:\n`;
            texto += `${this.valorPagamentoFormatado}\n\n`;
            texto += `Vencimento:\n`;
            texto += `${this.vencimentoPagamento}\n`;
            
            const textarea = document.createElement('textarea');
            textarea.value = texto;
            document.body.appendChild(textarea);
            textarea.select();
            document.execCommand('copy');
            document.body.removeChild(textarea);

            this.showToast(this.mensagemSucessoCopiar, '', 'success', false);
        } catch (error) {
            this.showToast('', 'Erro ao copiar dados de pagamento', 'Error', false);
            this.logError('handleCopiarDadosDePagamento', error);
        }
    }

    handleTentarNovamenteAnteciparParcelas(){
        this.realizarAntecipacao();
    }

    async handleProsseguir(){
        if(this.step01){
            this.setDetalhesPagamento();
            await this.realizarAntecipacao();
        } else {
            window.location.href = '/lightning/r/Case/'+ this.idCaso +'/view';
        }
    }

    handleVoltarModal() {
        if(this.step02){
            this.dispatchEvent(new CustomEvent('atualizartabela'));
        }
        this.fecharModal();
    }

    setDetalhesPagamento(){
        if(this.tipoPagamento == 'Boleto'){
            this.mensagemAlertaRealizarPagamento = 'Caso o pagamento do boleto não seja realizado, o valor antecipado será somado ao mínimo da sua fatura em aberto.';
            this.pagamentoPorBoleto = true;
            this.tituloPagamento = 'Detalhes do boleto';
            this.codigoPagamentoTitulo = 'Código de barras';
            this.labelBotaoCopiar = 'Copiar código de barras';
            this.incluirPdfBoleto = true;
            this.labelGerarFormaPagamentoNovamente = 'Gerar boleto novamente';
            this.labelAlterarFormaPagamento = 'Alterar para Pix';
            this.mensagemSucessoCopiar = 'Código de barras copiado!'
            this.fraseEnviarEmailAlternativo = 'Encaminhar o código de pagamento para um endereço de e-mail alternativo';
            this.formaPagamentoErroMsg = 'boleto';
        }else if(this.tipoPagamento == 'Pix'){
            this.mensagemAlertaRealizarPagamento = 'Caso o pagamento do Pix não seja realizado, o valor antecipado será somado ao mínimo da sua fatura em aberto.';
            this.pagamentoPorBoleto = false;
            this.tituloPagamento = 'Detalhes do Pix'
            this.codigoPagamentoTitulo = 'Código Pix';
            this.labelBotaoCopiar = 'Copiar código Pix';
            this.incluirPdfBoleto = false;
            this.labelGerarFormaPagamentoNovamente = 'Gerar pix novamente';
            this.labelAlterarFormaPagamento = 'Alterar para Boleto';
            this.mensagemSucessoCopiar = 'Código Pix copiado!'
            this.fraseEnviarEmailAlternativo = 'Encaminhar o código de pagamento para um endereço de e-mail alternativo';
            this.formaPagamentoErroMsg = 'pix';
        }else if(this.tipoPagamento == 'Fatura'){
            this.tituloEnvioDoEmail = 'O contrato foi enviado para o endereço de e-mail de cadastro:';
            this.incluirPdfBoleto = false;
            this.fraseEnviarEmailAlternativo = 'Encaminhar o contrato para um endereço de e-mail alternativo';
        }
    }

    listenProsseguir(){

        if(this.step01){

            let opcaoParcelasPostada = true;

            if(this.temParcelaPostada){
                opcaoParcelasPostada = this.prosseguirComParcelasPostadas == 'Sim' ? true : false;
            }

            let prosseguir =  (
                opcaoParcelasPostada &&
                this.tipoPagamento &&
                this.origemCaso && 
                this.canalCaso 
            );

            this.desativarBotaoProsseguir =  prosseguir ? false : true;

        }else if(this.step02){

            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

            this.desativarBotaoEnviarEmail =  emailRegex.test(this.emailAlternativo) ? false : true;

        }

    }

    getDate() {
        const today = new Date();
        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const year = today.getFullYear();

        return `${day}/${month}/${year}`;
    }

    formatarDataDDMMYYYY(data){
        data = new Date(data);

        const ano = String(data.getFullYear()); 
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const dia = String(data.getDate()).padStart(2, '0');

        return `${dia}/${mes}/${ano}`;
    }

    formatarValor(valor) {
        return Intl.NumberFormat('pt-BR', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(valor);
    }

    formatarValorComReal(valor){
        return Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL'
        }).format(valor);
    }

    showSpinner(){
        this.spinner= true;
    }

    closeSpinner(){
        this.spinner = false;
    }

    fecharModal(){
        this.dispatchEvent(new CustomEvent('closeparentmodal'))
    }

    handleErroSimulacao(){
        this.dispatchEvent(new CustomEvent('errosimulacao'))
    }
    
    handleSucessoSimulacao(){
        this.dispatchEvent(new CustomEvent('sucessosimulacao'))
    }

    showToast(titulo, mensagem, variante, close) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if (close) {
            this.fecharModal();
        }
    }    

    logError(metodo, error) {
        if (error) {
            console.error('componente => ', 'bcsf_cmp_ParcelamentosAntecipar'); 
            console.error('metodo => ', metodo); 
            console.error('erro => ', error);  
            if(error.body){
                console.error('error.body.exceptionType => ', error.body.exceptionType);
                console.error('error.body.message => ', error.body.message);
                console.error('error.body.stackTrace => ', error.body.stackTrace);
            }else{
                console.error('error.name => ' + error.name );
                console.error('error.message => ' + error.message );
                console.error('error.stack => ' + error.stack );
            }
           
        }
    }
}