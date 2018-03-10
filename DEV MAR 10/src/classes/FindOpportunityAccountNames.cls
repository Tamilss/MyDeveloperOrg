global class FindOpportunityAccountNames {
    
    webservice static string[] prepopulateAccAndOppNames(Id campaignId) {
        
        system.debug('::::campaignId::::'+campaignId);
        List<Account> insertedOppAccount = new List<Account>();
        Map<Integer,String> getMonthStringMap = new Map<Integer,String>{
        
            1 =>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',
            9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'
        };
        List<CampaignMember> recentContRecList = [
                                                SELECT 
                                                    Id,CampaignId,ContactId, Contact.AccountId,CreatedDate, Contact.Name 
                                                FROM 
                                                    CampaignMember
                                                WHERE 
                                                    ( ContactId != NULL AND Is_Opportunity_Created__c = FALSE AND CampaignId =:CampaignId AND Contact.AccountId != NULL )
                                                
                                                ORDER BY 
                                                    CreatedDate DESC
                                                 Limit 1
                                                
                                                    
                                             ];  
        if(recentContRecList.size()>0) {
            
            insertedOppAccount = [ SELECT Id,Name,Description FROM Account WHERE Id =:recentContRecList[0].Contact.AccountId];
        }
        String month = getMonthStringMap.get(System.Today().Month());
        String year = (String.valueOf(System.Today().Year())).subString(2,4);
        String createdDate = month+' '+year;
        String oppName;
        String contactName = recentContRecList[0].Contact.Name;
        //String accDes;
        if(insertedOppAccount.size() >0) {
        
            /*accDes = insertedOppAccount[0].Description;
            if(accDes == NULL){
                accDes = '';
            }else if(accDes.length() > 50){
                accDes = '- '+accDes.subString(0,50);
            }else if(accDes.length() < 50){
                accDes = '- '+accDes;
            }  */ 
            
            oppName = createdDate +' - '+insertedOppAccount[0].Name +' - '+contactName;
        }
        String[] returnValues = new String[]{insertedOppAccount[0].Name,insertedOppAccount[0].Id,oppName};
        return returnValues;    
    }
}