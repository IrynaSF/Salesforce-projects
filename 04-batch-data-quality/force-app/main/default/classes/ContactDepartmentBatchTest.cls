@isTest
public class ContactDepartmentBatchTest {
    @isTest
    static void testBatch() {
        // 1. Create a Contact without a Department
        Contact cont = new Contact(LastName = 'Test Contact');
        insert cont;

        // 2. Run the Batch
        Test.startTest();
            Database.executeBatch(new ContactDepartmentBatch());
        Test.stopTest();

        // 3. Check that Department was updated
        Contact updated = [SELECT Department FROM Contact WHERE Id = :cont.Id];
        System.assertEquals('Needs Review', updated.Department);
    }
}
