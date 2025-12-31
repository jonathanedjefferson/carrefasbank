import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import listarClientes from '@salesforce/apex/BlindagemCPFController.listarClientes';
import USER_ID from '@salesforce/user/Id';
import USER_DRT from '@salesforce/schema/User.DRT__c';
import criarClientesMassa from '@salesforce/apex/BlindagemCPFController.criarClientesMassa';
import removerClientesMassa from '@salesforce/apex/BlindagemCPFController.removerClientesMassa';
import obterCliente from '@salesforce/apex/BlindagemCPFController.obterCliente';


export default class Bcsf_BlindagemImportacaoMassiva extends LightningElement {
    @track spinner;
    @track exibirModal = false;
    @track isProsseguirDisabled = true;
    @track exibirModalConfirmacao = false;
    @track linhasParaImportar = [];
    @track sortedByData = 'data';
    @track sortedDirectionData = 'desc';
    @track sortedByCPF = 'cpf';
    @track sortedDirectionCPF = 'desc';
    drtUser;
    file;

    acao;
    registrosPaginados = [];
    paginaAtual = 1;
    itensPorPagina = '10';
    totalPaginas = 1;

    opcoesItensPorPagina = [
        { label: '5', value: '5' },
        { label: '10', value: '10' },
        { label: '20', value: '20' }
    ];

    colunas = [
        { label: 'Dt. Blindagem', fieldName: 'data', sortable: true },
        { label: 'CPF', fieldName: 'cpf' },
        { label: 'Nome do Cliente', fieldName: 'nome' },
        { label: 'Tipo de blindagem', fieldName: 'tipo' },
        { label: 'Motivo', fieldName: 'motivo' },
        { label: 'Usuário', fieldName: 'usuario' }
    ];

    opcoesTipoBlindagem = [
        { label: 'Todos', value: '' },
        { label: 'Simples', value: 'Simples' },
        { label: 'Full', value: 'Full' }
    ];

    filtroTipo = '';
    filtroCpf = '';

