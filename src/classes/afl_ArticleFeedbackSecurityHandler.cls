/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Security Handler class for Article Feedback object
**/
public class afl_ArticleFeedbackSecurityHandler {
    /**
    * @description
    *  Constants
    **/
    public static final String  ERROR_OBJECT_NOT_ACCESSIBLE = 'You do not have access to the following objects: {0}. Please contact your Salesforce Administrator for assistance.';
    public static final String  ERROR_OBJECT_NOT_UPDATEABLE = 'You cannot update the following objects: {0}. Please contact your Salesforce Administrator for assistance.';
    public static final String  ERROR_OBJECT_NOT_CREATEABLE = 'You cannot create the following objects: {0}. Please contact your Salesforce Administrator for assistance.';
    public static final String  ERROR_OBJECT_NOT_DELETABLE = 'You cannot delete the following objects: {0}. Please contact your Salesforce Administrator for assistance.';
    public static final String  ERROR_FIELD_NOT_ACCESSIBLE = 'You do not have access to the following fields: {0} Please contact your Salesforce Administrator for assistance.';
    public static final String  ERROR_FIELD_NOT_UPDATEABLE = 'You cannot update the following fields: {0} Please contact your Salesforce Administrator for assistance.';
    public static final String  ERROR_FIELD_NOT_CREATEABLE = 'You cannot create the following fields: {0} Please contact your Salesforce Administrator for assistance.';

    public static Boolean securityEnabled { get; set; }
    public static Boolean isPrivateSharingEnabled { get; set; }
    public static Boolean isRecordTypeIdActive = checkForSchemaFieldActive('recordtypeid');

    static {
        securityEnabled = true;
        isPrivateSharingEnabled = true;
    }

    public static String knowledgeObject {
        get {
            if (knowledgeObject == null) {
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Set<String> keySet = gd.keySet();
                for (String key : keySet) {
                    Schema.SObjectType objectType = gd.get(key);
                    if (key.endsWith('kav')&& objectType.getDescribe().isAccessible()) {
                        knowledgeObject = objectType.getDescribe().getName();
                    }
                }
            }

            return knowledgeObject;
        }
        private set;
    }

    //@Description: (get/set) List of Record Types
    public static List<RecordType> allRecordTypes {
        get {
            if (allRecordTypes == null) {
                allRecordTypes = [SELECT DeveloperName, Id, Name FROM RecordType WHERE SobjectType =: knowledgeObject];
            }
            return allRecordTypes;
        }
        private set;
    }

    /*
    * @description
    *   Return a boolean to know if we had kav permissions
    * @params
    *   N/A
    * @return
    *   Boolean
    */
    public static Boolean getKAVPermissions() {
        Boolean result = false;
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();

        for (String s : gd.keySet()) {
            if (s.contains('__kav'))
            result = gd.get(s).getDescribe().isAccessible();
        }
        return result ;
    }

    public static Boolean isGuestUser() {
        List<UserLicense> up = [select Name from UserLicense Where Id IN ( select UserLicenseId from Profile where Id = :UserInfo.getProfileId() ) LIMIT 1 ];
        return up[0].Name == 'Guest';
    }

    // Batch methods
    public static Boolean isAccessible(Schema.SObjectType[] objectTypeList) {
        if (securityEnabled) {
            for (Schema.SObjectType objectType : objectTypeList) {
                if (!objectType.getDescribe().isAccessible()) {
                    return false;
                }
            }
        }
        return true;
    }

    public static Boolean isUpdateable(Schema.SObjectType[] objectTypeList) {
        if (securityEnabled) {
            for (Schema.SObjectType objectType : objectTypeList) {
                if (!objectType.getDescribe().isUpdateable()) {
                    return false;
                }
            }
        }
        return true;
    }

    public static Boolean isCreateable(Schema.SObjectType[] objectTypeList) {
        if (securityEnabled) {
            for (Schema.SObjectType objectType : objectTypeList) {
                if (!objectType.getDescribe().isCreateable()) {
                    return false;
                }
            }
        }
        return true;
    }

    public static Boolean isDeletable(Schema.SObjectType[] objectTypeList) {
        if (securityEnabled) {
            for (Schema.SObjectType objectType : objectTypeList) {
                if (!objectType.getDescribe().isDeletable()) {
                    return false;
                }
            }
        }
        return true;
    }

