public class HolidayWrapper {
@AuraEnabled

    public String name;
    @AuraEnabled
    public HolidayDate z0date;// взята из ответа Calendarific сайта

    public class HolidayDate{
         @AuraEnabled
        public String iso;//взята из ответа Calendarific сайта 
    }
 }
