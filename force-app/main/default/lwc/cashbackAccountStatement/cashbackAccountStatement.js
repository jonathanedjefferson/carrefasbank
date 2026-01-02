import { LightningElement, api, track } from 'lwc';
import getStatment from '@salesforce/apex/CashbackController.consultarExtrato';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CLOUD_RAIN from "@salesforce/resourceUrl/CloudRain";

const MAP_MONTHS = {
    '01' : 'Janeiro',
    '02' : 'Fevereiro',
    '03' : 'Março',
    '04' : 'Abril',
    '05' : 'Maio',
    '06' : 'Junho',
    '07' : 'Julho',
    '08' : 'Agosto',
    '09' : 'Setembro',
    '10' : 'Outubro',
    '11' : 'Novembro',
    '12' : 'Dezembro'
}

const WEEKDAY = ["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"];

const ACCOUNT_STATMENT_ICON = {
    1 : "utility:currency", 
    2 : "utility:sort", 
    3 : "utility:close", 
    4 : "utility:skip_forward",
    5 : "utility:warning",
    7 : "utility:skip_back"
}

const MAP_CASHBACK_CLASS = {
    1 : "received-cashback", 
    2 : "standard-cashback", 
    3 : "canceled-cashback", 
    4 : "received-cashback",
    5 : "standard-cashback",
    7 : "received-cashback"
}

export default class CashbackAccountStatement extends LightningElement {
    @api cpf;
    @api contractStatus;
    @track accountStatements = [];
    isLoading = true;
    isLoadingMore = true;
    disableLoadMore = false;
    hasError = false;
    hasRequestedMore = false;
    showEmptyState = false;
    emptyStateImg = CLOUD_RAIN;
    openSection;
    rawData = [];
    lastRequestedDate;

    connectedCallback() {
        this.fetchAccountStatment();
    }

    fetchAccountStatment() {
        if (this.isBlocked) {
            this.showEmptyCard(false);
            return;
        }

        const params = {
            'cpf' : this.cpf, 
            'canal' : '', 
            'unidadeNegocio' : '',
            'params' : this.buildRequestParams()
        };

        getStatment(params).then(accountStatmentData => {
            if (accountStatmentData.statusAPI != 'OK') {
                this.showEmptyCard(true);
                return;
            }

            this.formatAccountStatmentData(accountStatmentData.statements);
        })
        .catch(error => {
            this.showEmptyCard(true);
            console.error(error);
        })
    }

    buildRequestParams() {
        const endDate = new Date();

        const initDate = new Date(endDate);
        initDate.setMonth(endDate.getMonth() - 2);
        initDate.setDate(1);

        let params = {
            'initDate' : `${initDate.getFullYear()}-${String(initDate.getMonth() + 1).padStart(2, '0')}-${String(initDate.getDate()).padStart(2, '0')}T00:00:00-03:00`,
            'endDate' : `${endDate.getFullYear()}-${String(endDate.getMonth() + 1).padStart(2, '0')}-${String(endDate.getDate()).padStart(2, '0')}T23:59:59-03:00`,
            'pageSize' : 200
        };

        this.lastRequestedDate = initDate;

        return params;
    }

    formatAccountStatmentData(accountStatementData) {
        try {
            this.rawData = [...this.rawData, ...accountStatementData];
            let data = JSON.parse(JSON.stringify(this.rawData));
            const sortedAccountStatement = this.sortByDateAscending(data, 'dateReplaced');
            this.groupData(sortedAccountStatement);
        } catch (error) {
            console.error(error);
            if (this.hasRequestedMore) {
                this.isLoadingMore = false;
                this.showNotification('', 'Não foi possível carregar mais transações do Comprou Voltou do cliente.', 'error');
                return;
            }

            this.showEmptyCard(true);
        }
    }

    sortByDateAscending(array, dateKey) {
        return array.sort((firstItem, secondItem) => {
            return new Date(secondItem[dateKey]) - new Date(firstItem[dateKey]);
        });
    }

