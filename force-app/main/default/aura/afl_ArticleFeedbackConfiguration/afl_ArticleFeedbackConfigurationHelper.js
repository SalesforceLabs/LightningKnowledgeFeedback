({
	getInitialData : function(component) {
		this.handleAction(component, null, 'c.getInitialData', this.getInitialDataCallback);
	},

	getInitialDataCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response)) {
			if (!component.isValid()) { 
				return;
			}

			console.log('test'); 
			if (!$A.util.isUndefinedOrNull(response.hashtag)) {
				component.set('v.hashtagValue', response.hashtag);
			}

			if (!$A.util.isUndefinedOrNull(response.allPicklistValues)) {
				component.set('v.deleteValues', JSON.parse(response.allPicklistValues));
			}
			
			if (!$A.util.isUndefinedOrNull(response.activePositiveValues)) {
				component.set('v.activePositiveValues', JSON.parse(response.activePositiveValues));
			}

			if (!$A.util.isUndefinedOrNull(response.activeNegativeValues)) {
				component.set('v.activeNegativeValues', JSON.parse(response.activeNegativeValues));
			}

			if (!$A.util.isUndefinedOrNull(response.allPositiveValues)) {
				var jsonValues = response.allPositiveValues;
				var selectedValues = ctx.getPicklistValuesFromJSON(jsonValues);
				component.set('v.allPositiveValues', selectedValues);
			}

			if (!$A.util.isUndefinedOrNull(response.allNegativeValues)) {
				var jsonValues = response.allNegativeValues;
				var selectedValues = ctx.getPicklistValuesFromJSON(jsonValues);
				component.set('v.allNegativeValues', selectedValues);
			}

			console.log('end test');
		}
	},

	getPicklistValuesFromJSON: function(picklistValuesJSON) {
		var selectedValues = [];
		var returnSelectedValues = JSON.parse(picklistValuesJSON);
		for (var i = 0; i < returnSelectedValues.length; i++) {
			var item = {"label": returnSelectedValues[i], "value": returnSelectedValues[i]};
			selectedValues.push(item);
		}
		
		return selectedValues;
	},

	addPicklistValueHelper: function(component) {
		var picklistValue = component.find('picklistValue').get('v.value');
		if (!$A.util.isEmpty(picklistValue) && !$A.util.isUndefinedOrNull(picklistValue)) {
			var feedbackType = component.find('feedbackType').get('v.value');
			
			if (picklistValue.indexOf(";") > -1) {
				this.showToast('fail', 'Error', 'The picklist value cannot include a semi-colon.');
			} else if (feedbackType.length === 0) {
				this.showToast('fail', 'Error', 'You need to select at least one checbox to set a Reason Type.');
			} else { 
				var reasonType = '';
				if (feedbackType.length === 2) {
					reasonType = 'bothOption';
				} else {
					reasonType = feedbackType[0];
				}

				var actionParams = {'picklistValue' : picklistValue, 'reasonType' : reasonType};
				this.handleAction(component, actionParams, 'c.addNewPicklistValue', this.addPicklistValueCallback);
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
			component.find('picklistValue').set('v.value', '');
			ctx.getInitialData(component);
		} else {
			this.showToast('fail', 'Error', 'An error ocurred while adding the value');
		}
	},

	updateHashtagHelper: function(component) {
		var hashtag = component.find('inputHashtag').get('v.value');
		if ((!$A.util.isEmpty(hashtag) && !$A.util.isUndefinedOrNull(hashtag)) && hashtag.indexOf("]") === -1) {
			if (hashtag.indexOf("#") === -1) {
				this.showToast('fail', 'Error', 'The text needs to includ a hashtag (#) sign to be valid.');
			} else { 
				var actionParams = {'hashtag' : hashtag};
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
	}, 

	saveValueOrderHelper: function(component) {
		var activePositiveValues = component.get('v.activePositiveValues');
		var activeNegativeValues = component.get('v.activeNegativeValues');
		console.log('activePositiveValues: ' + activePositiveValues);
		console.log('activeNegativeValues: ' + activeNegativeValues);

		var valuesJSON = {};
		valuesJSON['activePositiveValues'] = activePositiveValues;
		valuesJSON['activeNegativeValues'] = activeNegativeValues;

		console.log('valuesJSON: ' + valuesJSON);
		console.log('JSON.stringify(valuesJSON): ' + JSON.stringify(valuesJSON));

		if (!$A.util.isUndefinedOrNull(activePositiveValues) || !$A.util.isUndefinedOrNull(activeNegativeValues)) {
			var actionParams = {'savedValuesJSON' : JSON.stringify(valuesJSON)};

			this.handleAction(component, actionParams, 'c.savePicklistOrder', this.saveValueOrderCallback);
		} else {
			this.showToast('fail', 'Error', 'This field cannot be empty or include a closing square bracket (])');
		}
	},

	saveValueOrderCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response) && response.status === 'SUCCESS') {
			if (!component.isValid()) {
				return;
			} 

			ctx.showToast(' SUCCESS ', ' SUCCESS ', 'Values succesfully updated');
		} else {
			this.showToast('fail', 'Error', 'An error ocurred while updating the values');
		}
	}, 

	deleteValueHelper: function(component) {
		// Do something
	}
})