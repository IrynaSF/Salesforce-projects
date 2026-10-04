@isTest
public class TrackLwcControllerTest {
@TestSetup
static void setupTestData() {
 insert new List<Contact>
{     new Contact(LastName= 'TestContactTrack', Email ='test.contact@example.com', Phone = '16449165'), 
    new Contact(LastName = 'TestContactTrack', Email ='test.contact2@example.com', Phone = '6464659498') };
}
    @isTest
    static void testGetContacts(){
     
        Test.startTest();
        List<Contact> result = TrackLwcController.getContacts();
        Test.stopTest();

        // 3. ПРОВЕРКА (Assert)
        // Проверяем, что список не пустой и содержит наши данные
        System.assertEquals(2, result.size(), 'The list of contacts must not be empty.');
        System.assertEquals('TestContactTrack', result[0].Name, 'Contact name mismatch');
    }
}
