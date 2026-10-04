public class ChildrenPageResult {
    @AuraEnabled
    public List<ChildrenLead__c> children;

    @AuraEnabled
   public Integer pageSize;

    @AuraEnabled
    public Integer totalCount;
}
