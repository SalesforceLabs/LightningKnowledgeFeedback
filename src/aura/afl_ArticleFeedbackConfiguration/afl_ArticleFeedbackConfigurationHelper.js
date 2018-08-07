({
	getInitialData : function(component, event) {
		this.handleAction(component, null, 'c.getInitialData', this.getInitialDataCallback);
	},
	getInitialDataCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response)) {
			if (!component.isValid()) return;
			component.set('v.hashtagValue', response.hashtag);
		}
	},
	updateHashtagHelper: function(component, event) {
		var hashtag = component.find('inputHashtag').get('v.value');
		if (hashtag !== '') {
			var actionParams = {'value': hashtag};
			this.handleAction(component, actionParams, 'c.updateHashtagValue', this.updateHashtagValueCallback);
		} else this.showToast('fail', 'Error', 'This field cannot be empty.');
	},
	updateHashtagValueCallback: function(component, response, ctx){
		if (!$A.util.isUndefinedOrNull(response) && response.status === 'SUCCESS') {
			if (!component.isValid()) return;
			ctx.showToast(' success ', ' SUCCESS ', 'Hashtag value successfully updated');
			component.set('v.editMode', false);
			component.find('inputHashtag').set('v.disabled', true);
		} else
		this.showToast('fail', 'Error', 'An error ocurred while updating the hashtag value');
	}

})
