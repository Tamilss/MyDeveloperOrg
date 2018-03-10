global with sharing Class pbxContactController {

  
    public string name{get;set;}
    public string numOne{get;set;}
    public string phoneNumber;
    public string notes{get;set;}
    Public List<Contact> conList{get;set;}
    Public List<Account> accList{get;set;}
    Public List<Lead> leadList{get;set;}
    Public List<Case> caseList{get;set;}
    Public Map<Id,Account> accountIdRecMap = new Map<Id,Account>();
    Public Map<Id,Contact> contactIdRecMap = new Map<Id,Contact>();
    Public Map<Id,Lead> leadIdRecMap = new Map<Id,Lead>();
    Public Map<Id,List<Case>> accountIdListOfCase = new Map<Id,List<Case>>();
    Public Map<Id,List<Case>> contactIdListOfCase = new Map<Id,List<Case>>();
    Public Map<Id,List<Case>> LeadIdListOfCase = new Map<Id,List<Case>>();
    
    public pbxContactController (ApexPages.StandardController stdCont) {
    }
    

    
     Public pbxContactController() {
        
        conList = new List<Contact>();
        accList = new List<Account>();
        leadList = new List<Lead>();
        PhoneNumber = ApexPages.CurrentPage().getParameters().get('pn'); 
        system.debug('::::PhoneNumber:::'+PhoneNumber);
        conList = [ SELECT AccountId,Name,MobilePhone FROM Contact WHERE MobilePhone = :PhoneNumber OR HomePhone =:PhoneNumber   ];
        system.debug('::::conList :::'+conList );
        conList = new List<Contact>();
        PhoneNumber = ApexPages.CurrentPage().getParameters().get('pn'); 
        
        system.debug('::::PhoneNumber:::'+PhoneNumber);
        
        for(Account acc : [ SELECT Id,Name,Household_Phone__c,Type,WorkPhone__c FROM Account WHERE Household_Phone__c = :PhoneNumber OR WorkPhone__c =:PhoneNumber]) {
            
            accountIdRecMap.put(acc.Id,acc);
            accList.add(acc);
              
        }
        
        for(Contact con : [ SELECT AccountId,Name,MobilePhone,AssistantPhone FROM Contact WHERE MobilePhone = :PhoneNumber OR HomePhone =:PhoneNumber OR AssistantPhone  = :PhoneNumber ]) {
            
            contactIdRecMap.put(con.Id,con); 
            conList.add(con);   
        }
        for(Lead leadRec : [ SELECT PartnerAccountId,Name,MobilePhone,Phone FROM Lead WHERE MobilePhone = :PhoneNumber OR Phone =:PhoneNumber]) {
            
            leadIdRecMap.put(leadRec.Id,leadRec);
            leadList.add(leadRec); 
               
        }
        for(Case caseRec : [SELECT AccountId,Origin,OwnerId,Reason FROM Case WHERE AccountId IN:accountIdRecMap.keySet()]) {
            
            if( accountIdListOfCase.containsKey(caseRec.AccountId)) {
                
                List<Case> tempList = accountIdListOfCase.get(caseRec.AccountId);
                tempList.add(caseRec);
                accountIdListOfCase.put(caseRec.AccountId,tempList);
                   
            } else {
                
                List<Case> tempList = new List<Case>();
                tempList.add(caseRec);
                accountIdListOfCase.put(caseRec.AccountId,tempList);    
            }   
        }
        for(Case caseRec : [SELECT ContactId,Origin,OwnerId,Reason FROM Case WHERE ContactId IN:contactIdRecMap.keySet()]) {
            
            if( contactIdRecMap.containsKey(caseRec.AccountId)) {
                
                List<Case> tempList = contactIdListOfCase.get(caseRec.AccountId);
                tempList.add(caseRec);
                contactIdListOfCase.put(caseRec.AccountId,tempList);
                   
            } else {
                
                List<Case> tempList = new List<Case>();
                tempList.add(caseRec);
                contactIdListOfCase.put(caseRec.AccountId,tempList);    
            }   
        }
       
    }
    
    webService static String save(String objId,String notesOfObject) {
        
        String idPrefix = objId.subString(0,3);
        String ObjName;
        Map<String, Schema.SObjectType> globalDescOfObjects = Schema.getGlobalDescribe(); 
        
        for(String obj : globalDescOfObjects.keySet() ) {
            
            Schema.DescribeSObjectResult desObj = globalDescOfObjects.get(obj).getDescribe();
            if(desObj.getKeyPrefix() == idPrefix ) {
                
                ObjName = obj ;
            }
        }
        
        Note caseNote = new Note();
        caseNote.ParentId = objId;
        caseNote.Body = notesOfObject;
        caseNote.Title = 'notesOfObject';
        insert caseNote;
        system.debug(':::::::caseNote:::'+caseNote);
     
     return ObjName;
    }
}