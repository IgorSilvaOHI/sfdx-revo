import { LightningElement, api } from 'lwc';

export default class HeaderTab extends LightningElement {

    @api selected;
    @api label;

    get selectedClass()
    {
        return this.selected ? 'selected' : '';
    }
}