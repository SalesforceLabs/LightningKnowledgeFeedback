import { LightningElement, api, track } from 'lwc';
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
	@track isLoading = false;

	connectedCallback() {
		this.relatedListRecords();
	}

	get recordCount() {
		return this.totalNumberOfRecords;
	}

	get showTable() {
		return this.renderedFeedbackRecordList.length > 0;
	}

	get setDatatableHeight() {
		if (this.renderedFeedbackRecordList.length > 8) {
			return 'height:300px;';
		}
		return '';
	}

	relatedListRecords() {
        this.isLoading = true;
		getRelatedFeedback({ kavId: this.recordId })
			.then(response => {
				response = JSON.parse(response.jsonResponse);
				response.forEach(record => {
					record.linkName = '/' + record.Id;
					record.Assigned_To = record.Assigned_To__r !== undefined ? record.Assigned_To__r.Name : '';
				});
				this.totalNumberOfRecords = response.length;
				this.allFeedbackRecordList = [...this.allFeedbackRecordList, ...response];
				this.renderedFeedbackRecordList = this.allFeedbackRecordList.slice(0, this.numberOfRecordsDisplayed);
				this.isLoading = false;
			})
			.catch(error => {
				console.error(error);
				this.allFeedbackRecordList = [];
				this.renderedFeedbackRecordList = [];
				this.isLoading = false;
			});
	}

	loadRecords() {
		this.numberOfRecordsDisplayed = this.numberOfRecordsDisplayed > this.totalNumberOfRecords ? this.totalNumberOfRecords : this.numberOfRecordsDisplayed;
		this.renderedFeedbackRecordList = this.allFeedbackRecordList.slice(0, this.numberOfRecordsDisplayed);
		if (this.targetDatatable) {
			this.targetDatatable.isLoading = false;
		}
		if (this.targetDatatable && this.renderedFeedbackRecordList.length >= this.allFeedbackRecordList.length) {
			this.targetDatatable.enableInfiniteLoading = false;
		}
	}

	handleLoadMore(event) {
		event.preventDefault();
		this.numberOfRecordsDisplayed += 15; // increase counter by 15
		event.target.isLoading = true;
		this.targetDatatable = event.target;
		this.loadRecords();
	}
}