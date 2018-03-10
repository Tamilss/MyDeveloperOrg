public class MyController {
   Public PageReference viewrecords() {
   
        Account acc = [SELECT Id, Name FROM Account
                WHERE Id = '00190000009L117'];
                //:ApexPages.currentPage().getParameters().get('Id')];
        PageReference pagRef = new PageReference('https://ap1.salesforce.com/00190000009L117');
        pagRef .setRedirect(true); 
        return pagRef ;            
    
    }
}