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
				this.showToast('fail', 'Error', $A.get("$Label.c.Picklist_with_semicolon_error"));
			} else {
				var actionParams = {'picklistValue' : picklistValue};
				this.handleAction(component, actionParams, 'c.addNewPicklistValue', this.addPicklistValueCallback);
			}
		} else {
			this.showToast('fail', 'Error', $A.get("$Label.c.Picklist_empty_error"));
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
			ctx.showToast('fail', 'Error', $A.get("$Label.c.Value_exists_error"));
		} else {
			this.showToast('fail', 'Error', $A.get("$Label.c.Adding_value_error"));
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
	}, 

	saveValueOrderHelper: function(component, event) {
		var allPositiveValues = component.get('v.allPositiveValues');
		var allNegativeValues = component.get('v.allNegativeValues');

		var valuesJSON = {};
		valuesJSON['allPositiveValues'] = allPositiveValues;
		valuesJSON['allNegativeValues'] = allNegativeValues;

		if (!$A.util.isUndefinedOrNull(allPositiveValues) || !$A.util.isUndefinedOrNull(allNegativeValues)) {
			var actionParams = {'savedValuesJSON' : JSON.stringify(valuesJSON)};
			if (event.getSource().getLocalId() == 'saveButton') {
				this.handleAction(component, actionParams, 'c.savePicklistOrder', this.saveValueOrderCallback);
			} else {
				this.handleAction(component, actionParams, 'c.savePicklistOrder', function(){});
			}
		} else {
			this.showToast('fail', 'Error', $A.get("$Label.c.No_hashtag_or_square_bracket_error"));
		}
	},

	saveValueOrderCallback: function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response) && response.status === 'SUCCESS') {
			if (!component.isValid()) {
				return;
			} 

			ctx.showToast(' SUCCESS ', ' SUCCESS ', $A.get("$Label.c.Values_updated_message"));
		} else {
			this.showToast('fail', 'Error', $A.get("$Label.c.Update_values_error"));
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
			this.showToast('fail', 'Error', $A.get("$Label.c.Select_a_value_to_delete_error"));
		}
	},

	deleteValueCallback : function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response) && response.length > 0) {
			ctx.getInitialData(component);
			ctx.showToast(' SUCCESS ', ' SUCCESS ', $A.get("$Label.c.Values_deleted_message"));
		} else {
			this.showToast('fail', 'Error', $A.get("$Label.c.Deleting_values_error"));
		}
	}
})