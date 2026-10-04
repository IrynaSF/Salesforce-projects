public with sharing class TernerniiOperator {
    public static String getAccountTier(Decimal annualRevenue){

         String tier = (annualRevenue >= 1000000) ? 'Enterprise' : 'SMB';
         System.debug('Account tier: ' + tier);
     
         return tier;
       
    }
    
}



//(revenue >= 1000000): the condition (what we check)
///?: "if the condition is true, then..."
//'Enterprise': the value if true
//: "otherwise..."
//'SMB': the value if false

// Ternary operator
// A one-line shorthand for if/else. Used when you just need to assign one of two values to a variable.
// Pattern:
// type variable = condition ? value_if_true : value_if_false;
// When to use it:
/// When the logic is simple: just pick one of two values.
// If the logic is complex (several actions inside), a regular if/else is better.

// Task 2: ternary operator
// Write a method getAccountTier(Decimal annualRevenue):
/// Takes the number annualRevenue
// Uses the ternary operator to determine the customer tier:
// if annualRevenue >= 1000000 → 'Enterprise'
// otherwise → 'SMB'
