trigger UpdateParentIdonAttacment on EmailMessage (After insert) {
    
    
    system.debug('::::::::::::::::'+Trigger.New);
    List<Attachment> att = [ SELECT ID, Name FROM Attachment WHERE parentId =: Trigger.New[0].Id];
    System.debug('::::att ::'+att);  
}