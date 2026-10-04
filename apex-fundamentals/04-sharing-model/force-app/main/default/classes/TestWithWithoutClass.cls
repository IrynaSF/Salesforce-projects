@isTest
private class TestWithWithoutClass {
    @isTest
    static void testWithWithoutSharingDifference() {

        //Находим ID стандартного Profile  для теста. 
        Profile standprof = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard Platform User'
        ];

        //Создаем тестового юзера. 
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
         
//Создаем тестовую employees-запись. 
Employee__c testEmp = new Employee__c();
 testEmp.Name = 'TestVictor';

        insert testEmp;

        //мы проверяем: "результат without sharing должен быть больше или равен результату with sharing"
           System.runAs(testUser) {
            List<Employee__c> withSharing = WithSharingHandler.getSharedVisibleRecords();
            List<Employee__c> withoutSharing = WithoutSharingHandler.getVisibleRecords();
            
            System.assert(withoutSharing.size() >= withSharing.size());
        }

    }
}
