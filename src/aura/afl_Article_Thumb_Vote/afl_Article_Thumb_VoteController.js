({
	doInit : function(component, event, helper) {
		//Initialize picklist data
		helper.loadPicklistValues(component, event, helper);

		var unlikeCardDivCmp = component.find("unlikeCardDiv");
        $A.util.removeClass(unlikeCardDivCmp, "slds-show");
        $A.util.addClass(unlikeCardDivCmp, "slds-hide");
	},

	handleToggleLike : function (component, event, helper) {

        var dislike = component.get("v.disliked");

		var unlikeCardDivCmp = component.find("unlikeCardDiv");
        $A.util.removeClass(unlikeCardDivCmp, "slds-show");
        $A.util.addClass(unlikeCardDivCmp, "slds-hide");

        component.set("v.disliked", false);
        component.set("v.liked", true);

		component.set("v.unlikeReason", "");
        component.set("v.undislikeescription","");
		if(component.get("v.displayNegativeFeedbackDescription"))
        	helper.saveThumbVote(component, event);
    },

	handleToggleDislike : function (component, event, helper) {

        var dislike = component.get("v.disliked");

		var unlikeCardDivCmp = component.find("unlikeCardDiv");
        $A.util.addClass(unlikeCardDivCmp, "slds-show");
        $A.util.removeClass(unlikeCardDivCmp, "slds-hide");
		component.set("v.disliked", true);
    },

	handleClick : function (component, event, helper) {
        helper.saveThumbVote(component, event);
    }
})
