public with sharing class ParentsLeadController {
 @AuraEnabled(cacheable=true)
public static ChildrenPageResult getChildrenByParent(Id parentId, Integer pageNumber) {

     // Get pageSize from Custom Metadata
    
        Pagination_Setting__mdt setting = [
            SELECT Page_Size__c 
            FROM Pagination_Setting__mdt
             WHERE DeveloperName = 'Children_Page_Size'
              LIMIT 1];

       Integer pageSize = Integer.valueOf(setting.Page_Size__c);

       // Calculate the offset.
       Integer offsetValue = pageNumber * pageSize;

        List<ParentsLead__c> parents = [
            SELECT Id, Name, 

            (SELECT Id, First_Name__c, Last_Name__c, Email__c, Phone__c 
            FROM 
            ChildrenLeads__r 
            ORDER BY First_Name__c
             ASC
             LIMIT :pageSize
             OFFSET :offsetValue )

             FROM 	ParentsLead__c 
             WHERE Id = :parentId
             LIMIT 1
        ];

        // query for the total count
        Integer totalChildren = [SELECT COUNT() FROM ChildrenLead__c WHERE ParentsLead__c = :parentId];


        ChildrenPageResult pageResult = new ChildrenPageResult();
         pageResult.children = parents[0].ChildrenLeads__r;
         pageResult.totalCount = totalChildren; 
         pageResult.pageSize = pageSize;

    return pageResult;
    }
}
