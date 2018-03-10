trigger toCheckAnnualRevenue on Account (after update, after insert) {
    
    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
    Set<Id> currentAccountOwner = new Set<Id>();
    Set<Id> currentAccount = new Set<Id>();
    Map<Id,String> accountContactEmail = new Map<Id,String>();
    List<Account> toBeUpdatedList = new List<Account>();
    Set<Id> insertedAccountIds = new Set<Id>();
    
    if( ChangePasswordController.triggerExecution == TRUE ) {
    
        if(Trigger.isInsert) {
        
            for(Account a : Trigger.New) {
                
                system.debug( ':::::::::before assign name:::::'+a);
                if( a.AnnualRevenue >= 500000 ) {
                    
                    currentAccountOwner.add(a.OwnerId); 
                    currentAccount.add(a.Id); 
                    
                }
                // a.Name = 'Test Acc1';
                insertedAccountIds.add( a.Id );
                system.debug( ':::::::::a:::::'+a);
                
            }
        }
        system.debug( '::::::::insertedAccountIds:::::'+insertedAccountIds);
        if(Trigger.isUpdate) {
            
            for( Account a : Trigger.New ) {
                
                if( Trigger.oldMap.get(a.Id).AnnualRevenue != a.AnnualRevenue && a.AnnualRevenue >= 500000  ) {
                        
                    currentAccountOwner.add(a.OwnerId); 
                    currentAccount.add(a.Id);       
                }
            }
        }
        ChangePasswordController.triggerExecution = FALSE; 
    } 
    for( Account acc : [ select Id,Name from account where Id IN : insertedAccountIds] ) {
            
            acc.Name = 'Test';
            toBeUpdatedList.add( acc );
    }
    system.debug( '::::::::insertedAccountIds:::::'+insertedAccountIds);
    if( toBeUpdatedList.size() > 0 ) {
        update toBeUpdatedList;
        Delete toBeUpdatedList;
    }
    for( Contact c :[ 
                    SELECT 
                        Id,Name, Email,AccountId 
                    FROM 
                        Contact 
                    WHERE 
                        AccountId IN:currentAccount ]) {
        accountContactEmail.put(c.AccountId, c.Id);                    
    }
    List<EmailTemplate> emailTep = [SELECT Id,Name FROM EmailTemplate WHERE Name =:'Large business'];
    
    for( Account acc :[ SELECT Id,Name FROM Account WHERE Id IN: currentAccount]) {
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        mail.setTargetObjectId(accountContactEmail.get(acc.Id));
        mail.setTemplateId(emailTep.get(0).Id);
        mail.setReplyTo('tamil@softsquare.biz');
        mail.setwhatId(acc.Id);
        mailList.add(mail);  
    } 
    if(mailList.size()>0) {
    Messaging.sendEmail(mailList);
    }
}