    connectedCallback() {
        this.buscarCliente();
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USER_DRT] })
    getUserRecord({ error, data }) {
        if (data) {
            this.drtUser = data.fields.DRT__c.value;
        } else if (error) {
            this.logError('getUserRecord', error);
        }
    }

    buscarCliente() {
        this.spinner = true;
        const tipoFiltro = this.filtroTipo === '' ? 2 : 1;
        const valor = this.filtroTipo === '' ? 'Desc' : this.filtroTipo;

        const inputFiltro = {
            tipoFiltro: tipoFiltro,
            valor: valor
        };

        let itensPorPaginaInt = parseInt(this.itensPorPagina, 10);

        if(this.filtroCpf){
            this.ObterCliente();
        }
        else{
            this.ListarClientes(itensPorPaginaInt, inputFiltro);
        }
    }

    ListarClientes(itensPorPaginaInt ,inputFiltro){
        listarClientes({
            filtro: inputFiltro,
            tamanhoPagina: itensPorPaginaInt,
            pagina: this.paginaAtual,
            canal: 'Cockpit'
        }).then(result => {
                if (result.statusAPI === 'OK') {
                    this.totalPaginas = Math.ceil(result.totalItens / itensPorPaginaInt);
                    this.paginaAtual = result.pagina;
                    this.registrosPaginados = result.listaDeUsuariosPorCpf.map((item, index) => ({
                        id: index,
                        data: this.formatarData(item.dataAlteracao),
                        cpf: item.cpf,
                        nome: item.nome,
                        tipo: item.blindagem,
                        motivo: item.descricao,
                        usuario: item.usuario,
                        dataOriginal: item.dataAlteracao
                    }));
                    this.spinner = false;
                } else {
                    this.showToast('Erro', 'Erro ao consultar clientes blindados.', 'error', true);
                }
            })
            .catch(error => {
                this.showToast('Erro', 'Erro ao chamar serviço.', 'error', true);
                console.error(error);
            });
    }

    ObterCliente(){
        obterCliente({
            cpfCliente: this.filtroCpf,
            canal: 'Cockpit'
        }).then(result => {
                if (result.statusAPI === 'OK') {
                    this.totalPaginas = 1;
                    this.paginaAtual = 1;
                    this.registrosPaginados = [{
                        id: 1,
                        data: this.formatarData(result.dataAlteracao),
                        cpf: result.cpf,
                        nome: result.nome,
                        tipo: result.blindagem,
                        motivo: result.descricao,
                        usuario: result.usuario,
                        dataOriginal: result.dataAlteracao
                    }];
                    this.spinner = false;
                } else {
                    this.showToast('Erro', 'Erro ao consultar cliente blindado.', 'error', true);
                }
            })
            .catch(error => {
                this.showToast('Erro', 'Erro ao chamar serviço.', 'error', true);
                console.error(error);
            });
    }

    handleItensPorPagina(event) {
        this.itensPorPagina = event.detail.value;
        this.paginaAtual = 1;
        this.buscarCliente();
    }

    paginaAnterior() {
        if (this.paginaAtual > 1) {
            this.paginaAtual--;
            this.buscarCliente();
        }
    }

    paginaProxima() {
        if (this.paginaAtual < this.totalPaginas) {
            this.paginaAtual++;
            this.buscarCliente();
        }
    }

    handleFiltroTipo(event) {
        this.filtroTipo = event.detail.value;
        this.paginaAtual = 1;
        this.buscarCliente();
    }

    handleBuscaCpf(event) {
        this.filtroCpf = event.detail.value;
    }

    handleSortData(event) {
        this.sortedDirectionData = event.detail.sortDirection;
        const isReverse = this.sortedDirectionData === 'asc' ? 1 : -1;

        this.registrosPaginados = [...this.registrosPaginados].sort((a, b) => {
            let valorA = a.dataOriginal;
            let valorB = b.dataOriginal;
            return (valorA > valorB ? 1 : -1) * isReverse;
        });
    }

    handleSortCPF(event) {
        this.sortedDirectionCPF = event.detail.sortDirection;
        const isReverse = this.sortedDirectionCPF === 'asc' ? 1 : -1;

        this.linhasParaImportar = [...this.linhasParaImportar].sort((a, b) => {
            let valA = a[this.sortedByCPF];
            let valB = b[this.sortedByCPF];

            valA = valA.replace(/\D/g, '');
            valB = valB.replace(/\D/g, '');

            if (valA > valB) return 1 * isReverse;
            if (valA < valB) return -1 * isReverse;
            return 0;
        });
    }

    abrirModal(event) {
        this.acao = event.target.name;
        this.titleAcao = event.target.name == 'excluir'? 'Exclusão massificada': 'Importação massificada';
        this.exibirModal = true;
    }

    fecharModal() {
        this.exibirModal = false;
        this.isProsseguirDisabled = true;
        this.file = null;
    }

    fecharConfirmacao() {
        this.exibirModalConfirmacao = false;
        this.exibirModal = true;
    }   

    abrirFilePicker() {
        this.template.querySelector('input[type="file"]').click();
    }

    handleFileChange(event) {
        const files = event.target.files;
        if (files.length > 0) {
            this.file = files[0];
            this.isProsseguirDisabled = false;
        }
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleExcluirLinha(event) {
        const linhaId = event.detail.row.id;
        this.linhasParaImportar = this.linhasParaImportar.filter(linha => linha.id !== linhaId);
    }

    handleDrop(event) {
        event.preventDefault();
        const files = event.dataTransfer.files;
        if (files.length > 0 && files[0].type === 'text/csv') {
            this.file = files[0];
            this.isProsseguirDisabled = false;
        } else {
            this.showToast('Erro', 'Somente arquivos .csv são permitidos.', 'error');
        }
    }

    handleProsseguir() {
        if (!this.file) return;

        const reader = new FileReader();
        reader.onload = () => {
            const linhas = reader.result.split('\n').filter(l => l.trim() !== '');
            const headers = linhas[0].split(',').map(h => h.trim().toLowerCase());
  
            if (this.invalidData(linhas, headers)) {
                this.showToast('Erro', 'Encontramos uma ou mais linhas inconsistentes no anexo. Revise o conteúdo do arquivo e tente novamente após corrigir os dados.', 'error', true);
                this.isProsseguirDisabled = true;
                return;
            }

            this.linhasParaImportar = this.acao === 'excluir' ? this.mapExcludeLines(linhas) : this.mapImportLines(linhas);

            if (this.linhasParaImportar.length > 100) {
                this.showToast('Erro', 'O arquivo possui mais de 100 linhas, ajuste e tente novamente.', 'error', true);
                this.isProsseguirDisabled = true;
                return;
            }

            this.exibirModal = false;
            this.exibirModalConfirmacao = true;
        };

        reader.readAsText(this.file, 'UTF-8');
    }

    invalidData(linhas, headers) {
        let isInvalid = this.acao === 'excluir' ? this.validateExludeLines(linhas, headers) : this.validateImportLines(linhas, headers);

        return isInvalid;
    }

    validateImportLines(linhas, headers) {
        let isInvalid = false;
        linhas.shift(); //Remover headers

        if (!headers.includes('cpf') || !headers.includes('tipo de blindagem')) {
            return true;
        }

        for (const linha of linhas) {
            const valores = linha.split(',');
            let cpf = valores[0];
            let tipo = valores[2]

            if (this.invalidCPF(cpf) || this.invalidTipo(tipo)) {
                isInvalid = true;
                break;
            }
        }

        return isInvalid;
    }

    validateExludeLines(linhas, headers) {
        let isInvalid = false;
        linhas.shift(); //Remover headers

        if (!headers.includes('cpf')) {
            return true;
        }

        for (const linha of linhas) {
            const valores = linha.split(',');
            let cpf = valores[1];

            if (this.invalidCPF(cpf)) {
                isInvalid = true;
                break;
            }
        }

        return isInvalid;
    }

    invalidCPF(cpf) {
        if (cpf.length != 11 || cpf.includes('.') || cpf.includes('-') || !cpf) {
            return true;
        }

        return false;
    }

    invalidTipo(tipo) {
        if (!tipo || !['Simples', 'Full'].includes(tipo)) {
            return true;
        }

        return false;
    }

    mapImportLines(linhas) {
        const registros = [];
        for (let i = 0; i < linhas.length; i++) {
            const valores = linhas[i].split(',');
            if (valores.length >= 4) {
                registros.push({
                    id: i,
                    cpf: valores[0]?.trim(),
                    nome: valores[1]?.trim(),
                    tipo: valores[2]?.trim(),
                    motivo: valores[3]?.trim(),
                    usuario: this.drtUser
                });
            }
        }

        return registros;
    }

    mapExcludeLines(linhas) {
        const registros = [];
        for (let i = 0; i < linhas.length; i++) {
            const valores = linhas[i].split(',');
            if (valores.length >= 4) {
                registros.push({
                    id: i,
                    dtBlindagem: valores[0]?.trim(),
                    cpf: valores[1]?.trim(),
                    nome: valores[2]?.trim(),
                    motivo: valores[4]?.trim(),
                    tipo: valores[3]?.trim(),
                    usuario: this.drtUser
                });
            }
        }

        return registros;
    }

    finalizarImportacao() {
        this.spinner = true;
        const payload = this.linhasParaImportar.map(linha => ({
            cpf: linha.cpf,
            nome: linha.nome,
            descricao: linha.motivo,
            usuario: linha.usuario,
            fullBlindagem: linha.tipo?.toLowerCase() === 'full',
            siglaUnidadeNegocio: 1
        }));
        
        if(this.acao === 'excluir'){
            this.ExcluirClientesMassa(payload);
        }else{
            this.CriarClientesMassa(payload);
        }
    }

    CriarClientesMassa(payload){
        criarClientesMassa({ clientes: payload, canal: 'Cockpit' })
            .then(result => {
                if (result.statusAPI === 'OK') {
                    this.showToast('Sucesso', 'Importação concluída com sucesso!', 'success');
                    this.exibirModalConfirmacao = false;
                    this.buscarCliente();
                } else {
                    this.showToast('Erro', result.mensagemRetorno || 'Falha ao importar clientes.', 'error');
                    this.spinner = false;
                }
            })
            .catch(error => {
                this.showToast('Erro', 'Erro inesperado na importação.', 'error', true);
                console.error(error);
            });
    }

    ExcluirClientesMassa(payload){
        removerClientesMassa({ clientes: payload, canal: 'Cockpit' })
            .then(result => {
                if (result.statusAPI === 'OK') {
                    this.showToast('Sucesso', 'Exclusão concluída com sucesso!', 'success');
                    this.exibirModalConfirmacao = false;
                    this.buscarCliente();
                } else {
                    this.showToast('Erro', result.mensagemRetorno || 'Falha ao excluir clientes.', 'error');
                    this.spinner = false;
                }
            })
            .catch(error => {
                this.showToast('Erro', 'Erro inesperado na exclusão.', 'error', true);
                console.error(error);
            });
    }

    handleBaixarModelo(event) {
        event.preventDefault();
        this.baixarModelo();
    }

    baixarModelo() {
        const bom = '\uFEFF';
        const csv = this.acao === 'excluir' ? 'Dt. Blindagem,CPF, Nome do Cliente, Tipo de blindagem, Motivo\ndd/mm/aaaa hh:mm:ss, 00000000000, Cliente Nome, Simples, INVASAO DE CONTA' :
            'CPF, Nome do Cliente, Tipo de blindagem, Motivo\n00000000000, Cliente Nome, Simples, INVASAO DE CONTA';
        const csvData = 'data:text/csv;charset=utf-8,' + encodeURIComponent(bom  + csv);
        const link = document.createElement('a');
        link.href = csvData;
        link.download = this.acao === 'excluir' ? 'modelo_blindagem_exclusao.csv' : 'modelo_blindagem_importacao.csv';;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    formatarData(dataISO) {
        const data = new Date(dataISO);
        const dia = String(data.getDate()).padStart(2, '0');
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const ano = data.getFullYear();
        const horas = String(data.getHours()).padStart(2, '0');
        const minutos = String(data.getMinutes()).padStart(2, '0');
        const segundos = String(data.getSeconds()).padStart(2, '0');
        return `${dia}/${mes}/${ano} ${horas}:${minutos}:${segundos}`;
    }

    exportarTabela() {
        const dados = this.registrosPaginados;
        let doc;

        const colunas = [
            'Dt. Blindagem',
            'CPF',
            'Nome do Cliente',
            'Tipo de blindagem',
            'Motivo',
            'Usuario',
        ];

        colunas.forEach(element => {
            doc += element + ','
        });
        doc += '\n';

        dados.forEach(registro => {
            doc += registro.data + ',';
            doc += registro.cpf + ',';
            doc += registro.nome + ',';
            doc += registro.tipo + ',';
            doc += registro.motivo + ',';
            doc += registro.usuario + ',';
            doc += '\n';
        });
        doc = doc.replaceAll('undefined','');

        let element = 'data:text/csv;charset=utf-8,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'Clientes Blindados.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    showToast(title, message, variant, close = false) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
                mode: 'dismissable'
            })
        );

        if(close){
            this.spinner = false;
        }
    }

    get colunasConfirmacao() {
        let baseColumns = [
            { label: 'CPF', fieldName: 'cpf', sortable: true },
            { label: 'Nome do Cliente', fieldName: 'nome' },
            { label: 'Tipo de blindagem', fieldName: 'tipo' },
            { label: 'Motivo', fieldName: 'motivo' },
            {
                type: 'button-icon',
                fixedWidth: 50,
                typeAttributes: {
                    iconName: 'utility:delete',
                    alternativeText: 'Excluir',
                    title: 'Excluir',
                    variant: 'bare',
                    name: 'excluir_linha'
                }
            }
        ];

        return this.acao === 'excluir' ?  [{ label: 'Dt. Blindagem', fieldName: 'dtBlindagem', sortable: true }, ...baseColumns] : baseColumns;
    }
}