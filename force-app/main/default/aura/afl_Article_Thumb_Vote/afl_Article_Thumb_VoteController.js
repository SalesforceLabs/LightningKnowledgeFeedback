({
	doInit : function(component, event, helper) {
		// Validate recordId
		if (!helper.validateRecordId(component, event, helper)) {
			component.set("v.invalidRecordId", true);
			return;
		}

		// Initialize data
		helper.getUserVote(component, event, helper);

		if (!component.get("v.alwaysDisplayFeedDescription")) {
			var feedbackDivContainerCmp = component.find("feedbackDivContainer");
			$A.util.removeClass(feedbackDivContainerCmp, "slds-show");
			$A.util.addClass(feedbackDivContainerCmp, "slds-hide");
		}
	},

	handleToggleLike : function (component, event, helper) {
		helper.getPicklistValuesFromAttribute(component, component.get("v.activePositiveValues"));

		component.set("v.disliked", false);
		component.set("v.liked", true);

		var feedbackDivContainerCmp = component.find("feedbackDivContainer");
		$A.util.addClass(feedbackDivContainerCmp, "slds-show");
		$A.util.removeClass(feedbackDivContainerCmp, "slds-hide");
	},

	handleToggleDislike : function (component, event, helper) {
		helper.getPicklistValuesFromAttribute(component, component.get("v.activeNegativeValues"));

		component.set("v.disliked", true);
		component.set("v.liked", false);

		var feedbackDivContainerCmp = component.find("feedbackDivContainer");
        $A.util.addClass(feedbackDivContainerCmp, "slds-show");
        $A.util.removeClass(feedbackDivContainerCmp, "slds-hide");
    },

	handleClick : function (component, event, helper) {
        helper.saveThumbVote(component, event);
    }
})