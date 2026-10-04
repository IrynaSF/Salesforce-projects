public with sharing class TrackLwcController {
    @AuraEnabled(cacheable=true)
   public static List<Contact> getContacts() {
    List<Contact> contacts = [SELECT Id, Name,Email,Phone FROM Contact LIMIT 10];
    System.debug('Number of accounts found:'+ contacts.size());
        return contacts;
    }   
    
}
