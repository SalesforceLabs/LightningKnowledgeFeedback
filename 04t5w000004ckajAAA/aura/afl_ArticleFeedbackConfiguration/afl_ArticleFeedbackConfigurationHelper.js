({
	getInitialData : function(component) {
		this.handleAction(component, null, 'c.getInitialData', this.getInitialDataCallback);
	},

	getInitialDataCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response)) {
			if (!component.isValid()) { 
				return;
			}

			if (!$A.util.isUndefinedOrNull(response.hashtag)) {
				component.set('v.triggerCheckbox', response.triggersEnabled);
				component.set('v.hashtagValue', response.hashtag);
			}
		}
	},

	updateHashtagHelper: function(component) {
		var hashtag = component.find('inputHashtag').get('v.value');
		var triggerEnabledCheckbox = component.find('triggerEnabledCheckbox').get('v.value');

		// If hashtag input is not empty, validate it
		if ((!$A.util.isEmpty(hashtag) && !$A.util.isUndefinedOrNull(hashtag))) {
			// Check that there is a hashtag at the beginning
			if (hashtag.charAt(0).indexOf("#") === -1) {
				this.showToast('fail', 'Error', $A.get("$Label.c.No_hashtag_error"));
			} else {

				console.log(hashtag);
				console.log(hashtag.indexOf("]") === -1);
				// Check that text does not include a square bracket
				if (hashtag.indexOf("]") !== -1) {
					this.showToast('fail', 'Error', $A.get("$Label.c.Square_bracket_error"));
				} else { 
					var actionParams = {'hashtag' : hashtag, 'triggerEnabled' : triggerEnabledCheckbox};
					this.handleAction(component, actionParams, 'c.updateHashtagValue', this.updateHashtagValueCallback);
				}
			}
		} else {
			// If hashtag input is empty, set default value;
			component.set('v.hashtagValue', '#ArticleFeedback');
			var actionParams = {'hashtag' : '#ArticleFeedback', 'triggerEnabled' : triggerEnabledCheckbox};
			this.handleAction(component, actionParams, 'c.updateHashtagValue', this.updateHashtagValueCallback);
		}
	},

	updateHashtagValueCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response) && response.status === 'SUCCESS') {
			if (!component.isValid()) {
				return;
			} 

			ctx.showToast(' SUCCESS ', ' SUCCESS ', $A.get("$Label.c.Hashtag_value_updated_message"));
		} else {
			this.showToast('fail', 'Error', $A.get("$Label.c.Update_hashtag_error"));
		}
	}
})