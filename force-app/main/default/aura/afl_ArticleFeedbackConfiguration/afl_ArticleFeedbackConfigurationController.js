({
	doInit : function(component, event, helper) {
		helper.getInitialData(component, event);
	},

	addPicklistValue: function(component, event, helper) {
		helper.addPicklistValueHelper(component, event);
	},

	updateHashtag: function(component, event, helper) {
		helper.updateHashtagHelper(component, event);
	},
})