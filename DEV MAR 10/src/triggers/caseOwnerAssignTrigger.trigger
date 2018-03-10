trigger caseOwnerAssignTrigger on Case (before insert,before update) {
    map<Id,List<Case>> caseAccount = new  map<Id,List<Case>>();
    map<Id,Id>  accountOwnerMap = new map<Id,Id>();
    for( Case c : Trigger.New ) {
       
       if(caseAccount.containsKey(c.AccountId)){  
           caseAccount.get(c.Id).add(c);  
       }
       else {
           
          caseAccount.put(c.AccountId, new List<Case>{c}) ;
       } 
    }               
    for( Account acc : [ 
                        SELECT
                             Id,
                             Name,
                             OwnerId
                        FROM
                             Account
                         WHERE
                             Id IN:caseAccount.keySet() ]) {
        accountOwnerMap.put(acc.Id,acc.OwnerId); 
    }                                                                                  
                         
   for( Id ids : caseAccount.keySet() ) {
       
       for(Case c : caseAccount.get(ids)) {
           
           c.OwnerId = accountOwnerMap.get(ids);
       }
   }     
    
}