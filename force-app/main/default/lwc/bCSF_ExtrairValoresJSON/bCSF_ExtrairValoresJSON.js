import { LightningElement, api, track } from 'lwc';

export default class BCSF_ExtrairValoresJSON extends LightningElement {
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

    @api get automaticOutputVariables() {
        return this._automaticOutputVariables;
    }

    set automaticOutputVariables(value) {
        this._automaticOutputVariables = value;
    }

    @api inputVariables;

    get inputJSONString() {
        //return this.inputValues['Endpoint'];
        const param = this.inputVariables.find(({ name }) => name === 'inputJSONString');
        return param && param.value;
    }

    get inputJSONStringType() {
        //return this.inputValues['Endpoint'];
        const param = this.inputVariables.find(({ name }) => name === 'inputJSONString');
        return param && param.valueDataType;
    }

    get keysToExtract() {
        //return this.inputValues['Endpoint'];
        const param = this.inputVariables.find(({ name }) => name === 'keysToExtract');
        return param && param.value;
    }
    _builderContext;
    _flowVariables;

    handleFlowComboboxValueChange(event) {
        if (event && event.detail) {
            this.dispatchFlowValueChangeEvent(event.detail.id, event.detail.newValue, event.detail.newValueDataType);
        }

    }

    changekeysToExtract(event) {
        this.dispatchFlowValueChangeEvent('keysToExtract', event.detail.value, 'String');

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
}