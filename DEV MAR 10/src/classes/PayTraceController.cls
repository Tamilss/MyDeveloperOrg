Public Class PayTraceController {
    
    public String paramValue{get;Set;}
    public String orderId{get;Set;}
    public String authkey{get;Set;}
    
    public string cxml{get; set;}
    public string headers {get; set;}
    public string response{get; set;}
    
    Public PayTraceController() {
        
        system.debug('::ApexPage:::'+ApexPages.currentPage());
        system.debug('::ApexPage:::'+ApexPages.currentPage().getParameters().get('PARMLIST'));
    }
    
     public PageReference getResponse() {
     if ( ApexPages.currentPage().getParameters().get('parmList') != null )
         response = ApexPages.currentPage().getParameters().get('parmList');
         
        headers='';
        MAP<string, string> hdrs = ApexPages.currentPage().getheaders();
        for (string key : hdrs.keySet() )
            headers += key + ' : ' + hdrs.get(key) + '\n';
        system.debug(':::::headers:::'+headers);
        system.debug(':::::response :::'+response );
        return null;
    }
    public PageReference init() {
     if ( ApexPages.currentPage().getParameters().get('PARMLIST') != null )
         cxml = ApexPages.currentPage().getParameters().get('PARMLIST');
         
        headers='';
        MAP<string, string> hdrs = ApexPages.currentPage().getheaders();
        for (string key : hdrs.keySet() )
            headers += key + ' : ' + hdrs.get(key) + '\n';
        system.debug(':::::headers:::'+headers);
        system.debug(':::::cxml:::'+cxml);
        return null;
    }
    
    public pageReference redirectPayTrace() {
     
     try {
     
    /* HttpRequest req = new HttpRequest();
     req.setEndpoint('https://api.paytrace.com/oauth/token');
  
     req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
     req.setMethod('POST');
     req.setTimeout(120000);
     req.setHeader('Host', 'api.paytrace.com');
     req.setHeader('Content-Length', '512'); 
     String s = 'grant_type=password&username=diplomatic&password=4DL$payments&TERMS=Y';
     req.setBody(s);
     
     Http http = new Http();
     HTTPResponse res = http.send(req);
     System.debug(res.getBody());*/
 
     
     HttpRequest req = new HttpRequest();
     req.setEndpoint('https://paytrace.com/api/validate.pay');
     req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
     req.setMethod('POST');
     req.setTimeout(120000);
     req.setHeader('Content-Length', '512'); 
     String s = 'parmList=UN~asgiri@softsquare.biz|PSWD~12project|TERMS~Y|ORDERID~5660|TRANXTYPE~Sale|Amount~0|';
     req.setBody(s);
     system.debug('Request::----'+req.getbody());
     Http http = new Http();
     HTTPResponse res = http.send(req);
     system.debug('Request::----'+res.getBody());
     String response = String.valueOf( ( res.getBody()).replace('|','') );
     
     orderId = response.subString( response.indexOf('ORDERID~')+8, response.indexOf('AUTHKEY~'));
     authkey= response.subString( response.indexOf('AUTHKEY~')+8,response.length());
     
     
     system.debug( ':::orderId :::'+orderId );
     system.debug( ':::authkey:::'+authkey); 

     
     } catch( Exception ex ) {
         
         System.debug(':::'+ex);  
     }
     //PageReference page = new PageReference('/apex/CheckOut');
     
     return null;
    }
    
}