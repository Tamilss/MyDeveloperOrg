public class WebServiceCallout1 {

    public static void sendNotification() {

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        req.setEndpoint('https://ap1.salesforce.com/services/Soap/s/30.0');
        req.setMethod('POST');
        req.setBody('Username=tamilselvam@gmail.com&password=12345project');
        req.setCompressed(true);

        try {
            res = http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

    }

    
}