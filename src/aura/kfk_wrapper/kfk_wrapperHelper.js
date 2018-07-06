({
	doInit : function(component, event, helper) {
		
        var actionParams ={	recordId: component.get("v.recordId")};
		this.handleAction(component, actionParams, 'c.getInitData', this.doInitCallback);
		
	},

	//Logic to run on success.
	doInitCallback : function(component, responseMap, ctx){
		var that = ctx;

		if (!$A.util.isUndefinedOrNull(responseMap)){
			if(!component.isValid()) return;
            console.log(responseMap);
            component.set('v.ka_vote',responseMap.ka_vote);
            component.set('v.ka_feedback',responseMap.ka_feedback);
        }
	},
    addVote: function(isVoteUp,component, event, helper){
		 var actionParams ={	recordId: component.get("v.recordId")};
		this.handleAction(component, actionParams, 'c.addVote', this.addVoteCallback);
	},
    addVoteCallback : function(component, responseMap, ctx){
		var that = ctx;

		if (!$A.util.isUndefinedOrNull(responseMap)){
			if(!component.isValid()) return;
            console.log(responseMap);
            component.set('v.ka_vote',responseMap.ka_vote);
            component.set('v.ka_feedback',responseMap.ka_feedback);
        }
	}
})