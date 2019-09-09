({
	showSpinner : function (component) {
		var spinner = component.find("spinner");
		$A.util.removeClass(spinner, "slds-hide");
		$A.util.addClass(spinner, "slds-show");
	},

	hideSpinner : function (component) {
		var spinner = component.find("spinner");
		$A.util.removeClass(spinner, "slds-show");
		$A.util.addClass(spinner, "slds-hide");
	},

	getUserVote: function(component, event, helper) {
		var actionParams = {
			'recordId': component.get("v.recordId")
		};

		this.handleAction(component, actionParams, 'c.getVote', this.getUserVoteCallback);
	},

	getUserVoteCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response)) {
			var result = JSON.parse(response.vote);

			if (result) {
				component.set("v.liked", true);
				component.set("v.disliked", false);
				component.set("v.savedVote",'5');
			} else {
				component.set("v.liked", false);
				component.set("v.disliked", true);
				component.set("v.savedVote",'1');

				// We should always display the feedback comp
				var feedbackDivContainerCmp = component.find("feedbackDivContainer");
				$A.util.removeClass(feedbackDivContainerCmp, "slds-hide");
				$A.util.addClass(feedbackDivContainerCmp, "slds-show");

			}
		} else {
			// There's no vote so both buttons must be shown unchecked
			component.set("v.liked", false);
			component.set("v.disliked", false);
		}

		ctx.loadPicklistValues(component, ctx);
	},

	loadPicklistValues: function(component, ctx) {
		this.handleAction(component, null, 'c.getPickListValuesIntoList', this.loadPicklistValuesCallback);
	},

	loadPicklistValuesCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response)) {
			if (!$A.util.isUndefinedOrNull(response.activePositiveValues)) {
				component.set('v.activePositiveValues', JSON.parse(response.activePositiveValues));

				if (component.get("v.liked")) {
					ctx.getPicklistValuesFromAttribute(component, component.get('v.activePositiveValues'));
				}
			}

			if (!$A.util.isUndefinedOrNull(response.activeNegativeValues)) {
				component.set('v.activeNegativeValues', JSON.parse(response.activeNegativeValues));

				if (component.get("v.disliked")) {
					ctx.getPicklistValuesFromAttribute(component, component.get('v.activeNegativeValues'));
				}
			}

			if (!$A.util.isUndefinedOrNull(response.allValues)) {
				component.set('v.allValues', JSON.parse(response.allValues));

				if (!component.get('v.liked') && !component.get('v.disliked')) {
					ctx.getPicklistValuesFromAttribute(component, component.get('v.allValues'));
				}
			}
		}
	},

	getPicklistValuesFromAttribute: function (component, listValues) {
		var finalList = [];
		
		// Initialize the attribute
		component.set("v.reasonTypeOptions", finalList);

		for (var i=0; i<listValues.length; i++) {
			var option = {value: listValues[i], label: listValues[i]};
			finalList.push(option);
		}

		component.set("v.reasonTypeOptions", finalList);
		component.set("v.reasonType", listValues[0]);
	},

	saveThumbVote: function (component, event) {
		var ratingRequired = false;
		var hasNoRate = false;

		// Check if component rating is required
		if (component.get('v.requireRating')) {
			ratingRequired = true;
			if (!component.get('v.liked') && !component.get('v.disliked')) {
				this.showToast('ERROR', 'ERROR', 'Please, rate the article before leaving any comments', 'pester');
				return;
			}
		}

		// Prevent user from voting the same again
		var isSameVote = false;
		if ((component.get("v.savedVote") === '5' && component.get('v.liked')) || (component.get("v.savedVote") === '1' && component.get("v.disliked"))) {
			isSameVote = true;
		}

		this.showSpinner(component);

		if (!ratingRequired && !component.get('v.liked') && !component.get("v.disliked")) {
			hasNoRate = true;
		}

		var reason = component.get("v.reasonType");
		var description = component.get("v.voteReasonDescription");
		var isLiked = !component.get("v.disliked");
		var articleId = component.get("v.recordId");
		var actionParams = {
			"recordId": articleId,
			"feedbackReason" : reason,
			"voteDescription" : description,
			"isLiked" : isLiked,
			"isSameVote": isSameVote,
			"hasNoRate": hasNoRate
		};

		this.handleAction(component, actionParams, 'c.upsertThumbArticleVote', this.saveThumbVoteCallback);
	},

	saveThumbVoteCallback: function (component, response, ctx) {
		component.set("v.unlikeReason","");
		component.set("v.voteReasonDescription","");
		component.set("v.savedVote", component.get("v.liked") ? '5' : '1');
		ctx.hideSpinner(component);
		ctx.showToast('SUCCESS', 'Success', 'Feedback saved successfully', 'pester');
	},

	validateRecordId: function (component, event, helper) {
		var recordId = component.get("v.recordId");
		if (!$A.util.isUndefinedOrNull(recordId)) {
			var prefix = recordId.substring(0, 2);
			if (prefix === "ka")
			return true;
		}

		return false;
	}
})