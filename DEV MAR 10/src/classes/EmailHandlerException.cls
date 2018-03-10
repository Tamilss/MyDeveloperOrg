public class EmailHandlerException extends Exception{

    public static final Integer SUSPECTED_VENDOR = 1;
    public static final Integer BLACKLISTED_CLIENT = 2;
    public static final Integer THREADED_EMAIL = 3;
    public static final Integer NOT_SENT_TO_ANALYST = 4;
    public static final Integer NO_DELIMITERS_FOUND = 5;
    public static final Integer PROCESSING_FAILED = 6;
    public static final Integer NOT_BIO_OR_SCHEDULE_EMAIL = 7;
    public static final Integer SUSPECTED_NAME = 8;
    public static final Integer MISSING_START_DELIMITER = 9;
    public static final Integer MISSING_BIO_END_DELIMITER = 10;
    public static final Integer NO_CALL_DATA = 11;
    public static final Integer DUPLICATE_EXPERTS_FOUND = 12;
    public static final Integer VENDOR_NOT_FOUND = 13;
    public static final Integer BIO_WITHOUT_EXPERT = 14;
    
    
    //Mosaic specific exceptions
    public static Final Integer MOSAIC_SCHEDULER_SUBJECT_DOUBTFUL = 201; //all mosaic specific emals will start with 2
    
    public EmailHandlerException(Integer errorNo){
        
        if ( errorNo == SUSPECTED_VENDOR ){
            this.setMessage('The sender of this email is suspected to be from a invalid vendor');
        } else if ( errorNo == BLACKLISTED_CLIENT ){
            this.setMessage('The email is sent to a blacklisted client');
        } else if ( errorNo == THREADED_EMAIL ){
            this.setMessage('This email is suspected as a reply/forward email');
        } else if ( errorNo == NOT_SENT_TO_ANALYST ){
            this.setMessage('This email was not sent to an anlayst');
        } else if ( errorNo == NO_DELIMITERS_FOUND ){
            this.setMessage('This cannot be processed as no parser delimiters are found');
        } else if ( errorNo == MOSAIC_SCHEDULER_SUBJECT_DOUBTFUL ){
            this.setMessage('The subject for mosaic scheduling email is doubted as invalid');
        } else if ( errorNo == NOT_BIO_OR_SCHEDULE_EMAIL ){
            this.setMessage('The email does not contain any bio or scheduling detail');
        } else if ( errorNo == SUSPECTED_NAME ){
            this.setMessage('One or more expert names may be blank or have special characters in it');
        } else if ( errorNo == MISSING_START_DELIMITER ){
            this.setMessage('Missing Body start delimiter');
        } else if ( errorNo == MISSING_BIO_END_DELIMITER ){
            this.setMessage('Missing bio end delimiter');
        } else if ( errorNo == NO_CALL_DATA ){
            this.setMessage('Research call data could not be updated');
        } else if ( errorNo == DUPLICATE_EXPERTS_FOUND ){
            this.setMessage('Duplicate expert records found for the same vendor.');
        } else if ( errorNo == VENDOR_NOT_FOUND ){
            this.setMessage('Vendor account not found. Please create the vendor account.');
        }  else if ( errorNo == BIO_WITHOUT_EXPERT ){
            this.setMessage('Expert bio without expert name');
        } else { //for PROCESSING_FAILED
            this.setMessage('An exception has occured while processing the email');
        }
    }
    
    static testMethod void testEmailHandlerExceptions(){
        
        try{
            throw new EmailHandlerException(SUSPECTED_VENDOR);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'The sender of this email is suspected to be from a invalid vendor');
        }
        
        try{
            throw new EmailHandlerException(BLACKLISTED_CLIENT);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'The email is sent to a blacklisted client');
        }
        
        try{
            throw new EmailHandlerException(THREADED_EMAIL);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'This email is suspected as a reply/forward email');
        }
        
        try{
            throw new EmailHandlerException(NOT_SENT_TO_ANALYST);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'This email was not sent to an anlayst');
        }
        
        try{
            throw new EmailHandlerException(NO_DELIMITERS_FOUND);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'This cannot be processed as no parser delimiters are found');
        }
        
        try{
            throw new EmailHandlerException(MOSAIC_SCHEDULER_SUBJECT_DOUBTFUL);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'The subject for mosaic scheduling email is doubted as invalid');
        }
        
        try{
            throw new EmailHandlerException(NOT_BIO_OR_SCHEDULE_EMAIL);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'The email does not contain any bio or scheduling detail');
        }
        
        try{
            throw new EmailHandlerException(SUSPECTED_NAME);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'One or more expert names may be blank or have special characters in it');
        }
        
        try{
            throw new EmailHandlerException(MISSING_START_DELIMITER);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'Missing Body start delimiter');
        } 
        
        try{
            throw new EmailHandlerException(MISSING_BIO_END_DELIMITER);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'Missing bio end delimiter');
        } 
        
        try{
            throw new EmailHandlerException(NO_CALL_DATA);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'Research call data could not be updated');
        } 
        
        try{
            throw new EmailHandlerException(DUPLICATE_EXPERTS_FOUND);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'Duplicate expert records found for the same vendor.');
        }  
        
        try{
            throw new EmailHandlerException(0);
        } catch (EmailHandlerException e){
            System.AssertEquals(e.getMessage(), 'An exception has occured while processing the email');
        }
    }
}