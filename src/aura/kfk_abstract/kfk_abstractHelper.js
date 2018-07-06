({
	handleAction : function(component, actionParams, actionName, successCallback, errorCallback){

		var action = component.get(actionName);
		action.setParams(actionParams);
		var self = this;
		action.setCallback(self,function(a){
			try{
				if(a.getState() !== 'SUCCESS'){
					throw {'message' : 'An undetermined error occurred with the Apex call.'};
				}

				var result = a.getReturnValue();
				//Some error likely inside of the Apex code occurred.
				if(result.state !== 'SUCCESS'){
					//Try to get the error message from the lightningdmlerror object

					var errorEncountered;
					if (!$A.util.isUndefinedOrNull(result.errors) ){
						errorEncountered = result.errors[0].message;
					}
					else{
							if (!$A.util.isUndefinedOrNull(result.error) )
								errorEncountered = result.error;
						}
					throw {
						'message' : 'An error occurred in the apex call',
						'extendedMessage' : errorEncountered
					};
				}

				var returnValue = undefined;
				if(!$A.util.isEmpty(result.jsonResponse)){
					//Will throw a JSON exception if the result cannot be parsed.
					returnValue = JSON.parse(result.jsonResponse);
				}

				//SUCCESS!!! Use the parameterized callback for additional / specific logic.
				var concreteComponent = component.getConcreteComponent();
				successCallback(concreteComponent,returnValue, self);
			}catch(ex){
				//Handle any exceptions encountered in the callback
				var errorTitle = "An error occurred";
				var errorMessage = ex.message;

				//Add a detailed description of the error if one is found.
				if(!$A.util.isEmpty(ex.extendedMessage)){
					errorMessage = ex.extendedMessage;
				}

				if($A.util.isEmpty(errorCallback)){
					self.handleError(component, errorTitle, errorMessage);
				}else{
					errorCallback(component, errorTitle, errorMessage);
				}
			}
		});

		$A.enqueueAction(action);
	},
	handleError : function(component, errorTitle, errorMessage){
		this.showToast('error', errorTitle, errorMessage);
	},
	showToast : function(type, title, message){

		var toastEvent = $A.get("e.force:showToast");
		if (!$A.util.isUndefinedOrNull(toastEvent)){
			toastEvent.setParams({
				"title" : title,
				"type" : type,
				"message" : message,
				"mode" : "sticky",
				"duration" : 30000
			});
			toastEvent.fire();
		}else{
			alert('title :'+title+' -  type : '+type+' -  message : '+message);
		}
	}
})