import { LightningElement, api, track } from 'lwc';
import getFutureTransactions from '@salesforce/apex/CashbackController.consultarTransacoesFuturas';
import CLOUD_RAIN from "@salesforce/resourceUrl/CloudRain";

export default class CashbackFutureReleases extends LightningElement {
    @api cpf;
    @api contractStatus;
    @track futureReleases = [];
    isLoading = true;
    showError = false;
    errorImg = CLOUD_RAIN;

    connectedCallback() {
        this.fetchFutureTransactions();
    }

    fetchFutureTransactions() {
        if (this.isBlocked) {
            this.showErrorCard(false);
            return;
        }

        getFutureTransactions({'cpf' : this.cpf, 'canal' : '', 'unidadeNegocio' : ''}).then(futureTransactionData => {
            if (futureTransactionData.statusAPI != 'OK') {
                this.showErrorCard();
                return;
            }

            this.formatFutureTransactionsData(futureTransactionData);
        })
        .catch(error => {
            this.showErrorCard();
            console.error(error);
        })
    }

    formatFutureTransactionsData(futureTransactionData) {
        try {
            const sortedTransactions = this.sortByDateAscending(futureTransactionData.futureTransactions, 'rewardReleaseDate');
            this.formatInLineData(sortedTransactions);
        } catch (error) {
            console.error(error);
            this.showErrorCard();
        }
    }

    sortByDateAscending(array, dateKey) {
        return array.sort((firstItem, secondItem) => {
            return new Date(secondItem[dateKey]) - new Date(firstItem[dateKey]);
        });
    }

    formatInLineData(futureTransactions) {
        if (futureTransactions && futureTransactions.length <= 0) {
            this.isLoading = false;
            return;
        }

        futureTransactions.forEach(item => {
            item.purchase.amount = this.formatCash(item?.purchase?.amount);
            item.purchaseDateTime = this.formatDateTime(item?.purchase?.dateReplaced);
            item.purchase.dateReplacedShort = this.formatDateShort(item?.purchase?.dateReplaced);
            item.purchase.dateReplaced = this.formatDate(item?.purchase?.dateReplaced);
            item.rewardAmount = this.formatCashback(item.rewardAmount);
        });

        this.futureReleases = futureTransactions;
        this.isLoading = false;
    }

    formatCash(aValue) {
        if (!aValue && aValue != 0) {
            return '-';
        }

        const valueReplaced = aValue.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        return `R$ ${valueReplaced}`;
    }

    formatCashback(aValue) {
        if (!aValue && aValue != 0) {
            return '-';
        }

        const valueReplaced = aValue.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        return `CB$ ${valueReplaced}`;
    }

    formatDate(aDate) {
        if (!aDate) {
            return '-';
        }

        const parsedDate = new Date(aDate);
        return parsedDate.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
        });
    }

    formatDateTime(dateString) {
        if (!dateString) {
            return '-';
        }

        const date = new Date(dateString);
        
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const seconds = String(date.getSeconds()).padStart(2, '0');
        
        return `${day}/${month}/${year} às ${hours}:${minutes}:${seconds}`;
    }

    formatDateShort(aDate) {
        if (!aDate) {
            return '-';
        }

        const transactionDate = new Date(aDate);
        const dateParsed = transactionDate.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
        });

        const today = new Date();
        const todayParsed = today.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
        });
        
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        const yestedayParsed = yesterday.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
        });

        if (dateParsed == todayParsed) {
            return 'Hoje';
        }

        if (dateParsed == yestedayParsed) {
            return 'Ontem';
        }

        return transactionDate.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit'
        });
    }
    
    showErrorCard(dispatchError = true) {
        this.isLoading = false;
        this.showError = true;
        if (dispatchError) {
            this.dispatchEvent(new CustomEvent("error"));
        }
    }

    handleExpand(event) {
        const id = event.target.dataset.id;

        let singleTransaction = this.futureReleases.find(elem => elem.id === id);
        if (singleTransaction) {
            singleTransaction.showDetails = ! singleTransaction.showDetails;
        }
    }

    get showData() {
        return this.futureReleases && this.futureReleases.length > 0 && !this.isLoading;
    }

    get message() {
        return 'Ops! Não conseguimos carregar as movimentações do cliente.';
    }

    get subMessage() {
        return 'Tente novamente mais tarde.';
    }

    get isBlocked() {
        return this.contractStatus == 'BloqueioDefinitivo';
    }
}