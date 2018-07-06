({
	doInit : function(component, event, helper) {
			helper.doInit(component, event, helper);
	},
    voteUp : function(component, event, helper) {
			helper.addVote(true,component, event, helper);
	},
	 voteDown : function(component, event, helper) {
			helper.addVote(false,component, event, helper);
	}
})