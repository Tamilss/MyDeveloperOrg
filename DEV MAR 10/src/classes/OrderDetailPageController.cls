Public class OrderDetailPageController{
    
   /* public Orders__x ordRec;
    public Order_Details__x ordDetails {get;set;}
    public List<Order_Details__x> ordDetails12 {get;set;}
    public OrderDetailPageController( ApexPages.StandardController stdController ) {
        
      
        this.ordRec = ( Orders__x )stdController.getRecord();

        ordDetails12  = new List<Order_Details__x>();
        
        ordDetails12 = [ SELECT Id, Discount__c,ExternalId,Quantity__c, OrderID__c FROM  Order_Details__x WHERE OrderID__c =: ordRec.ExternalId LIMIT 2 ];  
        System.debug(':::ordDetails12 :::'+ordDetails12 );   
    }
    public void sample() {
        
        
    }
    */
}