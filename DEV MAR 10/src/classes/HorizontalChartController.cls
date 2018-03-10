public with sharing class HorizontalChartController {
    
    Public String fieldName;
    Public String DispfieldName{get;set;}

    public HorizontalChartController () {
        
        fieldName = Apexpages.Currentpage().getparameters().get('fldName');
        system.debug('::::::'+fieldName );
        if( fieldName == 'AmexAmtProcessed' ) {
            
            DispfieldName = 'Amex Amount Processed';
        } else {
            
            DispfieldName = 'Annual Revenue' ;

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
        
      
        Month[] months = new Month[] {};
        for ( Monthly_Sales__c monthSale : [ SELECT Prev1_Value__c, Prev2_Value__c, Prev3_Value__c, Prev4_Value__c, Prev5_Value__c,
                                            Prev6_Value__c, Prev7_Value__c, Prev8_Value__c, Prev9_Value__c,Prev10_Value__c,
                                            Prev11_Value__c, Prev12_Value__c ,
                                            Annual_Revenue_Prev1_Value__c, Annual_Revenue_Prev2_Value__c, Annual_Revenue_Prev3_Value__c, Annual_Revenue_Prev4_Value__c,
                                            Annual_Revenue_Prev5_Value__c, Annual_Revenue_Prev6_Value__c, Annual_Revenue_Prev7_Value__c, Annual_Revenue_Prev8_Value__c,
                                            Annual_Revenue_Prev9_Value__c, Annual_Revenue_Prev10_Value__c, Annual_Revenue_Prev11_Value__c, Annual_Revenue_Prev12_Value__c 
                                            FROM Monthly_Sales__c
                                            ] ) {
                                            
        Date currDate =  System.Today();
        if( fieldName == 'AmexAmtProcessed' ) {
            
            months.add(new Month( currDate.addMonths(-12).Month(), currDate.addMonths(-12).Year(), monthSale.Prev12_Value__c != NULL ? monthSale.Prev12_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-11).Month(), currDate.addMonths(-11).Year(), monthSale.Prev11_Value__c != NULL ? monthSale.Prev11_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-10).Month(), currDate.addMonths(-10).Year(), monthSale.Prev10_Value__c != NULL ? monthSale.Prev10_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-9).Month(), currDate.addMonths(-9).Year(), monthSale.Prev9_Value__c != NULL ? monthSale.Prev9_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-8).Month(), currDate.addMonths(-8).Year(), monthSale.Prev8_Value__c != NULL ? monthSale.Prev8_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-7).Month(), currDate.addMonths(-7).Year(), monthSale.Prev7_Value__c != NULL ? monthSale.Prev7_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-6).Month(), currDate.addMonths(-6).Year(), monthSale.Prev6_Value__c != NULL ? monthSale.Prev6_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-5).Month(), currDate.addMonths(-5).Year(), monthSale.Prev5_Value__c != NULL ? monthSale.Prev5_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-4).Month(), currDate.addMonths(-4).Year(), monthSale.Prev4_Value__c != NULL ? monthSale.Prev4_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-3).Month(), currDate.addMonths(-3).Year(), monthSale.Prev3_Value__c != NULL ? monthSale.Prev3_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-2).Month(), currDate.addMonths(-2).Year(), monthSale.Prev2_Value__c != NULL ? monthSale.Prev2_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-1).Month(), currDate.addMonths(-1).Year(), monthSale.Prev1_Value__c != NULL ? monthSale.Prev1_Value__c : 0 ));
            
            
        }
        if( fieldName == 'AnnualRevenue' ) {
            
            months.add(new Month( currDate.addMonths(-12).Month(), currDate.addMonths(-12).Year(), monthSale.Annual_Revenue_Prev12_Value__c != NULL ? monthSale.Annual_Revenue_Prev12_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-11).Month(), currDate.addMonths(-11).Year(), monthSale.Annual_Revenue_Prev11_Value__c != NULL ? monthSale.Annual_Revenue_Prev11_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-10).Month(), currDate.addMonths(-10).Year(), monthSale.Annual_Revenue_Prev10_Value__c != NULL ? monthSale.Annual_Revenue_Prev10_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-9).Month(), currDate.addMonths(-9).Year(), monthSale.Annual_Revenue_Prev9_Value__c != NULL ? monthSale.Annual_Revenue_Prev9_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-8).Month(), currDate.addMonths(-8).Year(), monthSale.Annual_Revenue_Prev8_Value__c != NULL ? monthSale.Annual_Revenue_Prev8_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-7).Month(), currDate.addMonths(-7).Year(), monthSale.Annual_Revenue_Prev7_Value__c != NULL ? monthSale.Annual_Revenue_Prev7_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-6).Month(), currDate.addMonths(-6).Year(), monthSale.Annual_Revenue_Prev6_Value__c != NULL ? monthSale.Annual_Revenue_Prev6_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-5).Month(), currDate.addMonths(-5).Year(), monthSale.Annual_Revenue_Prev5_Value__c != NULL ? monthSale.Annual_Revenue_Prev5_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-4).Month(), currDate.addMonths(-4).Year(), monthSale.Annual_Revenue_Prev4_Value__c != NULL ? monthSale.Annual_Revenue_Prev4_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-3).Month(), currDate.addMonths(-3).Year(), monthSale.Annual_Revenue_Prev3_Value__c != NULL ? monthSale.Annual_Revenue_Prev3_Value__c : 0 ));
            months.add(new Month( currDate.addMonths(-2).Month(), currDate.addMonths(-2).Year(), monthSale.Annual_Revenue_Prev2_Value__c != NULL ? monthSale.Annual_Revenue_Prev2_Value__c: 0 ));
            months.add(new Month( currDate.addMonths(-1).Month(), currDate.addMonths(-1).Year(), monthSale.Annual_Revenue_Prev1_Value__c != NULL ? monthSale.Annual_Revenue_Prev1_Value__c : 0 ));
                                           
        }

        }
        return months;
        
    }
}