    public static Boolean isAccessible(Schema.SObjectField[] fieldList) {
        if (securityEnabled) {
            for (Schema.SObjectField field : fieldList) {
                if (!field.getDescribe().isAccessible()) {
                    return false;
                }
            }
        }
        return true;
    }

    public static Boolean isUpdateable(Schema.SObjectField[] fieldList) {
        if (securityEnabled) {
            for (Schema.SObjectField field : fieldList) {
                if (!field.getDescribe().isUpdateable()) {
                    return false;
                }
            }
        }
        return true;
    }

    public static Boolean isCreateable(Schema.SObjectField[] fieldList) {
        if (securityEnabled) {
            for (Schema.SObjectField field : fieldList) {
                if (!field.getDescribe().isCreateable()) {
                    return false;
                }
            }
        }
        return true;
    }

    // Single element methods
    public static Boolean isAccessible(Schema.SObjectType objectType) {
        return isAccessible(new Schema.SObjectType[] {objectType});
    }

    public static Boolean isUpdateable(Schema.SObjectType objectType) {
        return isUpdateable(new Schema.SObjectType[] {objectType});
    }

    public static Boolean isCreateable(Schema.SObjectType objectType) {
        return isCreateable(new Schema.SObjectType[] {objectType});
    }

    public static Boolean isDeletable(Schema.SObjectType objectType) {
        return isDeletable(new Schema.SObjectType[] {objectType});
    }

    public static Boolean isAccessible(Schema.SObjectField field) {
        return isAccessible(new Schema.SObjectField[] {field});
    }

    public static Boolean isUpdateable(Schema.SObjectField field) {
        return isUpdateable(new Schema.SObjectField[] {field});
    }

    public static Boolean isCreateable(Schema.SObjectField field) {
        return isCreateable(new Schema.SObjectField[] {field});
    }

    // Exception throwers

    // Batch methods
    public static void canAccess(Schema.SObjectType[] objectTypeList) {
        if (!isAccessible(objectTypeList)) {
            throw new SecurityException(formatReplace(ERROR_OBJECT_NOT_ACCESSIBLE, new String[] {toString(objectTypeList)}));
        }
    }

    public static void canUpdate(Schema.SObjectType[] objectTypeList) {
        if (!isUpdateable(objectTypeList)) {
            throw new SecurityException(formatReplace(ERROR_OBJECT_NOT_UPDATEABLE, new String[]{toString(objectTypeList)}));
        }
    }

    public static void canCreate(Schema.SObjectType[] objectTypeList) {
        if (!isCreateable(objectTypeList)) {
            throw new SecurityException(formatReplace( ERROR_OBJECT_NOT_CREATEABLE, new String[] {toString(objectTypeList)}));
        }
    }

    public static void canDelete(Schema.SObjectType[] objectTypeList) {
        if (!isDeletable(objectTypeList)) {
            throw new SecurityException(formatReplace( ERROR_OBJECT_NOT_DELETABLE, new String[] {toString(objectTypeList)}));
        }
    }

    public static void canAccess(Schema.SObjectField[] fieldList) {
        if (!isAccessible(fieldList)) {
            throw new SecurityException(formatReplace( ERROR_FIELD_NOT_ACCESSIBLE, new String[] {toString(fieldList)}));
        }
    }

    public static void canUpdate(Schema.SObjectField[] fieldList) {
        if (!isUpdateable(fieldList)) {
            throw new SecurityException(formatReplace( ERROR_FIELD_NOT_UPDATEABLE, new String[] {toString(fieldList)}));
        }
    }

    public static void canCreate(Schema.SObjectField[] fieldList) {
        if (!isCreateable(fieldList)) {
            throw new SecurityException(formatReplace( ERROR_FIELD_NOT_CREATEABLE, new String[] {toString(fieldList)}));
        }
    }

    // single element methods
    public static void canAccess(Schema.SObjectType objectType) {
        canAccess(new Schema.SObjectType[] {objectType});
    }

    public static void canUpdate(Schema.SObjectType objectType) {
        canUpdate(new Schema.SObjectType[] {objectType});
    }

    public static void canCreate(Schema.SObjectType objectType) {
        canCreate(new Schema.SObjectType[] {objectType});
    }

