/**
 * @author Altimetrik
 * @description
 *    started on 07/12/2018
 *    Test class for the ArticleFeedbackSecurityHandler trigger
 **/
@isTest
public class afl_ArticleFeedbackSecurityHandler_Test {

	public static testMethod void testSecurityEnabled() {
	   Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];
	   Map<Id,String> profileMap = new Map<Id,String>();

	   for( Profile p : profileList ){
		   profileMap.put( p.id, p.Name );
	   }

	   List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

	   if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ){
		   for (Profile p : profileList) {
			   u[0].profileId = p.id;
			   update u;
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.sObjectType), Case.sObjectType.getDescribe().isAccessible());
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.sObjectType), Case.sObjectType.getDescribe().isCreateable());
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.sObjectType), Case.sObjectType.getDescribe().isUpdateable());
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isDeletable(Case.sObjectType), Case.sObjectType.getDescribe().isDeletable());
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.subject), Case.subject.getDescribe().isAccessible());
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.subject), Case.subject.getDescribe().isCreateable());
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), Case.subject.getDescribe().isUpdateable());

			   if (Case.sObjectType.getDescribe().isAccessible())
				   afl_ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
			   else
				   try {
					   afl_ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.sObjectType.getDescribe().isCreateable())
				   afl_ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
			   else
				   try {
					   afl_ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.sObjectType.getDescribe().isUpdateable())
				   afl_ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
			   else
				   try {
					   afl_ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.sObjectType.getDescribe().isDeletable())
				   afl_ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
			   else
				   try {
					   afl_ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.subject.getDescribe().isAccessible())
				   afl_ArticleFeedbackSecurityHandler.canAccess(Case.subject);
			   else
				   try {
					   afl_ArticleFeedbackSecurityHandler.canAccess(Case.subject);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.subject.getDescribe().isCreateable())
				   afl_ArticleFeedbackSecurityHandler.canCreate(Case.subject);
			   else
				   try {
					   afl_ArticleFeedbackSecurityHandler.canCreate(Case.subject);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.subject.getDescribe().isUpdateable())
				   afl_ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
			   else
				   try {
					   afl_ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
					   System.assert(false);
				   } catch (SecurityException e) {}
		   }
	   }
   }

   public static testMethod void testSecurityDisabled() {
	   afl_ArticleFeedbackSecurityHandler.securityEnabled = false;
	   Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

	   Map<Id,String> profileMap = new Map<Id,String>();

	   for( Profile p : profileList ){
		   profileMap.put( p.id, p.Name );
	   }
	   List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

	   if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ) {
		   for (Profile p : profileList) {
			   u[0].profileId = p.id;
			   update u;
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.sObjectType), true);
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.sObjectType), true);
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.sObjectType), true);
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isDeletable(Case.sObjectType), true);
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.subject), true);
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.subject), true);
			   System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), true);

			   afl_ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
			   afl_ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
			   afl_ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
			   afl_ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
			   afl_ArticleFeedbackSecurityHandler.canAccess(Case.subject);
			   afl_ArticleFeedbackSecurityHandler.canCreate(Case.subject);
			   afl_ArticleFeedbackSecurityHandler.canUpdate(Case.subject);

			   List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
			   fieldList.add( Case.subject );
			   afl_ArticleFeedbackSecurityHandler.toString(fieldList);

			   List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
			   objectTypeList.add( Case.sObjectType );
			   afl_ArticleFeedbackSecurityHandler.toString(objectTypeList);
		   }
	   }
   }

   public static testMethod void testGetKAVPermissions() {
	   //Create the Knowledge Article
	   SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();

	   System.Test.startTest();
		 Boolean result = afl_ArticleFeedbackSecurityHandler.getKAVPermissions();
		 System.assertEquals (true,result);
	   System.Test.stopTest();
   }
}
