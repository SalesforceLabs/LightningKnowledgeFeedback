import { LightningElement, api, track, wire } from 'lwc';
import getRelatedFeedback from '@salesforce/apex/afl_RelatedFeedbackCtrl.getRelatedFeedback';
import FeedbackObject from '@salesforce/schema/afl_Article_Feedback__c';
import SOURCE_FIELD from '@salesforce/schema/afl_Article_Feedback__c.Feedback_Source__c';
import STATUS_FIELD from '@salesforce/schema/afl_Article_Feedback__c.Feedback_Status__c';
import REASON_FIELD from '@salesforce/schema/afl_Article_Feedback__c.Feedback_Reason__c';


const columns = [
	{ label: 'Name', fieldName: 'linkName', type: 'url', hideDefaultActions: true, typeAttributes: { label: { fieldName: 'Name' }, target: '_parent' } },
	{ label: 'Feedback Source', fieldName: SOURCE_FIELD.fieldApiName, hideDefaultActions: true },
	{ label: 'Status', fieldName: STATUS_FIELD.fieldApiName, hideDefaultActions: true },
	{ label: 'Feedback Reason', fieldName: REASON_FIELD.fieldApiName, hideDefaultActions: true },
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
	@track loadMoreRecords = true;

	connectedCallback() {
		this.relatedListRecords();
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

	handleRefresh() {
		//reset variables
		this.renderedFeedbackRecordList = [];
		this.numberOfRecordsDisplayed = 15;
		this.relatedListRecords();
	}

	relatedListRecords() {
		this.isLoading = true;
		getRelatedFeedback({ kavId: this.recordId })
			.then(response => {
				response = JSON.parse(response.jsonResponse);
				response.forEach(record => {
					record.linkName = '/' + record.Id;
					if (record.afl__Assigned_To__r) {
						record.Assigned_To = record.afl__Assigned_To__r !== undefined ? record.afl__Assigned_To__r.Name : '';
					} else {
						record.Assigned_To = record.Assigned_To__r !== undefined ? record.Assigned_To__r.Name : '';
					}	
				});
				this.totalNumberOfRecords = response.length;
				this.allFeedbackRecordList = [...response];
				this.renderedFeedbackRecordList = this.allFeedbackRecordList.slice(0, this.numberOfRecordsDisplayed);
				this.isLoading = false;
				this.loadMoreRecords = true;
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
			this.loadMoreRecords = false;
			this.targetDatatable.isLoading = false;
		}
	}

	handleLoadMore(event) {
		event.preventDefault();
		this.numberOfRecordsDisplayed += 15; // increase counter by 15
		this.loadMoreRecords = true;
		event.target.isLoading = true;
		this.targetDatatable = event.target;
		this.loadRecords();
	}
}