({
	doInit : function(component, event, helper) {
		//Validate recordId
		if(!helper.validateRecordId(component, event, helper)) {
			component.set("v.invalidRecordId", true);
			return;
		}
		//Initialize data
		helper.getUserVote(component, event, helper);

		if(!component.get("v.alwaysDisplayFeedDescription")) {
			var feedbackDivContainerCmp = component.find("feedbackDivContainer");
			$A.util.removeClass(feedbackDivContainerCmp, "slds-show");
			$A.util.addClass(feedbackDivContainerCmp, "slds-hide");
		}
	},

	handleToggleLike : function (component, event, helper) {
		component.set("v.disliked", false);
		component.set("v.liked", true);
		component.set("v.unlikeReason", "");
		component.set("v.voteReasonDescription", "");

		var feedbackDivContainerCmp = component.find("feedbackDivContainer");
		$A.util.removeClass(feedbackDivContainerCmp, "slds-hide");
		$A.util.addClass(feedbackDivContainerCmp, "slds-show");

		if(!component.get("v.alwaysDisplayFeedDescription")) {
			$A.util.removeClass(feedbackDivContainerCmp, "slds-show");
			$A.util.addClass(feedbackDivContainerCmp, "slds-hide");
			helper.saveThumbVote(component, event);
		}
	},

	handleToggleDislike : function (component, event, helper) {
		component.set("v.unlikeReason", "");
		component.set("v.voteReasonDescription", "");
		var feedbackDivContainerCmp = component.find("feedbackDivContainer");
        $A.util.addClass(feedbackDivContainerCmp, "slds-show");
        $A.util.removeClass(feedbackDivContainerCmp, "slds-hide");
		component.set("v.disliked", true);
		component.set("v.liked", false);
    },

	handleClick : function (component, event, helper) {
        helper.saveThumbVote(component, event);
    }
})
