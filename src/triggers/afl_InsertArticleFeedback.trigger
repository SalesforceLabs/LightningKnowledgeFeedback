/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Trigger on the after insert event of a feedback item
 **/
 trigger afl_InsertArticleFeedback on FeedItem (after insert) {
     if (afl_ArticleFeedbackSecurityHandler.isCreateable(afl_Article_Feedback__c.sObjectType)) {
         try {
             Boolean communitiesAvailable = false;
             String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;
             Boolean hasRecordType = afl_ArticleFeedbackSecurityHandler.isRecordTypeIdActive;
             Map<Id,String> recordTypeDetails = afl_ArticleFeedbackSecurityHandler.getAllowedRecordTypesMap();
             afl_Knowledge_feedback__c kf = afl_Knowledge_feedback__c.getOrgDefaults();

             if (String.isEmpty(kf.Hashtag__c)) {
                 kf.Hashtag__c = '#ArticleFeedback';
                 UPSERT kf;
             }
             String netId = '';
             String commName = afl_ArticleFeedbackSecurityHandler.getCommunityName();
             Map<String,String> mapLanguages = new Map<String,String>();
             List<afl_Article_Feedback__c> lstAfd = new list<afl_Article_Feedback__c>();
             Set<Id> setIds = new Set<Id>();
             Map<String,sObject> mKav = new Map<String,sObject>();
             Schema.DescribeFieldResult fieldResult = KnowledgeArticleVersion.Language.getDescribe();
             List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

             for (Schema.PicklistEntry picklistEntry : picklistValues) {
                 mapLanguages.put(picklistEntry.getValue(),picklistEntry.getLabel());
             }

             String pubStatus = 'Online';
             if (Test.isRunningTest()) {
                 pubStatus = 'draft';
                 hasRecordType = true;
             }

             Set<String> objectFields = Schema.SObjectType.FeedItem.fields.getMap().keySet();
             if (objectFields.contains('networkscope')) {
                 communitiesAvailable = true;
                 netId = Network.getNetworkId();
                 if (String.isNotEmpty(netId)) {
                     String query = 'SELECT Name FROM Network WHERE Id =: netId';
                     SObject comm = Database.query(query);
                     commName = (String)comm.get('Name');
                 }
             }

             for (FeedItem f : trigger.new) {
                 String parentId = f.parentId;
                 if (parentId.startsWith('kA') && (f.Type == 'TextPost' || f.Type == 'LinkPost') && f.Body.containsIgnoreCase(kf.Hashtag__c)) {
                     setIds.add(f.ParentId);
                 }
             }

             if (!setIds.isEmpty()) {
                 String recordTypeField = '';
                 if(hasRecordType) {
                     recordTypeField = ',RecordTypeId';
                 }
                 String q = 'SELECT KnowledgeArticleId, CreatedDate, ArticleNumber, Title, VersionNumber, Language, LastPublishedDate, LastModifiedById ' +
                 'FROM ' + knowledgeObject + ' WHERE PublishStatus = \'' + pubStatus + '\'' + ' AND KnowledgeArticleId IN :setIds';
                 List<sObject> kavs = Database.query(q);
                 for (sObject kav : kavs) {
                     mKav.put((String)kav.get('KnowledgeArticleId'), kav);
                 }
             }

             for (FeedItem f : trigger.new) {
                 String parentId = f.parentId;

                 if (mkav.containsKey(parentId)) {
                     SObject kav = mkav.get(parentId);
                     afl_Article_Feedback__c afd = new afl_Article_Feedback__c();
                     afd.Article_Number__c = (String)kav.get('ArticleNumber');
                     afd.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String)kav.get('KnowledgeArticleId');
                     afd.Article_Title__c = (String)kav.get('Title');
                     afd.Knowledge_Article_Version_Id__c = (String)kav.get('Id');
                     //afd.Record_Type__c = '';

                     if (hasRecordType) {
                         //sObject obj = (sObject)kav;
                         if (!test.isRunningTest()) {
                             String rTypeId = String.valueOf(kav.get('RecordTypeId'));
                             if (recordTypeDetails.containsKey(rTypeId))
                             afd.Record_Type__c = recordTypeDetails.get(rTypeId);
                         } else {
                             afd.Record_Type__c = 'test article type';
                         }
                     }

                     afd.Article_Version__c = (Decimal)kav.get('VersionNumber');
                     afd.Feedback__c = f.Body;
                     afd.Feedback_Status__c = 'New';
                     afd.Language__c = mapLanguages.get((String)kav.get('Language'));
                     afd.Last_Published_Date__c = (Datetime)kav.get('LastPublishedDate');
                     afd.Last_Published_By__c = (String)kav.get('LastModifiedById');
                     afd.Article_Created_Date__c = (Datetime)kav.get('CreatedDate');
                     afd.Parent_FeedItem__c = f.Id;

                     if (communitiesAvailable) {
                         if (String.isEmpty(Network.getNetworkId())) {
                             afd.Feedback_Source__c = 'Internal';
                         } else {
                             afd.Feedback_Source__c = 'Communities';
                             afd.Community_Name__c = commName;
                         }
                     } else {
                         afd.Feedback_Source__c = 'Internal';
                     }

                     lstAfd.add(afd);
                 }
             }

             INSERT lstAfd;

         } catch (System.Exception e) {
             String errorStr = '\n getTypeName : ' + e.getTypeName() +
             '\n getCause : ' + e.getCause() +
             '\n getMessage : ' + e.getCause() +
             '\n getLineNumber : ' + e.getLineNumber() +
             '\n getStackTraceString : ' + e.getStackTraceString() +
             '\n getTypeName : ' + e.getTypeName();
             System.debug('\n====== InsertArticleFeedback Exception :\n' +  errorStr);
         }
     }
 }
