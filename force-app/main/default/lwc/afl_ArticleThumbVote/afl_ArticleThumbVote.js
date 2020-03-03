/* eslint-disable no-console */
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import cardTitle from '@salesforce/label/c.Was_this_article_helpful';
import chooseGeneralReason from '@salesforce/label/c.Choose_a_general_reason';
import description from '@salesforce/label/c.Description';
import descriptionPlaceholder from '@salesforce/label/c.Description_placeholder';
import submit from '@salesforce/label/c.Submit_button';

import getVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.getVote';
import upsertThumbArticleVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.upsertThumbArticleVote';

import FeedbackObject from '@salesforce/schema/afl_Article_Feedback__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

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
     countryPicklistValues({error, data}) {
         if(data) {
             let initialOptions = [];

             this.controlValues = data.picklistFieldValues.Unlike_Reason__c.controllerValues;
             // Unlike Reason dependent Field Picklist values
             this.totalDependentValues = data.picklistFieldValues.Unlike_Reason__c.values;
 
            if (this.liked) {
                this.setLikeValues();
            } else if (this.disliked) {
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
         else if(error) {
             this.error = JSON.stringify(error);
         }
     }

    label = {
        cardTitle,
        chooseGeneralReason,
        description,
        descriptionPlaceholder,
        submit
    };

    connectedCallback() {
        if (!this.validateRecordId()) {
			this.invalidRecordId =true;
        }
        
        if(this.alwaysDisplayFeedbackDescription === false) {
            this.showHideFeedback = 'slds-hide';
        }

        this.getUserVote();
    }

    getUserVote() {
        getVote({recordId : this.recordId})
        .then(response => {
            const parsedVote = JSON.parse(response.jsonResponse);
            if(parsedVote.vote === 'true') {
                this.liked = true;
                this.disliked = false;
                this.savedVote = '5';
            } else {
                this.liked = false;
                this.disliked = true;
                this.savedVote = '1';

                this.showHideFeedback = 'slds-show';
            }
        })
        .catch(error => {
            this.liked = false;
            this.disliked = false;
            console.log(error);
        });
    }

    validateRecordId() {
		if (this.recordId) {
			const prefix = this.recordId.substring(0, 2);
			if (prefix === "ka"){
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
            if(conValues.validFor.includes(this.controlValues['Thumbs_up'])) {
                dependValues.push({
                    label: conValues.label,
                    value: conValues.value
                })
            }
        })
        this.reasonTypeOptions = dependValues;
        this.reasonType = dependValues[0] ? dependValues[0].value : '';
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
            if(conValues.validFor.includes(this.controlValues['Thumbs_down'])) {
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
				this.showToast('ERROR', 'ERROR', 'Please, rate the article before leaving any comments', 'pester');
				return;
			}
        }
        
        this.voteReasonDescription = this.template.querySelector('lightning-textarea').value;

        if (this.descriptionRequired === true) {
            if ((this.voteReasonDescription === undefined || this.voteReasonDescription === '') && this.disliked === true) {
                this.showToast('ERROR', 'ERROR', 'Please, provide a description before submiting your vote', 'pester');
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
            if(response.state === 'SUCCESS') {
                this.voteReasonDescription = "";
                this.savedVote = this.liked ? '5' : '1';
                this.showHideSpinner = 'slds-hide';
                this.showToast('SUCCESS', 'Success', 'Feedback saved successfully', 'pester');
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