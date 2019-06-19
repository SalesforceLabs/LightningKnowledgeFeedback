/**
 * @author Altimetrik
 * @description
 *    started on 07/12/2018
 *    Test class for the ArticleFeedbackSecurityHandler trigger
 **/
@isTest
private class afl_ArticleFeedbackSecurityHandler_Test {
	public static testMethod void testSecurityEnabled() {
		List<User> users = new List<User> {
			afl_TestDataFactory.createUser('System Administrator'),
			afl_TestDataFactory.createUser('Standard User'),
			afl_TestDataFactory.createUser('Read Only')
		};

		System.Test.startTest();
		for (User u : users) {
			System.runAs(u) {
				System.assertEquals(Case.SObjectType.getDescribe().isAccessible(), afl_ArticleFeedbackSecurityHandler.isAccessible(Case.SObjectType));
				System.assertEquals(Case.SObjectType.getDescribe().isCreateable(), afl_ArticleFeedbackSecurityHandler.isCreateable(Case.SObjectType));
				System.assertEquals(Case.SObjectType.getDescribe().isUpdateable(), afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.SObjectType));
				System.assertEquals(Case.SObjectType.getDescribe().isDeletable(), afl_ArticleFeedbackSecurityHandler.isDeletable(Case.SObjectType));
				System.assertEquals(Case.subject.getDescribe().isAccessible(), afl_ArticleFeedbackSecurityHandler.isAccessible(Case.subject));
				System.assertEquals(Case.subject.getDescribe().isCreateable(), afl_ArticleFeedbackSecurityHandler.isCreateable(Case.subject));
				System.assertEquals(Case.subject.getDescribe().isUpdateable(), afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.subject));

				// Test object permissions
				// Test isAccessible
				Boolean isAccessible;
				try {
					afl_ArticleFeedbackSecurityHandler.canAccess(Case.SObjectType);
					isAccessible = true;
				} catch (Exception e) {
					isAccessible = false;
				}

				if (Case.SObjectType.getDescribe().isAccessible()) {
					System.assert(isAccessible, 'The user should have access permissions');
				} else {
					System.assertEquals(false, isAccessible, 'The user should not have access permissions');
				}

				// Test isCreateable
				Boolean isCreateable;
				try {
					afl_ArticleFeedbackSecurityHandler.canCreate(Case.SObjectType);
					isCreateable = true;
				} catch (Exception e) {
					isCreateable = false;
				}

				if (Case.SObjectType.getDescribe().isCreateable()) {
					System.assert(isCreateable, 'The user should have create permissions');
				} else {
					System.assertEquals(false, isCreateable, 'The user should not have create permissions');
				}

				// Test isUpdateable
				Boolean isUpdateable;
				try {
					afl_ArticleFeedbackSecurityHandler.canUpdate(Case.SObjectType);
					isUpdateable = true;
				} catch (Exception e) {
					isUpdateable = false;
				}

				if (Case.SObjectType.getDescribe().isUpdateable()) {
					System.assert(isUpdateable, 'The user should have update permissions');
				} else {
					System.assertEquals(false, isUpdateable, 'The user should not have update permissions');
				}

				// Test isDeletable
				Boolean isDeletable;
				try {
					afl_ArticleFeedbackSecurityHandler.canDelete(Case.SObjectType);
					isDeletable = true;
				} catch (Exception e) {
					isDeletable = false;
				}

				if (Case.SObjectType.getDescribe().isDeletable()) {
					System.assert(isDeletable, 'The user should have delete permissions');
				} else {
					System.assertEquals(false, isDeletable, 'The user should not have delete permissions');
				}

				// Test field permissions
				// Test isAccessible
				try {
					afl_ArticleFeedbackSecurityHandler.canAccess(Case.subject);
					isAccessible = true;
				} catch (Exception e) {
					isAccessible = false;
				}

				if (Case.subject.getDescribe().isAccessible()) {
					System.assert(isAccessible, 'The user should have access permissions');
				} else {
					System.assertEquals(false, isAccessible, 'The user should not have access permissions');
				}

				// Test isCreateable
				try {
					afl_ArticleFeedbackSecurityHandler.canCreate(Case.subject);
					isCreateable = true;
				} catch (Exception e) {
					isCreateable = false;
				}

				if (Case.subject.getDescribe().isCreateable()) {
					System.assert(isCreateable, 'The user should have create permissions');
				} else {
					System.assertEquals(false, isCreateable, 'The user should not have create permissions');
				}

				// Test isUpdateable
				try {
					afl_ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
					isUpdateable = true;
				} catch (Exception e) {
					isUpdateable = false;
				}

				if (Case.subject.getDescribe().isUpdateable()) {
					System.assert(isUpdateable, 'The user should have update permissions');
				} else {
					System.assertEquals(false, isUpdateable, 'The user should not have update permissions');
				}
			}
		}
		System.Test.stopTest();
	}

	public static testMethod void testSecurityDisabled() {
		afl_ArticleFeedbackSecurityHandler.securityEnabled = false;

		List<User> users = new List<User> {
			afl_TestDataFactory.createUSer('System Administrator'),
			afl_TestDataFactory.createUSer('Standard User'),
			afl_TestDataFactory.createUSer('Read Only')
		};

		System.Test.startTest();
		for (User u : users) {
			System.runAs(u) {
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.SObjectType), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.SObjectType), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.SObjectType), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isDeletable(Case.SObjectType), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.subject), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.subject), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), true);

				afl_ArticleFeedbackSecurityHandler.canAccess(Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.canCreate(Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.canUpdate(Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.canDelete(Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.canAccess(Case.subject);
				afl_ArticleFeedbackSecurityHandler.canCreate(Case.subject);
				afl_ArticleFeedbackSecurityHandler.canUpdate(Case.subject);

				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
				fieldList.add( Case.subject);
				afl_ArticleFeedbackSecurityHandler.toString(fieldList);

				List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
				objectTypeList.add( Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.toString(objectTypeList);
			}
		}
		System.Test.stopTest();
	}

	public static testMethod void testGetKAVPermissions() {
		// Create the Knowledge Article
		SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();

		System.Test.startTest();
		Boolean result = afl_ArticleFeedbackSecurityHandler.getKAVPermissions();
		System.assertEquals (true,result);
		System.Test.stopTest();
	}

	public static testMethod void testIsGuestUser() {
		SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();
		User testUser = afl_TestDataFactory.createUser('Standard User');

		System.runAs(testUser) {
			System.Test.startTest();
			Boolean result = afl_ArticleFeedbackSecurityHandler.isGuestUser();
			System.assertEquals(false, result);
			System.Test.stopTest();
		}
	}

	public static testMethod void testFormatReplace() {
		String value = '{0}';
		List<String> lstStr = new List<String> {'value1'};
		System.Test.startTest();
		String result = afl_ArticleFeedbackSecurityHandler.formatReplace(value, lstStr);
		System.assertEquals('value1', result);
		System.Test.stopTest();
	}
}