import { LightningElement, api } from 'lwc';

export default class EngagementSummaryModal extends LightningElement {
    @api recordId; // Account ID passed from the button

    handleClose() {
        // Close the modal by dispatching a close event
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }
}