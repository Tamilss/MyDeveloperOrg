Global Class SendEmailtoCustomers1 {
    
    Public List<selectOption> productList {get;set;}
    Public List<selectOption> customerType{get;set;}
    Public List<selectOption> recordType{get;set;}
    Public List<selectOption> noofRecordsToDisplay{get;set;}
    public List<customers> customersList{get;set;}
    public List<SelectOption> showRangeList{get;set;}
    public List<SelectOption> salesRepList{get;set;}
    public List<SelectOption> EmailTemplateList{get;set;}
    
    Public String selProdName{get;set;}
    Public String selEmailTepValue{get;set;}
    Public String selCustType{get;set;}
    Public String selShowRangeVal{get;set;}
    Public String selNoOfRecords{get;set;}
    Public String selSalesRep{get;set;}
    
    Public Boolean showResult{get;set;}
    
    public class customers{
        
        Public boolean isSelected{get;set;}
        Public string customerName{get;set;}
        Public string customerPhone{get;set;}
        Public string customerEmail{get;set;}
        Public string customerType{get;set;}
        Public string cusCreatedDate{get;set;}
    }
    Public SendEmailtoCustomers1() {
        
        showResult = false;
        salesRepList = new List<selectOption>();
        customersList = new List<customers>();
        customerType = new List<selectOption>();
        productList = new List<selectOption>(); 
        recordType = new List<selectOption>(); 
        showRangeList = new List<selectOption>();
        EmailTemplateList = new List<selectOption>();
        
        For ( EmailTemplate emailTep : [ SELECT Id, DeveloperName, Name, TemplateType FROM EmailTemplate WHERE DeveloperName != NULL AND CreatedById =: UserInfo.getUserId() AND TemplateType='HTML'  ] ) {
            
            EmailTemplateList.add( new selectOption( emailTep.Name, emailTep.Name ));   
        }
        
        For( User usr : [ SELECT Id, Name FROM User WHERE IsActive = TRUE AND UserType='Standard'] ) {
            
            salesRepList.add( new selectOption( usr.Id, usr.Name ));
        }
        For( Product2 prodRec : [ SELECT Id, Name FROM Product2 WHERE IsActive = TRUE ] ) {
            
            productList.add( new selectOption( prodRec.Id, prodRec.Name ));
        }
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
    public Void searchCustomers() {
        
        customersList.clear();
        
        showResult = true;
        system.debug(':::::::::::::::::::::::::'+selCustType );
        boolean isFilter = false;
        system.debug('::::::::::::selShowRangeVal :::::::::::::'+selShowRangeVal );
        String qryStr = 'SELECT id, LastName, FirstName, Phone, Email, CreatedDate, createdById FROM';
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
        if( selSalesRep != NULL && isFilter == TRUE ) {
            
            qryStr += ' AND CreatedById =\''+selSalesrep+'\'';
        } else {
            
            qryStr += ' WHERE CreatedById =\''+selSalesrep+'\'';
            isFilter = TRUE;
        }
        if( selNoOfRecords != NULL ) {
            
             qryStr += ' LIMIT '+selNoOfRecords;
        }
         System.debug(':::::'+qryStr);
        
       
        if( selCustType == 'Contacts') {
        
            List<Contact> contactList = Database.query(qryStr);
            For( Contact conRec : contactList ) { 
                                   
                 Customers cust = new Customers();
                 cust.isSelected = false;
                 cust.customerName = conRec.FirstName+conRec.Lastname;
                 cust.customerPhone = conRec.Phone;
                 cust.customerEmail = conRec.Email;
                 cust.customerType = 'Contact';
                 cust.cusCreatedDate = String.valueOf( conRec.createdDate );
                 customersList.add( cust );
                  
                                   
                                   
            }
        }
        else {
        List<Lead> leadList = Database.query(qryStr);
        
            For( Lead leadRec : leadList ) {
            
                Customers cust = new Customers();
                 cust.isSelected = false;
                 cust.customerName = leadRec.FirstName+leadRec.Lastname;
                 cust.customerPhone = leadRec.Phone;
                 cust.customerEmail = leadRec.Email;
                 cust.customerType = 'Lead';
                 cust.cusCreatedDate = String.valueOf( leadRec.createdDate );
                 customersList.add( cust );
                                   
            }
        }
    }
    
    @RemoteAction
    webservice static string search( string xx) {
        List<customers> customersList1 = new List<customers>();
        
        String qryStr = 'SELECT id, LastName, FirstName, Phone, Email, CreatedDate, createdById FROM Contact';
        
       
        
            List<Contact> contactList = Database.query(qryStr);
            For( Contact conRec : contactList ) { 
                                   
                 Customers cust = new Customers();
                 cust.isSelected = false;
                 cust.customerName = conRec.FirstName+conRec.Lastname;
                 cust.customerPhone = conRec.Phone;
                 cust.customerEmail = conRec.Email;
                 cust.customerType = 'Contact';
                 cust.cusCreatedDate = String.valueOf( conRec.createdDate );
                 customersList1.add( cust );
                  
                                   
                                   
            }
       
        
        if( customersList1.size() > 0 && customersList1 != NULL ) {
               
               String JSONString = JSON.serialize( customersList1 );
               system.debug('jkjf:::'+JSONString);
               return  JSONString;
        } else {
               
               return 'SearchCriteriaNotValid';
        }
        return null;
    }
  
}