/**
    Trigger Name :SetSchoolId
    Developer    :Tamilselvam.B
    Developed On :01/12/11
    Company      :Softsquare Solutions
    Description  :
        This trigger fire before insert of Lead object.when you create Lead object
        (School_Name__c  lookup field of Account object) School_Name__c  field value
        retrieved and query the account object then Id of the Account is assigned to
        Leads School__c field . 
        
*/
trigger SetSchoolId on Lead ( before insert ) {

    Set<String> accountNames = new Set<String>(); // This Set to store  all new lead AccountName  
    Map<String,String> accountNameIdMap = new Map<String, String>(); //This Map Stores new Lead AccountName and its Id
    
    // Loop for get the all new Lead Account lookup name
    for ( Lead leadObj : Trigger.New ){
        // if SchoolName is not NULL and not empty
        if( leadObj.School_Name__c != null && leadObj.School_Name__c != '') {
    
             accountNames.add( leadObj.School_Name__c.toUpperCase() );
        }        
    }
    
    // Loop for get all AccountId for new Lead AccountName
    for( Account accountObj : [ SELECT Id, Name FROM Account WHERE  Name IN : accountNames ]) {
    
        accountNameIdMap.put( accountObj.Name.toUpperCase(), accountObj.Id ); 
    }
    
    // loop for assign new leads School__c field updated by Lead Account lookup field School_Name__c 
    for ( Lead leadObj : Trigger.New ){
    
        leadObj.School__c = accountNameIdMap.get( leadObj.School_Name__c );
    }
    
}