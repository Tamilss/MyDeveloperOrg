trigger TestFormalaField on Test__c (after update) {
    
    for( Test__c t : trigger.New ) {
        
        if( t.Formula_Number__c != trigger.oldMap.get(t.Id).Formula_Number__c ){
            
            System.debug('t.Formula_Number__c ::: ' + t.Formula_Number__c);
            System.debug('trigger.oldMap.get(t.Id).Formula_Number__c ::: ' + trigger.oldMap.get(t.Id).Formula_Number__c);
        }
        system.debug('::t::'+t);
    }

}