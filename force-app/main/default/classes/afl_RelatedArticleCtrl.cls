public with sharing class afl_RelatedArticleCtrl {
    public static String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;

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
    public static afl_LightningResponse loadKAVId(String recordId) {
        afl_LightningResponse response = new afl_LightningResponse();
        Map<String,Object> result = new Map<String,Object>();
        String kavId = '';
        try {
            afl_Article_Feedback__c[] lstAF = [
                SELECT Id, Knowledge_Article_Version_Id__c, Originated_From_Trigger__c
                FROM afl_Article_Feedback__c
                WHERE Id =:recordId
                LIMIT 1
            ];

            if (!lstAF.isEmpty()) {
                afl_Article_Feedback__c af = lstAF.get(0);
                kavId = af.Knowledge_Article_Version_Id__c;

                // Check FLS
                if (!afl_ArticleFeedbackSecurityHandler.getKAVPermissions()) {
                    throw new SecurityException(afl_ArticleFeedbackSecurityHandler.formatReplace(afl_ArticleFeedbackSecurityHandler.ERROR_OBJECT_NOT_ACCESSIBLE,  new String[] {knowledgeObject}));
                }

                String query = ' SELECT Id, ArchivedDate, KnowledgeArticleId, Language, PublishStatus, VersionNumber ' +
                ' FROM ' + knowledgeObject +
                ' WHERE Id = \'' + kavId + '\' ' +
                ' LIMIT 1';
                List<SObject> actualKavs = Database.query(query);

                if (!actualKavs.isEmpty()) {
                    SObject actualKav = actualKavs.get(0);
                    result.put('kavId', kavId);

                    // Get the language - vers from related article
                    result = getCompactLayoutData(kavId, result);

                    Boolean cameFromTrigger = (af.Originated_From_Trigger__c) ? true : false;
                    result.put('originatedFromTrigger', cameFromTrigger);

                    Boolean isArchived = ((String) actualKAV.get('PublishStatus') == 'Archived') ? true : false;
                    result.put('isArchived', isArchived);
                } else {
                    response.state = 'ERROR';
                    response.error = Label.Related_article_not_found_error;
                }
            } else {
                response.state = 'ERROR';
                response.error = Label.Article_Feedback_id_not_found_on_Related_Article_error;
            }

            response.jsonResponse = JSON.serialize(result);
        } catch(QueryException ex) {
            response.state = 'ERROR';
            response.error = Label.Related_article_information_retrieval_error;
        } catch(Exception e) {
            response = new afl_LightningResponse(e);
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
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(knowledgeObject);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        List<String> fieldLabels = new List<String>();
        result.put('languageLabel', fieldMap.get('Language').getDescribe().getLabel());
        result.put('articleNumberLabel', fieldMap.get('ArticleNumber').getDescribe().getLabel());
        result.put('publishStatusLabel', fieldMap.get('PublishStatus').getDescribe().getLabel());
        result.put('versionNumberLabel', fieldMap.get('VersionNumber').getDescribe().getLabel());

        // Find the associated record type
        String queryString = '';
        List<SObject> sObjList = new List<SObject>();
        String recordTypeField = '';
        if (afl_ArticleFeedbackSecurityHandler.isRecordTypeIdActive) {
            recordTypeField = ',RecordTypeId';
        }

        queryString = 'SELECT Id, ArticleNumber, CreatedDate, Language, VersionNumber, PublishStatus' + recordTypeField + ' FROM ' + knowledgeObject + ' WHERE Id =  \'' + kavId + '\'';
        sObjList = Database.query(queryString);
        if (sObjList != null && !sObjList.isEmpty()) {
            SObject sObjKnowledge = sObjList.get(0);

            // Get record type name
            if (afl_ArticleFeedbackSecurityHandler.isRecordTypeIdActive) {
                if (String.isNotEmpty((String) sObjKnowledge.get('RecordTypeId'))) {
                    result.put('articleRecordType', afl_ArticleFeedbackSecurityHandler.getRecordTypeName(sObjKnowledge));
                    result.put('recordTypeIdLabel', fieldMap.get('RecordTypeId').getDescribe().getLabel());
                }
            }

            result.put('articleVersion', (Decimal) sObjKnowledge.get('VersionNumber'));
            result.put('articleNumber', (String) sObjKnowledge.get('ArticleNumber'));
            result.put('articlePublishingStatus', (String) sObjKnowledge.get('PublishStatus'));

            Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                if (picklistEntry.getValue() == (String) sObjKnowledge.get('Language')) {
                    result.put('articleLanguage', picklistEntry.getLabel());
                }
            }
        }

        return result;
    }
}