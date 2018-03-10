global class EmailNotificationforInactiveOrder implements Schedulable {
   
   public Static Set<Id> perAccountIds = new Set<Id>();
   global void execute(SchedulableContext sc) {
      
      List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
      List<Opportunity> OppList = [ Select Id, CloseDate,Email__c,Customer_Name__C, Amount FROM Opportunity WHERE CloseDate > TODAY AND StageName !='Completed' ];
      for( Opportunity oppRec: OppList ) {
          
            
            if( oppRec.Email__c != NULL ) {
                List <String> ccAddresses = new List<String>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setCcAddresses(new List<String>{oppRec.Email__c});
                mail.setBccSender(true);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                                
                mail.setPlainTextBody('This order is closed still now. Please look into this.');
                mailList.add(mail);
                    
            }
            system.debug(':::mailList::'+mailList);
            Messaging.sendEmail(mailList);
      }
   }
}