({
	onLoad: function (component, event, helper) {
        history.go(-1);
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			mode: 'sticky',
			type: 'warning',
			message: $A.get('$Label.c.Article_Feedback_creation_alert')
		});
		toastEvent.fire();
	}
});