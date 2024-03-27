/**
* @author Altimetrik
* @description
*    started on 21/02/2020
*    Test for custom labels reference to be included in package
**/
@isTest
private with sharing class afl_CustomLabels_Test {
    @isTest
    static void getLabelsTest() {
        System.Test.startTest();
        Boolean result = afl_CustomLabels.getLabels();
        System.Test.stopTest();

        System.assert(result);
    }
}