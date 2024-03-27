({
	doInit : function (component, event, helper) {
		var actionParams = {recordId: component.get("v.recordId")};
		this.handleAction(component, actionParams, 'c.loadKAVId', this.doInitCallback);
	},

	doInitCallback : function(component, response, ctx) {
		if (!component.isValid()) return;

		component.set("v.kavId", response.kavId);
		component.set('v.articleLanguage', response.articleLanguage);
		component.set('v.articleRecordType', response.articleRecordType);
		component.set('v.articleNumber', response.articleNumber);
		component.set('v.articlePublishingStatus', response.articlePublishingStatus);
		component.set('v.originatedFromTrigger', response.originatedFromTrigger);

		// Get field labels
		component.set('v.languageLabel', response.languageLabel);
		component.set('v.articleNumberLabel', response.articleNumberLabel);
		component.set('v.publishStatusLabel', response.publishStatusLabel);
		component.set('v.versionNumberLabel', response.versionNumberLabel);
		component.set('v.recordTypeIdLabel', response.recordTypeIdLabel);

		if (response.isArchived) {
			component.set('v.articleVersion', response.articleVersion + ' (deprecated)');

			var toastCmp = component.find("toastNotif");
			toastCmp.set("v.title", 'WARNING');
			toastCmp.set("v.description", 'The related Knowledge Article is archived.');
			toastCmp.set("v.className", '');
			toastCmp.set("v.severity", 'warning');
		} else {
			component.set('v.articleVersion', response.articleVersion);
		}
	},

	navigateTo : function(component, event, helper) {
		var idKav = component.get("v.kavId");
		var sObectEvent = $A.get("e.force:navigateToSObject");
		sObectEvent .setParams({
			"recordId": idKav,
			"slideDevName": "detail"
		});
		sObectEvent.fire();
	}
})