import { api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningModal from 'lightning/modal';
import consultarDetalhesTransacao from '@salesforce/apex/CashbackController.consultarDetalhesTransacao';
import ATACADAO_LOGO from "@salesforce/resourceUrl/LogoAtacadao";
import CARREFOUR_LOGO from "@salesforce/resourceUrl/LogoCarrefour";
import SAMS_CLUB_LOGO from "@salesforce/resourceUrl/LogoSamsClub";
import CLOUD_RAIN from "@salesforce/resourceUrl/CloudRain";

const MAP_LOGOS = {
    1: CARREFOUR_LOGO, 
    2: ATACADAO_LOGO, 
    6: SAMS_CLUB_LOGO
}

export default class CashbackPurchaseDetailsModal extends LightningModal  {
    @api detail;
    purchaseDetail;
    @track products;
    @track unfilteredProducts;
    @track unsortedProducts;
    logoImg;
    queryTerm;
    emptyStateImg = CLOUD_RAIN;
    isLoading = true;
    hasError = false;
    sortedProducts = false;

    connectedCallback() {
        this.fetchPurchaseDetails();
    }

    fetchPurchaseDetails() {
        let params = {
            'cpf' : this.detail.cpf,
            'canal' : '',
            'unidadeNegocio' : '',
            'idTransacao' : this.detail.transactionDetail.id,
        }

        consultarDetalhesTransacao(params).then(response => {
            if (response.statusAPI != 'OK') {
                this.showEmptyState();
            }

            this.formatPurchaseDetail(response);
        })
        .catch(error => {
            this.showEmptyState();
            console.error(error);
        })
    }

    formatPurchaseDetail(purchaseDetail) {
       try {
            this.formatData(purchaseDetail);
       } catch (error) {
            this.showEmptyState();
            console.error(error);
       }
    }

    showEmptyState() {
        this.isLoading = false;
        this.logoImg = null;
        this.purchaseDetail = {
            originDescription: '-',
            purchaseRewardNumberItems: '-',
            purchaseDateReplaced: '-',
            purchaseAmount: '-'
        }

        this.products = [];
        this.unfilteredProducts = [];
        this.hasError = true;
        this.showNotification('', 'Não foi possível carregar os detalhes da compra do cliente.', 'error');
    }

    formatData(purchaseDetail) {
        this.logoImg = MAP_LOGOS[purchaseDetail.buId];

        purchaseDetail.originDescription = purchaseDetail.originDescription.toUpperCase();
        purchaseDetail.purchaseRewardNumberItems = this.formatItemQuantity(purchaseDetail.purchaseRewardNumberItems);
        purchaseDetail.purchaseDateReplaced = this.formatDateTime(purchaseDetail?.purchase?.dateReplaced);
        purchaseDetail.purchaseAmount = this.formatCash(purchaseDetail?.purchase?.amount);
        let itemsArray = purchaseDetail?.purchase?.items || [];
        itemsArray.forEach(item => {
            item.purchaseAmount = this.formatCash(item.purchaseAmount);
            item.rewardAmount = this.formatCashback(item.rewardAmount);
            item.promotion = item.rewardDescription;
        })

        this.purchaseDetail = purchaseDetail;
        this.products = itemsArray;
        this.unfilteredProducts = itemsArray;
        this.unsortedProducts = [...itemsArray];
        this.isLoading = false;
    }

    formatItemQuantity(quantity) {
        if (!quantity) {
            return '-';
        }

        let sufix = quantity == 1 ? 'Item' : 'Itens';

        return `${quantity} ${sufix}`;
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

    formatCash(aValue) {
        if (!aValue) {
            return '-';
        }

        const valueReplaced = aValue.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        return `R$ ${valueReplaced}`;
    }

    formatCashback(aValue) {
        if (!aValue) {
            return '-';
        }

        const valueReplaced = aValue.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        return `+ CB$ ${valueReplaced}`;
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

    handleSort() {
        if (!this.sortedProducts) {
            this.products.sort((firstItem, secondItem) => {
                let firstValue = firstItem['itemDescription'].toString().toLowerCase();
                let secondValue = secondItem['itemDescription'].toString().toLowerCase();
                return firstValue.localeCompare(secondValue);
            });
            this.sortedProducts = !this.sortedProducts;
            return;
        }

        this.products = [...this.unsortedProducts];
        this.sortedProducts = !this.sortedProducts;        
    }

    handleSearch(event) {
        if(this.unfilteredProducts.length < 0) {
            return;
        }

        const insertedTerm = event.target.value;

        if (!insertedTerm) {
            this.products = this.unfilteredProducts;
        }

        this.queryTerm = event.target.value;
        this.products = this.filterProductsBySearch(this.queryTerm);
    }

    filterProductsBySearch(searchTerm) {   
        const lowerCaseSearchTerm = searchTerm.toLowerCase();
        return this.unfilteredProducts.filter(item => item.itemDescription.toLowerCase().includes(lowerCaseSearchTerm));
    }

    handleOkay() {
        this.close('okay');
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode : 'sticky'
        });

        document.dispatchEvent(evt);
    }

    handleConsultarOfertas() {
        const url = '/lightning/n/Ofertas_ComprouVoltou';
        window.open(url, '_blank');
    }

    get showData() {
        return this.purchaseDetail && !this.isLoading;
    }
    
    get hasProducts() {
        return this.products && this.products.length > 0 && !this.isLoading;
    }

    get message() {
        return !this.hasError ? 'Não foram encontrados produtos na pesquisa.' : 'Ops! Não conseguimos carregar os produtos da compra do cliente.';
    }

    get subMessage() {
        return !this.hasError ? 'Tente usar palavras que podem estar no nome do produto.' : 'Tente novamente mais tarde.';
    }
}