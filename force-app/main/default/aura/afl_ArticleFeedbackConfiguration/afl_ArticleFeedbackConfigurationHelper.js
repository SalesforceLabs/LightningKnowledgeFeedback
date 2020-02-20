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
				component.set('v.hashtagValue', response.hashtag);
			}
		}
	},

	updateHashtagHelper: function(component) {
		var hashtag = component.find('inputHashtag').get('v.value');
		if ((!$A.util.isEmpty(hashtag) && !$A.util.isUndefinedOrNull(hashtag)) && hashtag.indexOf("]") === -1) {
			if (hashtag.charAt(0).indexOf("#") === -1) {
				this.showToast('fail', 'Error', $A.get("$Label.c.No_hashtag_error"));
			} else { 
				var actionParams = {'hashtag' : hashtag};
				this.handleAction(component, actionParams, 'c.updateHashtagValue', this.updateHashtagValueCallback);
			}
		} else {
			this.showToast('fail', 'Error', $A.get("$Label.c.No_hashtag_or_square_bracket_error"));
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