@isTest
private class TestSetSchoolId {
   
    static testMethod void toUpdateSchoolName() {
    
        Lead[] leadSchoolName = new Lead[] {
            new Lead( LastName = 'tamil', School_Name__c = 'United Oil & Gas, Singapore', Company = 'genepoint'),
            new Lead( LastName = 'mani', School_Name__c = 'Cadinal Inc', Company = 'Cadinal Inc'),
            new Lead( LastName = 'james', School_Name__c = 'Emerson Transport', Company = 'Emerson Transport')
        }; 
        insert leadSchoolName;
        Lead[] leadObj = new Lead[] {    
            new Lead( LastName = 'Steve', School_Name__c = 'Abbott Insurance', Company = 'Abbott Insurance'),
            new Lead( LastName = 'mark', School_Name__c = 'Abbott Insurance', Company = 'Abbott Insurance'),
            new Lead( LastName = 'johnsion', School_Name__c = 'Abbott Insurance', Company = 'genepoint'),
            new Lead( LastName = 'bell', School_Name__c = 'genepoint', Company = 'genepoint'),
            new Lead( LastName = 'kesore', School_Name__c = 'Cadinal Inc', Company = 'genepoint'),
            new Lead( LastName = 'Daniyal', School_Name__c = 'Emerson Transport', Company = 'genepoint'),
            new Lead( LastName = 'joseph', School_Name__c = 'Emerson Transport', Company = 'genepoint')
        };
        insert leadObj; 
        Account acc = [ SELECT Id, Name FROM Account WHERE Name = 'United Oil & Gas, Singapore' LIMIT 1 ];
        Lead leadObject = [ SELECT Id, School__c FROM Lead WHERE  School_Name__c = 'United Oil & Gas, Singapore' LIMIT 1 ];   
        System.AssertEquals( leadObject .School__c, acc.Id );
    }
}