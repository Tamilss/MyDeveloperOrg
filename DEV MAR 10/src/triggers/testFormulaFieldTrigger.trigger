trigger testFormulaFieldTrigger on sample_objec__c (after update,after insert,after delete) {

   List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
   set<Id> currentChildParent = new set<Id>();
   map<string,Double> parentRollupValue = new map<string,Double>();
   map<id,string> sampleObjectContactEmail = new map<id,string>();
   if( Trigger.isInsert) {
    
       for(sample_objec__c  samObj : Trigger.New ) {
       
           currentChildParent.add(samObj .Sample_Object1__c);
           
       }
    }
    if(Trigger.isUpdate) {
        
       
        for( sample_objec__c  samObj : Trigger.New ) {
            
            if(samObj.Credit__c != Trigger.oldMap.get(samObj.Id).Credit__c  
               || samObj.Debit__c != Trigger.oldMap.get(samObj.Id).Debit__c ) {
               
                currentChildParent.add(samObj.Sample_Object1__c);   
            }
        
        }   
        
    
    }
    if(Trigger.isDelete) {
    
        for( sample_objec__c  samObj : Trigger.old ) {
    
            if(samObj.Credit__c != NULL || samObj.Debit__c != NULL) { 
            
                currentChildParent.add(samObj.Sample_Object1__c);    
            }    
        }          
    }
    List<AggregateResult> aggRes = [ 
                                    SELECT 
                                        SUM(Credit__c),
                                        SUM(Debit__c),
                                        Sample_Object1__c 
                                    FROM
                                        sample_objec__c
                                    WHERE 
                                        Sample_Object1__c IN: currentChildParent
                                    GROUP BY 
                                        Sample_Object1__c 
                                    
                                   ];
    
    for(AggregateResult ar : aggRes ) {
    
       double result = Double.valueOf(ar.get('expr0'))-Double.valueOf(ar.get('expr1'));
       parentRollupValue.put(string.valueOf(ar.get('Sample_Object1__c')) ,result);            
       system.debug('::parentRollupValue::'+parentRollupValue);
    } 
    
    List<Sample_Object1__c> samObjList= [SELECT Id,Contact__r.Email FROM Sample_Object1__c WHERE Id IN:currentChildParent ];
    
    for(Sample_Object1__c samObj1 : samObjList) {
    
        sampleObjectContactEmail.put( samObj1.Id, samObj1.Contact__r.Email );
    }
    system.debug('::sampleObjectContactEmail::'+sampleObjectContactEmail);
    for( Id  ids : currentChildParent ) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Double cliBal = parentRollupValue.get(ids);
        string[] emailAddress = new string[] { 'tamil@softsquare.biz' };
        system.debug('::emailAddress::'+emailAddress  );
        if( cliBal > 500 && cliBal<= 1000) {
                
           //mail.setTargetObjectId(sampleObjectContactEmail.get(ids));
           mail.setPlainTextBody('Your balance go to between 500 to 1000');
          // mail.setWhatId(ids);
           mail.setSubject('Customer intimation');
           mail.setToAddresses(emailAddress);
           
        } else if( cliBal > 300 && cliBal<= 500 ) {
            
           //mail.setTargetObjectId(sampleObjectContactEmail.get(ids));
           mail.setPlainTextBody('Your balance go to between 300 to 500');
           //mail.setWhatId(ids);
           mail.setSubject('Customer intimation');
           mail.setToAddresses(emailAddress); 
              
        } else if( cliBal >0 && cliBal <=300 ) {
            
          // mail.setTargetObjectId(sampleObjectContactEmail.get(ids));
           mail.setPlainTextBody('Your balance go to between 0 to 300');
           //mail.setWhatId(ids);
           mail.setSubject('Customer intimation');
           mail.setToAddresses(emailAddress);  
             
        }  else if( cliBal < = 0  ) {
            
           //mail.setTargetObjectId(sampleObjectContactEmail.get(ids));
           mail.setPlainTextBody('Your balance go to  0 ');
           //mail.setWhatId(ids);
           mail.setSubject('Customer intimation');
           mail.setToAddresses(emailAddress);    
        } 
        msgList.add(mail); 
    } 
    if( msgList.size()>0 ) { 
    
        Messaging.sendEmail(msgList);
    }      
    
}