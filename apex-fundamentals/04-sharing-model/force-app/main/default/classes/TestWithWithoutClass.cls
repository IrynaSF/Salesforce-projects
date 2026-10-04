@isTest
private class TestWithWithoutClass {
    @isTest
    static void testWithWithoutSharingDifference() {

        // Find the Id of a standard Profile for the test.
        Profile standprof = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard Platform User'
        ];

        // Create a test user.
        User testUser = new User();
         testUser.FirstName = 'Viktor';
         testUser.LastName = 'TestWhithWithout';
         testUser.Email = 'viktor.test@example.com';
         testUser.Username = 'viktor.test@example.com';
         testUser.Alias = 'vtest';
         testUser.TimeZoneSidKey = 'America/Los_Angeles';
         testUser.LocaleSidKey = 'en_US';
         testUser.EmailEncodingKey = 'UTF-8';
         testUser.LanguageLocaleKey = 'en_US';
          testUser.ProfileId = standprof.Id;

         insert testUser;
         
// Create a test Employee record.
Employee__c testEmp = new Employee__c();
 testEmp.Name = 'TestVictor';

        insert testEmp;

        // we check: "the without sharing result must be greater than or equal to the with sharing result"
           System.runAs(testUser) {
            List<Employee__c> withSharing = WithSharingHandler.getSharedVisibleRecords();
            List<Employee__c> withoutSharing = WithoutSharingHandler.getVisibleRecords();
            
            System.assert(withoutSharing.size() >= withSharing.size());
        }

    }
}
