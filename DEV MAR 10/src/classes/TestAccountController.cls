public class TestAccountController {
    
    public string docName{get;set;}
    public string conType{get;set;}
    public Blob docBody{get;set;}
    public Account account {get;set;}
    public Attachment att {get;set;}
    List<Attachment> attList;
    public String s;
    
    public TestAccountController(ApexPages.StandardController stdCon ) {
        
        attList = new List<Attachment>();
        account = (Account)stdCon.getRecord();
        //acc = [SELECT Id,Name,AccountNumber, AnnualRevenue FROM Account Limit1];    
    }
    public pageReference saveAccount() {
        
        update account;
        String[] str = docName.split('\\.');
        system.debug('::str::'+str);
        string type = str[str.size()-1];
        system.debug('::type ::'+type );
        if( (type).toUpperCase() !='XML')  {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'File sould be xml type');
            ApexPages.addMessage(myMsg);
        }
        Attachment att = new Attachment();
        att.body = docBody;
        att.Name = docName;
        att.contentType = conType;
        att.ParentId = account.Id;
        insert att;
        system.debug('::contenttype::'+att.ContentType);
        
        return null;
    }
    public pageReference createAccount() {
    
        for( Attachment att : [SELECT Id,Body,ParentId,ContentType FROM Attachment WHERE ParentId =: account.Id  Limit 1]) {
            System.debug('::att::'+att);
            system.debug('::val::'+String.valueOf(att.ParentId).subString(0,3));
            if(String.valueOf(att.ParentId).subString(0,3)=='001' ) {
                
                attList.add(att);    
            }
        }
        
        
        DOM.Document DOMDoc = new DOM.Document();
        DOMDoc.Load(String.valueOf(attList.get(0).Body));
        
        DOM.XMLNode node = DOMDoc.getRootElement();
        String XMLNodeText = getNodeTypes(node);
        return null;
        
    }
    public string getNodeTypes(DOM.XMLNode node) {
        
        
        system.debug('::node::'+node);
        if( node.getNodeType() == DOM.XMLNodeType.Element ) {
            
            system.debug(':::Element name::'+node.getName());
            s +='Element:'+ node.getName();
            if(node.getText() != NULL ) {
                
                s +='Text:'+ node.getName();
            }
            if( node.getAttributeCount() > 0 ) {
                
                    
            }     
                
        
        }  
        system.debug('::s::'+s);
        return null;
        
    }
}