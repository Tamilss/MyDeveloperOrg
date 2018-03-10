Public Class OrderCreationController {
    
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
    public double noOfQuantity{get;set;}
    public double deliverydate{get;set;}
    
    Public Opportunity opp{get;set;}
    
    public OrderCreationController() {
        
        opp = new Opportunity();   
    }
    public void createNewOrder() {
        
        opp.Name = 'Order-'+System.Today().Day()+'-'+System.Today().Month()+'-'+System.Today().Year();
        opp.StageName = 'Negotiation/Review';
        if(  opp.Delivery_Date__c != NULL ) {
            opp.CloseDate = opp.Delivery_Date__c;
        } else {
            
             opp.CloseDate = System.Today()+10;
        }
        if( custFirstName != NULL && custLastName != NULL ) {
            opp.Customer_Name__c = custFirstName+custLastName;
        } else {
            opp.Customer_Name__c = custLastName;
        }
        Insert opp;
    }
}