public class exportExcel {
   
    public string header{get;set;}
    public List<wrapper> lstwrapper {get; set;}
    public class wrapper{
        public string orderId{get; set;}
        public string ProductId{get; set;}
        public string quantity{get; set;}
        public string unitPrice{get; set;}
        public string dateval{get; set;}
 
 
             
    }
   
    public string Filetype{get;set;}
    public boolean isExcel {get;set;}
    public boolean isCsv {get;set;}   
   
 
 
 
 
  /*  public exportExcel(){
            Filetype = '';
            lstwrapper = new List<wrapper>();
            header = 'Ship To,Search Number,Account Name,Business Unit,Date,Expiration Date,Expiration End Date,Expiration Start Date,Group,Implant Date ,Invoice Date,Invoice Number\r\n';                     
    }
 
   
  /* public void exportToExcel(){
          string queryString = 'Select OrderID__c, ProductID__c, Quantity__c, UnitPrice__c FROM Order_Details__x LIMIT 10000'; 
         // List<Order_Details__x> orderDatails = DataBase.Query(queryString);
          //system.debug('orderDatails :'+orderDatails);
          //if( orderDatails.size()>0 ){
              for(Order_Details__x ordDet : DataBase.Query(queryString) ){
                  wrapper w = new wrapper();
                  w.orderId = String.valueOf( ordDet.OrderID__c );
                  w.ProductId = String.valueOf( ordDet.ProductID__c);
                  w.quantity = String.valueOf(ordDet.Quantity__c);
                  w.unitPrice = String.valueOf(ordDet.UnitPrice__c);
                  lstwrapper.add(w);               
              }             
         // }
          system.debug('lstwrapper :'+lstwrapper.size());
    }*/
 
   
 
}