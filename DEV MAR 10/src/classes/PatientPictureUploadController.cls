global with sharing class PatientPictureUploadController{
    public PatientPictureUploadController(ApexPages.StandardController c) {
    }
    @RemoteAction
    global static String doUploadAttachment(String acctId, String attachmentBody, String attachmentName, String attachmentId) {
        if(acctId != null) {
            
            if( attachmentId != NULL && attachmentId != '' ) {
                
                delete [ Select Id From Attachment where ( ParentId =: acctId AND Name = 'Contact Picture' AND Id !=:attachmentId  ) limit 1 ];
            } else {
                delete [ Select Id From Attachment where ( ParentId =: acctId AND Name = 'Contact Picture' ) limit 1 ];
            }
            if(attachmentBody != null) {
            
                Attachment att = getAttachment(attachmentId);
                String newBody = '';
                if(att.Body != null) {
                    newBody = EncodingUtil.base64Encode(att.Body);
                }
                newBody += attachmentBody;
                att.Body = EncodingUtil.base64Decode(newBody);
                if(attachmentId == null) {
                    att.Name = 'Contact Picture';
                    att.parentId = acctId ;
                }
                upsert att;
                return att.Id;
            } else {
                return 'Attachment Body was null';
            }
        } else {
            return 'Account Id was null';
        }
    }
     
    @RemoteAction
    global static String getAttachmentBlob( String acctId ) {
        
        if( acctId != null) {
        
            list<Attachment> attachments = [ SELECT Id, Body, ParentId FROM Attachment WHERE ( ParentId =: acctId AND Name = 'Contact Picture' ) limit 1 ];
            if( !attachments.isEmpty() ) {
            
                return attachments[0].id;
            }                 
        }
        return NULL;
    }
  
     
    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
   
}