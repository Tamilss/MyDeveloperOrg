trigger UpdateTaskCreatedDateOnPerAccount on Task ( after insert, after Update,after delete ) {
  
    Set<Id> personAccIdSet = new Set<Id>();
    List<Account> personAccList = new List<Account>();
    Map<String, DateTime> perAccIdAndTaskDateTimeMap = new Map<String, DateTime>();
    Map<String, Integer> perAccIdAndEmailCountMap = new Map<String, Integer>();
    Map<String, Integer> perAccIdAndCallCountMap = new Map<String, Integer>();
    Map<String, Integer> perAccIdAndAllAvtyCountMap = new Map<String, Integer>();
    List<Account> toBeUpdatedpersonAccList = new List<Account>();
    Set<String> callSubjectList = new Set<String>{'Call','Sales Call','Call Later'};
    Set<String> emailSubjectList = new Set<String>{'Email','Email Client'};
    Schema.DescribeSObjectResult perAccIdPrefix = Account.sObjectType.getDescribe();
        
   
  String oldSubject;
  Id oldWhatId;
    if ( trigger.isInsert ) {
    
        for (Task tskRec : Trigger.new) {
        
            if (tskRec.WhatId != NULL) {
            
                if ( String.valueOf( tskRec.WhatId ).startsWith(perAccIdPrefix.getKeyPrefix())){ 
                    
                    if ( perAccIdAndTaskDateTimeMap.ContainsKey(tskRec.WhatId)) {
               
                        Datetime r =  perAccIdAndTaskDateTimeMap.get (tskRec.WhatId);
                  
                        if (r > tskRec.CreatedDate) {
                  
                            perAccIdAndTaskDateTimeMap.Put (tskRec.WhatId, tskRec.CreatedDate);                                 
                        }                                       
                    } else {
           
                        perAccIdAndTaskDateTimeMap.Put(tskRec.WhatId, tskRec.CreatedDate);               
                    }   
                    personAccIdSet.add (tskRec.WhatId);                                                   
                }    
            }
        }
    }
  if( trigger.isUpdate ) {
        
        for (Task tskRec : Trigger.new) {
            
            if( Trigger.oldMap.get( tskRec.Id ).WhatId != tskRec.WhatId ||  Trigger.oldMap.get( tskRec.Id ).Subject != tskRec.Subject ) {
            
                if ( tskRec.WhatId != NULL ) {
                    
                    if ( String.valueOf( tskRec.WhatId ).startsWith(perAccIdPrefix.getKeyPrefix())){ 
                        
                        personAccIdSet.add ( tskRec.WhatId );
                    }
                }
                if( Trigger.oldMap.get( tskRec.Id ).WhatId != NULL) {
                    
                    if ( String.valueOf( Trigger.oldMap.get( tskRec.Id ).WhatId ).startsWith(perAccIdPrefix.getKeyPrefix())){ 
                    
                        personAccIdSet.add ( Trigger.oldMap.get( tskRec.Id ).WhatId  );
                    }
                }
            }
        
        }
    }
    if ( trigger.isDelete ) {
    
        for ( Task tskRec : Trigger.old ) {
        
            if (tskRec.WhatId != NULL) {
            
                if (String.valueOf( tskRec.WhatId ).startsWith(perAccIdPrefix.getKeyPrefix())){ 
                    
                    personAccIdSet.add (  tskRec.WhatId  );
                }
            }           
        }
    }
    if( personAccIdSet.size() > 0 ) {
        
         AggregateResult[] callCountAggResult,emailCountAggResult;  
        if( callSubjectList .size() > 0 ) {
        
            callCountAggResult  = [SELECT WhatId, Count(Id)
                                                     FROM Task 
                                                     WHERE ( WhatId IN : personAccIdSet AND Subject IN :callSubjectList ) GROUP BY WhatId  ];
        }
        if( emailSubjectList.size() > 0 ) {
        
            emailCountAggResult = [SELECT WhatId, Count(Id)
                                                    FROM Task 
                                                    WHERE ( WhatId IN : personAccIdSet AND Subject IN :emailSubjectList ) GROUP BY WhatId  ];
        }
          
        AggregateResult[] AllTaskCountResult = [SELECT WhatId, Count(Id)
                                                FROM Task 
                                                WHERE WhatId IN : personAccIdSet GROUP BY WhatId  ];
          
        AggregateResult[] allEventCountResult = [SELECT WhatId, Count(Id)
                                                FROM Event 
                                                WHERE WhatId IN : personAccIdSet GROUP BY WhatId  ];
      
    
        for (AggregateResult ar : emailCountAggResult )  {
        
            perAccIdAndEmailCountMap.put( String.valueOf(ar.get('WhatId')), Integer.valueOf( ar.get('expr0')) );
        }
        for (AggregateResult ar : callCountAggResult )  {
            perAccIdAndCallCountMap.put( String.valueOf(ar.get('WhatId')), Integer.valueOf( ar.get('expr0')) );
        }
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
    system.debug(':::perAccIdAndTaskDateTimeMap::'+perAccIdAndTaskDateTimeMap);
    system.debug(':::perAccIdAndEmailCountMap::'+perAccIdAndEmailCountMap);
    system.debug(':::perAccIdAndCallCountMap::'+perAccIdAndCallCountMap);
    system.debug(':::perAccIdAndAllAvtyCountMap::'+perAccIdAndAllAvtyCountMap);
    if (personAccIdSet.size() >0) {
        
        personAccList = [ SELECT Id,  Total_No_of_Emails_sent__c,First_Activity_Created_Date__c,
                         Total_No_of_Activities__c, To_No_of_Calls_Out__c   
                         FROM Account
                         WHERE Id IN : personAccIdSet ];
            
    }
    if ( personAccList.size() >0 ) {
        
        for (Account perAccRec : personAccList) {
            
            if( perAccRec.First_Activity_Created_Date__c == NULL ) {
            
                if( perAccIdAndTaskDateTimeMap.containsKey( perAccRec.Id ) ) {
                    
                    perAccRec.First_Activity_Created_Date__c = perAccIdAndTaskDateTimeMap.get(perAccRec.Id);
                }
            }
            if( perAccIdAndAllAvtyCountMap.containsKey( perAccRec.Id )  ) {
            
                    
                perAccRec.Total_No_of_Activities__c =  perAccIdAndAllAvtyCountMap.get( perAccRec.Id );     
                
            }
            if( perAccIdAndEmailCountMap.containsKey( perAccRec.Id ) ) {
            
                perAccRec.Total_No_of_Emails_sent__c = perAccIdAndEmailCountMap.get( perAccRec.Id );   
                    
            }
            
            if( perAccIdAndCallCountMap.containsKey( perAccRec.Id )) {
            
                perAccRec.To_No_of_Calls_Out__c =  perAccIdAndCallCountMap.get( perAccRec.Id );    
                  
            }
            toBeUpdatedpersonAccList.add( perAccRec ); 
                       
        }        
    }
    system.debug(':::toBeUpdatedpersonAccList:::'+toBeUpdatedpersonAccList);
    if ( toBeUpdatedpersonAccList.size() > 0) {
        
        update toBeUpdatedpersonAccList;        
    }
    
}