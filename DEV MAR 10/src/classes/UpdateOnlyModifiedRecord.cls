public class UpdateOnlyModifiedRecord {
    
    public List<Contact> toBeUpdatedContactList{get;set;}
    List<Contact> existingContactList  = new List<Contact>();
    List<Contact> finalUpdatedList = new List<Contact>();
    Id accId;
    public UpdateOnlyModifiedRecord() {
        
        accId = ApexPages.CurrentPage().getParameters().get('Id');
        toBeUpdatedContactList = [ 
                                   SELECT 
                                       Id,AccountId,LastName,FirstName,Level__c
                                   FROM 
                                       Contact 
                                   WHERE AccountId =: accId
                                  ];
        existingContactList =  toBeUpdatedContactList.clone();    
        system.debug('::::existingContactList:::'+existingContactList);                      
        system.debug('::::toBeUpdatedContactList:::'+toBeUpdatedContactList);                      
        
    }
    public void save() {
        
        /*existingContactList =  [ 
                                   SELECT 
                                       Id,AccountId,LastName,FirstName,Level__c
                                   FROM 
                                       Contact 
                                   WHERE AccountId =: accId
                                 ];   */
        system.debug('::::existingContactList:::'+existingContactList);                      
        system.debug('::::toBeUpdatedContactList:::'+toBeUpdatedContactList);                      
        for(Integer i = 0 ;i < existingContactList.size();i++ ) {
            
            if( existingContactList[i].AccountId != toBeUpdatedContactList[i].AccountId ||
               existingContactList[i].LastName!= toBeUpdatedContactList[i].LastName||
               existingContactList[i].FirstName!= toBeUpdatedContactList[i].FirstName||
               existingContactList[i].Level__c!= toBeUpdatedContactList[i].Level__c
               ) {
                
                 finalUpdatedList.add(toBeUpdatedContactList[i]); 
                       
             }    
        }
        if( finalUpdatedList.size() > 0 ) {
        
            update finalUpdatedList;
        } 
        system.debug('::::finalUpdatedList:::'+finalUpdatedList);                         
    }
}