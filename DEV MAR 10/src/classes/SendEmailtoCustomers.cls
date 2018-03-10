Public Class SendEmailtoCustomers {
    
    Public List<selectOption> productList {get;set;}
    Public List<selectOption> customerType{get;set;}
    Public List<selectOption> recordType{get;set;}
    Public List<selectOption> noofRecordsToDisplay{get;set;}
    Public List<customers> customersList{get;set;}
    public List<SelectOption> showRangeList{get;set;}
    public List<SelectOption> salesRepList{get;set;}
    public List<SelectOption> EmailTemplateList{get;set;}
    public List<Task> openTaskList{get;set;}
    
    Public String selProdName{get;set;}
    Public String selEmailTepValue{get;set;}
    Public String selCustType{get;set;}
    Public String selShowRangeVal{get;set;}
    Public String selNoOfRecords{get;set;}
    Public String selSalesRep{get;set;}
    
    Public Boolean showResult{get;set;}
    
    public String custFirstName{get;set;}
    public String custLastName{get;set;}
    public String custPhoneNumber{get;set;}
    public String custEmailAdd{get;set;}
    public String custStreetAdd{get;set;}
    public String custCity{get;set;}
    public String custState{get;set;}
    public String custZipCode{get;set;}
    public String errMsg{get;set;}
    public String urlString{get;set;}
    
    public Boolean ShowAtyStatus{get;set;}
    
    public List<Opportunity> oppList{get;set;}
    Boolean IsManager = False;
    String contactId;
    public class customers{
        
        Public boolean isSelected{get;set;}
        Public string customerName{get;set;}
        Public string customerID{get;set;}
        Public string customerPhone{get;set;}
        Public string customerEmail{get;set;}
        Public string customerType{get;set;}
        public String createdbyName{get;set;}
        Public Datetime cusCreatedDate{get;set;}
    }
    Public SendEmailtoCustomers() {
        
        ShowAtyStatus = false;
        openTaskList = new List<Task>();
        String strurl = ApexPages.currentPage().getUrl();
        contactId = ApexPages.currentPage().getParameters().get('id');
        String pageName = strurl.split('apex/')[1];
        system.debug(':::pageName ::'+pageName );
        
        User user = [ Select id,Name, Manager__c From User Where Id =: UserInfo.GetUserId() ];
        if( user.Manager__c == True ) {
            
            isManager = True; 
        }
        if( pageName == 'DisplayOrders' ) {
            
             if( !isManager ) {
                 oppList = [ Select Id,Name, CreatedBy.Name, Delivery_Date__c, Amount,CreatedDate,TotalOpportunityQuantity FROM Opportunity WHERE CreatedById =: UserInfo.getUserId() ORDER BY CreatedDate DESC ];
             } else {
                 
                  oppList = [ Select Id,Name, CreatedBy.Name, Delivery_Date__c, Amount,CreatedDate,TotalOpportunityQuantity FROM Opportunity  ORDER BY CreatedDate DESC ];
             }
             system.debug(':::oppList::'+oppList);
        } 
        if( pageName == 'DisplayOpenActivity' ) {
            
            List<Task> tempTaskList;
            if( !isManager ) {
            
                 tempTaskList= [ Select Id, Subject, Type, WhatID,What.Name, WhoId, Who.Name, OwnerID, Owner.Name, ActivityDate, CreatedDate FROM Task WHERE CreatedById =: UserInfo.getUserId() AND Status != 'Completed' AND Subject != NULL AND ActivityDate != NULL ORDER BY CreatedDate DESC ];
             } else {
                 
                  tempTaskList= [ Select Id,Subject, Type, WhatID,What.Name, WhoId, Who.Name, OwnerID, Owner.Name, ActivityDate, CreatedDate  FROM Task where Status != 'Completed' AND Subject != NULL AND ActivityDate != NULL ORDER BY CreatedDate DESC ];
             }
             for( Task tsk : tempTaskList ) {
                 
                 if( tsk.WhoID != NULL && ( String.valueOf( tsk.WhoID ).subString(0,3) == '003' || String.valueOf( tsk.WhoId ).subString(0,3) == '00Q') ) {
                     
                     openTaskList.add( tsk  );
                 }
                 
                 
             }
        } else {
            
        
        showResult = false;
        salesRepList = new List<selectOption>();
        customersList = new List<customers>();
        customerType = new List<selectOption>();
        productList = new List<selectOption>(); 
        recordType = new List<selectOption>(); 
        showRangeList = new List<selectOption>();
        EmailTemplateList = new List<selectOption>();
        
        For ( EmailTemplate emailTep : [ SELECT Id, DeveloperName, Name,isActive, TemplateType FROM EmailTemplate WHERE DeveloperName != NULL  AND TemplateType='Custom'  ] ) {
            
            EmailTemplateList.add( new selectOption( emailTep.ID, emailTep.Name));   
        }
        List<User> usrList = new List<User>();
        if( isManager ) {
            
            salesRepList.add( new selectOption( 'ALL', 'ALL'));
            usrList = [ SELECT Id, Name FROM User WHERE IsActive = TRUE AND UserType='Standard'] ;
        } else {
            
            usrList = [ SELECT Id, Name FROM User WHERE IsActive = TRUE AND UserType='Standard'AND Id =: UserInfo.getUserId() ] ;
        }
        
        For( User usr : usrList ) {
            
           
            salesRepList.add( new selectOption( usr.Id, usr.Name ));
        }
        For( Product2 prodRec : [ SELECT Id, Name FROM Product2 WHERE IsActive = TRUE AND Demo_Vedio_Link__c != NULL ] ) {
            
            productList.add( new selectOption( prodRec.Id, prodRec.Name ));
        }
        
        showRangeList.add( new selectOption('All', 'All') );
        showRangeList.add( new selectOption('Today', 'Today') );
        showRangeList.add( new selectOption('Yesterday', 'Yesterday') );
        showRangeList.add( new selectOption('This Week', 'This Week') );
        showRangeList.add( new selectOption('This Month', 'This Month') );
        showRangeList.add( new selectOption('This Year', 'This Year') );
        showRangeList.add( new selectOption('Last Year', 'Last Year') );
        
        noofRecordsToDisplay = new List<selectOption>();
        noofRecordsToDisplay.add( new selectOption('10', '10') ); 
        noofRecordsToDisplay.add( new selectOption('50', '50') );
        noofRecordsToDisplay.add( new selectOption('100', '100') );
        noofRecordsToDisplay.add( new selectOption('500', '500') );
        
        recordType.add( new selectOption('All Contacts', 'All Contacts'));
        recordType.add( new selectOption('My Contacts', 'My Contacts'));
        recordType.add( new selectOption('All Leads', 'All Leads'));
        recordType.add( new selectOption('My Leads', 'My Leads'));
        productList.add( new selectOption('LG 32 LF5900', 'LG 32 LF5900'));       
        productList.add(new selectOption('LG 42 LF5900', 'LG 42 LF5900'));    
        customerType.add(new selectOption('Leads', 'Leads'));
        customerType.add(new selectOption('Contacts', 'Contacts'));
        }
    }
    public Void searchCustomers() {
        
        customersList.clear();
        
        showResult = true;
        system.debug(':::::::::::::::::::::::::'+selCustType );
        boolean isFilter = false;
        system.debug('::::::::::::selShowRangeVal :::::::::::::'+selShowRangeVal );
        String qryStr = 'SELECT id, LastName, FirstName, Phone, Email, CreatedDate, createdById, CreatedBy.Name FROM';
        if( selCustType == 'Contacts') {
            
            qryStr += ' Contact';    
        } else {
            
            qryStr += ' Lead';
        }
        if( selShowRangeVal == 'Today' ) {
            
            qryStr += ' WHERE createdDate = TODAY';
            isFilter = TRUE;
            
        } else if( selShowRangeVal == 'Yesterday' ) {
        
            qryStr += ' WHERE createdDate = YESTERDAY';
            isFilter = TRUE;
            
        } else if( selShowRangeVal == 'This Week' ) {
            
            qryStr += ' WHERE createdDate = THIS_WEEK';
            isFilter = TRUE;
            
        } else if( selShowRangeVal == 'Last Week' ) {
        
            qryStr += ' WHERE createdDate = LAST_WEEK';
            
        } else if( selShowRangeVal == 'This Month' ) {
            
            qryStr += ' WHERE createdDate = THIS_MONTH';
            isFilter = TRUE;
            
        } else if( selShowRangeVal == 'Last Month' ) {
            
            qryStr += ' WHERE createdDate = LAST_MONTH';
            isFilter = TRUE;
        
        } else if( selShowRangeVal == 'This Year' ) {
            
            qryStr += ' WHERE createdDate = THIS_YEAR';
            isFilter = TRUE;
            
        } else if( selShowRangeVal == 'Last Year' ) {
            
            qryStr += ' WHERE createdDate = LAST_YEAR';
            isFilter = TRUE;
        }
        
        if( selSalesRep != NULL && selSalesRep != 'ALL' ) {
        
            if(  isFilter == TRUE  ) {
                
                qryStr += ' AND CreatedById =\''+selSalesrep+'\'';
            } else {
                
                qryStr += ' WHERE CreatedById =\''+selSalesrep+'\'';
                isFilter = TRUE;
            }
        }
        if( isFilter == TRUE  ) {
            
            qryStr += ' AND Email != NULL';
        } else {
            
            qryStr += ' WHERE Email != NULL';
        }
        if( selNoOfRecords != NULL ) {
            
             qryStr += ' ORDER BY CreatedDate DESC'+ ' LIMIT '+selNoOfRecords;
        }
         System.debug(':::::'+qryStr);
        
       
        if( selCustType == 'Contacts') {
        
            List<Contact> contactList = Database.query(qryStr);
            For( Contact conRec : contactList ) { 
                                   
                 Customers cust = new Customers();
                 cust.isSelected = false;
                 cust.customerID = conRec.Id;
                 if( conRec.FirstName != NULL && conRec.FirstName != NULL ) {
                 
                     cust.customerName = conRec.FirstName+conRec.Lastname;
                 } else {
                     
                     cust.customerName = conRec.Lastname;
                 }
                 cust.customerPhone = conRec.Phone;
                 cust.customerEmail = conRec.Email;
                 cust.createdbyName = conRec.CreatedBy.Name;
                 cust.customerType = 'Contact';
                 cust.cusCreatedDate =  conRec.createdDate ;
                 customersList.add( cust );
                  
                                   
                                   
            }
        }
        else {
        List<Lead> leadList = Database.query(qryStr);
        
            For( Lead leadRec : leadList ) {
            
                Customers cust = new Customers();
                 cust.isSelected = false;
                 cust.customerID = leadRec.Id;
                 if( leadRec.FirstName != NULL && leadRec.FirstName != NULL ) {
                                 
                     cust.customerName = leadRec.FirstName+leadRec.Lastname;
                 } else {
                     
                     cust.customerName = leadRec.Lastname;
                 }                 
                 cust.customerPhone = leadRec.Phone;
                 cust.customerEmail = leadRec.Email;
                 cust.createdbyName = leadRec.CreatedBy.Name;
                 cust.customerType = 'Lead';
                 cust.cusCreatedDate =  leadRec.createdDate ;
                 customersList.add( cust );
                                   
            }
        }
    }
    public void sendEmailtoCustomers() {
        

        list<Messaging.MassEmailMessage> mailList = new List<Messaging.MassEmailMessage>();
        for( Customers cus : customersList ) {
            
            if( cus.customerEmail != NULL ) {
                Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
                
                if( cus.isSelected == True ) {
                
                    mail.setBccSender(true);
                    mail.setUseSignature(false);
                    mail.setSaveAsActivity(false);
                    List<String> s = new List<String> {cus.customerID}; 
                    mail.setTargetObjectIds(s);
        
                    mail.setTemplateId(selEmailTepValue);
                    mailList.add(mail);
                    
                }
            }
            system.debug(':::mailList::'+mailList);
            Messaging.sendEmail(mailList);
       }
    }
    public void createNewCustomer() {
    
       
        urlString ='/apex/SendEmailtoCustomers';
        Lead newLead = new Lead();
        newLead.FirstName = custFirstName;
        newLead.LastName = custLastName; 
        newLead.Phone = custPhoneNumber; 
        newLead.Email = custEmailAdd; 
        newLead.Street = custStreetAdd; 
        newLead.City = custCity; 
        newLead.State = custState; 
        newLead.Company = 'Salesforce'; 
        newLead.PostalCode = custZipCode; 
        
        insert newLead;
    }
    public PageReference createActivity() {
        
        Task tsk = new Task();
        tsk.Subject = 'Call';
        tsk.ActivityDate= System.Today()+2;
        tsk.WhoId = contactId;
        tsk.Status = 'Not Started';
        tsk.Priority= 'Medium';
        tsk.Type ='Call';
        ShowAtyStatus = true;
        insert tsk;
        system.debug('::::tsk::'+tsk);
        return null;
    }
}