/**
 * @author Altimetrik
 * @description
 *    started on 07/12/2018
 *    Test class for the ArticleFeedbackSecurityHandler trigger
 **/
@isTest
public class ArticleFeedbackSecurityHandler_Test {

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
			   System.assertEquals(ArticleFeedbackSecurityHandler.isAccessible(Case.sObjectType), Case.sObjectType.getDescribe().isAccessible());
			   System.assertEquals(ArticleFeedbackSecurityHandler.isCreateable(Case.sObjectType), Case.sObjectType.getDescribe().isCreateable());
			   System.assertEquals(ArticleFeedbackSecurityHandler.isUpdateable(Case.sObjectType), Case.sObjectType.getDescribe().isUpdateable());
			   System.assertEquals(ArticleFeedbackSecurityHandler.isDeletable(Case.sObjectType), Case.sObjectType.getDescribe().isDeletable());
			   System.assertEquals(ArticleFeedbackSecurityHandler.isAccessible(Case.subject), Case.subject.getDescribe().isAccessible());
			   System.assertEquals(ArticleFeedbackSecurityHandler.isCreateable(Case.subject), Case.subject.getDescribe().isCreateable());
			   System.assertEquals(ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), Case.subject.getDescribe().isUpdateable());

			   if (Case.sObjectType.getDescribe().isAccessible())
				   ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
			   else
				   try {
					   ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.sObjectType.getDescribe().isCreateable())
				   ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
			   else
				   try {
					   ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.sObjectType.getDescribe().isUpdateable())
				   ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
			   else
				   try {
					   ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.sObjectType.getDescribe().isDeletable())
				   ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
			   else
				   try {
					   ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.subject.getDescribe().isAccessible())
				   ArticleFeedbackSecurityHandler.canAccess(Case.subject);
			   else
				   try {
					   ArticleFeedbackSecurityHandler.canAccess(Case.subject);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.subject.getDescribe().isCreateable())
				   ArticleFeedbackSecurityHandler.canCreate(Case.subject);
			   else
				   try {
					   ArticleFeedbackSecurityHandler.canCreate(Case.subject);
					   System.assert(false);
				   } catch (SecurityException e) {}

			   if (Case.subject.getDescribe().isUpdateable())
				   ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
			   else
				   try {
					   ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
					   System.assert(false);
				   } catch (SecurityException e) {}
		   }
	   }
   }

   public static testMethod void testSecurityDisabled() {
	   ArticleFeedbackSecurityHandler.securityEnabled = false;
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
			   System.assertEquals(ArticleFeedbackSecurityHandler.isAccessible(Case.sObjectType), true);
			   System.assertEquals(ArticleFeedbackSecurityHandler.isCreateable(Case.sObjectType), true);
			   System.assertEquals(ArticleFeedbackSecurityHandler.isUpdateable(Case.sObjectType), true);
			   System.assertEquals(ArticleFeedbackSecurityHandler.isDeletable(Case.sObjectType), true);
			   System.assertEquals(ArticleFeedbackSecurityHandler.isAccessible(Case.subject), true);
			   System.assertEquals(ArticleFeedbackSecurityHandler.isCreateable(Case.subject), true);
			   System.assertEquals(ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), true);

			   ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
			   ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
			   ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
			   ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
			   ArticleFeedbackSecurityHandler.canAccess(Case.subject);
			   ArticleFeedbackSecurityHandler.canCreate(Case.subject);
			   ArticleFeedbackSecurityHandler.canUpdate(Case.subject);

			   List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
			   fieldList.add( Case.subject );
			   ArticleFeedbackSecurityHandler.toString(fieldList);

			   List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
			   objectTypeList.add( Case.sObjectType );
			   ArticleFeedbackSecurityHandler.toString(objectTypeList);
		   }
	   }
   }

   public static testMethod void testGetKAVPermissions() {
	   //Create the Knowledge Article
	   SObject kavObj = TestDataFactory.createKnowledgeArticle();

	   System.Test.startTest();
		 Boolean result = ArticleFeedbackSecurityHandler.getKAVPermissions();
		 System.assertEquals (true,result);
	   System.Test.stopTest();
   }
}
