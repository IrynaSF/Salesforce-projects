@isTest
private class EmailTemplateTest {

  @testSetup
static void setupData() {

    // EmailTemplate is a setup object, so insert it separately inside System.runAs()
    User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(u) {
        EmailTemplate tmpl = new EmailTemplate(
            DeveloperName = 'Test_Template',
            Name          = 'Test Template',
            TemplateType  = 'text',
            FolderId      = UserInfo.getUserId(),
            Subject       = 'Invoice for {!Opportunity.Name}',
            Body          = 'Hello',
            HtmlValue     = '<html><body>Hello</body></html>'
        );
        insert tmpl;
    }

    // Non-setup objects are inserted after System.runAs()
    Account acc = new Account(Name = 'Test Acc');
    insert acc;

        // Contact: FirstName = 'Alex', the controller will put it into "Dear Alex,".
        Contact con = new Contact(
            FirstName = 'Alex',
            LastName  = 'Test',
            AccountId = acc.Id
        );
        insert con;

        // Opportunity: do NOT set Invoice_Number__c, it is an Auto Number field.
        // Salesforce generates the value on insert.
        Opportunity opp = new Opportunity(
            Name      = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Amount    = 1000.00,
            AccountId = acc.Id
        );
        insert opp;

        // OpportunityContactRole links the Contact to the Opportunity.
        // IsPrimary = true: the controller looks for exactly this condition.
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId     = con.Id,
            IsPrimary     = true
        );
        insert ocr;
    }

    // POSITIVE TEST: template, contact and all deal data are present
    @isTest
    static void testGetRenderedTemplate_withContact() {

        // Query the Opportunity and read Invoice_Number__c right away:
        // it is an Auto Number field, so we don't know its value in advance,
        // that's why we read the real value and use it in the assertions.
        Opportunity opp = [
            SELECT Id, Invoice_Number__c
            FROM Opportunity
            WHERE Name = 'Test Opp'
            LIMIT 1
        ];

        Test.startTest();
        Map<String, String> result = EmailTemplateController.getRenderedTemplate(
            'Test_Template',
            opp.Id
        );
        Test.stopTest();

        // Check that the method returned a result
        Assert.isNotNull(result, 'Result map should not be null');

        // Check that both keys are in the Map
        Assert.isTrue(result.containsKey('subject'),  'Should contain subject key');
        Assert.isTrue(result.containsKey('htmlBody'), 'Should contain htmlBody key');

        // Check subject
        Assert.isTrue(
            result.get('subject').contains('Test Opp'),
            'Subject should contain opportunity name'
        );

        // Check htmlBody
        // Invoice_Number__c comes from the opp variable: the real value from the database
        String body = result.get('htmlBody');
        Assert.isTrue(body.contains('Dear Alex'),           'Should contain contact first name');
        Assert.isTrue(body.contains(opp.Invoice_Number__c), 'Should contain invoice number');
        Assert.isTrue(body.contains('$1000.00'),            'Should contain formatted amount');
        Assert.isTrue(body.contains('Test Opp'),            'Should contain opportunity name');
    }

    // NEGATIVE TEST: no Primary Contact
    // Check that the method doesn't fail but returns an empty name
    @isTest
    static void testGetRenderedTemplate_withoutContact() {

        // Take the existing Account from setupData
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1];

        // Create an Opportunity WITHOUT Invoice_Number__c, it is an Auto Number field.
        // Create it WITHOUT an OpportunityContactRole: this is our negative scenario.
        Opportunity oppNoContact = new Opportunity(
            Name      = 'No Contact Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Amount    = 500.00,
            AccountId = acc.Id
        );
        insert oppNoContact;

        // Read the real Invoice_Number__c value that Salesforce generated
        oppNoContact = [
            SELECT Id, Invoice_Number__c
            FROM Opportunity
            WHERE Id = :oppNoContact.Id
        ];

        Test.startTest();
        Map<String, String> result = EmailTemplateController.getRenderedTemplate(
            'Test_Template',
            oppNoContact.Id
        );
        Test.stopTest();

        // The method must return a result, not throw an exception
        Assert.isNotNull(result, 'Result should not be null even without contact');

        String body = result.get('htmlBody');

        // contactFirstName will be '', so the greeting will be "Dear ,"
        Assert.isTrue(
            body.contains('Dear ,'),
            'Should handle missing contact gracefully with empty name'
        );

        Assert.isTrue(body.contains('$500.00'), 'Should contain amount');
    }
}
