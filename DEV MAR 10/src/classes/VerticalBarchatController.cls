public with sharing class VerticalBarchatController{
    
    Public String fieldName;
    Public String DispfieldName{get;set;}
    Public Montly_Sale_New__c monthSaleNew{get;set;}

    public VerticalBarchatController() {
        
        monthSaleNew = [ SELECT Calendar_Month__c,AmexAmtProcessed__c,AnnualBankcardSale__c,AverageTicket__c, AnnualRevenue__c, DebitAmtProcessed__c FROM Montly_Sale_New__c LIMIT 1];
        fieldName = Apexpages.Currentpage().getparameters().get('fldName');
        system.debug('::::::'+fieldName );
        if( fieldName == 'AmexAmtProcessed__c' ) {
            
            DispfieldName = 'Amex Amount Processed';
        } else if( fieldName == 'AnnualBankcardSale__c')  {
            
            DispfieldName = 'Annual Bankcard Sale' ;

        }else if( fieldName == 'AnnualRevenue__c')  {
            
            DispfieldName = 'Annual Revenue' ;

        }else if( fieldName == 'AverageTicket__c')  {
            
            DispfieldName = 'Average Ticket' ;

        }else if( fieldName == 'DebitAmtProcessed__c')  {
            
            DispfieldName = 'Debit Amount Processed' ;

        }
    }
    public class Month {
        public Integer year {get; set;}
        public Integer month {get; set;}
        public Decimal amount{get; set;}
        public String yearMonth {get; set; }
        Map<Integer, String> monthCodeAndValue = new Map<Integer, String>{ 1=>'Jan', 2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct', 11=>'Nov',12=>'Dec'};
        
        Month(Integer month, Integer year, Decimal amount) {
            this.year = year;
            this.month = month;
            this.amount= amount;
            this.yearMonth = monthCodeAndValue.get(month) +'-'+String.valueOf( year ).subString(2,4);
        }
    }

    public Month[] getMonths() {
        
        Date currDate =  System.Today();
        Month[] months = new Month[] {};
        List<Montly_Sale_New__c> monthlySaleList = [ SELECT Calendar_Month__c,AmexAmtProcessed__c,AnnualBankcardSale__c,AverageTicket__c, AnnualRevenue__c, DebitAmtProcessed__c FROM Montly_Sale_New__c ORDER BY Calendar_Month__c ASC ];
        Integer i = monthlySaleList.size() > 0 ? monthlySaleList.size() : 0;
        for ( Montly_Sale_New__c monthSale : monthlySaleList ) {                                        
                                            
            system.debug(':::monthSale:::'+monthSale);
            Double value = 0;
            if( fieldName == 'AmexAmtProcessed__c' ) {
                
                months.add(new Month( currDate.addMonths(-i).Month(), currDate.addMonths(-i).Year(),  monthSale.AmexAmtProcessed__c != NULL ? monthSale.AmexAmtProcessed__c: 0 ));
                value = monthSale.AmexAmtProcessed__c;
            } else if( fieldName == 'AnnualBankcardSale__c' ) {
                    
                months.add(new Month( currDate.addMonths(-i).Month(), currDate.addMonths(-i).Year(),  monthSale.AnnualBankcardSale__c != NULL ? monthSale.AnnualBankcardSale__c : 0 ));
            } else if( fieldName == 'AverageTicket__c' ) {
                
               months.add(new Month( currDate.addMonths(-i).Month(), currDate.addMonths(-i).Year(),  monthSale.AverageTicket__c != NULL ? monthSale.AverageTicket__c : 0 ));
            }else if( fieldName == 'AnnualRevenue__c' ) {
                
                months.add(new Month( currDate.addMonths(-i).Month(), currDate.addMonths(-i).Year(),  monthSale.AnnualRevenue__c != NULL ? monthSale.AnnualRevenue__c : 0 ));  
            } else if( fieldName == 'DebitAmtProcessed__c' )  {
                
                months.add(new Month( currDate.addMonths(-i).Month(), currDate.addMonths(-i).Year(),  monthSale.DebitAmtProcessed__c != NULL ? monthSale.DebitAmtProcessed__c : 0 ));
            }
            
            system.debug(':::months:::'+months);

            i--;
        }
        return months;
        
    }
  
}