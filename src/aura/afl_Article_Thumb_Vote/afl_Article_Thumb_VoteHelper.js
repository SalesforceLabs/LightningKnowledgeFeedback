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

   loadPicklistValues: function(component, event, helper) {
	   this.handleAction(component, null, 'c.getPickListValuesIntoList', this.loadPicklistValuesCallback);
   },

   loadPicklistValuesCallback: function(component, response, ctx) {
	   if(!$A.util.isUndefinedOrNull(response)) {
		   var listValues = JSON.parse(response.result);
		   var finalList = [];

		   for(var i=0; i<listValues.length; i++) {
			   var option = {value: listValues[i], label: listValues[i]};
			   finalList.push(option);
		   }
		   component.set("v.unlikeReasonOptions", finalList);
	   }
   },

   saveThumbVote: function (component, event) {
	   this.showSpinner(component);
	   var reason = component.get("v.unlikeReason");
	   var description = component.get("v.voteReasonDescription");
	   var isLiked = !component.get("v.disliked");
	   var articleId = component.get("v.recordId");
	   var actionParams = {
		   "recordId": articleId,
		   "unlikeReason" : reason,
		   "voteDescription" : description,
		   "isLiked" : isLiked
	   };
	   this.handleAction(component, actionParams, 'c.upsertThumbArticleVote', this.saveThumbVoteCallback);
   },

   saveThumbVoteCallback: function (component, response, ctx) {
	   component.set("v.unlikeReason","");
	   component.set("v.voteReasonDescription","");
	   ctx.hideSpinner(component);
	   ctx.showToast('SUCCESS', 'success', 'Feedback saved successfully', 'pester');
   }
})
