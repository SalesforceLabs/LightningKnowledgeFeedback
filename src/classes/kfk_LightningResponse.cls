/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Returns the operation result to the view
 **/
public class kfk_LightningResponse {

	@AuraEnabled public String jsonResponse {get; set;}
    @AuraEnabled public String error {get; set;}
    @AuraEnabled public String state {get; set;}

    public kfk_LightningResponse() {
        this.state = 'SUCCESS';
    }

    public kfk_LightningResponse(Exception e) {
    	this();
    	if(e != null){
    		this.state = 'ERROR';
            this.error = e.getMessage();
        }
    }
}