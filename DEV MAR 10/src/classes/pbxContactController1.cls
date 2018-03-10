global with sharing Class pbxContactController1 {

    public string PhoneNumber;
    Public List<Contact> conList{get;set;}
    
    Public pbxContactController1(ApexPages.StandardController stdCont) {
        
        conList = new List<Contact>();
        PhoneNumber = ApexPages.CurrentPage().getParameters().get('pn'); 
        
        system.debug('::::PhoneNumber:::'+PhoneNumber);
         
        conList = [ SELECT AccountId,Name,MobilePhone FROM Contact WHERE MobilePhone = :PhoneNumber OR HomePhone =:PhoneNumber   ];
        system.debug('::::conList :::'+conList );
    }
    /*webservice static String test(String accName) {
        
        System.debug('::::accName:::'+accName);
        return 'test';
    }
    public pageReference test1() {
    
        return null;
        
    }*/
}