({
	closeWindow : function(component, event, helper) {
		component.set("v.title",'');
		component.set("v.description",'');
		component.set("v.className",'slds-hide');
		component.set("v.severity",'info');
	}
})