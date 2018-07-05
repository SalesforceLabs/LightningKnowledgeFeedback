public class kfk_LightningResponse {

	@AuraEnabled public String jsonResponse {get; set;}
    @AuraEnabled public String error {get; set;}
    @AuraEnabled public String state {get; set;}

    public kfk_LightningResponse() {
        this.state = 'SUCCESS';
    }

    public kfk_LightningResponse(Exception e){
    	this();
    	if(e != null){
    		this.state = 'ERROR';
            this.error = e.getMessage();
        }
    }
}