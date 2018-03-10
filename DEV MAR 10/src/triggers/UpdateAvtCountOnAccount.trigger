trigger UpdateAvtCountOnAccount on Task (After insert, After update, After delete ) {
    
    public static Set<Id> personAccIdSet = new Set<Id>();
    public static string prevSchedlerId;
    Schema.DescribeSObjectResult perAccIdPrefix = Account.sObjectType.getDescribe();
    
    if ( trigger.isInsert ) {
    
        for (Task tskRec : Trigger.new) {
        
            if (tskRec.WhatId != NULL) {
            
                if ( String.valueOf( tskRec.WhatId ).startsWith(perAccIdPrefix.getKeyPrefix())){ 
                    
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
    if( prevSchedlerId == NULL ) {

        //schedulertoCallBatchApex.perAccountIds = personAccIdSet;
        Datetime sysTime = System.now().addSeconds( 120 );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        //prevSchedlerId = System.schedule( 'RollupAvtyOnPerAccount-'+sysTime, chronExpression, new schedulertoCallBatchApex ());
        system.debug('::prevSchedlerId :::'+prevSchedlerId );
        system.debug('::personAccIdSet:::'+personAccIdSet);
        
    } else {
    
       //Id CronTrigId = [ SELECT CronJobDetailId, CronExpression FROM CronTrigger WHERE CronJobDetailId =: prevSchedlerId ].CronJobDetailId; 
       System.abortJob( prevSchedlerId );
       //schedulertoCallBatchApex.perAccountIds = personAccIdSet;
       Datetime sysTime = System.now().addSeconds( 120 );      
       String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
       //prevSchedlerId  = System.schedule( 'RollupAvtyOnPerAccount', chronExpression, new schedulertoCallBatchApex ());
       system.debug('::prevSchedlerId :::'+prevSchedlerId );
       system.debug('::personAccIdSet:::'+personAccIdSet);
    }
}