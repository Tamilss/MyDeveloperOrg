public class SampleController {
public Account account {get;set;}
public string val {get;set;}

    public SampleController (Apexpages.StandardController cn) {
        account = new Account();
    }
    public void submitvalue() {
        if( account.End_Customer_Account__c!= null) {
            val = account.End_Customer_Account__c; 
        }
    }
}