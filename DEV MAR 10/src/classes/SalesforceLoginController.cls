public class SalesforceLoginController{
    public String username{get;set;}
    public string password{get;set;}
    public Boolean isError{get;set;}
    public String errorMsg{get;set;}
    public SalesforceLoginController(){
        isError = false;
        errorMsg = '';
    }
    
    public pageReference login(){
        isError = false;
        errorMsg = '';
        string startUrl;
        String returnURL = ApexPages.currentPage().getParameters().get('returnURL');
        if(username!=null && username.trim().length()>0){
            if(password!=null && password.trim().length()>0){
                List<Account> accountList = [select id from Account];
                 List<User> userList = [select id,Username from User];
                 Site.login(username, password, startUrl);

                system.debug(':::username:::'+username);
                system.debug(':::password:::'+password);
                system.debug(':::accountList :::'+accountList );
                if(accountList.size()>0){
                     List<Cookie> cookies = new List<Cookie>();
                     Cookie cook=new cookie('accountId',accountList[0].Id,null,-1,false);
                     cookies.add(cook);
                     ApexPages.currentPage().setCookies(cookies);
                     
                     if( returnURL == NULL || returnURL == '' ) {
                         
                         return new pageReference('/MyAccount');    
                     } else {
                         return new pageReference('/'+returnURL);
                     }
                }else{
                    isError = true;
                    errorMsg = 'Please verify your username and password.';
                }
            }else{
                isError = true;
                errorMsg = 'Please enter password.';
            }
        }else{
            isError = true;
            errorMsg = 'Please enter username.';
        }
        return null;
    }
}