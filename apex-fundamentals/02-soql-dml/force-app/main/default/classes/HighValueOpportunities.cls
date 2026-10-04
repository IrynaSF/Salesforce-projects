public class HighValueOpportunities {
    public static List<Opportunity> HighValueOpportunities(){
        List<Opportunity> opp = [
            SELECT Id, Name, Amount, StageName
            FROM Opportunity
            WHERE Amount > 50000
            AND StageName != 'Closed Lost'
            ORDER BY Amount DESC
             LIMIT 5
        ];
        System.debug(opp);
        return opp;
        
        
    }

}
