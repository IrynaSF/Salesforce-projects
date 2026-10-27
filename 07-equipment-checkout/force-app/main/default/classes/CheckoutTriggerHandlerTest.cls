@isTest
private class  CheckoutTriggerHandlerTest{
    @TestSetup
    static void setupData(){
        //Employee
        Contact employee = new Contact (LastName = 'Tester');
        insert employee;

        //Two available equipment records
        List<Equipment__c> equipmentsList = new List<Equipment__c>{
            new Equipment__c(Name = 'Test Laptop', Status__c = 'Available', Type__c = 'Laptop'),
            new Equipment__c(Name = 'Test Monitor', Status__c = 'Available', Type__c = 'Monitor')
        };
        insert equipmentsList;
    }

        @isTest
        static void markEquipmentInuseTest(){
            //Get the test data created in setupData
            Contact employee = [
                SELECT Id 
                FROM Contact
                LIMIT 1
            ];
            Equipment__c equipment = [
                SELECT Id 
                FROM Equipment__c 
                LIMIT 1
            ];
       
        //Build the checkout in memory
        Checkout__c checkout = new Checkout__c(
            Employee__c = employee.Id,
            Equipment__c = equipment.Id
        );
        

        //Run the action under test
        //Test.startTest();
        insert checkout;
       // Test.stopTest();

        //Re-query the equipment from the database
        //The trigger updated the equipment in the database; the in-memory variable still has the old status.
        //So we run a new SOQL query. The ":" before a variable in WHERE is a bind variable.
        Equipment__c updateEquipment = [
            SELECT Status__c
            FROM Equipment__c
            WHERE id = :equipment.Id
        ];

        //Assert the result
        Assert.areEqual('In Use', updateEquipment.Status__c, 'Equipment status should be In Use after checkout');


   }      
   //Double checkout
   @isTest
   static void preventDoubleCheckoutTest(){
    Contact employee = [
        SELECT Id 
        FROM Contact 
        LIMIT 1
    ];
    Equipment__c equipment =[
        SELECT Id
        FROM Equipment__c
        LIMIT 1
    ];
    //Setup: the first checkout makes the equipment busy.
    Checkout__c firstCheckout = new Checkout__c(
        Employee__c = employee.Id,
        Equipment__c = equipment.Id
    );
    insert firstCheckout;

    //Second checkout of the same equipment, still in memory.
    Checkout__c secondCheckout = new Checkout__c(
        Employee__c = employee.Id,
        Equipment__c = equipment.Id
    );

    Test.startTest();
    try {
        insert secondCheckout;
        Assert.fail('Expected DmlException for double checkout');

    }catch(DmlException e){
        Assert.isTrue(
         e.getMessage().contains('This equipment is already checked out and has not been returned yet'),
         'Error message should come from preventDoubleCheckout'
        );
    }
      Test.stopTest();
   }
    //Return test: status becomes Available
    @isTest
    static void markEquipmentAvailableTest(){
        Contact employee = [
            SELECT Id
            FROM Contact
            LIMIT 1
        ];
        Equipment__c equipment = [
            SELECT Id
            FROM Equipment__c
            LIMIT 1
        ];
        //Setup: checkout. The equipment becomes In Use.
          Checkout__c checkout = new Checkout__c(
            Employee__c  = employee.Id,
            Equipment__c = equipment.Id
        );
        insert checkout;
        //Action under test: return.
        Test.startTest();
             checkout.Return_Date__c = Date.today();
        update checkout;
        Test.stopTest();

        Equipment__c updatedEquipment = [
            SELECT Status__c
            FROM Equipment__c
            WHERE Id = :equipment.Id
        ];

        Assert.areEqual('Available', updatedEquipment.Status__c, 'Equipment status should be Available after return');

    }
}