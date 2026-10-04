public with sharing class CostomerMetadataController {
     @AuraEnabled(cacheable=true)
    

    public static App_Settings__mdt getAppSettings(String developerName) {
        try {
App_Settings__mdt settings =  [
                SELECT Max_Records__c, Notification_Email__c 
                FROM App_Settings__mdt 
                WHERE DeveloperName = :developerName
                LIMIT 1
            ];
 System.debug('Search settings for DeveloperName: ' + developerName);
System.debug('Record found: ' + settings);
          return   settings;

        } catch (Exception e) {
            throw new AuraHandledException('Error reading settings: ' + e.getMessage());
        }
    }
}
