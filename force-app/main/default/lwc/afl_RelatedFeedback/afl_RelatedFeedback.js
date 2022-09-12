import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedFeedback from '@salesforce/apex/afl_RelatedFeedbackCtrl.getRelatedFeedback';

const columns = [
	{ label: 'Name', fieldName: 'linkName', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'Name' }, target: '_parent' } },
	{ label: 'Feedback Source', fieldName: 'Feedback_Source__c', hideDefaultActions: true },
	{ label: 'Status', fieldName: 'Feedback_Status__c', hideDefaultActions: true },
	{ label: 'Feedback Reason', fieldName: 'Feedback_Reason__c', hideDefaultActions: true },
	{ label: 'Assigned To', fieldName: 'Assigned_To', hideDefaultActions: true }
];

export default class Afl_RelatedFeedback extends LightningElement {
	@api recordId;
	columns = columns;
	renderedFeedbackRecordList = []; // list of records displayed in the datatable
	allFeedbackRecordList = []; // list of all related feedback records
	numberOfRecordsDisplayed = 15;
	totalNumberOfRecords = 0;
	targetDatatable;
	_wiredPropData;
	lastModifiedDate;
	@track knowledge;
	@track isLoading = false;
	@track loadMoreRecords = true;

	//reloads the data table if the knowledge article is updated
	@wire(getRecord, { recordId: '$recordId', layoutTypes: ['Compact'] })
	getknowledgeRecord({ data, error }) {
		if (data) {
			this.knowledge = data;
			if (!this.lastModifiedDate) {
				this.lastModifiedDate = this.knowledge.lastModifiedDate;
			}
			if (this.knowledge.lastModifiedDate !== this.lastModifiedDate && this.lastModifiedDate !== undefined) {
				refreshApex(this._wiredPropData).then(() => {
					this.relatedListRecords;
				});
			}
		} else if (error) {
			console.error(error);
			this.showToast(JSON.stringify(error));
		}
	}

	connectedCallback() {
		this.relatedListRecords;
	}

	get recordCount() {
		return this.totalNumberOfRecords;
	}

	get setDatatableHeight() {
		if (this.renderedFeedbackRecordList.length > 8) {
			return 'height:300px;';
		}
		return '';
	}

	@wire(getRelatedFeedback, { kavId: '$recordId' })
	relatedListRecords(wireResult) {
		this.isLoading = true;
		this.renderedFeedbackRecordList = [];
		this._wiredPropData = wireResult;
		let { data, error } = wireResult;
		if (data) {
			this.numberOfRecordsDisplayed = 15;
			data = JSON.parse(data.jsonResponse);
			data.forEach(record => {
				record.linkName = '/' + record.Id;
				record.Assigned_To = record.Assigned_To__r !== undefined ? record.Assigned_To__r.Name : '';
			});
			this.totalNumberOfRecords = data.length;
			this.allFeedbackRecordList = [...data];
			this.renderedFeedbackRecordList = this.allFeedbackRecordList.slice(0, this.numberOfRecordsDisplayed);
			this.isLoading = false;
			this.loadMoreRecords = true;
		} else if (error) {
			this.allFeedbackRecordList = [];
			this.renderedFeedbackRecordList = [];
			this.isLoading = false;
			console.error(error);
			this.showToast(JSON.stringify(error));
		}
	}

	handleLoadMore(event) {
		event.preventDefault();
		this.loadMoreRecords = true;
		this.numberOfRecordsDisplayed += 15; // increase counter by 15
		event.target.isLoading = true;
		this.targetDatatable = event.target;
		this.loadRecords();
	}

	loadRecords() {
		this.numberOfRecordsDisplayed = this.numberOfRecordsDisplayed > this.totalNumberOfRecords ? this.totalNumberOfRecords : this.numberOfRecordsDisplayed;
		this.renderedFeedbackRecordList = this.allFeedbackRecordList.slice(0, this.numberOfRecordsDisplayed);
		if (this.targetDatatable) {
			this.targetDatatable.isLoading = false;
		}
		if (this.targetDatatable && this.renderedFeedbackRecordList.length >= this.allFeedbackRecordList.length) {
			this.loadMoreRecords = false;
			this.targetDatatable.isLoading = false;
		}
	}

	showToast(message) {
		const event = new ShowToastEvent({
			title: 'Error',
			message: message,
			variant: 'error',
			mode: 'pester'
		});
		this.dispatchEvent(event);
	}
}