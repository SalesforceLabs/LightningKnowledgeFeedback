({
	doInit : function(component, event, helper) {
		helper.getInitialData(component);
	},

	updateHashtag: function(component, event, helper) {
		helper.updateHashtagHelper(component);
	},

	addPicklistValue: function(component, event, helper) {
		helper.addPicklistValueHelper(component);
	},

	handlePositiveChange: function(component, event, helper) {
		// TODO
	},

	handleNegativeChange: function(component, event, helper) {
		// TODO
	},

	saveValueOrder: function(component, event, helper) {
		helper.saveValueOrderHelper(component, event);
	},

	deleteValue: function(component, event, helper) {
		helper.deleteValueHelper(component, event);
	}
})