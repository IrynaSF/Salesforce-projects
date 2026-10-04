@isTest
public class CostomerMetadataControllerTest{

    @isTest
    static void testGetAppSettings() {
        Test.startTest();
       App_Settings__mdt result = CostomerMetadataController.getAppSettings('Default_Settings');
        Test.stopTest();
System.assertNotEquals(null, result, 'Metadata must not be present null');
    
    System.assertEquals(10, result.Max_Records__c, 'Max Records should be 10');
    }
    @isTest
static void testGetAppSettingsError() {
    Test.startTest();
    try {
        App_Settings__mdt result = CostomerMetadataController.getAppSettings('NonExistent_Settings');
        System.assert(false, 'Exception should have been thrown');
    } catch (Exception e) {
        System.assert(true, 'Exception was caught as expected');
    }
    Test.stopTest();
}
}
