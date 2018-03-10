global class AccountWrecker implements Database.Batchable<sObject>{
    
     List<Account> accList1 = new List<Account>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
      String query = 'select Id, Name from Account LIMIT 2';
      return Database.getQueryLocator(query);
    }
    
    global void execute( Database.BatchableContext BC, SObject[] accList ) {
    
      
       for ( SObject acc : accList ) {
           Account accRec =(Account) acc ;
           accRec.Name += ' just got wrecked.';
           accList1.add(accRec);
       }
        
      }
    
    global void finish(Database.BatchableContext bc) {
      // send out an email or something to the user
      update accList1;
    }
}