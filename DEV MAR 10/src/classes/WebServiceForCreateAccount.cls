global class WebServiceForCreateAccount {
  
   webservice static String createAccountRec( String accName ) {
       
       Account acct = new Account();
       acct.Name = accName;
       insert acct;
       
       return acct.Id;
  }
  

}