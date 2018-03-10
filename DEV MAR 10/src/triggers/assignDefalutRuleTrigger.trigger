trigger assignDefalutRuleTrigger on Lead ( before insert) {
    List<Lead> assignmentRuleLeadList = new List<Lead>();
    
        try {
            for( Lead l : Trigger.New) {
            
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.assignmentRuleId = l.Id;
                dmo.assignmentRuleHeader.useDefaultRule= true;                
                l.setOptions(dmo);
                System.Debug(':::lead list::'+l);
            }
              
        }
        catch (System.DmlException e ) {
            System.Debug('exception'+e);
        }
    
    
}