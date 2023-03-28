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
import uploadFileLabel from '@salesforce/label/c.Upload_Files_Label';

import getVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.getVote';
import upsertThumbArticleVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.upsertThumbArticleVote';
import upsertOnlyVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.upsertOnlyVote';
import voteCounts from '@salesforce/apex/afl_ArticleThumbVoteCtrl.voteCounts';
import FeedbackObject from '@salesforce/schema/afl_Article_Feedback__c';

const ALWAYS_SHOW = 'Always Show';
const SHOW_AFTER_VOTE = 'Only Show After Upvote/Downvote';
const SHOW_AFTER_DISLIKE = 'Only Show After Downvote';
const ALWAYS_HIDE = 'Always Hide';

export default class Afl_ArticleThumbVote extends LightningElement {
    invalidRecordId = false;
    
    @api hideVoteCounter;
    @api recordId;
    @api feedbackFormBehavior;
    @api ratingRequired;
    @api descriptionRequired;
    @api displayFileAttachmentSection;
    @api likeCount;
	@api dislikeCount;

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
    optionsValueToLabelMap;
    optionsLabelToValueMap;
    voteReasonDescription;
    showHideFeedback = 'slds-hide';
    showHideFileUpload;
    hasNoRate = false;
    isSameVote = false;
    showHideSpinner = 'slds-hide';
    totalDependentValues = [];
    insertedFilesIds = [];
    
    // Account object info
    @wire(getObjectInfo, { objectApiName: FeedbackObject  })
    objectInfo;

