import {api, LightningElement} from 'lwc';

const FILES_UPLOADED_EVENT_TYPE = "filesuploaded";

export default class FileUploader extends LightningElement {
    @api uploadButtonLabel = 'Upload files';
    @api acceptedMimeTypes;

    handleFilesUploaded(event) {
        this.dispatchEvent(new CustomEvent(FILES_UPLOADED_EVENT_TYPE, {
            detail: { files: event.target.files }
        }));
    }
}