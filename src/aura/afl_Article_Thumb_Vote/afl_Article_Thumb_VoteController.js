({
	doInit : function(component, event, helper) {
		//Initialize data
		helper.getUserVote(component, event, helper);

		var unlikeCardDivCmp = component.find("unlikeCardDiv");
		$A.util.removeClass(unlikeCardDivCmp, "slds-show");
		$A.util.addClass(unlikeCardDivCmp, "slds-hide");
		component.set("v.validFeedbackDescription", true);
		component.set("v.errorMessage", "");
	},

	handleToggleLike : function (component, event, helper) {

		var unlikeCardDivCmp = component.find("unlikeCardDiv");
        $A.util.removeClass(unlikeCardDivCmp, "slds-show");
        $A.util.addClass(unlikeCardDivCmp, "slds-hide");

        component.set("v.disliked", false);
        component.set("v.liked", true);

		component.set("v.unlikeReason", "");
        component.set("v.undislikeescription","");
		component.set("v.validFeedbackDescription", true);
		component.set("v.errorMessage", "");
		if(component.get("v.displayNegativeFeedbackDescription"))
        	helper.saveThumbVote(component, event);
    },

	handleToggleDislike : function (component, event, helper) {
		var unlikeCardDivCmp = component.find("unlikeCardDiv");
        $A.util.addClass(unlikeCardDivCmp, "slds-show");
        $A.util.removeClass(unlikeCardDivCmp, "slds-hide");
		component.set("v.disliked", true);
		component.set("v.liked", false);
		component.set("v.validFeedbackDescription", true);
		component.set("v.errorMessage", "");
    },

	handleClick : function (component, event, helper) {
        helper.saveThumbVote(component, event);
    }
})
