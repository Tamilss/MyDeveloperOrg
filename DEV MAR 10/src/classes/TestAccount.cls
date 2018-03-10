public class TestAccount {
    
    public Account acc {get;set;}
    
    public TestAccount() {
        
        acc = [ SELECT Id,AccountNumber,Name FROM Account WHERE Id = : ApexPages.CurrentPage().getParameters().get('Id')];
    }
    public void saveAccount() {
    	
    	string name;
        insert acc;
    }
    public void Edit() {
    	
    	update acc;
    }
    
}