Public Class HTMLFormExampleController {
    
    public HTMLFormExampleController() {
        
        System.debug('::'+ApexPages.currentPage());
        system.debug('::'+ApexPages.currentPage().getParameters().get('fname'));  
    }
    public void retContact() {
        
       List<Contact> con = [Select Id,Name FROM Contact Limit 1 ];
       string  s = 'aaaa';
       //return s;
    }
}