    groupData(accountStatmentData) {
        if (accountStatmentData && accountStatmentData.length <= 0) {
            this.showEmptyCard(false);
            return;
        }
        console.log('=== DADOS ANTES DO PROCESSAMENTO ===');
        console.log(accountStatmentData);

        if (accountStatmentData[0] && accountStatmentData[0].transactions) {
        console.log('=== PRIMEIRA TRANSAÇÃO ===');
        console.log(accountStatmentData[0].transactions[0]);
    }

        const groupedData = [];

        accountStatmentData.forEach(item => {

            const date = new Date(item.dateReplaced);
            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();
            const monthYear = `${month}-${year}`;

            let index = groupedData.findIndex(group => group.monthYear === monthYear);
    
            if (index < 0) {
                groupedData.push(
                    {
                        month : MAP_MONTHS[month] + ' de ' + year,
                        monthYear : monthYear,
                        groupedDays : []
                    }
                )
            }

            let currentIndex = index < 0 ? groupedData.length - 1 : index;
            let dayGroup = groupedData[currentIndex].groupedDays.find(group => group.day === day);

            const weekday = this.formatWeekday(date) + ',';
            const fullDate = day + ' de ' + MAP_MONTHS[month];
            const balance = this.formatCashback(item.balance);

            if (!dayGroup) {
                dayGroup = { day, weekday, fullDate, balance, items: [] };
                groupedData[currentIndex].groupedDays.push(dayGroup);
            }

            item.transactions.forEach(transaction => {
                if (transaction.rewardTransactionType == 6) {
                    return;
                }
                transaction.transactionDateShort = this.formatDateShort(transaction.transactionDate);
                transaction.transactionDate = this.formatDateTime(transaction.transactionDate);
                transaction.rewardAmountRaw = transaction.rewardAmount;
                transaction.rewardAmount = this.formatCashback(transaction.rewardAmount);
                transaction.purchaseAmount = transaction.purchase ? this.formatCash(transaction?.purchase?.amount) : '-';
                transaction.purchaseDate = transaction.purchase ? this.formatDate(transaction?.purchase?.dateReplaced) : '';
                transaction.purchaseDateTime = transaction.purchase ? this.formatDateTime(transaction?.purchase?.dateReplaced) : '';
                transaction.purchaseDateShort = transaction.purchase ? this.formatDateShort(transaction?.purchase?.dateReplaced) : '';
                transaction.originDescriptionDetail = transaction.originDescription;
                transaction.originDescription = transaction.purchase ? transaction.originDescription : '';
                transaction.icon = ACCOUNT_STATMENT_ICON[transaction.rewardTransactionType];
                transaction.cashbackClass = MAP_CASHBACK_CLASS[transaction.rewardTransactionType];
                transaction.lineClass = transaction.rewardTransactionType == 3 ? 'canceled-line' : '';
                
                dayGroup.items.push(transaction);
            })
        })
        
        this.openSection = groupedData[0].monthYear;
        this.accountStatements = groupedData;
        this.isLoading = false;
        this.isLoadingMore = false;
    }

    formatWeekday(aDate) {
        if (!aDate) {
            return '-';
        }

        const dateParsed = aDate.toLocaleDateString('pt-BR', {
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
        
        return dateParsed == todayParsed ? 'Hoje' : 
            dateParsed == yestedayParsed ? 'Ontem' :  
            WEEKDAY[aDate.getDay()];
    }

    formatFullDate(aDate) {
        if (!aDate) {
            return '-';
        }

        return `${String(aDate.getDate()).padStart(2, '0')} de ${MAP_MONTHS[String(aDate.getMonth() + 1).padStart(2, '0')]}`
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

    handleExpand(event) {
        const id = event.target.dataset.id;
        this.accountStatements.forEach(monthTransaction => {
            monthTransaction.groupedDays.forEach(day => {
                let singleTransaction = day.items.find(elem => elem.id === id);
                if (singleTransaction) {
                    singleTransaction.showDetails = ! singleTransaction.showDetails;
                }
            })
        })
    }

    handleLoadMore() {
        this.isLoadingMore = true;
        this.hasRequestedMore = true;
        const params = {
            'cpf' : this.cpf, 
            'canal' : '', 
            'unidadeNegocio' : '',
            'params' : this.buildRequestParamsLoadMore()
        };

        getStatment(params).then(accountStatmentData => {
            if (accountStatmentData.statusAPI != 'OK') {
                this.showNotification('', 'Não foi possível carregar mais transações do Comprou Voltou do cliente.', 'error');
                this.isLoadingMore = false;
                return;
            }

            if (accountStatmentData.hasOwnProperty('statements') && accountStatmentData.statements.length <= 0) {
                this.showNotification('', 'Não foram encontrados mais transações no extrato do usuário.', 'error');
                this.disableLoadMore = true;
                this.isLoadingMore = false;
                return;
            }

            this.formatAccountStatmentData(accountStatmentData.statements);
        })
        .catch(error => {
            this.showNotification('', 'Não foi possível carregar mais transações do Comprou Voltou do cliente.', 'error');
            this.isLoadingMore = false;
            console.error(error);
        })
    }

    buildRequestParamsLoadMore() {
        const initDate = new Date(this.lastRequestedDate);
        initDate.setMonth(this.lastRequestedDate.getMonth() - 3);
        initDate.setDate(1);

        let params = {
            'initDate' : `${initDate.getFullYear()}-${String(initDate.getMonth() + 1).padStart(2, '0')}-${String(initDate.getDate()).padStart(2, '0')}T00:00:00-03:00`,
            'endDate' : `${this.lastRequestedDate.getFullYear()}-${String(this.lastRequestedDate.getMonth() + 1).padStart(2, '0')}-${String(this.lastRequestedDate.getDate()).padStart(2, '0')}T23:59:59-03:00`,
            'pageSize' : 200
        };

        this.lastRequestedDate = initDate;

        return params;
    }

    showEmptyCard(hasError) {
        this.isLoading = false;
        this.showEmptyState = true;
        this.hasError = hasError;
        if (hasError) {
            this.dispatchEvent(new CustomEvent("error"));
        }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant, 
            mode : 'sticky'
        });

        this.dispatchEvent(evt);
    }

    get showData() {
        return this.accountStatements && this.accountStatements.length > 0 && !this.isLoading;
    }

    get message() {
        return !this.hasError ? 'Não foram encontradas transações' : 'Ops! Não conseguimos carregar as movimentações do cliente.';
    }

    get subMessage() {
        return !this.hasError ? 'Quando acontecer alguma movimentação no saldo de cashback do cliente, os dados aparecerão aqui.' 
            : 'Tente novamente mais tarde.';
    }

    get isBlocked() {
        return this.contractStatus == 'BloqueioDefinitivo';
    }
}