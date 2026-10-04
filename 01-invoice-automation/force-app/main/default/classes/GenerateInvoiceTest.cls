@isTest
private class GenerateInvoiceTest {

    // Этот метод запускается ОДИН РАЗ перед всеми тестами
    // Здесь создаём данные которые нужны во всех трёх тестах
    @testSetup
    static void setupData() {

        // Account создаём первым — Opportunity зависит от него
        Account acc = new Account(Name = 'Test Acc');
        insert acc;

        // Opportunity — главный объект, его Id передаём в метод контроллера
        // Invoice_Number__c = 'INV-123' — это станет именем файла
        Opportunity opp = new Opportunity(
            Name              = 'Test Opp',
            StageName         = 'Prospecting',
            CloseDate         = Date.today().addDays(10),
            Amount            = 1000.00,
            AccountId         = acc.Id
        );
        insert opp;
    }

    // ТЕСТ 1 — файла ещё нет, метод должен создать новый
    @isTest
static void testGenerateAndAttachPDF_existingFile() {

    // Достаём Opportunity и сразу читаем Name — нужен для fileName
 Opportunity opp = [SELECT Id, Name, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];

String fileName = opp.Invoice_Number__c; // берём реальное значение

    // Создаём файл вручную ДО вызова метода
    // Title должен совпадать с fileName — иначе контроллер не найдёт существующий файл
    ContentVersion cv = new ContentVersion(
        Title                  = fileName,
        PathOnClient           = fileName + '.pdf',
        VersionData            = Blob.valueOf('Original'),
        FirstPublishLocationId = opp.Id
    );
    insert cv;

    // Вызываем метод — он должен найти существующий файл и создать новую версию
    Test.startTest();
        GenerateInvoiceController.generateAndAttachPDF(opp.Id);
    Test.stopTest();

    // Проверяем что версий стало две
    Integer versionCount = [
        SELECT COUNT()
        FROM ContentVersion
        WHERE ContentDocument.Title = :fileName
    ];
    Assert.areEqual(2, versionCount, 'Should have created a new version of existing file');
}
    // ТЕСТ 3 — передаём несуществующий Id, метод должен упасть с ошибкой
    @isTest
    static void testGenerateAndAttachPDF_wrongId() {

        // Создаём фейковый Id правильного формата но которого нет в базе
        Id fakeId = '006000000000001AAA';

        Test.startTest();
        try {
            // Ожидаем что метод бросит исключение
            GenerateInvoiceController.generateAndAttachPDF(fakeId);

            // Если дошли до этой строки — метод не упал, тест провален
            Assert.fail('Should have thrown an exception for invalid Id');

        } catch (Exception e) {
            // Метод упал как и ожидалось — проверяем что сообщение не пустое
            Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
}
