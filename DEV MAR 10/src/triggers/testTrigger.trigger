trigger testTrigger on Account (before insert,before update) {

    List<Account> accountList = new List<Account>();
    List<Account> insertedAccount = new List<Account>();
    Set<Id> accId = new Set<Id>();
    
    if(Trigger.isInsert) {
        
        for(Account a : Trigger.New ) {
        
            if(a.AnnualRevenue <= 5000 ) {
            
                 accountList.add(a);
            }
            insertedAccount.add(a);
        }
        insert insertedAccount;
        
    }
    if(Trigger.isUpdate) {
    
        for( Account a : Trigger.New ) {
            
            accId.add(a.Id);
        }
        List<Account> accList = [SELECT Id FROM Account where Id NOT IN : accId limit 1];
        update accList;
    }
    for(Account acc :accountList   ) {
        acc.Id.addError('it');    
    }
    getData();
    @future
    public static void getData() {
    }
}