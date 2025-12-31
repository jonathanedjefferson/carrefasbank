import LightningDatatable from 'lightning/datatable';
import tooltipTemplate from './tooltipTemplate.html';

export default class BCSF_CustomDatatableTooltip extends LightningDatatable {
    static customTypes = {
        customTextTooltip: {
            template: tooltipTemplate,
            standardCellLayout: true,
            typeAttributes: ['value']
        }
    };
}