global with sharing class afl_ArticleFeedbackFlowAction {
    @InvocableMethod(label='Get Knowledge Article' description='Gets data from knowledge article')
    global static List<Response> getKav (List<Request> req){
        List<Response> responses = new List<Response>();
        String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;
        Boolean hasRecordType = afl_ArticleFeedbackSecurityHandler.isRecordTypeIdActive;
        String recordTypeField = '';
        if (hasRecordType) {
            recordTypeField = ', RecordTypeId';
        }

		String query = 'SELECT Id, Title, VersionNumber, ArticleNumber, ArticleCreatedDate, KnowledgeArticleId, Language, LastPublishedDate, LastModifiedById ' + recordTypeField + ' FROM ' + knowledgeObject + ' WHERE Id = \'' + req[0].kavId + '\' LIMIT 1';
        List<SObject> sObjList = Database.query(query);
        if (!sObjList.isEmpty()) {
			SObject sObj = sObjList[0];
            Response response = new Response();
            response.kaId = (String) sObj.get('KnowledgeArticleId');
            response.articleTitle = (String) sObj.get('Title');
            response.articleVersion = (Decimal) sObj.get('VersionNumber');
            response.articleNumber = (String) sObj.get('ArticleNumber');
            response.articleCreatedDate = (Datetime) sObj.get('ArticleCreatedDate');
            response.articleLanguage = (String) sObj.get('Language');
            response.articleLastPublishedDate = (Datetime) sObj.get('LastPublishedDate');
            response.articleLastModifiedBy = (String) sObj.get('LastModifiedById');
			response.feedbackStatus = 'New';
			response.communityName = (String) getFeedbackSource(req[0].kavId).get('CommunityName');
			response.feedbackSource = (String) getFeedbackSource(req[0].kavId).get('FeedbackSource');
			response.articleUrl = (String) getFeedbackSource(req[0].kavId).get('ArticleUrl');

            if (hasRecordType) {
                if (String.isNotEmpty((String)sObj.get('RecordTypeId'))) {
                    response.articleRecordTypeName = afl_ArticleFeedbackSecurityHandler.getRecordTypeName(sObj);
                }
            }

            responses.add(response);
        }
        
        return responses;
    }

    global static Map<String, String> getFeedbackSource(String articleId) {
        Map<String, String> result = new Map<String, String>();
		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
		String communityName = afl_ArticleFeedbackSecurityHandler.getCommunityName();

        if (String.isNotEmpty(communityName)) {
            String networkId = Network.getNetworkId();
            String query = 'SELECT Id, UrlPathPrefix FROM Network WHERE Id =: networkId LIMIT 1';
            SObject ntw = Database.query(query);
            if(ntw.get('UrlPathPrefix') != null){
                result.put('ArticleUrl', (baseUrl + '/' + (String) ntw.get('UrlPathPrefix') + '/s/article/' + articleId));
            } else {
                result.put('ArticleUrl', (baseUrl + '/s/article/' + articleId));
            }
            result.put('CommunityName',communityName);
            result.put('FeedbackSource','Communities');

        } else {
            result.put('CommunityName','');
            result.put('FeedbackSource','Internal');
            result.put('ArticleUrl', (baseUrl + '/' + articleId));
        }
        return result;
    }

    global class Request {
        @InvocableVariable(required=true)
        global String kavId;
    }

    global class Response {
        @InvocableVariable
        global String kaId;
        @InvocableVariable
        global String articleTitle;
        @InvocableVariable
        global Decimal articleVersion;
        @InvocableVariable
        global String articleNumber;
        @InvocableVariable
        global Datetime articleCreatedDate;
        @InvocableVariable
        global String feedbackStatus;
        @InvocableVariable
        global String communityName;
        @InvocableVariable
        global String feedbackSource;
        @InvocableVariable
        global String articleLanguage;
        @InvocableVariable
        global Datetime articleLastPublishedDate;
        @InvocableVariable
        global String articleLastModifiedBy;
        @InvocableVariable
        global String articleRecordTypeName;
        @InvocableVariable
        global String articleUrl;
    }
}
