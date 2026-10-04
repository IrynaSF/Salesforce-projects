@isTest
public class ContactDepartmentBatchTest {
    @isTest
    static void testBatch() {
        // 1. Создай Contact без Department
        Contact cont = new Contact(LastName = 'Test Contact');
        insert cont;

        // 2. Запусти Batch
        Test.startTest();
            Database.executeBatch(new ContactDepartmentBatch());
        Test.stopTest();

        // 3. Проверь что Department обновился
        Contact updated = [SELECT Department FROM Contact WHERE Id = :cont.Id];
        System.assertEquals('Needs Review', updated.Department);
    }
}
