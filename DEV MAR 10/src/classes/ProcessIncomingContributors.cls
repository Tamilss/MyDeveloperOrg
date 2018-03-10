global class ProcessIncomingContributors  implements Messaging.InboundEmailHandler {
        
        //This method handles the incoming email and calls different methods for different vendors
        global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
            
            System.Debug(LoggingLevel.INFO, 'Plain Body :: ' + email.plainTextBody + '\n\n');
            System.Debug(LoggingLevel.INFO, 'HTML Body :: ' + email.htmlBody + '\n\n');
            System.Debug(LoggingLevel.INFO, 'Subject :: ' + email.subject + '\n\n');
            
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
                
           /* Id analyst1, analyst2;
            Contact vendorContact;
            Account vendorAccount;
            String vendorName;
            Id VendorAccountId;
            String vendorContactEmail;
            
            String plainBody = email.plainTextBody;
            String htmBody = email.htmlBody;
            String subject = email.subject;
            
            String bodyUpper;
            if ( !isBlank(plainBody) ) bodyUpper = plainBody.toUpperCase(); //conver to uppercase to make string comparisons perfect
            if ( !isBlank(htmBody) ) bodyUpper = htmBody.toUpperCase();
            
            Date callDate = getCallDateFromICS(email);  //Check if a calendar file is attached and a call date info is found

            //throw exception if the email is suspected to be a reply or forward email
            if ( (bodyUpper.contains('FROM:') && bodyUpper.contains('TO:') &&  bodyUpper.contains('SUBJECT:')) || subject.toUpperCase().startsWith('RE:') || subject.toUpperCase().startsWith('FWD:') ){
            
                //throw new EmailHandlerException(EmailHandlerException.THREADED_EMAIL);
            }    
           
            // Figure out the vendor based on sender's email address
             if (email.fromAddress.endsWith('@mosaicrm.com') || email.subject.startsWith('FROMMOSAIC')) {
            vendorName = 'Mosaic';
            } else if (email.fromAddress.endsWith('@ridgetopresearch.com') || email.subject.startsWith('FROMRIDGETOP')) {
                vendorName = 'Ridgetop';
            } else if (email.fromAddress.endsWith('glgroup.com') || email.fromAddress.endsWith('@glgresearch.com')  || email.subject.startsWith('FROMGLG')) {
                vendorName = 'GLG';
            } else if (email.fromAddress.endsWith('@colemanrg.com')  || email.subject.startsWith('FROMCOLEMAN')) {
                vendorName = 'Coleman';
            } else if (email.fromAddress.endsWith('@guidepointglobal.com') || email.subject.startsWith('FROMGUIDEPOINT')) {
                vendorName = 'Guidepoint';
            } else if (email.fromAddress.contains('cognolink.com')  || email.subject.contains('FROMCOGNOLINK')) {
                vendorName = 'Cognolink';
            } else if (email.fromAddress.contains('dmllc.com')  || email.subject.contains('FROMCOGNOLINK')) {
                vendorName = 'Cognolink';
            } else {
            
                throw new EmailHandlerException(EmailHandlerException.SUSPECTED_VENDOR);
            }
            system.debug('::::::vendorName:::'+vendorName);
            //Programaticaly fetch the record types so this works across orgs
            //no need to check if the record types exist as they are part of the package
            Id vendorRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Vendor_Contact' AND SObjectType = 'Contact' LIMIT 1].Id;      
           
            // Programmatically fetch the Analyst Profile ID so this works across orgs
            ID analystProfileId = [SELECT Id FROM Profile WHERE Name = 'Analyst' LIMIT 1].Id;        
           
            // Figure out the vendor's account ID
            // Uses hidden API_Name field so an analyst changing a vendor name does not break this
            try{
                VendorAccountId = [SELECT Id FROM Account WHERE API_Name__c=:vendorName LIMIT 1].Id;
            } catch (EmailHandlerException e){
                throw new EmailHandlerException(EmailHandlerException.VENDOR_NOT_FOUND);
            }
            
            // Create the vendor contact
            vendorContactEmail = email.fromAddress;
            
            // This should never be 0, but why not make sure
            if (vendorContactEmail.length() > 0) {
                
                // check if there is a vendor contact with this email
                Contact[] existingVendorContactId = [
                    SELECT Id, AccountId FROM Contact 
                    WHERE Email = :vendorContactEmail AND RecordTypeId =:vendorRecordTypeId AND AccountId = :VendorAccountId
                    LIMIT 1
                ];
                
                // matching vendor contact
                String firstname, lastname;
                if (existingVendorContactId.size() > 0) { //fetch the vendor contact details
                    
                    vendorContact = existingVendorContactId[0];
                } else { //create a new vendor contact

                    if(email.fromname != null){
                        Map<String, String> names = getNames(email.fromname);
                        firstname = names.get('firstname');
                        lastname = names.get('lastname');
                    } else {
                        firstname = NULL;
                        lastname = 'Unknown';
                    }
                    
                    vendorContact = new Contact(
                        Firstname = firstname,
                        Lastname = lastname,
                        Email = vendorContactEmail,
                        AccountId = vendorAccountId,
                        RecordTypeId=vendorRecordTypeId
                    );

                    insert vendorContact;
                }
            }
            // end of vendor contact
            
            // Find the analysts
            // Make a map of all the active analysts in the system
            List<User> activeAnalysts = [
                SELECT Id, Email, Secondary_Email__c FROM User 
                WHERE IsActive = true AND ProfileId = :analystProfileId
            ];
            Map<String,User> analystMap = new Map<String,User>();
            for(User analyst : activeAnalysts){
                analystMap.put(analyst.email.toLowerCase(), analyst);
                if (analyst.Secondary_Email__c != NULL ) analystMap.put(analyst.Secondary_Email__c.toLowerCase(),analyst);
            }
            
            // Make a list of all the TO email addresses in the above map
            List<User> analystRecipients = new List<User>();
            for (String to: email.toAddresses) {
                if (analystMap.containsKey(to.toLowerCase())) {
                    analystRecipients.add(analystMap.get(to.toLowerCase()));
                }
            }
            
            // Make a list of all the CC email addresses in the above map
            if(email.ccAddresses != null) {
                for (String cc: email.ccAddresses) {
                    if (analystMap.containsKey(cc.toLowerCase())) {
                        analystRecipients.add(analystMap.get(cc.toLowerCase()));
                    }
                }
            }
            
             //If there are no analyst matches, do not capture. BREAKS INTENTIONALLY
            if (analystRecipients.size() == 0) {
                throw new EmailHandlerException(EmailHandlerException.NOT_SENT_TO_ANALYST);
            }
            
            // If there is at least one match, add him as Analyst 1
            if (analystRecipients.size() > 0) {
                analyst1 = analystRecipients[0].id;
            }
            
            // If there are at least two matches, add the second as Analyst 2
            // NOTE: This should be turned off if a setting to not use analyst 2 exists
            if (analystRecipients.size() > 1) {
                analyst2 = analystRecipients[1].id;
            }
            // end of adding analysts
            
            List<String> analysts = new List<String>{analyst1, analyst2};
            String projectName;
                
            // Process GLG emails
            if(vendorName == 'GLG') {
                        
                //GLG bio emails will always have the string 'View the Council Member\'s full profile' at the end of each bio
                //GLG scheduling emails will always have the date next to When: in body and the text
                //'GLG Consultation: ServiceNow | Product Offering' in the subject line           
                if ( htmBody.indexOf('View the Council Member\'s full profile') != -1 ){
                
                    processGLGBioEmail(email, analysts, vendorContact);
                } else if (plainBody.indexOf('When:') != -1 && email.subject.indexOf('GLG Consultation:') != -1 ){ 
                    
                    processGLGSchedulingEmail(email, analysts, vendorContact); 
                } else {
                    throw new EmailHandlerException(EmailHandlerException.NOT_BIO_OR_SCHEDULE_EMAIL); 
                }
            }
            // end GLG
            
            // Process Mosaic emails
            if(vendorName == 'Mosaic') {
                          
                 
                        
                //mosaic bio emails will always have an <hr> in the html body
                //mosaic scheduling emails will always have the date next to When: in body and the meeting invite  as attachment
                if ( containsHrTag(htmBody) ){
                
                    processMosaicBioEmail(email, analysts, vendorContact);
                } else if ( plainBody.indexOf('When: ') != -1 || callDate != NULL){ 
                    
                    processMosaicSchedulingEmail(email, analysts, vendorContact, callDate); 
                } else {
                    throw new EmailHandlerException(EmailHandlerException.NOT_BIO_OR_SCHEDULE_EMAIL);
                }                    
            }
            //end of Mosaic  
            
            // Process Coleman emails
            if(vendorName == 'Coleman') {
                        
                //Coleman bio emails will always have the string 'TOTAL NUMBER OF BIOS:' followed by number of bios included
                //Coleman scheduling emails will always have the date next to Date: in body and the meeting invite  as attachment        
                if ( bodyUpper.contains('TOTAL NUMBER OF BIOS:') ){

                    processColemanBioEmail(email, analysts, vendorContact);    
                }  else if ( bodyUpper.indexOf('DATE: ') != -1 || bodyUpper.indexOf('<B>DATE</B>:') != -1 || callDate != NULL){ 
                    
                    processColemanSchedulingEmail(email, analysts, vendorContact, callDate); 
                } else {
                    throw new EmailHandlerException(EmailHandlerException.NOT_BIO_OR_SCHEDULE_EMAIL);
                } 
            }
            //end of Coleman
            
            // Process Guidepoint emails
            if(vendorName == 'Guidepoint') {
            
                //Guidepoint bio emails will always have the string '===================================================================='
                //at the beginning of each bio
                //Guidepoint scheduling emails will always have the date next to Date:, expert name next to Advisor: in body  
                //and Guidepoint Global: Consultation in the subject line     
                if ( plainBody.contains('====================================================================\n') ){
                    
                    processGuidepointBioEmail(email, analysts, vendorContact);    
                } else if (email.subject.contains('Guidepoint Global: Consultation') && plainBody.contains('Date:') && plainBody.contains('Advisor:')){
                
                    processGuidepointSchedulingEmail(email, analysts, vendorContact);                   
                } else {
                    throw new EmailHandlerException(EmailHandlerException.NOT_BIO_OR_SCHEDULE_EMAIL);
                }
            }
            //end of Guidepoint          
            
            // Process Ridgetop emails
            if(vendorName == 'Ridgetop') {
                    
                if ( ( plainBody.contains('Ridgetop Recruit:') || plainBody.contains('Ridgetop\nRecruit:') || plainBody.contains('Ridgetop Consultant:') || plainBody.contains('Ridgetop\nConsultant:') )&& plainBody.contains('\nName:') && !email.subject.contains('Conversation with') ){
                
                    processRidgetopBioEmail(email, analysts, vendorContact);
                } else if ( (plainBody.contains('When:') && email.subject.contains('Conversation with')) || callDate != NULL ){
                
                    processRidgetopSchedulingEmail(email, analysts, vendorContact, callDate);
                } else {
                
                    throw new EmailHandlerException(EmailHandlerException.NOT_BIO_OR_SCHEDULE_EMAIL);
                }
            }
            //end of Ridgetop
            
            // Process Cognolink emails
            if(vendorName == 'Cognolink') {
                
                if ( email.subject.contains('specialist profiles to screen') || email.subject.contains('specialist profiles to screen\'s') ){
                
                    processCognolinkBioEmail(email, analysts, vendorContact);
                
                } else if( plainBody.contains('Name:') && plainBody.contains('Email:') && plainBody.contains('Primary phone number:')) {
                    
                    processCognolinkBioEmail(email, analysts, vendorContact);
                } else if( email.subject.contains('CognoLink Consultation with') || callDate != NULL ) {
                    
                    processCognolinkSchedulingEmail(email, analysts, vendorContact,callDate);
                } else if( email.subject.contains('specialist profile') || email.subject.contains('specialist profile\'s') ) {
                    
                    throw new EmailHandlerException( EmailHandlerException.BIO_WITHOUT_EXPERT );
                } else {
                
                    throw new EmailHandlerException(EmailHandlerException.NOT_BIO_OR_SCHEDULE_EMAIL);
                }       
                
               
            } 
            if( vendorName =='Dematteo') {
                
            if( ( email.subject.toUpperCase()).contains('EXPERTS REQUEST') && email.htmlBody.Contains('<b>') && email.htmlBody.Contains('</b>') ) {
                
                processDematteoBioEmail( email, analysts, vendorContact );
            } else {
            
                throw new EmailHandlerException( EmailHandlerException.NOT_BIO_OR_SCHEDULE_EMAIL );
            }     
        }
            //end of Ridgetop        
            
            //send the incoming email to some other email to have the archive of incoming emails
            //if any exception happens in the processing, this email will not be sent
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage ();
            mail.toAddresses = new String [] {'tamil@softsquare.biz'};
            mail.setSubject ('PROCESSED SUCCESSFULLY - ' + email.subject);
            
            String successPlainTextBody = 'FROM: ' + email.fromAddress + '\nTO: ';

            if(email.toAddresses != null) {
                for (String to : email.toAddresses) {
                    successPlainTextBody += to + ', ';
                } 
            }  
            if ( successPlainTextBody.endsWith(', ') )  successPlainTextBody = successPlainTextBody.substring(0, successPlainTextBody.length()-2 );
            successPlainTextBody += '\nCC: ';
            
            if(email.ccAddresses != null) {
                for (String cc : email.ccAddresses) {
                    successPlainTextBody += cc + ', ';
                }
            }
            if ( successPlainTextBody.endsWith(', ') )  successPlainTextBody = successPlainTextBody.substring(0, successPlainTextBody.length()-2 );
            successPlainTextBody += '\nSUBJECT: ';
            
            successPlainTextBody += email.Subject + '\n\n\n';
            String successHtmlBody = successPlainTextBody.replaceAll('\n', '<br/>');
                   
            mail.setPlainTextBody(successPlainTextBody + email.plainTextBody);
            mail.setHtmlBody(successHtmlBody + email.htmlBody);
            
            Messaging.sendEmail (new Messaging.SingleEmailMessage[] {mail});
            //mail archiving ends here        
                            */
            return result;
        }
        /*private void processDematteoBioEmail( Messaging.InboundEmail email, List<String> analysts, Contact vendorContact ) {
            
           system.debug( ':::plaintextbody:::'+email.PlainTextBody );
           system.debug( ':::htmlbody:::'+email.htmlBody );
           
           Map<String, Contact> expertsMap = new Map<String, Contact>();
           string HTMLBody = email.htmlBody;
           string plainBody = email.PlainTextBody;
           String unFormatNameBeginner = '<b>';
           String unFormatNameEnd = '</b>';
           String unformatBody = '';
           String formatBody = '';
           String formatName = '';
           String biosEndingText = 'Robert Conklin';
           Integer unFormatNameBeginnerIdx = 0;
           Integer unFormatNameEndIdx = 0;
           Integer unFormatBodyIdx = 0;
           string projectName = '';
           
            Id expertRecordTypeId = getExpertRecordTypeId(); 
            while( HTMLBody.indexOf( unFormatNameBeginner, unFormatNameBeginnerIdx + unFormatNameBeginner.length() ) != -1  &&  HTMLBody.indexOf( unFormatNameEnd, unFormatNameEndIdx + unFormatNameEnd.length() ) != -1 ) {
            
                if( unFormatNameBeginnerIdx == 0 && unFormatNameEndIdx == 0 ) {
                
                    unFormatNameBeginnerIdx = HTMLBody.indexOf( unFormatNameBeginner, unFormatNameBeginnerIdx );
                    unFormatNameEndIdx = HTMLBody.indexOf( unFormatNameEnd, unFormatNameEndIdx );
                } else {
                    
                    unFormatNameBeginnerIdx = HTMLBody.indexOf( unFormatNameBeginner, unFormatNameBeginnerIdx + unFormatNameBeginner.length() );
                    unFormatNameEndIdx = HTMLBody.indexOf( unFormatNameEnd, unFormatNameEndIdx + unFormatNameEnd.length() );
                }

                if( unFormatNameBeginnerIdx != -1 && unFormatNameEndIdx != -1 ) {
                    
                    String unformattName = HTMLBody.subString( unFormatNameBeginnerIdx, unFormatNameEndIdx );
                    
                    if( !unformattName.contains( 'Robert Conklin' ) &&  !unformattName.contains( ':' ) ) {
                    
                        formatName = convertHtmlToPlainText( unformattName );
                        unFormatBodyIdx = HTMLBody.indexOf( unFormatNameBeginner, unFormatNameEndIdx + unFormatNameEnd.length() ); 
                        
                        if( unFormatBodyIdx != -1 ) {
                            
                            unformatBody = HTMLBody.subString( unFormatNameEndIdx, unFormatBodyIdx );
                            if( unformatBody != '' ) {
                            
                                formatBody = convertHtmlToPlainText( unformatBody );
                            }
                        } else {
                            
                            unFormatBodyIdx =  HTMLBody.indexOf( biosEndingText, unFormatNameEndIdx + unFormatNameEnd.length() ); 
                            if( unFormatBodyIdx != -1 ) {
                                
                                unformatBody = HTMLBody.subString( unFormatNameEndIdx, unFormatBodyIdx );
                                if( unformatBody != '' ) {
                                
                                    formatBody = convertHtmlToPlainText( unformatBody );
                                }
                            }
                        }
                        
                        if( formatBody != '' || formatName != '') {
                        
                            String expertBio = formatBody;
                            Map<String, String> names = getNames( formatName );
                            String firstName = names.get('firstname');
                            String lastname = names.get('lastname'); 
                            Contact ct = new Contact(
                                Firstname = firstname,
                                LastName = lastname,
                                Summary_Bio__c = expertBio,
                                AccountId = vendorContact.AccountId,
                                RecordTypeId=expertRecordTypeId
                            );
                            expertsMap.put(firstname+lastname, ct); 

                            system.debug('::::expertBio:::'+expertBio);
                        }   
                        
                    }   
                }
            }
            system.debug('::::expertsMap:::'+expertsMap);
            upsertBios(expertsMap, analysts, vendorContact, expertRecordTypeId, projectName);
        }
        
        //added by Subash on 09/21/2012 to process Cognolink bio emails
        private void processCognolinkBioEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact){  
            
            String emailHTMLBody = email.HTMLBody;
            Pattern myPattern=Pattern.compile('border-top:red.*?>');
            Matcher myMatcher=myPattern.Matcher(emailHTMLBody);
            String projectName = NULL;
            emailHTMLBody=myMatcher.replaceAll('>~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-');
            
            emailHTMLBody = convertHtmlToPlainText(emailHTMLBody);

            Id expertRecordTypeId = getExpertRecordTypeId();
            List<String> splitedBiosList = emailHTMLBody.split('~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-');
            for(String s : splitedBiosList) {
                system.debug(':::s:::'+s);
            }
            Map<String, Contact> expertsMap = new Map<String, Contact>();
            for (Integer i=1;i<splitedBiosList.size()-1; i++) {
            
                String fullNameIdx = 'Name:'; 
                String emailIdx = 'Email:';
                String phoneIdx = 'Primary phone number:';
                String fullName = '';
                String emailId = '';
                String phone = '';
                String expertBio = '';
                List<String> expertBioInfo = new List<String>();
                if( splitedBiosList[i].contains(fullNameIdx) && splitedBiosList[i].contains(emailIdx) && splitedBiosList[i].contains(phoneIdx)) {
                    
                    expertBioInfo = splitedBiosList[i].split(' - ');
                    if( expertBioInfo.size() >= 2 ) {
                        
                        expertBio = expertBioInfo[1].subString(0,expertBioInfo[1].indexOf('\n'));
                    }
                    system.debug(':::expertBio:::'+expertBio);
                    if(splitedBiosList[i].contains(fullNameIdx)) {
                     
                        fullName = splitedBiosList[i].subString(splitedBiosList[i].indexOf(fullNameIdx)+fullNameIdx.length(), splitedBiosList[i].indexOf('\n',splitedBiosList[i].indexOf(fullNameIdx)+fullNameIdx.length()));
                    }
                    if(splitedBiosList[i].contains(emailIdx)) {
                        
                        emailId = splitedBiosList[i].subString(splitedBiosList[i].indexOf(emailIdx)+emailIdx.length(),splitedBiosList[i].indexOf('\n',splitedBiosList[i].indexOf(emailIdx)+emailIdx.length()));
                    }
                    if(splitedBiosList[i].contains(phoneIdx)) {
                        
                        phone = splitedBiosList[i].subString(splitedBiosList[i].indexOf(phoneIdx)+phoneIdx.length(),splitedBiosList[i].indexOf('\n',splitedBiosList[i].indexOf(phoneIdx)+phoneIdx.length()));
                    }
                    expertBio = expertBio + splitedBiosList[i].subString(splitedBiosList[i].indexOf(phoneIdx)+phoneIdx.length()+phone.length());
                    
                } else {
                    expertBioInfo = splitedBiosList[i].split(' - ');
                    if( expertBioInfo.size() >= 2 ) {
                        fullName = expertBioInfo[1];
                        expertBio  = expertBioInfo[2];  
                    }
                }       
                system.debug(':::fullName:::'+fullName);
                system.debug(':::emailId:::'+emailId);
                system.debug(':::phone:::'+phone);
                system.debug('::::expertBio::::'+expertBio);
                
                Map<String, String> names = getNames(fullName);
                String firstName = names.get('firstname');
                String lastname = names.get('lastname'); 
                Contact ct = new Contact(
                    Firstname = firstname,
                    LastName = lastname,
                    Summary_Bio__c = expertBio,
                    AccountId = vendorContact.AccountId,
                    RecordTypeId=expertRecordTypeId
                );

                expertsMap.put(firstname+lastname, ct);                     
            }

            upsertBios(expertsMap, analysts, vendorContact, expertRecordTypeId, projectName);
        }
        
        private void processCognolinkSchedulingEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact, Date callDateFromICS) {
            
            String fullNameIdx = 'CognoLink Consultation with';
            String fullName = '';
            String bio = '';
            String body = email.plainTextBody.replaceAll('  ', ' ').trim();
            
            if(email.subject.contains(fullNameIdx)) {
                
                fullName = email.subject.subString(email.subject.indexOf(fullNameIdx)+fullNameIdx.length(),email.subject.indexOf(','));
            }
            Id expertRecordTypeId = getExpertRecordTypeId();
            Map<String, String> names = getNames(fullName);
            String firstName = names.get('firstname');
            String lastname = names.get('lastname');  
            if ( !isValidName(firstname) || !isValidName(lastname) ){
                
                throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
            }
            system.debug('::::fullName ::: '+fullName);
            Id expertId = getExpertId(firstname, lastname, bio, vendorContact.AccountId, expertRecordTypeId);
            
            // Get the date if there is one
            String preCallDate = 'When: ';
            Integer preCallDateIdx = body.indexOf(preCallDate);
            Date callDateFinal;
            if (preCallDateIdx != -1){
                String dateString = body.substring(preCallDateIdx + preCallDate.length(), body.indexOf('\n', preCallDateIdx + preCallDate.length()+2));
                callDateFinal = createDate( dateString);   
            } else if (callDateFromICS != NULL) {
            
                callDateFinal = callDateFromICS;
            }         
            system.debug(':::callDateFinal::'+callDateFinal);
            upsertCallSchedule(expertId, analysts, vendorContact.AccountId, vendorContact.Id, callDateFinal);   
        }
        
        //added by subash on 09/10/2012  
        private void processRidgetopSchedulingEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact, Date callDateFromICS){
        
            System.Debug(LoggingLevel.INFO, 'Schedule Ridgetop process... ' + callDateFromICS);
            String body = email.plainTextBody.replaceAll('  ', ' ').trim();
            
            //double check double space to single space conversion
            while ( body.indexOf('  ') >= 0){
        
                body = body.replaceAll('  ', ' ').trim();
            }        
            
            String subject = email.subject;
            
            Id expertRecordTypeId = getExpertRecordTypeId();
                    
            String fullNameDelimiter = 'Ridgetop Consultant:\n';
            Integer fullNameIdx = body.indexOf(fullNameDelimiter);
            fullNameDelimiter = 'Name:';
            fullNameIdx = body.indexOf(fullNameDelimiter, fullNameIdx+21);
            String fullName = body.substring(fullNameIdx + 5, body.indexOf('\n', fullNameIdx + 5)).trim();

            Map<String, String> names = getNames(fullName);
            String firstName = names.get('firstname');
            String lastname = names.get('lastname');  
            if ( !isValidName(firstname) || !isValidName(lastname) ){
                
                throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
            }
            
            //find bio from scheduling email
            String bioStart = 'Bio:';
            String bioEnd = 'Please note Ridgetop client will call Ridgetop consultant at the agreed upon time';
            
            Integer bioStartIdx = body.indexOf(bioStart);
            Integer bioEndIdx = body.indexOf(bioEnd);
            
            String bio;
            if ( bioStartIdx != -1 && bioEndIdx != -1 ){
                
                bio = body.substring(bioStartIdx + 4, bioEndIdx).trim(); 
                bio = startFromAlphabet(bio); 
                bio = removeEndBlankLines(bio);            
            }        
            // end of finding bio         
                   
            Id expertId = getExpertId(firstname, lastname, bio, vendorContact.AccountId, expertRecordTypeId);
            
            // Get the date if there is one
            String preCallDate = 'When: ';
            Integer preCallDateIdx = body.indexOf(preCallDate);
            Date callDateFinal;
            if (preCallDateIdx != -1){
                String dateString = body.substring(preCallDateIdx + preCallDate.length(), body.indexOf('\n', preCallDateIdx + preCallDate.length()+2));
                callDateFinal = createDate( dateString);   
            } else if (callDateFromICS != NULL) {
            
                callDateFinal = callDateFromICS;
            }         
            
            upsertCallSchedule(expertId, analysts, vendorContact.AccountId, vendorContact.Id, callDateFinal);    
        }    
        
        //added by Subash on 09/07/2012 to process Ridgetop bio emails
        private void processRidgetopBioEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact){  
        
            String subject = email.subject;
            
            //find the project name to be stored in call
            String projectName;
            List<String> projectNameFinders = new List<String>{
                'Ridgetop Recruit - ',   'Ridgetop Recruits - '
            };
            for ( String finder : projectNameFinders ){
                if ( subject.indexOf(finder) != -1 ){
                    projectName = subject.substring( subject.indexOf(finder) + finder.length() ).trim();   
                    break;  
                }
            }
            //project name logic ends      
        
            Map<String, Contact> expertsMap = new Map<String, Contact>();
            Id expertRecordTypeId = getExpertRecordTypeId();
            String body = email.plainTextBody.replaceAll('  ', ' ').replaceAll('Ridgetop\nConsultant:','Ridgetop Consultant:');
            body.replaceAll('&nbsp;', ' ');
            while ( body.indexOf('  ') != -1 ){
                body = body.replaceAll('  ', ' '); 
            }
            
            body = body.replaceAll('Ridgetop Recruit:', 'Ridgetop Consultant:');

            String[] unformattedBios = body.split('Ridgetop Consultant:\n');

            unformattedBios.remove(0);
            Integer totalBios = unformattedBios.size();
            
            for ( Integer i=0; i<totalBios; i++ ){
                
                String unformattedBio = unformattedBios[i];
                
                System.Debug(LoggingLevel.INFO, 'Ridgetop Bio + Name ' + i + ' :: ' + unformattedBio);
                
                unformattedBio = unformattedBio.substring( unformattedBio.indexOf('Name:') + 5 );
                unformattedBio = startFromAlphabet(unformattedBio);

                String fullName = unformattedBio.substring( 0, unformattedBio.indexOf('\n')).trim();
                Map<String, String> names = getNames(fullName);
                String firstname = names.get('firstname');
                String lastname = names.get('lastname');

                if ( !isValidName(firstname) || !isValidName(lastname) ){
                    
                    throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
                }            

                unformattedBio = unformattedBio.substring( unformattedBio.indexOf('\n') + 1).trim();
                
                System.Debug(LoggingLevel.INFO, 'Ridgetop Bio ' + i + ' :: ' + unformattedBio);
                                           
                if ( i < (totalBios-1) ){

                    Integer bioEndIdx = unformattedBio.lastIndexOf((i+2) + ')');
                    System.Debug(LoggingLevel.INFO, 'Bio End Idx :: ' + bioEndIdx);
                    if ( bioEndIdx != -1){
                        unformattedBio = unformattedBio.substring(0, bioEndIdx).trim();
                    }
                    System.Debug(LoggingLevel.INFO, 'Ridgetop Bio in if :: ' + i + ' :: ' + unformattedBio);
                } else {
                
                    //This will only work if sender is Chris Wallace
                    unformattedBio = unformattedBio.replaceAll('Chris\nWallace', 'Chris Wallace');
                
                    List<String> bioEnds = new List<String>{
                        'This email and the information contained herein is privileged  and confidential',
                        'This message may contain confidential, proprietary or legally privileged',
                        'Chris Wallace\n'
                    };
                    
                    for ( String s : bioEnds ){
                        Integer bioEndIdx = unformattedBio.lastIndexOf(s);
                        System.Debug(LoggingLevel.INFO, 's :: ' + s + ' :: ' + bioEndIdx);
                        if ( bioEndIdx >= 0 ){
                            unformattedBio = unformattedBio.substring(0, bioEndIdx).trim();
                        }
                        System.Debug(LoggingLevel.INFO, 'Ridgetop Bio in else :: ' + i + ' :: ' + unformattedBio);                
                    }                                             
                }
                
                unformattedBio = removeEndBlankLines(unformattedBio);
                            
                Contact ct = new Contact(
                  Firstname = firstname,
                  LastName = lastname,
                  Summary_Bio__c = formatBio(unformattedBio),
                  AccountId = vendorContact.AccountId,
                  RecordTypeId=expertRecordTypeId
                );

                expertsMap.put(firstname+lastname, ct);                     
            }
            upsertBios(expertsMap, analysts, vendorContact, expertRecordTypeId, projectName);
        }
        
        //added by subash on 09/06/2012  
        private void processGuidepointSchedulingEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact){
        
            String body = email.plainTextBody.replaceAll('  ', ' ').trim();
            
            //double check double space to single space conversion
            while ( body.indexOf('  ') >= 0){
        
                body = body.replaceAll('  ', ' ').trim();
            }
            String subject = email.subject;
            
            Id expertRecordTypeId = getExpertRecordTypeId();
                    
            Integer fullNameIdx = body.indexOf('Advisor: ');
            String fullName = body.substring(fullNameIdx + 9, body.indexOf('\n', fullNameIdx + 9)).trim();
            fullName = fullName.replace('(First Consult)', '').trim();
            Map<String, String> names = getNames(fullName);
            String firstName = names.get('firstname');
            String lastname = names.get('lastname');  
            if ( !isValidName(firstname) || !isValidName(lastname) ){
                
                throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
            }
            
            //find bio from scheduling email
            String bioStart = 'Advisor Bio:';
            String bioEnd = 'Please contact me if you have any questions or if you need to re-schedule for any reason';
            
            Integer bioStartIdx = body.indexOf(bioStart);
            Integer bioEndIdx = body.indexOf(bioEnd);
            
            String bio;
            if ( bioStartIdx != -1 && bioEndIdx != -1 ){
                
                bio = body.substring(bioStartIdx + 12, bioEndIdx).trim();  
                bio = startFromAlphabet(bio);            
                bio = removeEndBlankLines(bio);            
            }        
            // end of finding bio
            
            Id expertId = getExpertId(firstname, lastname, bio, vendorContact.AccountId, expertRecordTypeId);
                    
            // Get the date if there is one
            String preCallDate = 'Date: ';
            Integer preCallDateIdx = body.indexOf(preCallDate);
            String dateString = body.substring(preCallDateIdx + preCallDate.length(), body.indexOf('\n', preCallDateIdx + preCallDate.length()+2));

            Date callDateFinal = createDate( dateString);
                    
            upsertCallSchedule(expertId, analysts, vendorContact.AccountId, vendorContact.Id, callDateFinal);         
        }
        
        //added by subash on 08/31/2012
        private void processGuidepointBioEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact) {
        
            String subject = email.subject;    
        
            String projectName;
            if ( subject.contains('Guidepoint Global: ')&& subject.contains(' -') ){
                
                projectName = subject.substring( subject.indexOf('Guidepoint Global: ') + 19).trim();
                projectName = projectName.substring(0, projectName.indexOf(' -')).trim();
            }    
                    
            Map<String, Contact> expertsMap = new Map<String, Contact>();  
            Id expertRecordTypeId = getExpertRecordTypeId();      
                    
            String body = email.plainTextBody.replaceAll('&nbsp;', ' ');
            body = body.replaceAll('  ', ' ').trim();
            //double check double space to single space conversion
            while ( body.indexOf('  ') >= 0){
        
                body = body.replaceAll('  ', ' ').trim();
            }
            
            List<String> unformattedBios = body.split('====================================================================\n');
            if ( !unformattedBios.isEmpty() ) unformattedBios.remove(0);
            
            for ( Integer i=0; i < unformattedBios.size(); i++ ){
            
                String unformattedBio = unformattedBios[i];
                            
                String fullName = unformattedBio.substring(0, unformattedBio.indexOf('\n')).trim();
                fullName = startFromAlphabet(fullName);           
                fullName = fullName.replace( (i+1) + '. ', '').trim();
                fullName = fullName.replace('(First Consult)', '').trim();
                            
                Map<String, String> names = getNames(fullName);
                String firstname = names.get('firstname');
                String lastname = names.get('lastname');
                if ( !isValidName(firstname) || !isValidName(lastname) ){
                    
                    throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
                }            
                
                unformattedBio = unformattedBio.substring(unformattedBio.indexOf('\n')+1);
                if ( i == (unformattedBios.size()-1) ){
                    unformattedBio = unformattedBio.substring(0, unformattedBio.indexOf('------------------------------------------------------------------------')).trim();
                }

                unformattedBio = removeEndBlankLines(unformattedBio);
                
                Contact ct = new Contact(
                  Firstname = firstname,
                  LastName = lastname,
                  Summary_Bio__c = formatBio(unformattedBio),
                  AccountId = vendorContact.AccountId,
                  RecordTypeId=expertRecordTypeId
                );

                expertsMap.put(firstname+lastname, ct);                     
            }
            upsertBios(expertsMap, analysts, vendorContact, expertRecordTypeId, projectName);
        }
        
        //added by subash on 09/04/2012
        //Processes Coleman emails and upserts the scheduling
        private void processColemanSchedulingEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact, Date callDateFromICS){
            
            Id expertRecordTypeId = getExpertRecordTypeId();
            
            String body = convertHtmlToPlainText(email.htmlBody);
            System.dEbug(LoggingLevel.INFO, 'coleman schedule body :: ' + body);
            String fullName = 'Forum Member:';
            Integer fullNameIdx = body.indexOf(fullName);
            System.dEbug(LoggingLevel.INFO, 'Forum Member: ' + fullNameIdx);
            String fullNameFinal = body.substring(fullNameIdx + fullName.length(), body.indexOf('\n', fullNameIdx + 2));
            fullNameFinal = fullNameFinal.trim();
            System.dEbug(LoggingLevel.INFO, 'Coleman Schedule Name :: ' + fullNameFinal);
            Map<String, String> names = getNames(fullNameFinal);
            String firstname = names.get('firstname');
            String lastname = names.get('lastname');
            if ( !isValidName(firstname) || !isValidName(lastname) ){
                
                throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
            }               
            
            Id expertId = getExpertId(firstname, lastname, NULL, vendorContact.AccountId, expertRecordTypeId);
                            
            // Get the date if there is one
            String  preCallDate = 'Date: ';
            Integer preCallDateIdx = body.indexOf(preCallDate);
            Date callDateFinal;
            if (preCallDateIdx != -1){
                String dateString = body.substring(preCallDateIdx + preCallDate.length(), body.indexOf('\n', preCallDateIdx + preCallDate.length()+2)).trim();
                callDateFinal = createDate( dateString);   
            } else if (callDateFromICS != NULL) {
            
                callDateFinal = callDateFromICS;
            }     

            upsertCallSchedule(expertId, analysts, vendorContact.AccountId, vendorContact.Id, callDateFinal); 
        }
        
        //added by subash on 08/31/2012
        private void processColemanBioEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact) {
        
            String subject = email.subject;    
        
            //find the project name to be stored in call
            String projectName;
            List<String> projectNameFinders = new List<String>{
                'CRG Bio: ',   'CRG Bios: '
            };
            for ( String finder : projectNameFinders ){
                if ( subject.indexOf(finder) != -1 ){
                    projectName = subject.substring( subject.indexOf(finder) + finder.length()).trim();   
                    break;  
                }
            }
            //project name logic ends    
                   
            Map<String, Contact> expertsMap = new Map<String, Contact>();
            Id expertRecordTypeId = getExpertRecordTypeId();
            
            //replace with "<span class="SubTitleBold">" in production
            String body = email.htmlBody.replaceAll('<span class="SubTitleBold">', '~-~-~-~-~-');
            body = convertHtmlToPlainText(body);
        
            String totalBiosDelimiter = 'Total Number of Bios:';
            Integer totalBiosIdx = body.indexOf(totalBiosDelimiter);
            Integer totalBios;
            if( totalBiosIdx != -1) {
        
                totalBios = Integer.valueOf( (body.substring(totalBiosIdx+totalBiosDelimiter.length(), body.indexOf('\n',totalBiosIdx))).trim());
            }
            
            //start body from the very next line which starts like "Total Number of Bios:"        
            body = body.substring( body.indexOf('\n', totalBiosIdx) + 1 );
            
            String bioEndDelimiter = '________________________________________________________________________';
            Integer lastBioEndIdx = body.lastIndexOf(bioEndDelimiter);
            
            //terminate the body where last "________________________________________________________________________" is found
            body = body.substring(0, lastBioEndIdx + bioEndDelimiter.length());
            
            List<String> unformattedBios = body.split('~-~-~-~-~-');
            
            System.Debug(LoggingLevel.INFO, 'unformattedBios.size : ' + unformattedBios.size());
            
            List<String> notes = new List<String>();
            if (unformattedBios.size() > 0) notes.add(unformattedBios[0]);
            for ( Integer i=1; i < unformattedBios.size(); i++){
                
                String unformatName;
                String unformattedBio = unformattedBios[i];
                System.debug(LoggingLevel.INFO, 'Unformatted Bio :: ' + i + ' : ' + unformattedBio);

                Integer bioEndIdx = unformattedBio.lastIndexOf(bioEndDelimiter);
                    
                notes.add(unformattedBio.substring(bioEndIdx + bioEndDelimiter.length()));
                unformattedBio = unformattedBio.substring(0, bioEndIdx);
                
                Integer bioStart = unformattedBio.indexOf(i + '. ');                

                if ( bioStart >= 0 ){
                    
                    unformatName = unformattedBio.substring(0, unformattedBio.indexOf('\n\n'));
                    unformattedBio = unformattedBio.substring(unformattedBio.indexOf('\n\n')+2);
                    
                    notes[i-1] = !isBlank(notes[i-1]) ? notes[i-1] : '';
                    unformattedBio = notes[i-1] + unformattedBio;
                } else {
                    throw new EmailHandlerException(EmailHandlerException.PROCESSING_FAILED);
                }           
                                
                unformattedBio = unformattedBio.replaceAll(bioEndDelimiter+'\n', bioEndDelimiter);
                
                unformatName = unformatName.replace('\n', ' ');
                //remove the number from name.
                String fullname = unformatName.replace( String.valueOf(i) + '.', '').trim();
                
                Map<String, String> names = getNames(fullName);
                String firstname = names.get('firstname');
                String lastname = names.get('lastname');
                if ( !isValidName(firstname) || !isValidName(lastname) ){
                    
                    throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
                }
                
                unformattedBio = removeEndBlankLines(unformattedBio);
                unformattedBio = unformattedBio.replaceAll('________________________________________________________________________', '');
                
                Contact ct = new Contact(
                  Firstname = firstname,
                  LastName = lastname,
                  Summary_Bio__c = formatBio(unformattedBio),
                  AccountId = vendorContact.AccountId,
                  RecordTypeId=expertRecordTypeId
                );

                expertsMap.put(firstname+lastname, ct); 
                
                //System.Debug(LoggingLevel.INFO, 'Unformatted Bios :: ' + unformattedBio);
            }
            System.Debug(LoggingLevel.INFO, 'Coleman Bios :: ' + expertsMap.values());

            upsertBios(expertsMap, analysts, vendorContact, expertRecordTypeId, projectName);
        }           

        //added by subash on 08/31/2012
        //Processes Mosaic emails and upserts the scheduling
        private void processMosaicSchedulingEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact, Date callDateFromICS){
            
            Id expertRecordTypeId = getExpertRecordTypeId();
            String body = email.plainTextBody.replaceAll('  ', ' ').trim();
            
            //double check double space to single space conversion
            while ( body.indexOf('  ') >= 0){
        
                body = body.replaceAll('  ', ' ').trim();
            }
            String subject = email.subject;
            
            List<String> subjectItems = subject.split('-');
            
            if ( subjectItems.size() < 3 ){
                throw new EmailHandlerException(EmailHandlerException.MOSAIC_SCHEDULER_SUBJECT_DOUBTFUL);
            }
            
            String unformatName = subjectItems.get(2).trim();
            unformatName = startFromAlphabet(unformatName);
            Integer atIndex = unformatName.indexOf('@');
            String fullName = ( atIndex >= 0) ? unformatName.substring(0, atIndex).trim() : unformatName;
            
            Map<String, String> names = getNames(fullName);
            String firstname = names.get('firstname');
            String lastname = names.get('lastname');
            if ( !isValidName(firstname) || !isValidName(lastname) ){
                
                throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
            }        
             
            Id expertId = getExpertId(firstname, lastname, NULL, vendorContact.AccountId, expertRecordTypeId);
                           
            // Get the date if there is one        
            String preCallDate = 'When: ';
            Date callDateFinal;
            Integer callMonth;
            Integer preCallDateIdx = body.indexOf(preCallDate);
            if (callDateFromICS != NULL) {
            
                callDateFinal = callDateFromICS;
            } else if (preCallDateIdx != -1){
                
                String dateString = body.substring(preCallDateIdx + preCallDate.length(), body.indexOf('\n', preCallDateIdx + preCallDate.length()+2)).trim();
                callDateFinal = createDate( dateString);
            }    

            upsertCallSchedule(expertId, analysts, vendorContact.AccountId, vendorContact.Id, callDateFinal); 
        }
        
        //added by subash on 08/30/2012
        //Processes Mosaic bio emails and upserts the experts
        private void processMosaicBioEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact){
        
            String subject = email.subject;  
        
            String projectName;
            if ( subject.contains(' - New Contact' ) ){
                projectName = subject.substring(0, subject.indexOf(' - New Contact')).trim();
            }    

            Map<String,Contact> expertsMap = new Map<String,Contact>();
            Id expertRecordTypeId = getExpertRecordTypeId();

            //replace <hr> tags with ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-  for smooth parsing      
            String body = replaceHrTagWithLine(email.htmlBody); 
            //strip off all the html tags to make it a plain text
            body = convertHtmlToPlainText(body);
            
            System.Debug(LoggingLevel.INFO, 'after conversion :: ' + body);
            
            List<String> unformattedBios = body.split('~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-');
        
            for(Integer i=1; i<unformattedBios.size(); i++ ) {
                
                String unformattedBio = unformattedBios[i].trim();
                
                if( i == unformattedBios.size()-1 ) {

                    Integer findEndIdx = unformattedBio.indexOf('Last Compliance T&C Signed:');
                    findEndIdx = unformattedBio.indexOf('\n',findEndIdx);
                    
                    if ( findEndIdx != -1 ){
                        unformattedBio = unformattedBio.subString(0, findEndIdx);
                    }
                }

                unformattedBio = startFromAlphabet(unformattedBio);   

                String fullName = unformattedBio.substring(0,unformattedBio.indexOf('\n')).trim();
                
                Map<String, String> names = getNames(fullname);
                String firstname = names.get('firstname');
                String lastname = names.get('lastname');
                if ( !isValidName(firstname) || !isValidName(lastname) ){
                    
                    throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);
                }            
                
                String formattedBio = unformattedBio.subString(fullName.length(),unformattedBio.length()).trim();

                formattedBio = startFromAlphabet(formattedBio);           
                
                Contact ct = new Contact(
                  Firstname = firstname,
                  LastName = lastname,
                  Summary_Bio__c = formatBio(formattedBio),
                  AccountId = vendorContact.AccountId,
                  RecordTypeId=expertRecordTypeId
                );

                expertsMap.put(firstname+lastname, ct);
            }
            
            System.Debug(LoggingLevel.INFO, 'Mosaic Bio ::: ' + expertsMap.values());
            
            upsertBios(expertsMap, analysts, vendorContact, expertRecordTypeId, projectName);
        }
        
        //added by subash on 08/23/2012
        //Processes GLG emails and upserts the scheduling
        private void processGLGSchedulingEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact){
            
            Id expertRecordTypeId = getExpertRecordTypeId();
            
            String body = email.plainTextBody.replaceAll('  ', ' ').trim();
            
            //double check double space to single space conversion
            while ( body.indexOf('  ') >= 0){
        
                body = body.replaceAll('  ', ' ').trim();
            }
            String subject = email.subject;
            
            Integer fullNameIdx = subject.indexOf('(');
            String fullName = subject.substring(fullNameIdx + 1, subject.indexOf(')', fullNameIdx + 1 )).trim();
            Map<String, String> names = getNames(fullname);
            String firstName = names.get('firstname');
            String lastName = names.get('lastname');
            if ( !isValidName(firstname) || !isValidName(lastname) ){
                throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);    
            }         
            
            Id expertId = getExpertId(firstname, lastname, NULL, vendorContact.AccountId, expertRecordTypeId);
            
            String preCallDate = 'When: ';
            Integer preCallDateIdx = body.indexOf(preCallDate);
            String dateString = body.substring(preCallDateIdx + preCallDate.length(), body.indexOf('\n', preCallDateIdx + preCallDate.length()+2)).trim();
            Date callDateFinal = createDate( dateString);        
            
            upsertCallSchedule(expertId, analysts, vendorContact.AccountId, vendorContact.Id, callDateFinal); 
        }
        
        //added by subash on 08/22/2012
        //Processes GLG emails and upserts the experts
        private void processGLGBioEmail(Messaging.InboundEmail email, List<String> analysts, Contact vendorContact){
        
            String subject = email.subject;
        
            String projectName;
            //find the project name to be stored in call
            List<String> projectNameFinders = new List<String>{
                'Council Member Available - ',   'Council Members Available - ',  'Available on ' 
            };
            for ( String finder : projectNameFinders ){
                if ( subject.indexOf(finder) != -1 ){
                    projectName = subject.substring( subject.indexOf(finder) + finder.length()).trim();   
                    break;  
                }
            }
            //project name logic ends    

            Map<String, Contact> expertsMap = new Map<String, Contact>();
            Id expertRecordTypeId = getExpertRecordTypeId();
            
            //List of alternative phrases which can be considered as the beginning of bios
            //Should be list rather than set as order is important
            List<String> bioStartStrings = new List<String>{
                'As a Fir Tree employee, you are required to remind the Consultant at the outset of the consultation not to discuss any topics on which they believe they hold confidential information. Please contact the Fir Tree Chief Compliance Officer with any questions or concerns.',
                'All projects are subject to GLG\'s compliance policies. Find more information in our Compliance Guide and Usage Policies .'
            };
            
            //convert all double spaces to single spaces
            String body = email.htmlBody.replaceAll('&nbsp;', ' ');
            body = body.replaceAll('\r\n','');
            body = body.replaceAll('\n', '');
            body = body.replaceAll('<br>','\n');
            body = body.replaceAll('</p>','\n');
            body = body.replaceAll('</div>','\n');
            
            Pattern htmlPattern = Pattern.compile('<.*?>');
            Matcher htmlMatcher = htmlPattern.Matcher(body);
            body = htmlMatcher.replaceAll('');
            
            
            body = body.replaceAll('\t', ' ');
            
            while ( body.indexOf('  ') != -1 ){
                
                body = body.replaceAll('  ', ' ');
            }
            
            while ( body.indexOf('\n ') != -1 ){
            
                body = body.replaceAll('\n ', '\n');
            }        
            
            body = body.replaceAll('  ', ' ').trim();
            //double check double space to single space conversion
            while ( body.indexOf('  ') >= 0){
                body = body.replaceAll('  ', ' ').trim();
            }
            
            //Check for the bio start delimiters in order and throw exception if nothing is found
            Boolean bioStartDelimiterFound = FALSE;
            for ( Integer i=0; i < bioStartStrings.size(); i++ ){
                
                Integer startIdx = body.toUpperCase().indexOf(bioStartStrings[i].toUpperCase());
                if ( startIdx >= 0 ){
                    body = body.substring(startIdx + bioStartStrings[i].length()).trim();
                    bioStartDelimiterFound = TRUE;
                    break;
                }
            }
            if ( !bioStartDelimiterFound ){
                throw new EmailHandlerException(EmailHandlerException.MISSING_START_DELIMITER);  
            }
            //end of bio start delimiter check
            
            //Remove all characters and reach the first alphabet. That will be start of name
            body = startFromAlphabet(body);
            
            //as all GLG bios contain a back to top link, use that as end of each bio section
            List<String> unformattedBios = body.split('Back to top');
            
            //last array element will be reminder of email which will not be a bio
            //so loop through all elements except the last one and format it
            for (Integer i=0; i < unformattedBios.size()-1; i++ ){
                
                String unformattedBio = unformattedBios[i].trim();
                
                //Remove all characters and reach the first alphabet. That will be start of name
                unformattedBio = startFromAlphabet(unformattedBio);
               
                Integer newlineIdx = unformattedBio.indexOf('\n');
                String formattedBio;
                String emailPhone;                        
                String firstname, lastname;
                if ( newlineIdx != -1 ){ 
                    
                    //Start finding the name of expert and throw exception if name is not found
                    String fullname = unformattedBio.substring(0, newlineIdx + 1);
                    Integer sqBracketIdx = fullname.indexOf('[');
                    fullName = (sqBracketIdx != -1) ? fullname.substring(0, sqBracketIdx).trim() : fullname.trim();                
                    Map<String, String> names = getNames(fullName);
                    firstname = names.get('firstname');
                    lastname = names.get('lastname');
                    if ( !isValidName(firstname) || !isValidName(lastname) ){
                        throw new EmailHandlerException(EmailHandlerException.SUSPECTED_NAME);    
                    } 
                    
                    //start finding the bio and throw exception if end of bio cannot be found
                    List<String> bioEndDelimiters = new List<String>{
                        'HourlbioEndDelimiter:', 'Email:', 'In accordance with your firm\'s pre-set preferences'
                    };                
                    unformattedBio = unformattedBio.substring(newlineIdx).trim();
                    
                    //Check for the bio end delimiters in order and throw exception if nothing is found;
                    Boolean bioEndDelimiterFound = FALSE;
                    for ( Integer j=0; j < bioEndDelimiters.size(); j++ ){
                        
                        Integer bioEndIdx = unformattedBio.lastIndexOf(bioEndDelimiters[j]);
                        if ( bioEndIdx >= 0 ){
                            formattedBio = unformattedBio.substring(0, bioEndIdx).trim();
                            emailPhone = unformattedBio.substring(bioEndIdx).trim();
                            bioEndDelimiterFound = TRUE;
                            break;
                        }
                    }
                    if ( !bioEndDelimiterFound ){
                        throw new EmailHandlerException(EmailHandlerException.MISSING_BIO_END_DELIMITER);  
                    }
                    //end of bio end delimiter check                
                }
                Integer emailIdx = emailPhone.indexOf('Email:');
                String expertEmail;
                if (emailIdx != -1){
                    expertEmail = emailPhone.substring(emailIdx + 6, emailPhone.indexOf('Phone:', emailIdx + 6));
                    expertEmail = expertEmail.replace(' ','').trim();
                } 
                
                Integer phoneNumberIdx = emailPhone.indexOf('Phone:');
                String phoneNumber;
                if (phoneNumberIdx != -1){
                    System.Debug(LoggingLevel.INFO, 'emailPhone ::: ' + emailPhone);
                    phoneNumber = emailPhone.substring(phoneNumberIdx + 6, emailPhone.indexOf('\n', phoneNumberIdx + 6));
                    phoneNumber = phoneNumber.replace(' ','').trim();
                }
               
                Contact ct = new Contact(
                  Firstname = firstname,
                  LastName = lastname,
                  Phone = phoneNumber,
                  Email = expertEmail,
                  Summary_Bio__c = formatBio(formattedBio),
                  AccountId = vendorContact.AccountId,
                  RecordTypeId=expertRecordTypeId
                );

                expertsMap.put(firstname+lastname, ct);
            }
            
            //Insert or update the bios
            upsertBios(expertsMap, analysts, vendorContact, expertRecordTypeId, projectName);
        }     
                        
        private Date createDate(String dateString){
        
            String[] dtElements = dateString.replaceAll(',', '').replaceAll('  ', ' ').split(' ');
            System.Debug(LoggingLevel.INFO, 'Date Elements :: ' + dtElements);

            String callYear = dtElements[3].trim();
            while (callYear.startsWith('0')){ 
                callYear = callYear.substring(1).trim();
            }            
            String callMonth = dtElements[1].trim();
            while (callMonth.startsWith('0')){ 
                callMonth = callMonth.substring(1).trim();
            }        
            String callDay = dtElements[2].trim();
            while (callDay.startsWith('0')){ 
                callDay = callDay.substring(1).trim();
            }
            return Date.newInstance(Integer.valueOf(callYear), getMonthVal(callMonth), Integer.valueOf(callDay));    
        }   
      
        //added by Subash as suggested by Tad on 09/12/2012 to optimize code
        private Id getExpertId(String firstname, String lastname, String bio, Id accountId, Id expertRecordTypeId){
            
            List<Contact> experts = [
                SELECT Id, Firstname, Lastname, AccountId FROM Contact
                WHERE 
                    Firstname = :firstname AND Lastname = :lastname AND AccountId = :accountId
                    AND RecordTypeId = :expertRecordTypeId
            ];
            
            Id expertId;
            if ( experts.size() > 1 ){
                throw new EmailHandlerException(EmailHandlerException.DUPLICATE_EXPERTS_FOUND);
            } else if ( experts.size() == 1 ){
               expertId = experts[0].Id;     
            } else {
                Contact newExpert = new Contact(
                  Firstname = firstname,
                  LastName = lastname,
                  AccountId = accountId,
                  Summary_Bio__c = formatBio(bio),
                  RecordTypeId=expertRecordTypeId
                );
                insert newExpert;
                expertId = newExpert.Id;
            }   
            return expertId; 
        }
        
        //added by Subash as suggested by Tad on 09/12/2012 to optimize code
        private void upsertCallSchedule(Id expertId, List<String> analysts, Id accountId, Id vendorContactId, Date callDate){
        
            Calls__c[] openCallsWithExpert = [
                SELECT Id, Expert__c, Vendor__c, Analyst__c, Status__c
                FROM Calls__c 
                WHERE Expert__c = :expertId AND Vendor__c = :accountId AND 
                    Status__c IN ( 'Analyst Review', 'Scheduling', 'Scheduled' ) 
                    AND (Analyst__c IN :analysts OR Analyst_2__c IN :analysts)
                    
            ];
            
            Calls__c openCallWithExpert;
            if ( openCallsWithExpert.size() > 0 ){
            
                openCallWithExpert =  openCallsWithExpert[0];
                openCallWithExpert.Status__c = 'Scheduled';
                openCallWithExpert.Call_Date__c = callDate;               
            } else {
            
                openCallWithExpert = new Calls__c(
                    Analyst__c = analysts[0], Analyst_2__c = analysts[1],
                    Expert__c = expertId, Status__c = 'Scheduled',
                    Vendor__c = accountId,Scheduler__c = vendorContactId,
                    Call_Date__c = callDate
                ); 
            }

            if ( openCallWithExpert != NULL ){
                
                upsert openCallWithExpert;
            } else {
                throw new EmailHandlerException(EmailHandlerException.PROCESSING_FAILED);
            }   
        } 
       
        private void upsertBios(Map<String,Contact> expertsMap, List<String> analysts, Contact vendorContact, Id expertRecordTypeId, String projectName){
            
            if (expertsMap.size()>0){
            
                Set<String> expertNames = expertsMap.keySet();
                
                List<Contact> contacts = [
                  SELECT Id, Firstname, Lastname, AccountId, Summary_Bio__c, Expert_DeDuplicator__c FROM Contact 
                  WHERE 
                      AccountId = :vendorContact.AccountId AND RecordTypeId = :expertRecordTypeId 
                      AND Expert_DeDuplicator__c IN :expertNames
                      
                ];
              
                for (Contact c : contacts){

                    Contact updateContact = expertsMap.get(c.Firstname+c.Lastname);
                    
                    updateContact.Summary_Bio__c = formatBio(updateContact.Summary_Bio__c);
                    
                    updateContact = new Contact(
                        Id=c.Id, Firstname = updateContact.Firstname, Lastname = updateContact.Lastname,
                        Phone = updateContact.Phone, Email = updateContact.Email,
                        Summary_Bio__c = c.Summary_Bio__c + '\n\n-------------- Updated on ' + System.Now().format('MM/dd/yyyy') + ' --------------\n\n' + updateContact.Summary_Bio__c
                    );
                    expertsMap.put(c.Firstname+c.Lastname, updateContact);
                    expertNames.remove(c.Firstname+c.Lastname);
                }
                upsert expertsMap.values();
                
                List<Calls__c> insertCalls = new List<Calls__c>();

                for ( String expertName : expertNames ){
                    Calls__c call = new Calls__c(
                        Analyst__c = analysts[0], Analyst_2__c = analysts[1],
                        Expert__c = expertsMap.get(expertName).Id, Status__c = 'Analyst Review',
                        Vendor__c = vendorContact.AccountId,Scheduler__c = vendorContact.Id,
                        Project_Name__c = projectName
                    );
                    insertCalls.add(call);        
                }
                insert insertCalls;
            }
            //to do - nice to have - send an email with details of bios created/updated.
        }             
          
        //added by Subash on 08/20/2012
        //This method returns month value, if a month name is found in a string
        private Integer getMonthVal(String month){
        
            if ( month == NULL ) return NULL;
        
            String monthUC = month.toUpperCase(); //Convert input to upper case
            Integer monthVal; //month value to be returned
            
            Map<String, Integer> months = new Map<String, Integer>{
                'JANUARY' => 1, 'FEBRUARY' => 2, 'MARCH' => 3, 'APRIL' => 4, 'MAY' => 5, 'JUNE' => 6,
                'JULY' => 7, 'AUGUST' => 8, 'SEPTEMBER' => 9, 'OCTOBER' => 10, 'NOVEMBER' => 11, 'DECEMBER' => 12
            };
            
            for ( String monthName : months.keySet() ){
        
                if(monthUC.contains(monthName)){
                    
                    monthVal = months.get(monthName);
                    break;
                }
            }
            
            return monthVal;
        }   
        
        public static Boolean isAlphabet(String character){
            return (character >= 'A' && character <= 'Z') || (character >= 'a' && character <= 'z');
        }
        
        public static String startFromAlphabet(String unformattedString){
            
            String formattedString = unformattedString;
            while ( !isAlphabet(formattedString.substring(0,1)) ){
                formattedString = formattedString.substring(1).trim();
            }
            return formattedString;     
        }
        
        public static String removeEndBlankLines(String unformattedString){
        
            String formattedString = unformattedString;
            while ( formattedString.lastIndexOf('\n') == (formattedString.length()-1) || formattedString.lastIndexOf(' ') == (formattedString.length()-1) ){
                formattedString = formattedString.substring(0, formattedString.length()-1).trim();
            }
            return formattedString;
        }

        public Boolean isValidName(String name){
        
            System.Debug(LoggingLevel.INFO, 'xxx=' + name + 'yyy');
        
            if ( isBlank(name) ) return false;
            String regex = '[a-zA-Z\\.\\s]*?';
            Pattern ptn = Pattern.compile(regex);
            Matcher match = ptn.matcher(name);
            
            return match.matches();
        }
        
        public static Map<String, String> getNames(String inputFullName){
        
            String fullName = inputFullName.replace('Mr.', '').trim();
            fullName = fullName.replace('Mrs.', '').trim();
            fullName = fullName.replace('Ms.', '').trim();
            fullName = fullName.replace('Dr.', '').trim();
            
            while ( !isAlphabet(fullName.substring(fullName.length()-1)) ){
                fullName = fullName.substring(0, fullName.length()-1);
            }
            
            fullName = startFromAlphabet(fullName);      
        
            String firstname, lastname;
            Integer lastnameIdx = fullName.indexOf(' ');
            if ( lastnameIdx != -1){
                
                firstname = fullName.substring(0, lastnameIdx).trim();
                lastname = fullName.substring(lastnameIdx+1).trim();
            } else {
                firstname = fullName;
                lastname = NULL;
            } 
            return new Map<String, String>{'firstname' => firstname, 'lastname' => lastname}; 
        }
        
        public static Boolean isBlank(String input){
            
            return ( input == NULL || input.trim() == '' );
        }
        
        private static Id getExpertRecordTypeId(){
        
            return [SELECT Id FROM RecordType WHERE DeveloperName='Expert' AND SObjectType = 'Contact' LIMIT 1].Id;
        }  
        
        private String formatBio(String unformattedBio){
            
            String bio = unformattedBio;
            
            if ( !isBlank(bio) ){
                bio = unformattedBio.trim();
                bio = bio.replaceAll('&nbsp;', ' ');
                bio = bio.replaceAll('&amp;', '&');
                bio = bio.replaceAll('\t', ' ');        
                
                while ( bio.substring(bio.length()-1) == '\n' ){
                    bio = bio.substring(0, bio.length()-1);
                }

                bio = startFromAlphabet(bio);
                
                while ( bio.indexOf('  ') != -1 ){
                    bio = bio.replaceAll('  ', ' ');
                }
            }
              
            return bio;
        }  
        
        //added by subash on 09/13/2012 to place ICS parsing code in a method
        private Date getCallDateFromICS(Messaging.InboundEmail email){
        
            //Check if there exists a meeting invite which will tell if it is a scheduler email
            String attachmentContent;
            
            if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
              for (integer i = 0 ; i < email.binaryAttachments.size(); i++) {
                System.Debug(LoggingLevel.INFO, 'Attachment Name :: ' + email.binaryAttachments[i].filename.toUpperCase());
                if ( email.binaryAttachments[i].filename.toUpperCase().endsWith('.ICS') || email.binaryAttachments[i].mimeTypeSubType.equalsIgnoreCase('text/calendar') ){
                    attachmentContent = email.binaryAttachments[i].body.toString();
                    break;
                }
              }
            }
            if ( attachmentContent == NULL ){
            
                if (email.textAttachments != null && email.textAttachments.size() > 0) {
                
                  for (integer i = 0 ; i < email.textAttachments.size(); i++) {
                    
                    if ( email.textAttachments[i].filename.toUpperCase().endsWith('.ICS') || email.textAttachments[i].mimeTypeSubType.equalsIgnoreCase('text/calendar') ){
                        attachmentContent = email.textAttachments[i].body;
                        break;
                    }
                  }
                }   
            }
            
            System.Debug(LoggingLevel.INFO, 'Binary Attachments:: ' + email.binaryAttachments);
            System.Debug(LoggingLevel.INFO, 'Text Attachments:: ' + email.textAttachments);
            System.Debug(LoggingLevel.INFO, 'Attachment Content :: ' + attachmentContent);
            
            Date callDateFromFile;
            if ( attachmentContent != NULL ){
                System.Debug(LoggingLevel.INFO, 'attachment content :: ' + attachmentContent );
                Integer dtStartIdx = attachmentContent.lastIndexOf('DTSTART');
                String dtStartLine = attachmentContent.substring(dtStartIdx, attachmentContent.indexOf('\n', dtStartIdx+1) );
                String[] dtstartElements = dtStartLine.split(':');
                String callDate = dtstartElements[dtstartElements.size()-1];
                System.Debug(LoggingLevel.INFO, 'Call Date String :: ' + callDate);
                callDateFromFile = Date.newInstance(Integer.valueOf(callDate.substring(0,4)), Integer.valueOf(callDate.substring(4,6)), Integer.valueOf(callDate.substring(6,8)));
            }
            return callDateFromFile;
        }  
        
        public static Boolean containsHrTag(String stWithHr){
                   
            if ( isBlank(stWithHr) ) return false;
            return stWithHr.contains('<hr');
        }     
        
        public static String replaceHrTagWithLine(String stWithHr){
            
            String tempInput = stWithHr;
            
            if ( isBlank(tempInput) ) return tempInput;
            
            Pattern htmlPattern = Pattern.compile('<hr.*?>');
            Matcher htmlMatcher = htmlPattern.Matcher(tempInput);
            tempInput = htmlMatcher.replaceAll('~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-');
            return tempInput;
        }
        
        public static String replaceBrTagWithNewLine(String stWithBr){
            
            String tempInput = stWithBr;
            
            if ( isBlank(tempInput) ) return tempInput;
            
            system.debug('::::tempInput:::'+tempInput);
            Pattern htmlPattern = Pattern.compile('<br.*?>');
            Matcher htmlMatcher = htmlPattern.Matcher(tempInput);
            tempInput = htmlMatcher.replaceAll('\n');
            system.debug('::::tempInput:::'+tempInput);
            tempInput = tempInput.replaceAll('<br>','\n');
            system.debug('::::tempInput:::'+tempInput); 
            
            return tempInput;
        }
        public static String removeHtmlTags(String body){
            
            if ( isBlank(body)) return body;
            
            Pattern htmlPattern = Pattern.compile('<.*?>');
            Matcher htmlMatcher = htmlPattern.Matcher(body);
            return  htmlMatcher.replaceAll('');     
        }
        
        public static String convertHtmlToPlainText(String htmlText){
            
            String body = htmlText.replaceAll('&nbsp;', ' ');
            body = body.replaceAll('&amp;', '&');
            body = body.replaceAll('\r\n','');
            body = body.replaceAll('\n', '');
            body = body.replaceAll('\t', ' ');
            body = replaceBrTagWithNewLine(body);
            body = body.replaceAll('</p>','\n');
            body = body.replaceAll('</div>','\n');
            body = removeHtmlTags(body);
            
            while ( body.indexOf('  ') != -1 ){
                
                body = body.replaceAll('  ', ' ');
            }
            
            while ( body.indexOf('\n ') != -1 ){
            
                body = body.replaceAll('\n ', '\n');
            }        
            
            while ( body.indexOf('  ') >= 0){
                body = body.replaceAll('  ', ' ').trim();
            }
            String body='';
            return body.trim();     
        }*/
    }