@isTest
private class TestCreateOpportunityForCampaignMembers {
   
    static testMethod void createOppCampaignMembers() {
        
        Account[] acc = new Account[] {
            
            new Account(Name = 'Test Account1'),
            new Account(Name = 'Test Account2'),
            new Account(Name = 'Test Account3')
            
        };
        insert acc;
        Contact[] con = new Contact[] {
            
            new Contact(LastName = 'Test contact1',AccountId = acc[0].Id),
            new Contact(LastName = 'Test contact2',AccountId = acc[1].Id),
            new Contact(LastName = 'Test contact3',AccountId = acc[2].Id),
            new Contact(LastName = 'Test contact4',AccountId = acc[0].Id),
            new Contact(LastName = 'Test contact5',AccountId = acc[1].Id),
            new Contact(LastName = 'Test contact6',AccountId = acc[2].Id),
            new Contact(LastName = 'Test contact7',AccountId = acc[0].Id),
            new Contact(LastName = 'Test contact8',AccountId = acc[1].Id)
        };
        insert con;
        
        Campaign[] campList = new Campaign[] {
            
            new Campaign( Name = 'Test Campaign1',IsActive = true , Opportunity_Batch_Size__c = 2 ),
            new Campaign( Name = 'Test Campaign1',IsActive = true , Opportunity_Batch_Size__c = 1 ),
            new Campaign( Name = 'Test Campaign1',IsActive = true , Opportunity_Batch_Size__c = 2  )    
        }; 
        insert campList;
        Campaign[] compQuery = [SELECT id, Name, IsActive FROM CAMPAIGN WHERE Name = 'Test Campaign1' AND IsActive = true];
        system.assertEquals(3, compQuery.size());
        CampaignMember[] campMenber = new CampaignMember[] {
            
            new CampaignMember(CampaignId = campList[0].Id,ContactId = con[0].Id),
            new CampaignMember(CampaignId = campList[0].Id,ContactId = con[1].Id),
            new CampaignMember(CampaignId = campList[0].Id,ContactId = con[2].Id),
            new CampaignMember(CampaignId = campList[1].Id,ContactId = con[3].Id),
            new CampaignMember(CampaignId = campList[1].Id,ContactId = con[4].Id),
            new CampaignMember(CampaignId = campList[1].Id,ContactId = con[5].Id),
            new CampaignMember(CampaignId = campList[2].Id,ContactId = con[6].Id),
            new CampaignMember(CampaignId = campList[2].Id,ContactId = con[7].Id)
            
            
        };
        insert campMenber ;
        FindOpportunityAccountNames.prepopulateAccAndOppNames(campList[0].Id);
        try {
            Opportunity[] oppList1 = new Opportunity[] {
                
                new Opportunity(Name = 'Test Opp1',CloseDate = System.Today(),StageName='Prospecting',CampaignId=campList[0].Id,Generate_Opportunity__c =true,AccountId=acc[0].Id),
                new Opportunity(Name = 'Test Opp2',CloseDate = System.Today(),StageName='Prospecting',CampaignId=campList[0].Id,Generate_Opportunity__c =true,AccountId=acc[0].Id),
                new Opportunity(Name = 'Test Opp3',CloseDate = System.Today(),StageName='Prospecting',CampaignId=campList[1].Id,Generate_Opportunity__c =true,AccountId=acc[1].Id),
                new Opportunity(Name = 'Test Opp4',CloseDate = System.Today(),StageName='Prospecting',CampaignId=campList[2].Id,Generate_Opportunity__c =true,AccountId=acc[2].Id)
                
                };
            insert oppList1;
            /*Opportunity[] oppList2 = new Opportunity[] {
                new Opportunity(Name = 'Test Opp3',CloseDate = System.Today(),StageName='Prospecting',CampaignId=NULL,Generate_Opportunity__c =true,AccountId=acc[0].Id),
                new Opportunity(Name = 'Test Opp4',CloseDate = System.Today(),StageName='Prospecting',CampaignId='',Generate_Opportunity__c =true,AccountId=acc[0].Id)
                
            };
            insert oppList2; 
            Opportunity[] oppList3 = new Opportunity[] {
                
                new Opportunity(Name = 'Test Opp1',CloseDate = System.Today(),StageName='Prospecting',CampaignId=campList[1].Id,Generate_Opportunity__c =true,AccountId=acc[0].Id)
            };
            insert oppList3;*/
            
        } catch(Exception ex) {
        }
            
    }
    
    
}