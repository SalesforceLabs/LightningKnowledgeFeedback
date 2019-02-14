({
	doInit : function (component, event, helper) {
		var actionParams = {recordId: component.get("v.recordId")};
		this.handleAction(component, actionParams, 'c.loadKAVId', this.doInitCallback);
	},

	doInitCallback : function(component, response, ctx) {
		if (!component.isValid()) return;

		component.set("v.kavId", response.kavId);
		component.set("v.originalKavId", response.kavId);
		component.set('v.articleLanguage', response.articleLanguage);
		component.set('v.articleRecordType', response.articleRecordType);
		component.set('v.articleNumber', response.articleNumber);
		component.set('v.articlePublishingStatus', response.articlePublishingStatus);
		component.set('v.originalArticleVersion', response.articleVersion);
		component.set('v.originatedFromTrigger', response.originatedFromTrigger);
		component.set('v.hasMultipleLanguages', response.hasMultipleLanguages);

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

		if (response.hasMultipleLanguages) {
			var languages = [];
			var languagesMap = response.languagesMap;
			for (var key in languagesMap) {
                languages.push({value:key, label:languagesMap[key]});
				console.log('key: ' + key);
				console.log('languagesMap[key]: ' + languagesMap[key]);
            }

			component.set("v.languagesMap", languages);
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
	},

	reloadArticle : function(component, event, helper, kavId) {
		var actionParams = {kavId: kavId};
		this.handleAction(component, actionParams, 'c.reloadKav', this.reloadArticleCallback);
	},

	reloadArticleCallback : function(component, response, ctx) {
		if (!component.isValid()) return;

		component.set("v.kavId", response.kavId);
		component.set('v.articleVersion', response.articleVersion);
		component.set('v.articleLanguage', response.articleLanguage);
		component.set('v.articleRecordType', response.articleRecordType);
		component.set('v.articleNumber', response.articleNumber);
		component.set('v.articlePublishingStatus', response.articlePublishingStatus);

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
	}
})
