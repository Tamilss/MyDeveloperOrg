public class TestInputFileUsingAccount {
    
    public string cmuds{get;set;}
    Public Blob selectedFile{get;set;}
    Public String selFileName{get;set;}
    Public String fileName{get;set;}
    public List<Account> accountList{get;set;}
    
    
    public TestInputFileUsingAccount() {
        
        
        accountList = new List<Account>();
        accountList = [ select Id, Name from Account Limit 4 ];
    }
    public pageReference callExportCSV() {
        
        if( selFileName != NULL ) {
            
            fileName = selFileName;
        }
        else {
            fileName = 'test.csv';    
        }
        pageReference pgRef = new pageReference('/apex/samplepage');
        pgRef.setRedirect(false);
        return pgRef;    
    }
}