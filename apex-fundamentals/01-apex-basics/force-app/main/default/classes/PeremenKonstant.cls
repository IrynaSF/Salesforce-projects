public class PeremenKonstant {
    public static void Peremen(){
        String phone='Apple';
        Integer quantity=3;
        Decimal unitPrice =9.99;
        Boolean active=true;
        Date today=Date.today();
 
        final Decimal taxRate = 0.08;
         final String currencies ='USD';
        
       Decimal excludingTax = quantity * unitPrice;
       Decimal taxAmount = excludingTax *taxRate;
        Decimal includingTax = excludingTax + taxAmount;
        System.debug('Phone: ' + phone);
       System.debug('Total amount: ' + includingTax);
    }

}
