({
	handleAction : function(component, actionParams, actionName, successCallback, errorCallback) {
		var action = component.get(actionName);
		if (!$A.util.isUndefinedOrNull(actionParams)) {
			action.setParams(actionParams);
		}

		var self = this;
		action.setCallback(self, function(a) {
			try {
				if (a.getState() !== 'SUCCESS') {
					throw {'message' : 'An undetermined error occurred with the Apex call.'};
				}

				var result = a.getReturnValue();
				// Some error likely inside of the Apex code occurred.
				if (result.state !== 'SUCCESS') {
					// Try to get the error message from the lightningdmlerror object
					if(result.state != 'ERRORNOTFOUND'){
						var errorEncountered;
						if (!$A.util.isUndefinedOrNull(result.errors)) {
							errorEncountered = result.errors[0].message;
						} else {
							if (!$A.util.isUndefinedOrNull(result.error)) {
								errorEncountered = result.error;
							}
						}
						throw {
							'message' : 'An error occurred in the apex call',
							'extendedMessage' : errorEncountered
						};
					}
				}

				var returnValue = undefined;
				if (result.state == 'ERRORNOTFOUND') {
					// remove the modal that reads "The related article could not be found
					Response.error();
				}
				if (!$A.util.isEmpty(result.jsonResponse)) {
					// Will throw a JSON exception if the result cannot be parsed.
					returnValue = JSON.parse(result.jsonResponse);
				}
				var concreteComponent = component.getConcreteComponent();
				successCallback(concreteComponent,returnValue, self);
			} catch(ex) {
				// Handle any exceptions encountered in the callback
				var errorTitle = "An error occurred";
				var errorMessage = ex.message;
				if(ex.message=='Response.error is not a function'){
					//just show that can found the article and nothing else
				}
				else{

				// Add a detailed description of the error if one is found.
				if (!$A.util.isEmpty(ex.extendedMessage)) {
					errorMessage = ex.extendedMessage;
				}

				if ($A.util.isEmpty(errorCallback)) {
					self.handleError(component, errorTitle, errorMessage);
				} else {
					errorCallback(component, errorTitle, errorMessage);
				}
			}
			}
		});

		$A.enqueueAction(action);
	},

	handleError : function(component, errorTitle, errorMessage) {
		this.showToast('error', errorTitle, errorMessage);
	},

	showToast : function(type, title, message, mode) {
		
		var toastEvent = $A.get("e.force:showToast");
		if (!$A.util.isUndefinedOrNull(toastEvent)) {
			toastEvent.setParams({
				"title" : title,
				"type" : type,
				"message" : message,
				"mode" : !$A.util.isUndefinedOrNull(mode) ? mode : 'sticky',
				"duration" : 5000
			});
			
			toastEvent.fire();
		} else {
			alert('Message : ' + message);
		}
	}
})