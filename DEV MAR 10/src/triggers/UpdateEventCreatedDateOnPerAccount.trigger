trigger UpdateEventCreatedDateOnPerAccount on Event ( after Insert,after update, after delete ) {

    Set<Id> personAccIdSet = new Set<Id>();
    List<Account> personAccList = new List<Account>();
    List<Account> toBeUpdatedpersonAccList = new List<Account>();
    Map<Id, DateTime> perAccIdAndEventDateTimeMap = new Map<Id, DateTime>();
    Map<Id, Integer> perAccIdAndAllAvtyCountMap = new Map<Id, Integer>();
    Map<Id, Integer> oldPerAccIdAndAllAvtyCountMap = new Map<Id, Integer>();
    Schema.DescribeSObjectResult perAccIdPrefix = Account.sObjectType.getDescribe();
    
    if (trigger.isInsert) {
        
        system.debug('::::Trigger.new::'+Trigger.new);
        for (Event ev : Trigger.new) {
        
            if (ev.WhatId != NULL) {
            
                if (String.valueOf(ev.WhatId).startsWith(perAccIdPrefix.getKeyPrefix())){ 
           
                    if ( perAccIdAndEventDateTimeMap.ContainsKey(ev.WhatId)) {
               
                        if ( perAccIdAndEventDateTimeMap.get (ev.WhatId) > ev.CreatedDate) {
                  
                            perAccIdAndEventDateTimeMap.Put (ev.WhatId, ev.CreatedDate);                                 
                        }                                       
                    } else {
                        perAccIdAndEventDateTimeMap.Put(ev.WhatId, ev.CreatedDate);               
                    }  
                    personAccIdSet.add (ev.WhatId);                                                   
                }    
            }
        }
    } 
    if( trigger.isUpdate ) {
        
        for (Event ev : Trigger.new) {
    
            if( Trigger.oldMap.get( ev.Id ).WhatId != ev.WhatId ) {
                    
                if( ev.WhatId != NULL ) {  
                    
                   if ( String.valueOf(ev.WhatId).startsWith(perAccIdPrefix.getKeyPrefix()) ){ 
           
                        personAccIdSet.add (ev.WhatId); 
                    } 
                }
                if( Trigger.oldMap.get( ev.Id ).WhatId != NULL ) {
                    
                    if ( String.valueOf( Trigger.oldMap.get( ev.Id ).WhatId ).startsWith(perAccIdPrefix.getKeyPrefix()) ){ 
                    
                        personAccIdSet.add ( Trigger.oldMap.get( ev.Id ).WhatId );
                    }
                }  
            }
        }
    }
    if ( trigger.isDelete ) {
    
        for ( Event ev : Trigger.old ) {
        
            if (ev.WhatId != NULL) {
            
                personAccIdSet.add (ev.WhatId);                                                   
            }
        }
    }
    if( personAccIdSet.size() > 0 ) {
        
          
        AggregateResult[] AllTaskCountResult = [SELECT WhatId, Count(Id)
                                                FROM Task 
                                                WHERE WhatId IN : personAccIdSet GROUP BY WhatId  ];
          
        AggregateResult[] allEventCountResult = [SELECT WhatId, Count(Id)
                                                FROM Event 
                                                WHERE WhatId IN : personAccIdSet GROUP BY WhatId  ];
      
    
    
        for (AggregateResult ar : AllTaskCountResult )  {
            perAccIdAndAllAvtyCountMap.put( String.valueOf(ar.get('WhatId')), Integer.valueOf( ar.get('expr0')) );
        }
        for (AggregateResult ar : allEventCountResult )  {
            
            if( perAccIdAndAllAvtyCountMap.containsKey( String.valueOf(ar.get('WhatId'))) ) {
            
                perAccIdAndAllAvtyCountMap.put( String.valueOf(ar.get('WhatId')), perAccIdAndAllAvtyCountMap.get( String.valueOf(ar.get('WhatId')))+Integer.valueOf( ar.get('expr0')) );
            } else {
            
                perAccIdAndAllAvtyCountMap.put( String.valueOf(ar.get('WhatId')), Integer.valueOf(ar.get('expr0')) );
            }
        }
    }
    system.debug(':::personAccIdSet::'+personAccIdSet);
    system.debug(':::perAccIdAndAllAvtyCountMap::'+perAccIdAndAllAvtyCountMap);
    system.debug(':::oldPerAccIdAndAllAvtyCountMap::'+oldPerAccIdAndAllAvtyCountMap);
    if (personAccIdSet.size() >0) {
        
        personAccList = [ SELECT Id, Total_No_of_Emails_sent__c,First_Activity_Created_Date__c,
                         Total_No_of_Activities__c, To_No_of_Calls_Out__c   
                         FROM Account
                         WHERE Id IN : personAccIdSet ];
            
    }
    if ( personAccList.size() >0 ) {
        
        for (Account perAccRec : personAccList) {
            
            if ( perAccRec.First_Activity_Created_Date__c  == NULL ) {
            
                if ( perAccIdAndEventDateTimeMap.containsKey( perAccRec.Id ) ) {
            
                    perAccRec.First_Activity_Created_Date__c = perAccIdAndEventDateTimeMap .get (perAccRec.Id);
                    
                }
            }
           if( perAccIdAndAllAvtyCountMap.containsKey( perAccRec.Id )  ) {
            
                    
                perAccRec.Total_No_of_Activities__c =  perAccIdAndAllAvtyCountMap.get( perAccRec.Id );     
                
            }
            toBeUpdatedpersonAccList.add( perAccRec ); 
                       
        }        
    }
    system.debug(':::toBeUpdatedpersonAccList:::'+toBeUpdatedpersonAccList);
    if ( toBeUpdatedpersonAccList.size() > 0) {
        
        update toBeUpdatedpersonAccList;        
    }
}