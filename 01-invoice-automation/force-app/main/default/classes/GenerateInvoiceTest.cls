@isTest
private class GenerateInvoiceTest {

    // This method runs ONCE before all tests
    // Here we create the data needed by all three tests
    @testSetup
    static void setupData() {

        // Create the Account first: the Opportunity depends on it
        Account acc = new Account(Name = 'Test Acc');
        insert acc;

        // Opportunity is the main object, its Id is passed to the controller method
        // Invoice_Number__c = 'INV-123' becomes the file name
        Opportunity opp = new Opportunity(
            Name              = 'Test Opp',
            StageName         = 'Prospecting',
            CloseDate         = Date.today().addDays(10),
            Amount            = 1000.00,
            AccountId         = acc.Id
        );
        insert opp;
    }

    // TEST 1: no file yet, the method must create a new one
    @isTest
static void testGenerateAndAttachPDF_existingFile() {

    // Query the Opportunity and read Name right away: needed for fileName
 Opportunity opp = [SELECT Id, Name, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];

String fileName = opp.Invoice_Number__c; // take the real value

    // Create the file manually BEFORE calling the method
    // Title must match fileName, otherwise the controller won't find the existing file
    ContentVersion cv = new ContentVersion(
        Title                  = fileName,
        PathOnClient           = fileName + '.pdf',
        VersionData            = Blob.valueOf('Original'),
        FirstPublishLocationId = opp.Id
    );
    insert cv;

    // Call the method: it must find the existing file and create a new version
    Test.startTest();
        GenerateInvoiceController.generateAndAttachPDF(opp.Id);
    Test.stopTest();

    // Check that there are now two versions
    Integer versionCount = [
        SELECT COUNT()
        FROM ContentVersion
        WHERE ContentDocument.Title = :fileName
    ];
    Assert.areEqual(2, versionCount, 'Should have created a new version of existing file');
}
    // TEST 3: pass a non-existent Id, the method must fail with an error
    @isTest
    static void testGenerateAndAttachPDF_wrongId() {

        // Create a fake Id with a valid format that doesn't exist in the database
        Id fakeId = '006000000000001AAA';

        Test.startTest();
        try {
            // Expect the method to throw an exception
            GenerateInvoiceController.generateAndAttachPDF(fakeId);

            // If we reach this line the method didn't fail, so the test fails
            Assert.fail('Should have thrown an exception for invalid Id');

        } catch (Exception e) {
            // The method failed as expected: check that the message is not empty
            Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
}
