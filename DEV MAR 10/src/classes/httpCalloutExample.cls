@RestResource(urlMapping='/MessageLimit')
global with sharing class httpCalloutExample
{
    @HttpGet
    global static void doGet() 
    {
        RestRequest req = RestContext.request;
        Integer amount = Integer.valueOf(req.params.get('amount'));
        Messaging.reserveSingleEmailCapacity(amount);               
    }

    public static boolean checkSingleEmailCapacity()
    {   
        Http h = new Http();
        String userName = 'tselevam330@gmail.com';
        String password = 'perumal12ayyappan34';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('www.facebook.com');
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        HttpResponse res = h.send(req);
        system.debug(':::res :::'+res );
        if(res.getStatusCode() == 500) // May want to actually check the body message to be 100% sure
            return false;
        return true;
    }
}