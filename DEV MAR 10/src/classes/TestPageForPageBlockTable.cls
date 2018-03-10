public class TestPageForPageBlockTable {
    
    public List<Account> accList{get;set;}
    public string Name{get;set;}
    public TestPageForPageBlockTable() {
        
        accList = [ select Id,Name,Type from Account Limit 10 ];    
    }
    public void save() {
    
        update accList;
    }
}