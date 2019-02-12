/**
* @author Altimetrik
* @description
* started on July 2018
* This class is responsible of the interaction with lightning components
**/
public class afl_LightningResponse {
    @AuraEnabled public String jsonResponse {get; set;}
	@AuraEnabled public String error {get; set;}
	@AuraEnabled public String state {get; set;}

	/*
	* @description
	*	Set the current state as Success
	*/
	public afl_LightningResponse() {
		this.state = 'SUCCESS';
	}

	/*
	* @description
	*	Set the current state as Error if exist and exception
	*/
	public afl_LightningResponse(Exception e) {
		this();
		if (e != null) {
			this.state = 'ERROR';
			this.error = e.getMessage();
		}
	}
}
