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

			if (!$A.util.isUndefinedOrNull(response.allPicklistValues)) {
				var jsonValues = response.allPicklistValues;
			 	var selectedValues = ctx.getPicklistValuesFromJSON(jsonValues);
				component.set('v.allValues', selectedValues);
			}
			
			if (!$A.util.isUndefinedOrNull(response.allPositiveValues)) {
				component.set('v.allPositiveValues', JSON.parse(response.allPositiveValues));
			}

			if (!$A.util.isUndefinedOrNull(response.allNegativeValues)) {
				component.set('v.allNegativeValues', JSON.parse(response.allNegativeValues));
			}

		}
	},

	getPicklistValuesFromJSON : function(picklistValuesJSON) {
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
			
			if (picklistValue.indexOf(";") > -1) {
				this.showToast('fail', 'Error', 'The picklist value cannot include a semi-colon.');
			} else {
				var actionParams = {'picklistValue' : picklistValue};
				this.handleAction(component, actionParams, 'c.addNewPicklistValue', this.addPicklistValueCallback);
			}
		} else {
			this.showToast('fail', 'Error', 'The picklist value field cannot be empty.');
		}
	},

	addPicklistValueCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response) && response.status === 'SUCCESS') {
			if (!component.isValid()) {
				return;
			} 

			component.find('picklistValue').set('v.value', '');
			ctx.getInitialData(component);
		} else if (response.status === 'DUPLICATED') {
			ctx.showToast('fail', 'Error', 'The value already exists.');
		} else {
			this.showToast('fail', 'Error', 'An error ocurred while adding the value');
		}
	},

	updateHashtagHelper: function(component) {
		var hashtag = component.find('inputHashtag').get('v.value');
		if ((!$A.util.isEmpty(hashtag) && !$A.util.isUndefinedOrNull(hashtag)) && hashtag.indexOf("]") === -1) {
			if (hashtag.charAt(0).indexOf("#") === -1) {
				this.showToast('fail', 'Error', 'The text needs to include a hashtag (#) sign at the beginning to be valid.');
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

	saveValueOrderHelper: function(component, event) {
		var allPositiveValues = component.get('v.allPositiveValues');
		var allNegativeValues = component.get('v.allNegativeValues');

		var valuesJSON = {};
		valuesJSON['allPositiveValues'] = allPositiveValues;
		valuesJSON['allNegativeValues'] = allNegativeValues;

		if (!$A.util.isUndefinedOrNull(allPositiveValues) || !$A.util.isUndefinedOrNull(allNegativeValues)) {
			var actionParams = {'savedValuesJSON' : JSON.stringify(valuesJSON)};
			if (event.getSource().get('v.label') == 'Save') {
				this.handleAction(component, actionParams, 'c.savePicklistOrder', this.saveValueOrderCallback);
			} else {
				this.handleAction(component, actionParams, 'c.savePicklistOrder', function(){});
			}
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
		var deleteValuesString = component.find("selectDelete").get('v.value');
		if (!$A.util.isEmpty(deleteValuesString) && !$A.util.isUndefinedOrNull(deleteValuesString)) {
			var deleteValuesList = deleteValuesString.split(';');
			var actionParams ={
				'deleteValuesList' : deleteValuesList
			};
			this.handleAction(component, actionParams, 'c.deleteValues', this.deleteValueCallback);
		} else {
			this.showToast('fail', 'Error', 'You need to select at least one value to delete');
		}
	},

	deleteValueCallback : function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response) && response.length > 0) {
			ctx.getInitialData(component);
			ctx.showToast(' SUCCESS ', ' SUCCESS ', 'Values succesfully deleted');
		} else {
			this.showToast('fail', 'Error', 'An error ocurred while deleting the values');
		}
	}
})