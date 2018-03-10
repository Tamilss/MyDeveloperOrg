trigger createContactOnEmailToCase on Case ( after Insert ) {
    
    for( Case cse : Trigger.New ) {
        
        system.debug('::::cse ::'+cse );  
        List<Attachment> att = [ SELECT ID, Name FROM Attachment WHERE parentId =: cse.Id ];
        System.debug('::::att ::'+att);  
    }

}