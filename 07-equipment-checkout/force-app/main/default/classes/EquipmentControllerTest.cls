@isTest
private class EquipmentControllerTest {
  
    //Test data
    @TestSetup
    static void setupData(){
Contact employee = new Contact(LastName = 'Tester');
    insert employee;

    List<Equipment__c> equipmList = new List<Equipment__c>{
        new Equipment__c(Name = 'Laptop Test', Status__c = 'Available', Type__c = 'Laptop'),
        new Equipment__c(Name = 'Monitor Test', Status__c = 'Available', Type__c = 'Monitor'),
        new Equipment__c(Name = 'HeadPhone Test', Status__c = 'Maintenance', Type__c = 'Other')
    };
   insert equipmList;
        
    }

    //Check that available equipment is returned.
    @isTest
    static void getAvailableEquipmentTest(){
        Test.startTest();
        List<Equipment__c> result = EquipmentController.getAvailableEquipment();
        Test.stopTest();

        //Check the count.
        Assert.areEqual(2, result.size(), 'Only available equipment should be returned');

        
        for (Equipment__c item : result) {
    Assert.areEqual('Available', item.Status__c, 'Every returned equipment should be Available');
}
    }
    //Successful checkout test.
        @isTest
    static void checkoutEquipmentSuccessTest() {
        // 1. Setup: get the employee and available equipment
        Contact employee = [SELECT Id FROM Contact LIMIT 1];
        Equipment__c equipment = [
            SELECT Id
            FROM Equipment__c
            WHERE Status__c = 'Available'
            LIMIT 1
        ];

        // 2. Call the controller method
        Test.startTest();
        EquipmentController.checkoutEquipment(equipment.Id, employee.Id);
        Test.stopTest();

        // 3. Find the created checkout in the database
        List<Checkout__c> checkouts = [
            SELECT Id, Employee__c
            FROM Checkout__c
            WHERE Equipment__c = :equipment.Id
        ];

        // 4. Assert
        Assert.areEqual(1, checkouts.size(), 'One checkout should be created');
        Assert.areEqual(employee.Id, checkouts[0].Employee__c , 'Checkout should be created for the selected employee');
    }
    //Now we catch the error.
        @isTest
    static void checkoutEquipmentErrorTest() {
        // 1. Setup: employee and available equipment
        Contact employee = [SELECT Id FROM Contact LIMIT 1];
        Equipment__c equipment = [
            SELECT Id
            FROM Equipment__c
            WHERE Status__c = 'Available'
            LIMIT 1
        ];

        // 2. Setup: first checkout, the equipment becomes busy
        EquipmentController.checkoutEquipment(equipment.Id, employee.Id);

        // 3. Flag: was there an error (Boolean true/false)
        Boolean exceptionThrown = false;

        // 4. Second checkout of the same equipment should fail
        Test.startTest();
        try {
            EquipmentController.checkoutEquipment(equipment.Id, employee.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // 5. Assert that the error happened
        Assert.isTrue(exceptionThrown, 'Expected AuraHandledException for double checkout');
    }
    //Successful return test.
        @isTest
    static void returnEquipmentSuccessTest() {
        // 1. Setup: employee and available equipment
        Contact employee = [SELECT Id FROM Contact LIMIT 1];
        Equipment__c equipment = [
            SELECT Id
            FROM Equipment__c
            WHERE Status__c = 'Available'
            LIMIT 1
        ];

        // 2. Setup: create a checkout
        Checkout__c checkout = new Checkout__c(
            Employee__c  = employee.Id,
            Equipment__c = equipment.Id
        );
        insert checkout;

        // 3. Call the return method
        Test.startTest();
        EquipmentController.returnEquipment(checkout.Id);
        Test.stopTest();

        // 4. Re-query the checkout from the database
        Checkout__c updatedCheckout = [
            SELECT Return_Date__c
            FROM Checkout__c
            WHERE Id = :checkout.Id
        ];

        // 5. Assert the date
        Assert.areEqual(Date.today(), updatedCheckout.Return_Date__c, 'Return date should be set to today');
    }
    //Error handling when returning equipment.
    @isTest
    static void returnEquipmentErrorTest() {
        // 1. Setup: employee and available equipment
        Contact employee = [SELECT Id FROM Contact LIMIT 1];
        Equipment__c equipment = [
            SELECT Id
            FROM Equipment__c
            WHERE Status__c = 'Available'
            LIMIT 1
        ];

        // 2. Setup: create a checkout and delete it right away
        Checkout__c checkout = new Checkout__c(
            Employee__c  = employee.Id,
            Equipment__c = equipment.Id
        );
        insert checkout;
        delete checkout;

        // 3. Flag
        Boolean exceptionThrown = false;

        // 4. Try to return the deleted checkout
        Test.startTest();
        try {
            EquipmentController.returnEquipment(checkout.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // 5. Assert that the error happened
        Assert.isTrue(exceptionThrown, 'Expected AuraHandledException when returning a deleted checkout');
        
    }
    //With null the method must return an empty list (0 items) and not fail
        @isTest
    static void getMyCheckoutsNullTest() {
        // 1. Call the method without an employee
        Test.startTest();
        List<Checkout__c> result = EquipmentController.getMyCheckouts(null);
        Test.stopTest();

        // 2. Assert the list is empty
        Assert.areEqual(0, result.size(), 'Empty list expected when contactId is null');
    }
    //Only unreturned checkouts (Return_Date__c = null) are returned.
        @isTest
    static void getMyCheckoutsTest() {
        // 1. Setup: employee and ALL available equipment
        Contact employee = [SELECT Id FROM Contact LIMIT 1];
        List<Equipment__c> equipmentList = [
            SELECT Id
            FROM Equipment__c
            WHERE Status__c = 'Available'
        ];

        // 2. Setup: two checkouts for different equipment
        List<Checkout__c> checkouts = new List<Checkout__c>{
            new Checkout__c(Employee__c = employee.Id, Equipment__c = equipmentList[0].Id),
            new Checkout__c(Employee__c = employee.Id, Equipment__c = equipmentList[1].Id)
        };
        insert checkouts;

        // 3. Setup: return the FIRST checkout
        checkouts[0].Return_Date__c = Date.today();
        update checkouts[0];

        // 4. Call the method
        Test.startTest();
        List<Checkout__c> result = EquipmentController.getMyCheckouts(employee.Id);
        Test.stopTest();

        // 5. Assert
        Assert.areEqual(1, result.size(), 'Only open checkouts should be returned');
        Assert.areEqual(checkouts[1].Id, result[0].Id, 'Returned checkout should be the open one');
    }
    //The method must return the contacts that exist in the database.
        @isTest
    static void getContactsTest() {
        // 1. Call the method
        Test.startTest();
        List<Contact> result = EquipmentController.getContacts();
        Test.stopTest();

        // 2. Assert the count
        Assert.areEqual(1, result.size(), 'All test contacts should be returned');
    }
}