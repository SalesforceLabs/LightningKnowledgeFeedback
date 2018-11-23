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

   loadPicklistValues: function(component, ctx) {
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

   getUserVote: function(component, event, helper) {
	   var actionParams = {
		  'recordId': component.get("v.recordId")
	   };
	   this.handleAction(component, actionParams, 'c.getVote', this.getUserVoteCallback);
   },

   getUserVoteCallback: function(component, response, ctx) {
	   if(!$A.util.isUndefinedOrNull(response)) {
		 var result = JSON.parse(response.vote);

		  if(result) {
			  component.set("v.liked", true);
			  component.set("v.disliked", false);
			  component.set("v.savedVote",'5');
		  } else {
			  component.set("v.liked", false);
			  component.set("v.disliked", true);
			  component.set("v.savedVote",'1');

			  //If article has a negative vote show reason's pickList
			  if(component.get("v.savedVote") == "1") {
				  var unlikeCardDivCmp = component.find("unlikeCardDiv");
				  $A.util.removeClass(unlikeCardDivCmp, "slds-hide");
				  $A.util.addClass(unlikeCardDivCmp, "slds-show");
			  }
		  }
	  } else {
		  //There's no vote so both buttons must be shown unchecked
		  component.set("v.liked", false);
		  component.set("v.disliked", false);
	  }
	  ctx.loadPicklistValues(component, ctx);
   },

   saveThumbVote: function (component, event) {
	   //Prevent user from voting the same again
	   if((component.get("v.savedVote") == '5' && component.get('v.liked')) || (component.get("v.savedVote") == '1' && component.get("v.disliked")))
		   return;
	   if(!this.validateFeedbackDescription(component))
	   	   return;
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
	   component.set("v.savedVote", component.get("v.liked") ? '5' : '1');
	   component.set("v.validFeedbackDescription", true);
	   component.set("v.errorMessage", "");
	   ctx.hideSpinner(component);
	   ctx.showToast('SUCCESS', 'success', 'Feedback saved successfully', 'pester');
   },

   validateFeedbackDescription: function(component) {
	   var value = component.get("v.voteReasonDescription");
	   if(!$A.util.isUndefinedOrNull(value) && value.length > 29000){
            component.set("v.validFeedbackDescription", false);
			component.set("v.errorMessage", "Characters size length exceeded");
			return false;
        }
		return true;
   },
   validateRecordId: function (component, event, helper) {
	   var recordId = component.get("v.recordId");
	   if(!$A.util.isUndefinedOrNull(recordId)) {
		   var prefix = recordId.substring(0, 3);
		   if(prefix == "ka0")
		   	return true;
	   }
	   return false;
   }
})
