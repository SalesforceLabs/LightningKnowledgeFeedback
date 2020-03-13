/* eslint-disable no-console */
import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import cardTitle from '@salesforce/label/c.Was_this_article_helpful';
import chooseGeneralReason from '@salesforce/label/c.Choose_a_general_reason';
import description from '@salesforce/label/c.Description';
import descriptionPlaceholder from '@salesforce/label/c.Description_placeholder';
import submit from '@salesforce/label/c.Submit_button';
import noInfoTitle from '@salesforce/label/c.No_information_title';
import appropriateRecPage from '@salesforce/label/c.Appropriate_record_page_message';
import rateTheArticleToast from '@salesforce/label/c.Rate_the_article_toast';
import provideaDescriptionToast from '@salesforce/label/c.Provide_a_description_toast';
import feedbackSavedToast from '@salesforce/label/c.Feedback_saved_toast';

import getVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.getVote';
import upsertThumbArticleVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.upsertThumbArticleVote';
import FeedbackObject from '@salesforce/schema/afl_Article_Feedback__c';

export default class Afl_ArticleThumbVote extends LightningElement {
    invalidRecordId = false;

    @api recordId;
    @api alwaysDisplayFeedbackDescription;
    @api ratingRequired;
    @api descriptionRequired;

    @track liked = false;
    @track disliked = false;
    @track reasonTypeOptions = [];
    @track reasonType;
    @track controlValues;
    @track selectedValue;
    savedVote = '';
    activePositiveValues; activeNegativeValues;
    allValues;
    reasonTypeOptions;
    voteReasonDescription;
    showHideFeedback;
    hasNoRate = false;
    isSameVote = false;
    showHideSpinner = 'slds-hide';

    totalDependentValues = [];
    
     // Account object info
     @wire(getObjectInfo, { objectApiName: FeedbackObject  })
     objectInfo;

     // Picklist values based on record type
     @wire(getPicklistValuesByRecordType, { objectApiName: FeedbackObject, recordTypeId: '$objectInfo.data.defaultRecordTypeId'})
     reasonPicklistValues({error, data}) {
        
         if (data) {
            this.controlValues = data.picklistFieldValues.Unlike_Reason__c.controllerValues;
            // Unlike Reason dependent Field Picklist values
            this.totalDependentValues = data.picklistFieldValues.Unlike_Reason__c.values;

            this.refreshValuesByLikeOrDislike();
         }
         else if (error) {
             this.error = JSON.stringify(error);
         }
     }

    label = {
        cardTitle,
        chooseGeneralReason,
        description,
        descriptionPlaceholder,
        submit,
        noInfoTitle,
        appropriateRecPage,
        rateTheArticleToast,
        provideaDescriptionToast,
        feedbackSavedToast
    };

    connectedCallback() {
        if (!this.validateRecordId()) {
            this.invalidRecordId =true;
            return;
        }
        
        if (this.alwaysDisplayFeedbackDescription === false) {
            this.showHideFeedback = 'slds-hide';
        }

        this.getUserVote();
    }

    getUserVote() {
        getVote({recordId : this.recordId})
        .then(response => {
            const parsedVote = JSON.parse(response.jsonResponse);
            if (parsedVote.vote === 'true') {
                this.liked = true;
                this.disliked = false;
                this.savedVote = '5';
            } else if (parsedVote.vote === 'false') {
                this.liked = false;
                this.disliked = true;
                this.savedVote = '1';

                this.showHideFeedback = 'slds-show';
            }
            this.selectedValue = parsedVote.feedbackReason;
            this.refreshValuesByLikeOrDislike();
        })
        .catch(error => {
            this.liked = false;
            this.disliked = false;
            console.log(error);
        });
    }

    refreshValuesByLikeOrDislike() {
        let initialOptions = [];
        if (this.liked) {
            this.setLikeValues();
        } else {
            if (this.disliked) {
                this.setDislikeValues();
            } else {
                this.totalDependentValues.forEach(key => {
                    initialOptions.push({
                        label : key.label,
                        value: key.value
                    })
                });
                this.reasonTypeOptions = initialOptions;
                this.reasonType = initialOptions[0] ? initialOptions[0].value : '';
            }
        }
        
        if (this.selectedValue !== '') {
            this.reasonType = this.selectedValue;
        }
    }

    validateRecordId() {
		if (this.recordId) {
			const prefix = this.recordId.substring(0, 2);
			if (prefix === "ka") {
                return true;
            }
        }
        return false;
    }

    handleToggleLike() {
        this.liked = true;
        this.disliked = false;
        this.showHideFeedback = 'slds-show';
        this.setLikeValues();
    }

    setLikeValues() {
        let dependValues = [];
        // filter the total dependent values based on Like value 
        this.totalDependentValues.forEach(conValues => {
            if (conValues.validFor.includes(this.controlValues['Thumbs_up'])) {
                dependValues.push({
                    label: conValues.label,
                    value: conValues.value
                })
            }
        })
        this.reasonTypeOptions = dependValues;
        this.reasonType = dependValues[0] ? dependValues[0].value : '';
    }

    handleReasonChange(event) {
        const selectedOption = event.detail.value;
        this.reasonType = selectedOption;
    }

    handleToggleDislike() {
        this.liked = false;
        this.disliked = true;
        this.showHideFeedback = 'slds-show';
        this.setDislikeValues();
    }

    setDislikeValues() {
        let dependValues = [];
        // filter the total dependent values based on Dislike value 
        this.totalDependentValues.forEach(conValues => {
            if (conValues.validFor.includes(this.controlValues['Thumbs_down'])) {
                dependValues.push({
                    label: conValues.label,
                    value: conValues.value
                })
            }
        })
        this.reasonTypeOptions = dependValues;
        this.reasonType = dependValues[0] ? dependValues[0].value : '';
    }

    handleClick() {
		// Check if component rating is required
		if (this.ratingRequired === true) {
			if (!this.liked && !this.disliked) {
				this.showToast('ERROR', 'ERROR', rateTheArticleToast, 'pester');
				return;
			}
        }
        
        this.voteReasonDescription = this.template.querySelector('lightning-textarea').value;

        if (this.descriptionRequired === true) {
            if ((this.voteReasonDescription === undefined || this.voteReasonDescription === '') && this.disliked === true) {
                this.showToast('ERROR', 'ERROR', provideaDescriptionToast, 'pester');
                return;
            }
        }

		// Prevent user from voting the same again
		if ((this.savedVote === '5' && this.liked === true) || (this.savedVote === '1' && this.disliked === true)) {
			this.isSameVote = true;
		}
		this.showHideSpinner = 'slds-show';

		if (!this.ratingRequired && !this.liked && !this.disliked) {
			this.hasNoRate = true;
		}

        upsertThumbArticleVote({
			recordId : this.recordId,
			feedbackReason : this.reasonType,
			voteDescription : this.voteReasonDescription,
			isLiked : this.liked,
			isSameVote : this.isSameVote,
			hasNoRate : this.hasNoRate
		})
        .then(response => {
            if (response.state === 'SUCCESS') {
                this.voteReasonDescription = "";
                this.savedVote = this.liked ? '5' : '1';
                this.showHideSpinner = 'slds-hide';
                this.showToast('SUCCESS', 'Success', feedbackSavedToast, 'pester');
            }

            if (response.state === 'ERROR') {
                this.showToast('ERROR', 'ERROR', response.error, 'pester');
                this.showHideSpinner = 'slds-hide';
            }
        })
    }

    showToast(type, title, message, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
            mode: mode,
            duration: 5000
        });
        this.dispatchEvent(event);
    }
}