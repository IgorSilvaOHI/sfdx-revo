/* eslint-disable no-console */
import {
    LightningElement,
    wire
} from 'lwc';
import {
    getRecord
} from 'lightning/uiRecordApi';
import ACCOUNT_ID from '@salesforce/schema/User.Contact.AccountId';
import LANGUAGE from '@salesforce/schema/User.LanguageLocaleKey';

import Id from '@salesforce/user/Id';

export default class MiscGetUserId extends LightningElement {
    userId = Id;

    @wire(getRecord, {
        recordId: '$userId',
        fields: [ACCOUNT_ID, LANGUAGE]
    })
    wiredUser({
        error,
        data
    }) {
        if (data) {
            let contact = data.fields.Contact;
            let accountId;
            let bloquearSolicitacao;
            if (contact.value) {
                accountId = contact.value.fields.AccountId.value;
                bloquearSolicitacao = contact.value.fields.Account.value.fields.BloquearSolicitacaoVoo__c.value;
            }
            let currentUser = {
                id: this.userId,
                accountId,
                bloquearSolicitacao,
                language: data.fields.LanguageLocaleKey
            }
            const currentUserDefinedEvent = new CustomEvent('currentuserdefined', {
                detail: currentUser
            });
            this.dispatchEvent(currentUserDefinedEvent);
        } else if (error) {
            console.error(error)
            this.error = error;
        }
    }
    record;
}