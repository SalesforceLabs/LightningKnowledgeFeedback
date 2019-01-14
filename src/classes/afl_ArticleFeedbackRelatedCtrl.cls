/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Retrieves article feedbacks related to current article feedback
**/
public with sharing class afl_ArticleFeedbackRelatedCtrl {
    
    public List<afl_Article_Feedback__c> records {get; set;}
    
    public afl_ArticleFeedbackRelatedCtrl(ApexPages.StandardController std) {
        afl_Article_Feedback__c af = (afl_Article_Feedback__c)std.getRecord();
        if (af != null) {
            af = [SELECT Article_Number__c, Record_Type__c, Article_Version__c
            FROM afl_Article_Feedback__c
            WHERE id =: af.Id
            LIMIT 1];
            
            records = [SELECT Id, Name, Feedback_Source__c, Feedback_Status__c, Assigned_To__c, Community_Name__c ,Feedback__c, CreatedDate
            FROM afl_Article_Feedback__c
            WHERE Article_Number__c =: af.Article_Number__c AND
            Record_Type__c =: af.Record_Type__c AND
            Article_Version__c =: af.Article_Version__c AND
            id !=: af.id
            ORDER BY CreatedDate DESC
            LIMIT 1000];
        }
    }
}
