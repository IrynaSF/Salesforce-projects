@isTest
private class EmailTemplateTest {

  @testSetup
static void setupData() {

    // EmailTemplate — setup объект, вставляем отдельно через System.runAs()
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

    // Non-setup объекты — вставляем после System.runAs()
    Account acc = new Account(Name = 'Test Acc');
    insert acc;

        // Contact — FirstName = 'Alex', контроллер вставит его в "Dear Alex,".
        Contact con = new Contact(
            FirstName = 'Alex',
            LastName  = 'Test',
            AccountId = acc.Id
        );
        insert con;

        // Opportunity — Invoice_Number__c НЕ указываем, это Auto Number поле.
        // Salesforce сам сгенерирует значение при insert.
        Opportunity opp = new Opportunity(
            Name      = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Amount    = 1000.00,
            AccountId = acc.Id
        );
        insert opp;

        // OpportunityContactRole — связывает Contact с Opportunity.
        // IsPrimary = true — контроллер ищет именно с этим условием.
        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId     = con.Id,
            IsPrimary     = true
        );
        insert ocr;
    }

    // ПОЗИТИВНЫЙ ТЕСТ — есть шаблон, контакт, все данные сделки
    @isTest
    static void testGetRenderedTemplate_withContact() {

        // Достаём Opportunity и сразу читаем Invoice_Number__c —
        // это Auto Number поле, его значение  не знаем заранее,
        // поэтому читаем реальное значение и используем его в assertions.
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

        // Проверяем что метод вернул результат
        Assert.isNotNull(result, 'Result map should not be null');

        // Проверяем что оба ключа есть в Map
        Assert.isTrue(result.containsKey('subject'),  'Should contain subject key');
        Assert.isTrue(result.containsKey('htmlBody'), 'Should contain htmlBody key');

        // Проверяем subject
        Assert.isTrue(
            result.get('subject').contains('Test Opp'),
            'Subject should contain opportunity name'
        );

        // Проверяем htmlBody
        // Invoice_Number__c берём из переменной opp — реальное значение из базы
        String body = result.get('htmlBody');
        Assert.isTrue(body.contains('Dear Alex'),           'Should contain contact first name');
        Assert.isTrue(body.contains(opp.Invoice_Number__c), 'Should contain invoice number');
        Assert.isTrue(body.contains('$1000.00'),            'Should contain formatted amount');
        Assert.isTrue(body.contains('Test Opp'),            'Should contain opportunity name');
    }

    // НЕГАТИВНЫЙ ТЕСТ — нет Primary Contact
    // Проверяем что метод не падает а возвращает пустое имя
    @isTest
    static void testGetRenderedTemplate_withoutContact() {

        // Берём существующий Account из setupData
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1];

        // Создаём Opportunity БЕЗ Invoice_Number__c — это Auto Number поле.
        // Создаём БЕЗ OpportunityContactRole — это и есть наш негативный сценарий.
        Opportunity oppNoContact = new Opportunity(
            Name      = 'No Contact Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Amount    = 500.00,
            AccountId = acc.Id
        );
        insert oppNoContact;

        // Читаем реальное значение Invoice_Number__c которое Salesforce сгенерировал
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

        // Метод должен вернуть результат — не упасть с исключением
        Assert.isNotNull(result, 'Result should not be null even without contact');

        String body = result.get('htmlBody');

        // contactFirstName будет '' — приветствие будет "Dear ,"
        Assert.isTrue(
            body.contains('Dear ,'),
            'Should handle missing contact gracefully with empty name'
        );

        Assert.isTrue(body.contains('$500.00'), 'Should contain amount');
    }
}
