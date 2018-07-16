public with sharing class afl_RelatedArticleCtrl {

    public static String knowledgeObject = ArticleFeedbackSecurityHandler.knowledgeObject;

    /*
    * @description
    *   Retrieves a Map<String,Object> with kavId , some necessary fields of the kav and
    *   information about if the article its archived.
    * @params
    *   Id of the article feedback object
    * @return
    *   Map<String,Object> with the kav id , some fields of the article compact layout, and information about if the article its archived.
    */
    @AuraEnabled
    public static afl_LightningResponse loadKAVId(String recordId){
        afl_LightningResponse response = new afl_LightningResponse();
        Map<String,  Object> result = new Map<String,  Object>();
        String kavId = '';
        try {
            response.state = 'SUCCESS';
            Article_Feedback__c af = [Select Id, Knowledge_Article_Version_Id__c  from Article_Feedback__c  where id=:recordId LIMIT 1];


            if (af != null) {
                kavId =  af.Knowledge_Article_Version_Id__c;
                result.put('kavId', kavId);
                //we get the language - vers
                result = getCompactLayoutData(kavId,result);
                string query =  '	SELECT Id,ArchivedDate, KnowledgeArticleId, Language ,PublishStatus, VersionNumber'+
                '	FROM KnowledgeArticleVersion ' +
                '	WHERE Id = \'' + kavId + '\' LIMIT 1';
                ArticleFeedbackSecurityHandler.canAccess(KnowledgeArticleVersion.sObjectType);
                KnowledgeArticleVersion actualKav =  Database.query(query);
                if(actualKav != null) {
                    Boolean isArchived = (actualKAV.PublishStatus == 'Archived') ? true : false;
                    result.put('isArchived', isArchived);
                } else {
                	response.state = 'ERROR';
                	response.error = 'An error occurred getting the id of the related article, please check that the component is in the correct record page.';
            	}

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
        return response;
    }

    /*
    * @description
    *   Retrieves a Map<String,Object> with some fields of the article compact layout to display on our
    *   lightning component 'aqi_RelatedArticle' and with this avoid some duplicated values on the layout.
    *   For example in the record page of Knowledge we dont need to show the language cause appears on the compact layout
    *   but in other component that contain the article layout data we will need another way to display the language without
    *   add it to the layout.
    * @params
    *   Id of the kav and Map<String,Object> with some fields of the article compact layout
    * @return
    *   Map<String,Object> with the defined fields of the kav with the kavId received
    */
    public static Map<String,Object> getCompactLayoutData(String kavId, Map<String,Object> result) {
        KnowledgeArticleVersion article = [ SELECT ArticleNumber,CreatedDate,Id,Language,VersionNumber,PublishStatus FROM KnowledgeArticleVersion WHERE Id =:kavId ];
        // Find the associated record type
        String queryString = '';
        List<SObject> sObjList = new List<SObject>();
        String recType = 'This article has no record type';
        if(ArticleFeedbackSecurityHandler.isRecordTypeIdActive){
            queryString = 'SELECT  Id, RecordTypeId, RecordType.Name FROM ' + knowledgeObject + ' WHERE Id =  \'' + kavId + '\'';
            sObjList = Database.query(queryString);
            if(sObjList != null && !sObjList.isEmpty()){
                SObject sObjKnowledge = sObjList.get(0);
                recType = sObjKnowledge.getSObject('RecordType') != null ? (String)sObjKnowledge.getSObject('RecordType').get('Name') : 'This article has no record type';
            }
        }
        result.put('articleVersion', article.VersionNumber);
		result.put('articleRecordType', recType);
		result.put('articleNumber',article.ArticleNumber);
		result.put('articlePublishingStatus',article.PublishStatus);
        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            if(picklistEntry.getValue() == article.Language){
                result.put('articleLanguage', picklistEntry.getLabel());
            }
        }
        return result;
    }
}