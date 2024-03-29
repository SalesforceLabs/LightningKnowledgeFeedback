/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Front Controller for Article Feedback project setup page
**/
public with sharing class afl_ArticleFeedbackConfigCtrl {
    public afl_Knowledge_feedback__c csObj {get; set;}
    public Boolean editMode {get;set;}

    public afl_ArticleFeedbackConfigCtrl() {
        editMode = false;
        csObj = afl_Knowledge_feedback__c.getOrgDefaults();
    }

    public PageReference edit() {
        editMode = true;
        return null;
    }

    public PageReference cancel() {
        editMode = false;
        csObj = afl_Knowledge_feedback__c.getOrgDefaults();
        PageReference page = new PageReference('/apex/afl_ArticleFeedbackConfigPage');
        page.setRedirect(true);

        return page;
    }

    public PageReference save() {
        try {
            upsert csObj;
            editMode = false;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            e.getMessage()
           ));
        }

        return null;
    }
}