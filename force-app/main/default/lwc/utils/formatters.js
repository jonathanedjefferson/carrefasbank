export function formatarValor(valor) {
    try {
        return new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            minimumFractionDigits: 2,
            currency: 'BRL'
        }).format(valor);
    } catch (error) {
        this.logError('formatarValor', error);
        return valor;
    }
}


export function formatarPorcentagem(valor, locale = 'pt-BR') {
    try {
        const numero = parseFloat(Number(valor));
        const formatoBR = numero.toLocaleString(locale) + '%';
        return formatoBR;
    } catch (error) {
        this.logError('formatarPorcentagem', error);
        return valor; 
    }
}

export function formatarCPF(cpf) {
    try {
        cpf = cpf.replace(/\D/g, '');

        if (cpf.length === 11) {
            return cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
        }

        return cpf;
    } catch (error) {
        this.logError('formatarCPF', error);
        return cpf;
    }
}

export function formatarData(dataString) {
    try {

        if (!dataString) return '--';

        const data = new Date(dataString);
        
        const dia = String(data.getDate()).padStart(2, '0');
        const mes = String(data.getMonth() + 1).padStart(2, '0'); 
        const ano = data.getFullYear();
        
        return `${dia}/${mes}/${ano}`;
    } catch (error) {
        this.logError('formatarData', error);
        return '--';
    }
}

export function formatarDataHora(dataString) {
    try {
        if (!dataString) return '--';
        
        const data = new Date(dataString);
        
        const dia = String(data.getDate()).padStart(2, '0');
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const ano = data.getFullYear();
        
        const hora = String(data.getHours()).padStart(2, '0');
        const minutos = String(data.getMinutes()).padStart(2, '0');
        
        return `${dia}/${mes}/${ano} ${hora}:${minutos}`;
    } catch (error) {
        this.logError('formatarDataHora', error);
        return '--';
    }
}

export function formatarDataHoraCompleto(dataString) {
    try {
        if (!dataString) return '--';
        
        const data = new Date(dataString);
        
        const dia = String(data.getDate()).padStart(2, '0');
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const ano = data.getFullYear();
        
        const hora = String(data.getHours()).padStart(2, '0');
        const minutos = String(data.getMinutes()).padStart(2, '0');
        const segundos = String(data.getSeconds()).padStart(2, '0');
        
        return `${dia}/${mes}/${ano} ${hora}:${minutos}:${segundos}`;
    } catch (error) {
        this.logError('formatarDataHoraCompleto', error);
        return '--';
    }
}