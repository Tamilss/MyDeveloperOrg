public class ListViewController{
    
    public Account[] acct{get;set;}
    
    public ListViewController( ApexPages.StandardSetController con) {
    
        acct = [ SELECT Name ,BillingCity, Phone FROM ACCOUNT ];    
        
    }
}