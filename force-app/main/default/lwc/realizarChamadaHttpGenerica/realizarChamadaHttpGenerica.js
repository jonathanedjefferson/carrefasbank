import { LightningElement, track, api } from 'lwc';
//import sendCallout from "@salesforce/apex/RealizarChamadaApiGenerica.sendCallout";

const METHOD_LIST = [
    'GET',
    'POST',
    'PATCH',
    'PUT',
    'DELETE',
    'TRACE',
    'CONNECT',
    'HEAD',
    'OPTIONS'
];

export default class RealizarChamadaHttpGenerica extends LightningElement {
    @api inputVariables;
    @track data = {};

    headers = 'Headers';
    // timeout = '30000';
    params = 'Parâmetros';
    value = 'get';
    testResult; //escrever tratativa de erro

    _builderContext;
    _flowVariables;
    _automaticOutputVariables;

    get methodList() {
        return METHOD_LIST;
    }

    get errorMessage() {
        return this.errors.join('; ');
    }

    get isError() {
        return this.errors.length > 0;
    }

    get headerList() {
        const param = this.inputVariables.find(({ name }) => name === 'Headers');
        return param && param.value;

    }

    get paramList() {
        const param = this.inputVariables.find(({ name }) => name === 'Params');
        return param && param.value;
    }

    get url() {
        const param = this.inputVariables.find(({ name }) => name === 'Endpoint');
        return param && param.value;
    }

    get method() {
        const param = this.inputVariables.find(({ name }) => name === 'Method');
        return param && param.value;
    }

    get body() {
        const param = this.inputVariables.find(({ name }) => name === 'Body');
        return param && param.value;
    }

    @api get automaticOutputVariables() {
        return this._automaticOutputVariables;
    }

    set automaticOutputVariables(value) {
        this._automaticOutputVariables = value;
    }

    handleFlowComboboxValueChange(event) {
        if (event && event.detail) {
            this.dispatchFlowValueChangeEvent(event.detail.id, event.detail.newValue, event.detail.newValueDataType);
        }
    }

    dispatchFlowValueChangeEvent(id, newValue, newValueDataType) {
        const valueChangedEvent = new CustomEvent('configuration_editor_input_value_changed', {
            bubbles: true,
            cancelable: false,
            composed: true,
            detail: {
                name: id,
                newValue: newValue,
                newValueDataType: newValueDataType
            }
        });
        this.dispatchEvent(valueChangedEvent);
    }

    changeHeaders(event) {
        this.dispatchFlowValueChangeEvent('Headers', event.detail.value, 'String');
    }

    changeParams(event) {
        this.dispatchFlowValueChangeEvent('Params', event.detail.value, 'String');
    }

    changeBody(event) {
        this.dispatchFlowValueChangeEvent('Body', event.detail.value, 'String');
    }

    //---Context builder---//
    _builderContext;
    @api
    get builderContext() {
        return this._builderContext;
    }

    set builderContext(context) {
        this._builderContext = context || {};
        if (this._builderContext) {
            const { variables } = this._builderContext;
            this._flowVariables = [...variables];
        }
    }
    //---Context builder---//

    makeTestCallout() {
        this.testResult = null;
        let requestJSON = this.getRequestJSON();
    }

    getRequestJSON() {
        let request = {
            Method: this.method,
            Endpoint: this.url,
            Body: this.body,
            // Timeout: this.timeout,
            Params: this.paramList,
            Headers: this.headerList

        };
        return JSON.stringify(request);
    }


    @track errors = [];
    @api validate() {
        let validity = [];
        this.errors = [];

        if ((!this.method || !METHOD_LIST.includes(this.method.toUpperCase()))) {
            this.errors.push('Método inválido, por favor utilize alguma das opções a seguir: GET, POST, PATCH, PUT, DELETE.');
            validity.push({
                key: 'Error',
                errorString: 'Método inválido, por favor utilize alguma das opções a seguir: GET, POST, PATCH, PUT, DELETE.',
            });
        }

        return validity;
    }
}