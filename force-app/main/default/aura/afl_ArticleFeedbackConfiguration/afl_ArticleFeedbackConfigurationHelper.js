({
	getInitialData : function(component, event) {
		this.handleAction(component, null, 'c.getInitialData', this.getInitialDataCallback);
	},

	getInitialDataCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response)) {
			if (!component.isValid()) { 
				return;
			}

			component.set('v.hashtagValue', response.hashtag);
		}
	},

	addPicklistValueHelper: function(component, event) {
		var picklistValue = component.find('picklistValue').get('v.value');
		console.log('test');
		if (!$A.util.isEmpty(picklistValue) && !$A.util.isUndefinedOrNull(picklistValue)) {
			var feedbackType = component.find('feedbackType').get('v.value');
			
			if (picklistValue.indexOf(";") > -1) {
				this.showToast('fail', 'Error', 'The picklist value cannot include a semi-colon.');
			} else if (feedbackType.length === 0) {
				this.showToast('fail', 'Error', 'You need to select at least a type of feedback value.');
			} else { 
				var reasonType = '';
				if (feedbackType.length === 2) {
					reasonType = 'bothOption';
				} else {
					reasonType = feedbackType[0];
				}

				// var actionParams = {'value': picklistValue};
				// this.handleAction(component, actionParams, 'c.updateHashtagValue', this.addPicklistValueCallback);
				var actionParams = {value : picklistValue, type : reasonType};
				// var actionParams = {value : picklistValue};
				this.handleAction(component, actionParams, 'c.addPicklistValue', this.addPicklistValueCallback);
			}
		} else {
			this.showToast('fail', 'Error', 'The picklist value field cannot be empty.');
		}
	},

	addPicklistValueCallback: function(component, response, ctx) {
		console.log('addPicklistValueCallback');
		if (!$A.util.isUndefinedOrNull(response) && response.status === 'SUCCESS') {
			if (!component.isValid()) {
				return;
			} 

			ctx.showToast(' SUCCESS ', ' SUCCESS ', 'Value added correctly.');
		} else {
			this.showToast('fail', 'Error', 'An error ocurred while adding the value');
		}
	},

	updateHashtagHelper: function(component, event) {
		var hashtag = component.find('inputHashtag').get('v.value');
		if ((!$A.util.isEmpty(hashtag) && !$A.util.isUndefinedOrNull(hashtag)) && hashtag.indexOf("]") === -1) {
			if (hashtag.indexOf("#") === -1) {
				this.showToast('fail', 'Error', 'The text needs to includ a hashtag (#) sign to be valid.');
			} else { 
				var actionParams = {value : hashtag};
				this.handleAction(component, actionParams, 'c.updateHashtagValue', this.updateHashtagValueCallback);
			}
		} else {
			this.showToast('fail', 'Error', 'This field cannot be empty or include a closing square bracket (])');
		}
	},

	updateHashtagValueCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response) && response.status === 'SUCCESS') {
			if (!component.isValid()) {
				return;
			} 

			ctx.showToast(' SUCCESS ', ' SUCCESS ', 'Hashtag value successfully updated');
		} else {
			this.showToast('fail', 'Error', 'An error ocurred while updating the hashtag value');
		}
	}
})