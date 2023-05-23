import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FeedbackObject from '@salesforce/schema/afl_Article_Feedback__c';
import cardTitle from '@salesforce/label/c.Was_this_article_helpful';
import chooseGeneralReason from '@salesforce/label/c.Choose_a_general_reason';
import getVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.getVote';
import voteCounts from '@salesforce/apex/afl_ArticleThumbVoteCtrl.voteCounts';
import upsertOnlyVote from '@salesforce/apex/afl_ArticleThumbVoteCtrl.upsertOnlyVote';
import isGuest from '@salesforce/user/isGuest';

const likeCountVisibleClass = 'slds-m-right--medium';
const likeCountHiddenClass = 'slds-hide';
const dislikeCountVisibleClass = '';
const dislikeCountHiddenClass = 'slds-hide';

export default class Afl_ArticleFeedbackFlowScreen extends LightningElement {

	@api showVotes;
	@api recordId;
	@api likeCount;
	@api dislikeCount;
	@api controllingFieldValue;
	@api dependentFieldValue;

	@track liked = false;
	@track disliked = false;
	@track reasonTypeOptions = [];
	@track reasonType;
	@track controlValues;
	@track selectedValue;

	optionsValueToLabelMap;
	optionsLabelToValueMap;
	totalDependentValues = [];

    hasNoRate = false;
    isSameVote = false;	

    isGuestUser = isGuest;
	likeCountVisibility = likeCountHiddenClass;
	dislikeCountVisibility = dislikeCountHiddenClass;



	@wire(getObjectInfo, { objectApiName: FeedbackObject })
	objectInfo;

	// Picklist values based on record type
	@wire(getPicklistValuesByRecordType, { objectApiName: FeedbackObject, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
	reasonPicklistValues({ error, data }) {
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
		chooseGeneralReason
	};

 	async upsertSingleVote(recordId, isLiked, isSameVote, hasNoRate){
        await upsertOnlyVote({
            recordId : recordId,
            isLiked : isLiked,
            isSameVote : isSameVote,
            hasNoRate : hasNoRate,
        })
    }
	
    checkSameVote(){
        if ((this.savedVote === '5' && this.liked === true) || (this.savedVote === '1' && this.disliked === true)) {
            this.isSameVote = true;
        } else {
            this.isSameVote = false;
        }
    }

	checkVoteCountVisibility(){
		if(this.showVotes){
			this.likeCountVisibility = likeCountVisibleClass;
			this.dislikeCountVisibility = dislikeCountVisibleClass;
		} else {
			this.likeCountVisibility = likeCountHiddenClass; 
			this.dislikeCountVisibility = dislikeCountHiddenClass;
		}
	}

	connectedCallback() {
		this.checkVoteCountVisibility();
		if (this.controllingFieldValue === undefined && this.dependentFieldValue === undefined) {
			this.getUserVote();
		} else {
			this.selectedValue = '';
			this.liked = this.controllingFieldValue;
			this.disliked = !this.controllingFieldValue;
			this.reasonType = this.dependentFieldValue;
		}
		this.getVoteCounts();
	}

	getUserVote() {
		getVote({ recordId: this.recordId })
			.then(response => {
				const parsedVote = JSON.parse(response.jsonResponse);
				if (parsedVote.vote === 'true') {
					this.liked = true;
					this.disliked = false;
					this.controllingFieldValue = true;
				} else if (parsedVote.vote === 'false') {
					this.liked = false;
					this.disliked = true;
					this.controllingFieldValue = false;
				}
				if (parsedVote.feedbackReason) {
					this.selectedValue = parsedVote.feedbackReason;
                    this.dependentFieldValue = parsedVote.feedbackReason;
				} else {
					this.selectedValue = 'None';
				}

				this.refreshValuesByLikeOrDislike();
			})
			.catch(error => {
				this.liked = false;
				this.disliked = false;
				console.error(error);
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
						label: key.label,
						value: key.value
					});
				});

				this.reasonTypeOptions = initialOptions;
				this.reasonType = initialOptions[0] ? initialOptions[0].value : '';
			}
		}

		if (this.selectedValue !== '' && this.optionsLabelToValueMap.size !== 0) {
			if (this.optionsLabelToValueMap.get(this.selectedValue)) {
				this.reasonType = this.optionsLabelToValueMap.get(this.selectedValue);
			} else {
				this.reasonType = this.selectedValue;
			}
		}
	}

    async handleToggleLike() {   
		this.liked = true;
        this.disliked = false;
		this.controllingFieldValue = true;
        this.checkSameVote();
        this.setLikeValues(); 
        this.savedVote = '5';
		if(!this.isGuestUser){
			await this.upsertSingleVote(
				this.recordId,
				this.liked,
				this.isSameVote,
				this.hasNoRate
				);
			await this.getVoteCounts();
		}
    }

	async handleToggleDislike() {
		this.liked = false;
		this.disliked = true;
		this.controllingFieldValue = false;
		this.checkSameVote();
		this.savedVote = '1';
		this.setDislikeValues();
		if(!this.isGuestUser){
			await this.upsertSingleVote(
				this.recordId,
				this.liked,
				this.isSameVote,
				this.hasNoRate			
				);
			await this.getVoteCounts();
		}
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
				});
			}
		});

		this.reasonTypeOptions = dependValues;
	}

	handleReasonChange(event) {
		const selectedOption = event.detail.value;
		this.reasonType = selectedOption;
		this.dependentFieldValue = selectedOption;
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
				});
			}
		});

		this.reasonTypeOptions = dependValues;
	}

	getVoteCounts() {
		voteCounts({ recordId: this.recordId })
			.then(response => {
				this.likeCount = response.Likes ? response.Likes : '0';
				this.dislikeCount = response.Dislikes ? response.Dislikes : '0';
			})
			.catch(error => {
				console.log(error);
			});
	}
}