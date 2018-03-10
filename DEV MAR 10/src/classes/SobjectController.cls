public class SobjectController {
    @AuraEnabled
    Public Static List<SObject> getSobjectRecords( String objName ) {
    	List<SObject> sobjRecords;
        if( objName == 'Accounts') {
        	sobjRecords = [ SELECT Id,Name, Website from Account where Website != NULL  Limit 10];
        } else {
       		sobjRecords = [ SELECT Id,Email,Name from Contact where Email != NULL  Limit 10];    
        }
        
        return sobjRecords;
            
    }

}