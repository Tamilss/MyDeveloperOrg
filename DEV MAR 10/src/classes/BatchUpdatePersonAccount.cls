global class BatchUpdatePersonAccount implements Database.Batchable<sObject>{

    global final String query;
    global final Set<Id> personAccIdSet = new Set<Id>();
    global final Set<Id> AllPersonAccIdSet = new Set<Id>();
    global final List<Account> personAccList = new List<Account>();
    global final Map<String, DateTime> perAccIdAndRecAvtDateTimeMap = new Map<String, DateTime>();
    global final Map<String, Integer> perAccIdAndEmailCountMap = new Map<String, Integer>();
    global final Map<String, Integer> perAccIdAndCallCountMap = new Map<String, Integer>();
    global final Map<String, Integer> perAccIdAndAllAvtyCountMap = new Map<String, Integer>();
    global final List<Account> toBeUpdatedpersonAccList = new List<Account>();
    global final Set<String> callSubjectList = new Set<String>();
    global final Set<String> emailSubjectList = new Set<String>();
    global final Schema.DescribeSObjectResult perAccIdPrefix = Account.sObjectType.getDescribe();
  
    global BatchUpdatePersonAccount( Set<Id> tempPerIds ){
        
        AllPersonAccIdSet = tempPerIds;   
    }

    global Iterable<sObject> start(Database.BatchableContext BC){
        
        List<Account> AllPersonAccList = [ SELECT Id,Total_No_of_Emails_sent__c,First_Activity_Created_Date__c,
                              Total_No_of_Activities__c, To_No_of_Calls_Out__c
                              FROM Account
                              WHERE  ( Total_No_of_Emails_sent__c = NULL OR Total_No_of_Activities__c = NULL OR  To_No_of_Calls_Out__c = NULL )]; 
        return AllPersonAccList;
    }

    global void execute(Database.BatchableContext BC, List<Account> tempPersonAccList ) {
                       
    
        for( String callSub : ( System.Label.Email_Task_Subject ).trim().split(',') ) {
                
                emailSubjectList.add( callSub.trim() );   
        }
        for( String callSub : ( System.Label.Call_Task_Subject).trim().split(',') ) {
                
            callSubjectList.add( callSub.trim() );   
        }
        for( Account perAcc : personAccList ) {
                                     
            personAccIdSet.add( perAcc.Id );
            personAccList.add( perAcc );
        }
        if( personAccIdSet.size() > 0 ) {
            
            AggregateResult[] callCountAggResult,emailCountAggResult, taskFstAvtyDate, eventFstAvtyDate, AllTaskCountResult, allEventCountResult ;  
            if( callSubjectList.size() > 0 ) { 
            
                callCountAggResult  = [SELECT WhatId, Count(Id)
                                                         FROM Task 
                                                         WHERE ( WhatId IN : personAccIdSet AND Subject IN :callSubjectList ) GROUP BY WhatId  ];
            }
            if( emailSubjectList.size() > 0 ) {
            
                emailCountAggResult = [SELECT WhatId, Count(Id)
                                                        FROM Task 
                                                        WHERE ( WhatId IN : personAccIdSet AND Subject IN :emailSubjectList ) GROUP BY WhatId  ];
            }
            taskFstAvtyDate  = [SELECT WhatId, MIN( CreatedDate )
                                                         FROM Task 
                                                         WHERE WhatId IN : personAccIdSet GROUP BY WhatId  ];
            eventFstAvtyDate  = [SELECT WhatId, MIN( CreatedDate )
                                                         FROM Event 
                                                         WHERE WhatId IN : personAccIdSet GROUP BY WhatId  ];
        
            AllTaskCountResult = [SELECT WhatId, Count(Id)
                                                    FROM Task 
                                                    WHERE WhatId IN : personAccIdSet GROUP BY WhatId  ];
              
            allEventCountResult = [SELECT WhatId, Count(Id)
                                                    FROM Event 
                                                    WHERE WhatId IN : personAccIdSet GROUP BY WhatId  ];
            
            for (AggregateResult ar : emailCountAggResult )  {
                       
                perAccIdAndEmailCountMap.put( String.valueOf(ar.get('WhatId')), Integer.valueOf( ar.get('expr0')) );
            }
            for (AggregateResult ar : callCountAggResult )  {
                perAccIdAndCallCountMap.put( String.valueOf(ar.get('WhatId')), Integer.valueOf( ar.get('expr0')) );
            }
            
            for( AggregateResult ar : taskFstAvtyDate ) {
                
                perAccIdAndRecAvtDateTimeMap.put( String.valueOf(ar.get('WhatId')), DateTime.valueOf( ar.get('expr0')));
            }
            for( AggregateResult ar : eventFstAvtyDate ) {
                
                if( perAccIdAndRecAvtDateTimeMap.containsKey( String.valueOf(ar.get('WhatId')))) {
                    
                    DateTime recAvt = perAccIdAndRecAvtDateTimeMap.get( String.valueOf(ar.get('WhatId')));
                    if( recAvt > DateTime.valueOf( ar.get('expr0'))) {
                        
                        perAccIdAndRecAvtDateTimeMap.put( String.valueOf(ar.get('WhatId')), DateTime.valueOf( ar.get('expr0')));   
                    }
                } else {
                    perAccIdAndRecAvtDateTimeMap.put( String.valueOf(ar.get('WhatId')), DateTime.valueOf( ar.get('expr0')));
                }
            }
           
            for (AggregateResult ar : AllTaskCountResult )  {
                
                perAccIdAndAllAvtyCountMap.put( String.valueOf(ar.get('WhatId')), Integer.valueOf( ar.get('expr0')) );
            }
            for (AggregateResult ar : allEventCountResult )  {
                       
                if( perAccIdAndAllAvtyCountMap.containsKey( String.valueOf(ar.get('WhatId')))) {
                           
                    perAccIdAndAllAvtyCountMap.put( String.valueOf(ar.get('WhatId')), perAccIdAndAllAvtyCountMap.get( String.valueOf(ar.get('WhatId')))+Integer.valueOf( ar.get('expr0')) );
                } else {
                           
                    perAccIdAndAllAvtyCountMap.put( String.valueOf(ar.get('WhatId')), Integer.valueOf(ar.get('expr0')) );
                }
                
            }
        }
        if ( personAccList.size() > 0 ) {
                
            for ( Account perAccRec : personAccList ) {
                    
                if( perAccRec.First_Activity_Created_Date__c == NULL ) {
                    
                        if( perAccIdAndRecAvtDateTimeMap.containsKey( perAccRec.Id ) ) {
                            
                            perAccRec.First_Activity_Created_Date__c = perAccIdAndRecAvtDateTimeMap.get(perAccRec.Id);
                        }
                }
                if( perAccIdAndAllAvtyCountMap.containsKey( perAccRec.Id )  ) {
                
                        
                    perAccRec.Total_No_of_Activities__c =  perAccIdAndAllAvtyCountMap.get( perAccRec.Id );     
                    
                } else {
                    perAccRec.Total_No_of_Activities__c  = 0 ;  
                }
                if( perAccIdAndEmailCountMap.containsKey( perAccRec.Id ) ) {
                
                    perAccRec.Total_No_of_Emails_sent__c = perAccIdAndEmailCountMap.get( perAccRec.Id );   
                        
                } else {
                    
                    perAccRec.Total_No_of_Emails_sent__c = 0;
                }
                
                if( perAccIdAndCallCountMap.containsKey( perAccRec.Id )) {
                
                    perAccRec.To_No_of_Calls_Out__c =  perAccIdAndCallCountMap.get( perAccRec.Id );    
                      
                } else {
                    perAccRec.To_No_of_Calls_Out__c =  0;        
                }
                toBeUpdatedpersonAccList.add( perAccRec ); 
                           
            }        
        }
        if ( toBeUpdatedpersonAccList.size() > 0) {
            
            update toBeUpdatedpersonAccList;        
        }
    }
    global void finish(Database.BatchableContext BC){
    
    }
}