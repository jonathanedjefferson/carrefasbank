import { LightningElement, api } from 'lwc';

export default class CustomTextCard extends LightningElement {
    @api text = '';
    @api height = '';
    @api width = '';
    @api backgroundColor = '';
    @api fontColor = '';
    @api fontStyle = '';
    @api fontSize = '';
    @api iconColor = '';
    @api iconName = '';

    renderedCallback() {
        const textContainer = this.template.querySelector("[data-id=\"text\"]");
        textContainer.style = `
            height: ${this.height}; 
            width: ${this.width}; 
            background-color: ${this.backgroundColor}; 
            color: ${this.fontColor};
            font-weight: ${this.fontStyle};
            font-size: ${this.fontSize};
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 1%;`

        const icon = this.template.querySelector("lightning-icon");
        icon.style = `
            --sds-c-icon-color-foreground-default: ${this.iconColor};
            margin-right: 10px;
            margin-left: 10px`;
    }

    get hasIcon() {
        return this.iconName;
    }
}