import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import cashbackPurchaseDetailsModal from 'c/cashbackPurchaseDetailsModal';
import cashbackRefundModal from 'c/cashbackRefundModal';

const EXPIRED_MESSAGE = 'O cliente pode utilizar o saldo em todas as lojas Atacadão, Carrefour, Sams Club, ' + 
'Postos e Farmácias Carrefour, além de todas as plataformas digitais das marcas.';

const DETAIL_FIELD = {
    2 : [ //Resgate
        {
            "label" : "Tipo de Transação",
            "field" : 'rewardTransactionTypeDescription'
        },
        {
            "label" : "Cashback Resgatado",
            "field" : 'rewardAmount'
        },
        {
            "label" : "Loja do Resgate",
            "field" : 'originDescriptionDetail'
        },
        {
            "label" : "Data do Resgate",
            "field" : 'transactionDate'
        }
    ],
    3 : [ //Cashback cancelado
        {
            "label" : "Tipo de Transação",
            "field" : 'rewardTransactionTypeDescription'
        },
        {
            "label" : "Cashback Cancelado",
            "field" : 'rewardAmount'
        },
        {
            "label" : "Loja",
            "field" : 'originDescriptionDetail'
        },
        {
            "label" : "Data do Cancelamento",
            "field" : 'transactionDate'
        }
    ],
    7 : [ //Contestação de resgate
        {
            "label" : "Tipo de Transação",
            "field" : 'rewardTransactionTypeDescription'
        },
        {
            "label" : "Valor da Contestação",
            "field" : 'rewardAmount'
        },
        {
            "label" : "Loja",
            "field" : 'originDescriptionDetail'
        },
        {
            "label" : "Data da Execução",
            "field" : 'transactionDate'
        }
    ],
    4 : [ //Ajuste de cashback
        {
            "label" : "Tipo de Transação",
            "field" : 'rewardTransactionTypeDescription'
        },
        {
            "label" : "Valor do ajuste",
            "field" : 'rewardAmount'
        },
        {
            "label" : "Data do ajuste",
            "field" : 'transactionDate'
        }
    ],
    5 : [//Cashback expirado
        {
            "label" : "Tipo de Transação",
            "field" : 'rewardTransactionTypeDescription'
        },
        {
            "label" : "Cashback Expirado",
            "field" : 'rewardAmount'
        },
        {
            "label" : "Data da Expiração",
            "field" : 'transactionDate'
        }
    ],
    8 : [// Cashback Estornado
        {
            "label" : "Tipo de Transação",
            "field" : 'rewardTransactionTypeDescription'
        },
        {
            "label" : "Cashback Estornado",
            "field" : 'rewardAmount'
        },
        {
            "label" : "Data da Execução",
            "field" : 'transactionDate'
        },
    {
            "label" : "Loja",
            "field" : 'originDescription'
        }

    ]
}

export default class CashbackAccountStatementDetail extends NavigationMixin(LightningElement) {
    @api detail;
    @api cpf;
    message = EXPIRED_MESSAGE;
    customCard = [];

    connectedCallback() {
        this.buildCustomCard();
    }
    
    buildCustomCard() {
        const valueSet = DETAIL_FIELD[this.detail.rewardTransactionType];
        if (!valueSet) {
            return;
        }

        valueSet.forEach(elem => {
            elem.value = this.detail[elem.field];
        });

        this.customCard = valueSet;
    }

    async handlePurchaseDetails() {
        const result = await cashbackPurchaseDetailsModal.open({
            size: 'medium',
            description: 'Modal para exibição dos Detalhes da Compra',
            detail: {
                'cpf' : this.cpf,
                'transactionDetail' : this.detail
            }
        });
    }

    async handleRefund() {
        const result = await cashbackRefundModal.open({
            size: 'medium',
            description: 'Modal para solicitação de reembolso',
            detail: {
                'type': 'refund',
                'cpf' : this.cpf,
                'transactionDetail' : this.detail
            }
        });

        if (result.eventType == 'close') {
            return;
        }

        this.redirectToRecord(result.recordId);
    }

    async handleReversal() {
        const result = await cashbackRefundModal.open({
            size: 'medium',
            description: 'Modal para solicitação de estorno',
            detail: {
                'type': 'reversal',
                'cpf' : this.cpf,
                'transactionDetail' : this.detail
            }
        });

        if (result.eventType == 'close') {
            return;
        }

        this.redirectToRecord(result.recordId);
    }

    redirectToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    get isCashbackReceived() {
        return this.detail.rewardTransactionType == 1;
    }

    get isCashbackRefunded() {
        return this.detail.rewardTransactionType == 8;
    }

    get showMessage() {
        return this.detail.rewardTransactionType == 5;
    }

    get isRedeem() {
        return this.detail.rewardTransactionType == 2;
    }
}