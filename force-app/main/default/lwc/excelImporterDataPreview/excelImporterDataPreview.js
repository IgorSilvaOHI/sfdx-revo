import { LightningElement, api } from 'lwc';

export default class XlsxUploaderDataPreview extends LightningElement {
    @api fileName;
    @api sheets;
    @api previewRows = 5;

    FILENAME_TITLE = 'Filename';

    previewData;
    currentId = 0;

    connectedCallback() {
        this.preparePreview();
    }

    preparePreview() {
        if (!this.sheets) {
            return;
        }
        this.previewData = this.sheets.map(sheet => this.prepareSheetPreview(sheet));
    }

    prepareSheetPreview(sheet) {
        const id = this.currentId++;
        const label = this.buildLabel(sheet);
        const data = sheet.data.slice(0, sheet.data.length);
        const columns = this.extractColumns(sheet)
        return {id, label, data, columns};
    }

    buildLabel(sheet) {
        const numberOfRows = sheet.data.length;
        return `${sheet.name} (${numberOfRows} row${numberOfRows === 1 ? '' : 's'})`
    }

    extractColumns(sheet) {
        if (!sheet.data.length) {
            return [];
        }
        return Object.keys(sheet.data[0])
            .map(key => ({
                label: key,
                fieldName: key,
                hideDefaultActions: true,
                initialWidth: 200
            }));
    }
}