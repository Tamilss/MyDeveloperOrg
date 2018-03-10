trigger createOpportunityCampaignMembersAccount on Opportunity (Before insert,  after insert ) {
    
    
    Map<Id,List<Opportunity>> campaignIdListOfOppMap = new Map<Id,List<Opportunity>>();
    Map<Id,List<CampaignMember>> campIdListCampMemMap = new Map<Id,List<CampaignMember>>();
    Map<Id,Set<Id>> insertedCampIdListAccIds = new Map<Id,Set<Id>>();
    Map<Id,String> accIdAndAccNameMap = new Map<Id,String>();
    Map<Id, Map<Id,Integer>> campIdandAccIdNotCreateOppCountMap = new Map<Id, Map<Id,Integer>>();
    Map<Id, Map<Id,Set<Id>>> campIdandAccIdandAssigedOppIdMap = new Map<Id, Map<Id,Set<Id>>>();
    Map<Id,String> accIdAndAccDesMap = new Map<Id,String>(); 
    
    Map<Id,String> campMemIdAndContNameMap = new Map<Id,String>();
    Map<Id,Integer> campIdandCreatedOppSizeMap = new Map<Id,Integer>();
    Map<Id,Map<Id,Integer>> campIdandAccIdandOppCountMap = new Map<Id,Map<Id,Integer>>();
    Map<Id,Integer> campIdandBatchSize = new Map<Id,Integer>();
    List<CampaignMember> toBeUpdatedCampMemberList = new List<CampaignMember>();
    List<Sobject> sobjectOppList = new List<Sobject>();
    Set<Id> insertedOppAccIdSet = new Set<Id>();
    String objtype = 'Opportunity';
    SObjectType objectType  = Schema.getGlobalDescribe().get( objtype );
    
    List<Opportunity> noCampaignOppList = new List<Opportunity>();
    
    Map<Id,List<Opportunity>> campIdOfWithOutCampMember = new Map<Id,List<Opportunity>>();
    Map<Integer,String> getMonthStringMap = new Map<Integer,String>{
    
        1 =>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',
        9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'
    };
    
    Map<Id,List<Sobject>> accIdOppMap = new Map<Id,List<Sobject>>();
    //Map<Id,List<Opportunity>> accIdOppMap = new Map<Id,List<Opportunity>>();
    Map<Id,List<Id>> accIdConIdMap = new Map<Id,List<Id>>();
    List<OpportunityContactRole> oppConRoleList = new List<OpportunityContactRole>();
    
    List<Campaign> campList = new List<Campaign>();
    Map<Id,Id> campOwnerMap = new Map<Id,Id>();
    if(Trigger.isBefore && Trigger.isInsert){
        for(Opportunity opp : Trigger.new ) {
            
            if(opp.Generate_Opportunity__c == true && opp.CampaignId != NULL ) {
                if(campaignIdListOfOppMap.containsKey(opp.CampaignId) ) {
                    
                    campaignIdListOfOppMap.put(opp.CampaignId,campaignIdListOfOppMap.get(opp.CampaignId)).add(opp);
                    
                } else {
                    campaignIdListOfOppMap.put(opp.CampaignId,new List<Opportunity>{opp});   
                }
            }
        }
        campList = [SELECT 
                        Id,OwnerId,
                        BLSTX_Opportunity_Batch_owner__c
                    FROM Campaign
                    WHERE Id IN:campaignIdListOfOppMap.KeySet()
                    ];
        for(Campaign cam : campList){
            if(cam.BLSTX_Opportunity_Batch_owner__c != NULL)
                campOwnerMap.put(cam.Id,cam.BLSTX_Opportunity_Batch_owner__c);
            else
                campOwnerMap.put(cam.Id,userinfo.getuserid());
        }
        system.debug(':::campOwnerMap:::'+campOwnerMap);
        for(Id camId : campOwnerMap.keySet()){
            List<Opportunity> tOppList = campaignIdListOfOppMap.get(camId);
            for(Opportunity op : tOppList){
                op.OwnerId = campOwnerMap.get(camId);
                system.debug(':::op:::'+op );
            }
        }
        
    }
        
    if(Trigger.isAfter && Trigger.isInsert){
    
        for(Opportunity opp : Trigger.new ) {
            
            if(opp.Generate_Opportunity__c == true && opp.CampaignId != NULL ) {
            
                if(campaignIdListOfOppMap.containsKey(opp.CampaignId) ) {
                    
                    campaignIdListOfOppMap.put(opp.CampaignId,campaignIdListOfOppMap.get(opp.CampaignId)).add(opp);
                    
                } else {
                    campaignIdListOfOppMap.put(opp.CampaignId,new List<Opportunity>{opp});   
                } 
                if( opp.AccountId != NULL) {
                
                    if( campIdandAccIdandOppCountMap.containsKey( opp.CampaignId ) ) {
                        
                        if( campIdandAccIdandOppCountMap.get( opp.CampaignId ).containsKey( opp.AccountId ) ) {
                            
                            Integer count  =  campIdandAccIdandOppCountMap.get( opp.CampaignId ).get( opp.AccountId );
                            campIdandAccIdandOppCountMap.get( opp.CampaignId ).put( opp.AccountId, count+1 );
                        } else {
                            campIdandAccIdandOppCountMap.get( opp.CampaignId ).put( opp.AccountId, 1 );
                        }
                    } else {
                        campIdandAccIdandOppCountMap.put( opp.CampaignId, new Map<Id, Integer>{ opp.AccountId => 1 } );   
                    }
                    insertedOppAccIdSet.add(opp.AccountId);
                }    
            } else if(opp.Generate_Opportunity__c == true && (opp.CampaignId == NULL || opp.CampaignId =='')) {
                
                noCampaignOppList.add(opp);    
            }     
        }
        List<RecordType> oppRecTypeList = [ SELECT Id, DeveloperName, SobjectType, isActive FROM RecordType WHERE ( isActive = TRUE AND SobjectType = 'Opportunity' ) ];
        system.debug( ':::campIdandAccIdandOppCountMap::'+campIdandAccIdandOppCountMap);
        system.debug( ':::campIdandAccIdandOppCountMap.size()::'+campIdandAccIdandOppCountMap.size());
        system.debug( ':::campaignIdListOfOppMap::'+campaignIdListOfOppMap);
        system.debug( ':::campaignIdListOfOppMap.size()::'+campaignIdListOfOppMap.size());
        system.debug( ':::noCampaignOppList::'+noCampaignOppList);
        for(Campaign cam : [ SELECT Id,BLSTX_Opportunity_Batch_owner__c, Opportunity_Batch_Size__c FROM Campaign WHERE Id IN : campaignIdListOfOppMap.KeySet() ]){
        
            campOwnerMap.put( cam.Id,cam.BLSTX_Opportunity_Batch_owner__c );
            
            if( cam.Opportunity_Batch_Size__c != NULL ) {
            
                campIdandBatchSize.put( cam.Id, Integer.valueOf( cam.Opportunity_Batch_Size__c ) );
            }
        }
        system.debug( ':::campIdandBatchSize.size()::'+campIdandBatchSize.size());
        system.debug( ':::campIdandBatchSize::'+campIdandBatchSize);
        for(CampaignMember campMem :[
                                    SELECT 
                                        Id,ContactId, Contact.AccountId,Contact.Account.Name,Contact.Account.Description,Contact.Name,CampaignId, Is_Opportunity_Created__c
                                    FROM 
                                        CampaignMember 
                                    WHERE ( ( CampaignId IN:campaignIdListOfOppMap.KeySet() ) AND ( ContactId != NULL AND Contact.AccountId != NULL AND Is_Opportunity_Created__c = FALSE )) ORDER BY  CreatedDate DESC ] ) {
                                                   
                                    
             if( campIdListCampMemMap.containsKey(campMem.CampaignId ) ) {
                 
                 List<CampaignMember> tempCampMemList = campIdListCampMemMap.get(campMem.CampaignId);
                 tempCampMemList.add(campMem);
                 campIdListCampMemMap.put( campMem.CampaignId,tempCampMemList );
                  
             } else {
                 
                campIdListCampMemMap.put(campMem.CampaignId,new List<CampaignMember>{campMem});
             }                             
             accIdAndAccNameMap.put(campMem.Contact.AccountId,campMem.Contact.Account.Name);
             accIdAndAccDesMap.put(campMem.Contact.AccountId,campMem.Contact.Account.Description);
             campMemIdAndContNameMap.put(campMem.Id , campMem.Contact.Name);
            
        }
        system.debug( ':::campOwnerMap::'+campOwnerMap);
        system.debug( ':::campIdListCampMemMap::'+campIdListCampMemMap);
        system.debug( ':::campIdListCampMemMap.size()::'+campIdListCampMemMap.size());
        for(Id campIds : campaignIdListOfOppMap.keySet()) {
            
            if(!campIdListCampMemMap.containsKey(campIds)) {
                
             List<Opportunity> tempOpp = campaignIdListOfOppMap.get(campIds);
             campIdOfWithOutCampMember.put(campIds,tempOpp );   
            }
        }
        for(Id campIds : campIdListCampMemMap.keySet()) {
            
            system.debug( ':::campIds::'+campIds);
            Integer count = 0;
            List<Opportunity> oppList = new List<Opportunity>();
            String month = getMonthStringMap.get(System.Today().Month());
            String year = (String.valueOf(System.Today().Year())).subString(2,4);
            String createdDate = month+' '+year;
            
            if( campaignIdListOfOppMap.containsKey( campIds ) ) {
                
                
                oppList = campaignIdListOfOppMap.get( campIds ) ;
                for( CampaignMember camp : campIdListCampMemMap.get( campIds ) ) {
                    
                    system.debug( ':::camp Mem Id::'+camp);
                    Boolean createOppRec = FALSE;
                    Boolean ProceedCamMem = TRUE;
                    system.debug('::campIds :::'+campIds );
                    system.debug( ':::campIdandBatchSize ::'+campIdandBatchSize );
                    if( campIdandBatchSize.containsKey( campIds ) ) {
                    
                        if( campIdandCreatedOppSizeMap.containsKey( campIds ) ) {
                            
                            if( campIdandBatchSize.get( campIds )  > campIdandCreatedOppSizeMap.get( campIds ) ) {
                            
                                createOppRec = TRUE;
                                Integer tempVal = campIdandCreatedOppSizeMap.get( campIds );
                                campIdandCreatedOppSizeMap.put( campIds, tempVal+1 );
                                system.debug('campIdandCreatedOppSizeMap::::'+campIdandCreatedOppSizeMap);
                            }
                        } else {
                        
                            createOppRec = TRUE;
                            campIdandCreatedOppSizeMap.put( campIds, 1 );
                        }
                    } else {
                        
                        createOppRec = TRUE;
                    }
                    system.debug(':::createOppRec::'+createOppRec);
                    if( createOppRec ) {
                    
                        system.debug(':::Trigger.new.Size()::'+Trigger.new.Size());
                        system.debug(':::count::'+count);
                        system.debug(':::camp.contact.AccountId::'+camp.contact.AccountId);
                        if( count < Trigger.new.Size() ) {
                        
                            if( campIdandAccIdandOppCountMap.containsKey( campIds ) && campIdandAccIdandOppCountMap.get( campIds ).containsKey( camp.contact.AccountId ) ) {
                                
                                if( campIdandAccIdNotCreateOppCountMap.containsKey( campIds ) && campIdandAccIdNotCreateOppCountMap.get( campIds ).containsKey( camp.contact.AccountId ) ) {
                                    
                                    Integer actualOpp = campIdandAccIdandOppCountMap.get( campIds ).get( camp.contact.AccountId );
                                    Integer notProcessCampMam = campIdandAccIdNotCreateOppCountMap.get( campIds ).get( camp.contact.AccountId ) ;
                                    
                                    if( actualOpp > notProcessCampMam ) {
                                    
                                        ProceedCamMem = FALSE;
                                        Integer tempVal =  campIdandAccIdNotCreateOppCountMap.get( campIds ).get( camp.contact.AccountId );
                                        campIdandAccIdNotCreateOppCountMap.get( campIds ).put( camp.contact.AccountId, tempVal+1 );
                                    }
                                } else {
                                    
                                    if( campIdandAccIdNotCreateOppCountMap.containsKey( campIds ) ) {
                                    
                                        campIdandAccIdNotCreateOppCountMap.get( campIds ).put( camp.contact.AccountId, 1 ); 
                                    } else {
                                        campIdandAccIdNotCreateOppCountMap.put( campIds , new Map<Id, Integer> { camp.contact.AccountId => 1 } ); 
                                    }
                                    ProceedCamMem = FALSE;
                                }
                            }
                        }
                        system.debug('::    :'+ProceedCamMem);
                        if( !ProceedCamMem ) {
                            
                            system.debug(':::entered::');
                            for( Opportunity opp : campaignIdListOfOppMap.get( campIds ) ) {
                                
                                Boolean processOpp = FALSE;
                                if( opp.AccountId != NULL && opp.AccountId == camp.Contact.AccountId ) {
                                
                                    if( campIdandAccIdandAssigedOppIdMap.containsKey( campIds )  ) {
                                        
                                        if( campIdandAccIdandAssigedOppIdMap.get( campIds ).containsKey( camp.Contact.AccountId )  ) {
                                            
                                            if( !campIdandAccIdandAssigedOppIdMap.get( campIds ).get( camp.Contact.AccountId ).contains( opp.Id ) ) {
                                                
                                                Map<Id,Set<Id>> tempMap = campIdandAccIdandAssigedOppIdMap.get( campIds ) ;
                                                tempMap.get( camp.Contact.AccountId ).add( opp.Id );
                                                processOpp = TRUE;
                                            }
                                        } else {
                                            
                                            Map<Id,Set<Id>> tempMap = campIdandAccIdandAssigedOppIdMap.get( campIds ) ;
                                            tempMap.put( camp.Contact.AccountId , new Set<Id>{ opp.Id } );
                                            campIdandAccIdandAssigedOppIdMap.put( campIds, tempMap ) ;
                                            processOpp = TRUE;
                                        }
                                    } else {
                                        processOpp = TRUE;
                                        campIdandAccIdandAssigedOppIdMap.put( campIds,new Map<Id,Set<Id>> { camp.Contact.AccountId => new Set<Id>{ opp.Id }} ) ;
                                    }
                                }
                                system.debug(':::campIdandAccIdandAssigedOppIdMap::'+campIdandAccIdandAssigedOppIdMap);
                                if( processOpp ) {
                                
                                    if(accIdOppMap.containsKey( camp.Contact.AccountId )) {
                                    
                                        accIdOppMap.put(camp.Contact.AccountId, accIdOppMap.get( camp.Contact.AccountId )).add(opp);
                                        accIdConIdMap.put(camp.Contact.AccountId, accIdConIdMap.get(camp.Contact.AccountId)).add(camp.ContactId);
                                        
                                    }else{
                                    
                                        accIdOppMap.put(camp.Contact.AccountId, new List<Opportunity>{opp});
                                        accIdConIdMap.put(camp.Contact.AccountId, new List<Id>{camp.ContactId});
                                    }
                                    system.debug('::accIdOppMap:::-->'+accIdOppMap);
                                    system.debug(':::accIdConIdMap:::-->'+accIdConIdMap);
                                    count++;
                                    break;
                                }
                            }
                            
                        
                        } else if( ProceedCamMem ) {
                            
                            /*String AccDes = accIdAndAccDesMap.get(camp.contact.AccountId);
                            if(AccDes == Null){
                                AccDes = '';
                            }else if(AccDes.length() > 50){
                                AccDes = '- '+AccDes.substring(0,50);
                            }else if(AccDes.length() < 50){
                                AccDes = '- '+AccDes;
                            }*/
                            //opp.Name = createdDate+' - '+accIdAndAccNameMap.get(camp.contact.AccountId)+' '+AccDes;  ->old format
                            
                            system.debug(':::In else :::');
                            SObject obj = objectType.newSObject();
                            SObject obj1 = oppList[0];
                            Boolean gereateOpp = False;
                            
                            String oppName = createdDate+' - '+accIdAndAccNameMap.get(camp.contact.AccountId)+' - '+campMemIdAndContNameMap.get(camp.Id); 
                            obj.put('Name', oppName );
                            obj.put('AccountId', camp.Contact.AccountId );
                            obj.put('CampaignId', campIds );
                            obj.put('CloseDate', oppList[0].CloseDate );
                            if( oppRecTypeList != NULL && oppRecTypeList.size() > 0 ) {
                                
                                system.debug(':::::::'+obj1.get('RecordTypeId'));
                                if( obj1 != NULL && obj1.get('RecordTypeId') != NULL ) {
                                
                                    obj.put('RecordTypeId', obj1.get('RecordTypeId') );
                                }
                            }
                            
                            obj.put('Type', oppList[0].Type );
                            obj.put('StageName', oppList[0].StageName );
                            obj.put('Generate_Opportunity__c', gereateOpp );
                            obj.put('Amount', oppList[0].Amount );
                            obj.put('Description', oppList[0].Description );
                            
                            obj.put( 'ForecastCategoryName', oppList[0].ForecastCategoryName );
                            obj.put( 'LeadSource', oppList[0].LeadSource );
                            obj.put( 'NextStep', oppList[0].NextStep );
                            obj.put( 'IsPrivate', oppList[0].IsPrivate );
                            obj.put( 'Probability', oppList[0].Probability );
                            
                            obj.put( 'TotalOpportunityQuantity', oppList[0].TotalOpportunityQuantity );
                            
                            if(campOwnerMap.get(campIds) != NULL)
                                obj.put( 'OwnerId', campOwnerMap.get(campIds) );
                                
                            Opportunity opp = (Opportunity)Obj;
                            if( accIdOppMap.containsKey(camp.Contact.AccountId) ) {
                            
                                accIdOppMap.put(camp.Contact.AccountId, accIdOppMap.get(camp.Contact.AccountId)).add( opp );
                                accIdConIdMap.put(camp.Contact.AccountId, accIdConIdMap.get(camp.Contact.AccountId)).add(camp.ContactId);
                            }else{
                            
                                accIdOppMap.put(camp.Contact.AccountId, new List<Opportunity>{ opp });
                                accIdConIdMap.put(camp.Contact.AccountId, new List<Id>{camp.ContactId});
                            }
                            sobjectOppList.add( obj );
                        }
                        camp.Is_Opportunity_Created__c = TRUE;
                        toBeUpdatedCampMemberList.add( camp );
                        
                    } 
                } 
            }
            
        }
        system.debug(':::sobjectOppList:::'+sobjectOppList);
        system.debug(':::toBeUpdatedCampMemberList:::'+toBeUpdatedCampMemberList);
        if( toBeUpdatedCampMemberList != NULL && toBeUpdatedCampMemberList.size() > 0 ) {
            
            Update toBeUpdatedCampMemberList;
        }
        if( sobjectOppList != NULL && sobjectOppList.size()>0 ) {
            
           insert sobjectOppList;
        }
       
        System.debug(':::::::::::accIdOppMap::::::::::'+accIdOppMap );
        System.debug('::::::::::::accIdConIdMap:::::'+accIdConIdMap);
       
        for(Id accId : accIdOppMap.keySet()){
            
            System.debug(';;;;accId ::::'+accId  );
            
            List<Opportunity> tempOppList = accIdOppMap.get(accId);
            List<Id> tempConIdList  = accIdConIdMap.get(accId);
            System.debug(';;;;;;tempConIdList:::::'+tempConIdList );
            for(Integer i = 0 ; tempOppList.size() > i ;i++){
               
               
               if( tempOppList[i] != NULL ){
               
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.ContactId = tempConIdList[i];
                    ocr.IsPrimary = true;
                    ocr.OpportunityId = tempOppList[i].Id;
                    oppConRoleList.add(ocr);
                }
            }
        }
        if(oppConRoleList.size() > 0){
            insert oppConRoleList;
        }
        for(Id campIds : campIdOfWithOutCampMember.keySet() ) {
            
            for(Opportunity opp :campIdOfWithOutCampMember.get(campIds)) {
                
                system.debug(':::without Campaign members::====>'+opp.Name);
                opp.addError('No Campaign Member contact is available');
            }      
        }
        for(Opportunity opp : noCampaignOppList ) {
            
            opp.addError('Generate Opportunity field is only applicable for Campaign Opportunites ');    
        }
    }
}