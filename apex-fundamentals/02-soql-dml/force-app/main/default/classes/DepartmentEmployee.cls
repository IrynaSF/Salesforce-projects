public class DepartmentEmployee {
    public static void testDepartmentEmployee(){
        
     Department__c existingDept = [SELECT Id, Name FROM Department__c WHERE Name = 'IT' LIMIT 1];
        
        //2. Create a list of three Employee records (our child)
       List<Employee__c> emploees = new  List<Employee__c> ();
        
        Employee__c emplPeter = new Employee__c();
         emplPeter.Name = 'Peter Wills';
         emplPeter.Position__c = 'Developer';
         emplPeter.Salary__c = 120000;
        //// linked to Department through the Department__c Lookup field
        // since Employee__c and Department__c are related by a Lookup
         emplPeter.Department__c = existingDept.Id;
         emploees.add(emplPeter);
        
        Employee__c emplBetty = new Employee__c();
         emplBetty.Name = 'Betty Bound';
         emplBetty.Position__c = 'Manager';
         emplBetty.Salary__c = 10000;
         emplBetty.Department__c = existingDept.Id;
         emploees.add(emplBetty);
        
        /// Add a non-existent record to trigger an error.
        Employee__c emplMishel = new Employee__c();
         emplMishel.Name = 'Mishel Korby';
         emplMishel.Position__c = 'Designer';
         emplMishel.Salary__c = 900000;
         emplMishel.Department__c = '001000000000000AAA';// Non-existent record.
         emploees.add(emplMishel);
        
        //3. Wrap insert employees in try/catch/finally
        try{
            // perform the DML operation
            insert emploees;
            System.debug('Employees after insert: ' + emploees);
        }catch(DmlException e){
            // Catch the error and log its description
            System.debug('Error inserting employees: ' + e.getMessage());
        }finally{
            System.debug('Insert completed');
        }      
        
            //4. Query the parent with its children
        
        List<Department__c> department = [
            SELECT Id, Name,
            (SELECT Id, Name,Position__c FROM Employees__r )
            FROM Department__c
            WHERE Id = :existingDept.Id
        ];
        System.debug(department);
        
        // Check that we can work with our data
        emploees[0].Position__c = 'Senior Developer';
         update emploees[0];
    }
}
