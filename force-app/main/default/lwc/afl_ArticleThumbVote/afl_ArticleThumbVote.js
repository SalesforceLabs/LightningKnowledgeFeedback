/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import cardTitle from '@salesforce/label/c.Was_this_article_helpful';
import chooseGeneralReason from '@salesforce/label/c.Choose_a_general_reason';
import description from '@salesforce/label/c.Description';
import descriptionPlaceholder from '@salesforce/label/c.Description_placeholder';
import submit from '@salesforce/label/c.Submit_button';
import alwaysDisplayFeedbackSection from '@salesforce/label/c.Always_display_feedback_section';
import makeRatingRequired from '@salesforce/label/c.Make_rating_required';

import getVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.getVote';
import getPicklistValuesIntoList from '@salesforce/apex/afl_ArticleThumbVoteCtrl.getPickListValuesIntoList';
import upsertThumbArticleVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.upsertThumbArticleVote';

export default class Afl_ArticleThumbVote extends LightningElement {

    invalidRecordId = false;

    @api recordId;
    @api alwaysDisplayFeedbackDescription;
    @api ratingRequired;

    @track liked = false;
    @track disliked = false;
    savedVote = '';
    activePositiveValues; activeNegativeValues;
    allValues;
    reasonTypeOptions;
    reasonType;
    voteReasonDescription;
    showHideFeedback;
    hasNoRate = false;
    isSameVote = false;
    showHideSpinner = 'slds-hide';

    label = {
        cardTitle,
        chooseGeneralReason,
        description,
        descriptionPlaceholder,
        submit,
        alwaysDisplayFeedbackSection,
        makeRatingRequired
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

    getPicklistValues() {
        getPicklistValuesIntoList()
        .then(response => {
            const parsedResponse = JSON.parse(response.jsonResponse); 
            if (parsedResponse.activePositiveValues) {
                this.activePositiveValues = JSON.parse(parsedResponse.activePositiveValues);

				if (this.liked === true) {
					this.getPicklistValuesFromAttribute(this.activePositiveValues);
				}
			}

			if (parsedResponse.activeNegativeValues) {
                this.activeNegativeValues = JSON.parse(parsedResponse.activeNegativeValues);

				if (this.disliked === true) {
					this.getPicklistValuesFromAttribute(this.activeNegativeValues);
				}
			}

			if (parsedResponse.allValues) {
                this.allValues = JSON.parse(parsedResponse.allValues);

				if (this.liked === false && this.disliked === false) {
					this.getPicklistValuesFromAttribute(this.allValues);
				}
			}
        })
        .catch(error => {
            console.log(error);
        });
    }

    getPicklistValuesFromAttribute(listValues) {
        let finalList = [];

		for (let i=0; i<listValues.length; i++) {
			const option = {value: listValues[i], label: listValues[i]};
			finalList.push(option);
		}

		this.reasonTypeOptions = finalList;
		this.reasonType = listValues[0];
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
            this.getPicklistValues();
        })
        .catch(error => {
            this.liked = false;
            this.disliked = false;
            console.log(error);
            this.getPicklistValues();
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
        this.getPicklistValuesFromAttribute(this.activePositiveValues);
        this.liked = true;
        this.disliked = false;
        if(this.alwaysDisplayFeedbackDescription === false) {
            this.showHideFeedback = 'slds-hide';
        } else {
            this.showHideFeedback = 'slds-show';
        }
    }

    handleToggleDislike() {
        this.getPicklistValuesFromAttribute(this.activeNegativeValues);
        this.liked = false;
        this.disliked = true;
        this.showHideFeedback = 'slds-show';
    }

    handleClick() {
		// Check if component rating is required
		if (this.ratingRequired === true) {
			if (!this.liked && !this.disliked) {
				this.showToast('ERROR', 'ERROR', 'Please, rate the article before leaving any comments', 'pester');
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
            type: type,
            mode: mode,
            duration: 5000
        });
        this.dispatchEvent(event);
    }
}