// This is a scheduler class responsible for background work
// Its job: wake up at the right time and do the work
// Its specifics: it must implement the System.Schedulable interface
// It lives deep inside Salesforce and cannot talk directly to buttons on the screen
public class OpportSchedulerClass implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        
        // 1. A direct and clear query (find deals closed yesterday)
        List<Opportunity> closedOpps = [
            SELECT Name, AccountId, Amount, OwnerId 
            FROM Opportunity 
            WHERE StageName = 'Closed Won' AND CloseDate = YESTERDAY
        ];
        
        // 2. A "basket" for the new deals
        // Create an empty list where we collect
        // the new Follow-up Opportunities before inserting them into the database.
        List<Opportunity> newOpps = new List<Opportunity>();
        
        // 3. Data transfer loop
        // The for loop takes the list of yesterday's deals (closedOpps) and iterates over them one by one.
        // We call the current deal in the loop the variable opp.
        // For each closed Opportunity create a new Follow-up:
        for (Opportunity opp : closedOpps) {
            newOpps.add(new Opportunity(
                Name = 'Follow-up: ' + opp.Name,
                AccountId = opp.AccountId,
                Amount = opp.Amount,
                OwnerId = opp.OwnerId,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(90)
            ));
        }
        
        // 4. Save to the database (if the basket is not empty)
        if (!newOpps.isEmpty()) {
            insert newOpps;
        }
    }
}


// Scenario
// Every day the system automatically finds Opportunities that were closed as
// "Closed Won" and creates a new Follow-up Opportunity for a repeat
// sale to the same customer.

// I used the YESTERDAY filter instead of LAST_N_DAYS:30 because the scheduler runs every day.
// With a 30-day window the code would find the same deals again and create duplicates.
// Filtering by yesterday guarantees
// that every closed deal gets exactly one Follow-up.

// At a set time the scheduler wakes up ➡️ takes a snapshot of yesterday's won deals ➡️
// loops over them in a fraction of a second, creating copies ➡️ saves them to the database ➡️
// and goes back to sleep until the next night. If there were no closed deals yesterday,
// the query returns 0 records,
// the loop simply doesn't start, and the code finishes gracefully without breaking anything.
