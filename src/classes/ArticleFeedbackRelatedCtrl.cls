/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Retrieves article feedbacks related to current article feedback
 **/
public with sharing class ArticleFeedbackRelatedCtrl {

   public List<Article_Feedback__c> records {get; set;}

   public ArticleFeedbackRelatedCtrl(ApexPages.StandardController std) {
       Article_Feedback__c af = (Article_Feedback__c)std.getRecord();
       af = [select Article_Number__c, Article_Type__c, Article_Version__c from Article_Feedback__c where id =: af.Id limit 1];
       records = [select Id, Name, Feedback_Source__c, Feedback_Status__c, Assigned_To__c, Community_Name__c ,Feedback__c, CreatedDate
                  from Article_Feedback__c
                  where Article_Number__c =: af.Article_Number__c and
                       Article_Type__c =: af.Article_Type__c and
                       Article_Version__c =: af.Article_Version__c
                       and id !=: af.id
                       order by CreatedDate DESC
                       limit 1000];
   }
}