/**
 * @author Altimetrik
 * @description
 *  started on MM/DD/YYYY
 *  REPLACE_BY_CLASS_LOGIC_RESPONSABILITIES
 **/
public with sharing class kfk_WrapperCtrl {
    // Constants

    //************************************************************************
    // Properties & data members



    //************************************************************************
    // Methods

    public kfk_WrapperCtrl() {}


    @AuraEnabled
    public static kfk_LightningResponse getInitData(String recordId){

	    kfk_LightningResponse response = new kfk_LightningResponse();
       	Map<String,Object> result = new Map <String,Object>();
		//get Ka Id from Kav Id
		List<KnowledgeArticleVersion> kaList = [SELECT Id,KnowledgeArticleId 
                                                FROM KnowledgeArticleVersion where id =:recordId];
        if (!kaList.isEmpty()){
            KnowledgeArticleVersion k = kaList.get(0);
            Vote res;
            List<Vote> voteResult = [SELECT CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,
                              		LastModifiedDate,ParentId,SystemModstamp,Type 
                              	FROM Vote WHERE ParentId =: k.KnowledgeArticleId];
        	if (!voteResult.isEmpty())
                res  = voteResult.get(0);
        	result.put('ka_vote',res);
            
            Article_Feedback__c fRes;
            String kId = '%'+k.KnowledgeArticleId+'%';
            List<Article_Feedback__c> feedbackResult = [SELECT Action_Date__c,Action_Taken__c,Article_Created_Date__c,Article_Feed_Update__c,
                                     		Article_Link__c,Article_Number__c,Article_Title__c,Article_Type__c,Article_Version__c,
                                     		Assigned_To__c,Community_Name__c,CreatedById,CreatedDate,Feedback_Source__c,Feedback_Status__c,
                                     		Feedback__c,Id,Internal_Notes__c,IsDeleted,Is_Current_User__c,Language__c,
                                     	LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Last_Published_By__c,
                                     	Last_Published_Date__c,Name,OwnerId,Parent_FeedItem__c,SystemModstamp 
                                     		FROM Article_Feedback__c 
                                     WHERE Article_Link__c LIKE :kId AND CreatedById =:UserInfo.getUserId()];
            
            system.debug('\n k.KnowledgeArticleId :'+k.KnowledgeArticleId+'\n UserInfo.getUserId() :'+UserInfo.getUserId());
            if (!feedbackResult.isEmpty())
                fRes  = feedbackResult.get(0);
            result.put('ka_feedback',fRes);
        response.jsonResponse = JSON.serialize(result);
        }
        
		return response;
    }



    @AuraEnabled
    public static kfk_LightningResponse loadKAVId(String recordId){
        kfk_LightningResponse response = new kfk_LightningResponse();
        Map<String,  Object> result = new Map<String,  Object>();
        String kavId = '';
        try{
            response.state = 'SUCCESS';
            List<Article_Feedback__c > l = [Select Id, Article_Link__c  from Article_Feedback__c  where id=:recordId];

            if (!l.isEmpty()){
                String aux =  l.get(0).Article_Link__c;
                List<String> tmp = aux.split('/');
                kavId = tmp.get(tmp.size()-1);
                result.put('kavId', kavId);
                Boolean isArchived = false;
                string query =  '	SELECT Id,ArchivedDate, KnowledgeArticleId '+
                                '	FROM KnowledgeArticleVersion ' +
                                '	WHERE PublishStatus = \'Archived\' ' +
                                            ' and Id = \'' + kavId + '\' ';
                //aqi_SecurityHandler.canAccess(KnowledgeArticleVersion.sObjectType);
                List<KnowledgeArticleVersion> actualKavs =  Database.query(query);
                if(!actualKavs.isEmpty()){
                    isArchived = true;
                }
                result.put('isArchived', isArchived);
            }
            else {
                response.state = 'ERROR';
                response.error = 'An error occurred getting the id of the related article, please check that the component is in the correct record page.';
            }

            response.jsonResponse = JSON.serialize(result);

        }
        catch(Exception e){
            response.state = 'ERROR';
        }
system.debug('\n======\n');
        
system.debug(response);

        return response;
    }

}