    public static void canDelete(Schema.SObjectType objectType) {
        canDelete(new Schema.SObjectType[] {objectType});
    }

    public static void canAccess(Schema.SObjectField field) {
        canAccess(new Schema.SObjectField[] {field});
    }

    public static void canUpdate(Schema.SObjectField field) {
        canUpdate(new Schema.SObjectField[] {field});
    }

    public static void canCreate(Schema.SObjectField field) {
        canCreate(new Schema.SObjectField[] {field});
    }

    // output helper functions
    public static String toString(Schema.SObjectType[] objectTypeList) {
        String result = '';
        if (!objectTypeList.isEmpty()) {
            result = objectTypeList[0].getDescribe().getLabel();
            for (Integer i = 1; i < objectTypeList.size(); ++i) {
                result += ', ' + objectTypeList[i].getDescribe().getLabel();
            }
        }
        return result;
    }

    public static String toString(Schema.SObjectField[] fieldList) {
        String result = '';
        if (!fieldList.isEmpty()) {
            result = fieldList[0].getDescribe().getLabel();
            for (Integer i = 1; i < fieldList.size(); ++i) {
                result += ', ' + fieldList[i].getDescribe().getLabel();
            }
        }
        return result;
    }

    public static String formatReplace(String value, List<String> lstStr){
        String res = value;

        for( Integer i=0; i<lstStr.size(); i++ ){
            if( lstStr[i] != null && lstStr[i] != '' )
            res = res.replaceAll('\\{'+i+'\\}', lstStr[i]);
        }
        return res;
    }

    /*
    * @description
    *   Return a Map of the Id -> Record Type allowed.
    * @params
    *   N/A
    * @return
    *   Map<Id,String>
    */
    public static Map<Id,String> getAllowedRecordTypesMap() {
        Map<Id,String> res = new Map<Id,String>();

        for (RecordType rt : allRecordTypes) {
            res.put(rt.Id, rt.Name);
        }

        if (res.size() == 0)
        res = null;
        return res;
    }

    /*
    * @description
    *   Return a Map of the Record Type -> Id allowed.
    * @params
    *   N/A
    * @return
    *   Map<Id,String>
    */
    public static Map<String,Id> getAllowedRecordTypeNameToIdMap() {
        Map<String,Id> res = new Map<String,Id>();

        for (RecordType rt : allRecordTypes) {
            res.put(rt.Name, rt.Id);
        }

        if (res.size() == 0)
        res = null;
        return res;
    }

    /*
    * @description
    *	Method that return a boolean to know if the fieldname exist on the fields of the schema
    * @params
    *	N/A
    * @return
    *	Boolean
    */
    public static Boolean checkForSchemaFieldActive(String fieldName){
        Schema.DescribeSObjectResult sor = Schema.getGlobalDescribe().get(knowledgeObject).getDescribe();
        Map<String,Schema.SObjectField> sofs = sor.fields.getMap();

        Set<String> objectFields = sofs.keySet();
        return objectFields.contains(fieldName);
    }

    /*
    * @description
    *   Method that returns the first value of a PicklistEntry for the "Language" field of a given Object, if exists
    * @params
    *   sObject Name
    * @return
    *   String - PicklistEntry value
    */
    public static String getValidLanguagePicklistValue(String sObjectName) {
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        if(gd != null) {
            Schema.DescribeSObjectResult sor = gd.get(sObjectName).getDescribe();
            Map<String,Schema.SObjectField> sofs = sor.fields.getMap();
            Schema.DescribeFieldResult dfr = sofs.get('Language').getDescribe();
            if(dfr != null) {
                List<Schema.PicklistEntry> ples = dfr.getPicklistValues();
                return ples.get(0).getValue();
            }
        }
        return null;
    }

    /*
    * @description
    *   Method that returns the user’s current community name
    * @params
    *  None
    * @return
    *   String - Community name
    */
    public static String getCommunityName() {
        String commName = '';
        Set<String> objectFields = Schema.SObjectType.FeedItem.fields.getMap().keySet();
        if(objectFields.contains('networkscope')) {
            String netId = Network.getNetworkId();
            if(String.isNotEmpty(netId)){
                String query = 'select name from Network where id =: netId';
                SObject comm = Database.query(query);
                commName = (String)comm.get('name');
            }
        }
        return commName;
    }


    public class SecurityException extends Exception {}
}
