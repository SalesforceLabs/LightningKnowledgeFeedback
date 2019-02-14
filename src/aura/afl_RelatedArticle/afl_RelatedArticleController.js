({
	doInit: function(component, event, helper) {
		helper.doInit(component, event, helper);
	},

	navigateTo : function(component, event, helper) {
		helper.navigateTo(component, event, helper);
	},

	handleLanguageChange: function (component, event, helper) {
		var kavId = event.getParam("value");

		if (component.get('v.originalKavId') === kavId) {
			helper.doInit(component, event, helper, kavId);
		} else {
			helper.reloadArticle(component, event, helper, kavId);
		}
    }
})
