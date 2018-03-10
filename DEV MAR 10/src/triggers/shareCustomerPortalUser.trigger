trigger shareCustomerPortalUser on Account (after update) {
    
    List<Account> toBeSharedAccount = new List<Account>();
    Map<String,Id> partnerPortalNameAccountIdMap = new Map<String,Id>();
    Map<Id,Id> userRoleIdAndAccountIdMap= new Map<Id,Id>();
    Map<Id,Id> accountIdAndGroupIdMap = new Map<Id,Id>();
    List<AccountShare> accountSharingList = new List<AccountShare>();
    
    
    for( Account acc : trigger.new ) {
        
        if( acc.IsPartner == true && acc.AnnualRevenue >= 500000 ) {
            
            toBeSharedAccount.add(acc);
            partnerPortalNameAccountIdMap .put(acc.Name+' Partner User',acc.Id);
            
        }    
    }
    system.debug('::partnerPortalNameAccountIdMap:::'+partnerPortalNameAccountIdMap);
    for( UserRole usrRole : [SELECT Id,Name FROM UserRole WHERE Name IN: partnerPortalNameAccountIdMap.KeySet()]) {
    
        userRoleIdAndAccountIdMap.put(usrRole.Id,partnerPortalNameAccountIdMap.get(usrRole.Name));
        
    }
    system.debug('::userRoleIdAndAccountIdMap::'+userRoleIdAndAccountIdMap);
    for(Group usrGroup :[ SELECT Id,RelatedId FROM Group WHERE RelatedId IN : userRoleIdAndAccountIdMap.KeySet() ]  ) {
        
        accountIdAndGroupIdMap.put(userRoleIdAndAccountIdMap.get(usrGroup.RelatedId ),usrGroup.Id);
    }
    system.debug('::accountIdAndGroupIdMap::'+accountIdAndGroupIdMap);
    
    for(Account a : toBeSharedAccount ) {
    
        AccountShare newAccShare = new AccountShare();
        newAccShare.AccountId = a.Id;
        newAccShare.AccountAccessLevel= 'Edit';
        newAccShare.UserOrGroupId = accountIdAndGroupIdMap.get(a.Id);
        newAccShare.OpportunityAccessLevel = 'Read';
        newAccShare.CaseAccessLevel = 'None';
        accountSharingList.add(newAccShare);    
        
    }
    if(accountSharingList.size()>0 ) {
        insert accountSharingList;
    }
    system.debug('::accountSharingList::'+accountSharingList);
}