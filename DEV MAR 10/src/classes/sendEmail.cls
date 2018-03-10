public class sendEmail  {
    
    public sendEmail() {
        
        String s = Apexpages.currentPage().getParameters().get('s');
    }
    public void sendEmailtoCantacts() {
        
        List<Id> AddressList = new List<Id>();
        Messaging.MassEmailMessage message = new Messaging.MassEmailMessage();
        message.setDescription('hai');
        message.setReplyTo('tami');
        for(Contact con : [ SELECT Id,Name FROM Contact]) {
            
            AddressList.add(con.Id);
        }
        message.settargetObjectIds(AddressList);
        //message.setccAddresses('');
       // massEmail.setToAddresses(new List<String>{'tam'});
    }
}