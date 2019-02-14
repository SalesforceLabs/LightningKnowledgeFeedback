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

            if (lstAF.size() > 0) {
                afl_Article_Feedback__c af = lstAF.get(0);
                kavId = af.Knowledge_Article_Version_Id__c;
                result.put('kavId', kavId);
                // We get the language - vers
                result = getCompactLayoutData(kavId, result);

                // Check FLS
                if (!afl_ArticleFeedbackSecurityHandler.getKAVPermissions()) {
                    throw new SecurityException(afl_ArticleFeedbackSecurityHandler.formatReplace(afl_ArticleFeedbackSecurityHandler.ERROR_OBJECT_NOT_ACCESSIBLE,  new String[] {knowledgeObject}));
                }

                String query = ' SELECT Id, ArchivedDate, KnowledgeArticleId, Language, PublishStatus, VersionNumber' +
                ' FROM ' + knowledgeObject +
                ' WHERE Id = \'' + kavId + '\' ' +
                ' LIMIT 1';
                SObject actualKav = Database.query(query);

                if (actualKav != null) {
                    Boolean isArchived = ((String) actualKAV.get('PublishStatus') == 'Archived') ? true : false;
                    result.put('isArchived', isArchived);

                    if (af.Originated_From_Trigger__c) {
                        result.put('originatedFromTrigger', true);
                    } else {
                        result.put('hasMultipleLanguages', false);
                    }

                    String relatedQuery = ' SELECT Id, IsMasterLanguage, Language' +
                    ' FROM ' + knowledgeObject +
                    ' WHERE KnowledgeArticleId = \'' + (String) actualKAV.get('KnowledgeArticleId') + '\' AND ' +
                    ' PublishStatus = \'Online\' ' +
                    ' ORDER BY Language DESC';
                    List<SObject> relatedKavs =  Database.query(relatedQuery);

                    if (relatedKavs.size() > 1) {
                        Map<String,String> idsToLanguage = new Map<String,String>();
                        Map<String,String> languageValueToLabel = new Map<String,String>();
                        Set<String> languagesList = new Set<String>();

                        for (SObject relatedKav : relatedKavs) {
                            languagesList.add((String) relatedKav.get('Language'));
                        }

                        // Get languages label
                        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
                        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
                        for (Schema.PicklistEntry picklistEntry : picklistValues) {
                            if (languagesList.contains(picklistEntry.getValue())) {
                                languageValueToLabel.put(picklistEntry.getValue(), picklistEntry.getLabel());
                            }
                        }

                        for (SObject relatedKav : relatedKavs) {
                            if ((Boolean) relatedKav.get('IsMasterLanguage')) {
                                idsToLanguage.put((String) actualKav.get('Id'), languageValueToLabel.get((String) actualKav.get('Language')));
                            } else {
                                idsToLanguage.put((String) relatedKav.get('Id'), languageValueToLabel.get((String) relatedKav.get('Language')));
                            }
                        }

                        result.put('languagesMap', idsToLanguage);
                        result.put('hasMultipleLanguages', true);
                    } else {
                        result.put('originatedFromTrigger', false);
                    }
                } else {
                    response.state = 'ERROR';
                    response.error = 'An error occurred getting the Id of the related article, please check that the component is in the correct record page.';
                }
            } else {
                response.state = 'ERROR';
                response.error = 'An error occurred getting the Id of the article feedback, please check that the component is in the correct record page.';
            }

            response.jsonResponse = JSON.serialize(result);
        } catch (QueryException ex) {
            response.state = 'ERROR';
            response.error = 'An error ocurred while retrieving the information, the related article was not found.';
        } catch(Exception e) {
            response = new afl_LightningResponse(e);
        }

        return response;
    }

    /*
    * @description
    *   Retrieves a Map<String,Object> with kavId, some necessary fields of the kav and
    *   information about if the article its archived.
    * @params
    *   Id of the knowledge Article
    * @return
    *   Map<String,Object> with the kav id , some fields of the article compact layout, and information about if the article its archived.
    */
    @AuraEnabled
    public static afl_LightningResponse reloadKav(String kavId) {
        afl_LightningResponse response = new afl_LightningResponse();
        Map<String,Object> result = new Map<String,Object>();
        try {
            result.put('kavId', kavId);
            // We get the language - vers
            result = getCompactLayoutData(kavId, result);

            // Check FLS
            if (!afl_ArticleFeedbackSecurityHandler.getKAVPermissions()) {
                throw new SecurityException(afl_ArticleFeedbackSecurityHandler.formatReplace(afl_ArticleFeedbackSecurityHandler.ERROR_OBJECT_NOT_ACCESSIBLE,  new String[] {knowledgeObject}));
            }

            String query = ' SELECT Id, ArchivedDate, KnowledgeArticleId, Language, PublishStatus, VersionNumber' +
            ' FROM ' + knowledgeObject +
            ' WHERE Id = \'' + kavId + '\' ' +
            ' LIMIT 1';
            SObject actualKav =  Database.query(query);

            if (actualKav != null) {
                Boolean isArchived = ((String) actualKAV.get('PublishStatus') == 'Archived') ? true : false;
                result.put('isArchived', isArchived);
            } else {
                response.state = 'ERROR';
                response.error = 'An error occurred getting the Id of the related article, please check that the component is in the correct record page.';
            }

            response.jsonResponse = JSON.serialize(result);
        } catch (QueryException ex) {
            response.state = 'ERROR';
            response.error = 'An error ocurred while retrieving the information, the related article was not found.';
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
        // KnowledgeArticleVersion article = [ SELECT ArticleNumber,CreatedDate,Id,Language,VersionNumber,PublishStatus FROM KnowledgeArticleVersion WHERE Id =:kavId ];
        // Find the associated record type
        String queryString = '';
        List<SObject> sObjList = new List<SObject>();
        // String recType = 'This article has no record type';
        Map<Id,String> recordTypeDetails = afl_ArticleFeedbackSecurityHandler.getAllowedRecordTypesMap();
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
                    if (!test.isRunningTest()) {
                        String rTypeId = (String) sObjKnowledge.get('RecordTypeId');
                        if (recordTypeDetails.containsKey(rTypeId)) {
                            result.put('articleRecordType', recordTypeDetails.get(rTypeId));
                        }
                    } else {
                        result.put('articleRecordType', 'test article type');
                    }
                }
            }

            result.put('articleVersion', (Decimal) sObjKnowledge.get('VersionNumber'));
            result.put('articleNumber',(String) sObjKnowledge.get('ArticleNumber'));
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
