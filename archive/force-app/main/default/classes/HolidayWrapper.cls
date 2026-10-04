public class HolidayWrapper {
@AuraEnabled

    public String name;
    @AuraEnabled
    public HolidayDate z0date;// taken from the Calendarific API response

    public class HolidayDate{
         @AuraEnabled
        public String iso;// taken from the Calendarific API response
    }
 }
