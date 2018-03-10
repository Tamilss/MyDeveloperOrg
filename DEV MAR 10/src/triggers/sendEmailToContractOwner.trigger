trigger sendEmailToContractOwner on Attachment (after insert,after update, after delete ) {
    
    Map<Id,List<Attachment>> contractAttachments = new Map<Id,List<Attachment>>();
    Map<Id,Id> contractOwnerIdRecordIdMap = new Map<Id,Id>();
    List<Task> toBeinsertedTask =  new List<Task>();
    DescribeSObjectResult desSObjRes = Contract.SObjectType.getDescribe();
    String contPrefix = desSObjRes.getkeyPrefix();
    
    if( Trigger.IsInsert ) {
    
        for(Attachment att : Trigger.New) {
            
            if( (String.ValueOf(att.ParentId).startsWith(contPrefix))) {
                
                if( contractAttachments.containsKey(att.ParentId) ) {
                
                   List<Attachment> temAttList = contractAttachments.get(att.ParentId);
                   temAttList.add(att);  
                    contractAttachments.put(att.ParentId,temAttList);
                }  
                else {
                
                    contractAttachments.put(att.ParentId,new List<Attachment>{att} );
                }          
            }
        }
    }  
    system.debug('::contractAttachments::'+contractAttachments);  
    system.debug('::contractAttachments.size 1::'+contractAttachments);  

    for( Contract contr : [ SELECT Id,OwnerId FROM Contract WHERE Id IN: contractAttachments.keySet()] ) {
        
        contractOwnerIdRecordIdMap.put(contr.Id, contr.OwnerId );    
    }
    system.debug('::contractOwnerIdRecordIdMap::'+contractOwnerIdRecordIdMap);
    for( Id ids : contractOwnerIdRecordIdMap.keySet()) {
        
        for( Attachment att : contractAttachments.get(ids)) {
            
            Task t = new Task();
            t.OwnerId =  contractOwnerIdRecordIdMap.get(ids);
            t.WhatId = ids;
            t.subject = 'Attachment is created';
            
            toBeinsertedTask.add(t);
        }    
    }
    system.debug('::toBeinsertedTask::'+toBeinsertedTask);
    if(toBeinsertedTask.size()>0 ) {
        
        insert toBeinsertedTask;
    }
}