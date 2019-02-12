({
	doInit : function(component, event, helper) {
		helper.getInitialData(component, event);
	},

	updateHashtag: function(component, event, helper) {
		helper.updateHashtagHelper(component, event);
	},

	setEditMode: function(component, event, helper) {
		component.set('v.editMode', true);
		component.find('inputHashtag').set('v.disabled', false);
	},

	cancelEditMode: function(component, event, helper) {
		component.set('v.editMode', false);
		component.find('inputHashtag').set('v.disabled', true);
	}
})