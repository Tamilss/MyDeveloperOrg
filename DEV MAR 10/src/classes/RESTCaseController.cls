@RestResource(urlMapping='/FieldCase/*')
global with sharing class RESTCaseController {

  @HttpGet
  global static List<Case> getOpenCases() {
    String companyName = RestContext.request.params.get('companyName');
    Account company = [ Select ID, Name, BillingState from Account where Name =:companyName];
     
    List<Case> cases = [SELECT Id, Subject, Status, OwnerId, Owner.Name from Case WHERE AccountId =: company.Id];
    return cases;
    
  }

}