    // Picklist values based on record type
    @wire(getPicklistValuesByRecordType, { objectApiName: FeedbackObject, recordTypeId: '$objectInfo.data.defaultRecordTypeId'})
    reasonPicklistValues({error, data}) {
        if (data) {
            // Check if there's a namespace
            if (data.picklistFieldValues.afl__Unlike_Reason__c) {
                this.controlValues = data.picklistFieldValues.afl__Unlike_Reason__c.controllerValues;
                // Unlike Reason dependent Field Picklist values
                this.totalDependentValues = data.picklistFieldValues.afl__Unlike_Reason__c.values;
            } else {
                this.controlValues = data.picklistFieldValues.Unlike_Reason__c.controllerValues;
                // Unlike Reason dependent Field Picklist values
                this.totalDependentValues = data.picklistFieldValues.Unlike_Reason__c.values;
            }
            
            this.refreshValuesByLikeOrDislike();
        } else if (error) {
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
        feedbackSavedToast,
        uploadFileLabel
    };

    connectedCallback() {
        if (!this.validateRecordId()) {
            this.invalidRecordId =true;
            return;
        }

        if (this.displayFileAttachmentSection === false) {
			this.showHideFileUpload = 'slds-hide';
		}
        this.getUserVote();
        this.getVoteCounts();
        this.setInitialFeedbackVisibility();
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
            }

            if (parsedVote.feedbackReason) {
                this.selectedValue = parsedVote.feedbackReason;
            } else {
                this.selectedValue = 'None';
            }

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
                // Set default value
                initialOptions.push({
                    label: '-- ' + chooseGeneralReason + ' --',
                    value: 'None'
                });

                // Set values in map for later use
                this.optionsValueToLabelMap = new Map();
                this.optionsLabelToValueMap = new Map();
                
                this.optionsLabelToValueMap.set('-- ' + chooseGeneralReason + ' --', 'None');
                this.optionsValueToLabelMap.set('None', '-- ' + chooseGeneralReason + ' --');

                this.totalDependentValues.forEach(key => {
                    this.optionsValueToLabelMap.set(key.value, key.label);
                    this.optionsLabelToValueMap.set(key.label, key.value);

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
            if (this.optionsLabelToValueMap.get(this.selectedValue)) {
                this.reasonType = this.optionsLabelToValueMap.get(this.selectedValue);
            } else {
                this.reasonType = this.selectedValue;
            }
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



    async upsertSingleVote(recordId, isLiked, isSameVote, hasNoRate){
        await upsertOnlyVote({
            recordId : recordId,
			isLiked : isLiked,
			isSameVote : isSameVote,
			hasNoRate : hasNoRate,
		})

    }

    setLikeValues() {
        let dependValues = [];
        // Set default value
        dependValues.push({
            label: '-- ' + chooseGeneralReason + ' --',
            value: 'None'
        });

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

    async handleToggleLike() {        
        this.liked = true;
        this.disliked = false;
        this.checkSameVote();
        await this.upsertSingleVote(
            this.recordId,
            this.liked,
            this.isSameVote,
            this.hasNoRate
        );
        this.setLikeValues(); 
        this.savedVote = '5';
        await this.getVoteCounts();
        this.updateFeedbackVisibility();
    }

    async handleToggleDislike() {
        this.liked = false;
        this.disliked = true;
        
        this.checkSameVote();
        await this.upsertSingleVote(
            this.recordId,
            this.liked,
            this.isSameVote,
            this.hasNoRate
        );
        this.savedVote = '1';
        this.setDislikeValues();
        await this.getVoteCounts();
        this.updateFeedbackVisibility();
    }

    setDislikeValues() {
        let dependValues = [];
        // Set default value
        dependValues.push({
            label: '-- ' + chooseGeneralReason + ' --',
            value: 'None'
        });

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
        this.checkSameVote();
		this.showHideSpinner = 'slds-show';
		if (!this.ratingRequired && !this.liked && !this.disliked) {
			this.hasNoRate = true;
        }
        
        let reasonSelected, reasonSelectedDeveloperValue; 
        if (this.reasonType === 'None') {
            reasonSelected = '';
            reasonSelectedDeveloperValue = '';
        } else {
            reasonSelected = this.optionsValueToLabelMap.get(this.reasonType);
            reasonSelectedDeveloperValue = this.reasonType;
        }
        upsertThumbArticleVote({
			recordId : this.recordId,
			feedbackReason : reasonSelected,
			feedbackReasonDeveloperValue : reasonSelectedDeveloperValue,
			voteDescription : this.voteReasonDescription,
			isLiked : this.liked,
			isSameVote : this.isSameVote,
			hasNoRate : this.hasNoRate,
            filesInserted: this.insertedFilesIds
		})
        .then(response => {
            if (response.state === 'SUCCESS') {
                this.voteReasonDescription = "";
                this.savedVote = this.liked ? '5' : '1';
                this.showHideSpinner = 'slds-hide';
                this.showToast('SUCCESS', 'Success', feedbackSavedToast, 'pester');
                this.insertedFilesIds = [];
            }
            if (response.state === 'ERROR') {
                this.showToast('ERROR', 'ERROR', response.error, 'pester');
                this.showHideSpinner = 'slds-hide';
            }
        })
    }

    checkSameVote(){
        if ((this.savedVote === '5' && this.liked === true) || (this.savedVote === '1' && this.disliked === true)) {
			this.isSameVote = true;
		} else {
            this.isSameVote = false;
        }
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

    async getVoteCounts() {
		await voteCounts({ recordId: this.recordId })
        .then(response => {
            this.likeCount = (response.Likes) ? response.Likes : '0';
            this.dislikeCount = (response.Dislikes) ? response.Dislikes : '0';
        })
        .catch(error => {
            console.log(error);
        });
	}	

    handleUploadFinished(event){
        let files = event.detail.files;
        files.forEach((x) => {this.insertedFilesIds.push(x.documentId)});
    }

    setInitialFeedbackVisibility(){
        switch(this.feedbackFormBehavior){
            case ALWAYS_SHOW:
                this.showHideFeedback = 'slds-show';        
                break;
            case SHOW_AFTER_VOTE:
                this.showHideFeedback = 'slds-hide';        
                break;
            case SHOW_AFTER_DISLIKE:
                this.showHideFeedback = 'slds-hide';        
                break;
            case ALWAYS_HIDE:
                this.showHideFeedback = 'slds-hide';
                break;
        }
    }

    updateFeedbackVisibility(){    
        switch(this.feedbackFormBehavior){
            case SHOW_AFTER_VOTE:
                if(this.liked || this.disliked){
                    this.showHideFeedback = 'slds-show';                            
                } else {
                    this.showHideFeedback = 'slds-hide';        
                }
                break;

            case SHOW_AFTER_DISLIKE:
                if(this.disliked){
                    this.showHideFeedback = 'slds-show';                            
                } else {
                    this.showHideFeedback = 'slds-hide';        
                }        
                break;
        }        

    }

}