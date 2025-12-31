import { LightningElement, track, api } from 'lwc';
import getBalance from '@salesforce/apex/CashbackController.consultarSaldosNativos';
import updateCustomerBalance from '@salesforce/apex/CashbackController.updateCustomerBalance';

export default class CashbackBalance extends LightningElement {
    @api cpf;
    @api contractStatus;
    @track balanceData = {};
    isLoading = true;

    connectedCallback() {
        this.fetchBalanceData();
    }

    fetchBalanceData() {
        if (this.isBlocked) {
            this.setBlankValues(false);
            return;
        }

        getBalance({'cpf' : this.cpf, 'canal' : '', 'unidadeNegocio' : ''}).then(balanceData => {
            if (balanceData.statusAPI != 'OK') {
                this.setBlankValues();
                return;
            }

            this.updateBalance(balanceData);
            this.formatBalanceData(balanceData);
        }).catch(error => {
            this.setBlankValues();
            console.error(error);
        })
    }

    updateBalance(balanceData) {
        const params = {
            'cpf' : this.cpf,
            'rewardPoints' : balanceData.rewardPoints,
            'expireDate' : balanceData.expireDate
        }
        
        updateCustomerBalance({'aBalanceData' : params}).then(() => {
            console.log('Saldo e Validade atualizados com sucesso!');
        })
        .catch(error => {
            console.error(error);
        })
    }

    formatBalanceData(balanceData) {
        balanceData.rewardPoints = this.formatBalanceAmout(balanceData.rewardPoints);
        balanceData.expireDate = this.formatExpirationDate(balanceData.expireDate);
        
        this.balanceData = balanceData;
        this.isLoading = false;
    }

    formatBalanceAmout(rewardPoints) {
        if (!rewardPoints && rewardPoints != 0) {
            return '-';
        }
        
        return 'CB$ ' + rewardPoints.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    formatExpirationDate(expireDate) {
        if (!expireDate) {
            return '-';
        }

        const parsedDate = new Date(expireDate);
        return parsedDate.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
        });
    }

    setBlankValues(dispatchError = true) {
        this.balanceData.rewardPoints = '-';
        this.balanceData.expireDate = '-';
        this.balanceData.daysToExpire = null;
        this.isLoading = false;
        if (dispatchError) {
            this.dispatchEvent(new CustomEvent("error"));
        }
    }

    get showCloseExpiration() {
        return this.balanceData && this.balanceData.daysToExpire && this.balanceData.daysToExpire <= 7;
    }

    get isBlocked() {
        return this.contractStatus == 'BloqueioDefinitivo';
    }
}