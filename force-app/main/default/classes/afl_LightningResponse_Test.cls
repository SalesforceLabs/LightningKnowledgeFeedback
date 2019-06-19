/**
* @author Altimetrik
* @description
*   started on 07/17/2018
*   This class test the afl_LightningResponse Class
**/
@isTest
private class afl_LightningResponse_Test {
    private static afl_LightningResponse lightningResponse = new afl_LightningResponse();

    //***** Test Methods *****//

    /*
    Description: Check for the get and set of the class
    */
    @isTest static void test_getAttributes() {
        System.Test.startTest();
        lightningResponse.jsonResponse = 'testJSON';
        lightningResponse.error = 'testERROR';
        lightningResponse.state = 'testSTATE';
        System.Test.stopTest();

        System.assertEquals('testJSON', lightningResponse.jsonResponse, 'jsonResponse should be equal');
        System.assertEquals('testERROR', lightningResponse.error, 'error should be equal');
        System.assertEquals('testSTATE', lightningResponse.state, 'state should be equal');
    }

    /*
    Description: Check for the state of the constructor
    */
    @isTest static void test_constructor() {
        System.Test.startTest();
        String state = lightningResponse.state;
        System.Test.stopTest();

        System.assertEquals('SUCCESS', state, 'state should be "SUCCESS"');
    }

    /*
    Description: Check for the state of the constructor
    */
    @isTest static void test_exception() {
        try {
            System.Test.startTest();
            User testUser = new User();
            // This insert will fail because there are no required fields set for the user
            insert testUser;
        } catch (Exception e) {
            afl_LightningResponse klr = new afl_LightningResponse(e);
            System.Test.stopTest();
            System.assertEquals('ERROR', klr.state, 'State should be ERROR');
        }
    }
}