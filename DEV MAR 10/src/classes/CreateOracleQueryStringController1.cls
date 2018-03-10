/* Algorithm
    1.Get the sf object API name and  get description of all fields in object through Schema.DescribrFieldResult
        and sort fieldName alphapetical order .and some standard fields (It is comman to all object)
       already   added to list.That object remaining Standard and custom fields get from DescribeResult
       sort them added to same standardfield list.
    2.sfOracleDataTypeMap created in Constructor for map sf and Oracle datatype
    3.Inner class variables for assign some field of  description result values (Like length,Scale,precision)assign to inner class variables .Then put to map like 
        (fieldname,innerclass instance) here inner class instance have SObject field description result of some information .
    4. finallay Iterate the List the access the inner class using the field name( Map name :sfFieldDescriptionMap ) then make querystring
    5.finally it displays the output text 
        
     */
            
public class CreateOracleQueryStringController1 {

    public String selectedObject{get;set;}    // For StosfobjectsQueryStringListre selected sf Object name
    
    Public String finalQueryString {get;set;}   // Strore Final result of  querystring
    //Map<String,Schema.DescribeFieldResult> SfFieldNameFieldDescribeMap= new Map<String,Schema.DescribeFieldResult>();
    Map<String,String> sfOracleDataTypeMap;
    Map<String,String> sfObjectFieldDataTypeMap = new Map<String,String>();
    List<String> sfObjectDefaultStandardFieldList ;
    Map<String,SObjectDescribeFieldResult > sfFieldDescriptionMap = new Map<String,SObjectDescribeFieldResult>(); 
    List<String> sfObjectCustomFieldsList = new List<String>();
    List<String> sfObjectStandardFieldsList = new List<String>();
    Map<String,String> sfobjectNameQueryStringMap= new Map<String,String>();  
    List<String> sfObjectsList = new List<String>();
    List<String> sfObjectAllFieldList = new List<String>();
    List<String> sfObjectsTrimList = new List<String>();
    
    public List<Oracle > oracleQueryStringList{get;set;}
    
    // Inner class for store some Sobject field description result
    Public Class SObjectDescribeFieldResult {
    
        Public Integer precision;   
        Public Integer scale;
        Public Integer length;
        Public Integer digit; 
    }
    public Class Oracle {
    
        Public String sfObjectName{get;set;}
        Public String sfObjectOraclequeryString {get;set;}
        
    }
    public CreateOracleQueryStringController1 () {
    
        // Salesforce Oracle datatype map
        oracleQueryStringList= new List<Oracle>();
        sfOracleDataTypeMap = new Map<String, String>{
            'BOOLEAN' => 'varchar2',
            'DATE' => 'date',
            'DATETIME' => 'date',
            'CURRENCY' => 'number',
            'DOUBLE' => 'number',
            'INTEGER' => 'number',
            'PICKLIST' =>'varchar2',
            'ID' => 'varchar2',
            'REFERENCE' => 'varchar2',
            'TEXTAREA' => 'varchar2',
            'EMAIL' => 'varchar2',
            'PHONE' => 'varchar2',
            'URL' => 'varchar2',
            'MULTIPICLIST' => 'varchar2',
            'ANYTYPE' => 'varchar2',
            'PERCENT' => 'number',
            'COMBOBOX' => 'varchar2',
            'BASE64' => 'varchar2',
            'TIME' => 'varchar2',
            'STRING' => 'varchar2'
        };
        sfObjectDefaultStandardFieldList = new List<String>{
            'Id',
            'OwnerId', 
            'IsDeleted', 
            'Name',
            'RecordTypeId', 
            'CreatedDate', 
            'CreatedById',
            'LastModifiedDate',
            'LastModifiedById'
        };
    }  
    public pageReference submit() {
        
        String currentOracleDataType;
        if( !oracleQueryStringList.isEmpty() ) { 
        
              oracleQueryStringList.clear();    
        }
        if( !sfObjectsTrimList.isEmpty() ) {     
        
            sfObjectsTrimList.clear();    
        }
        if( !sfObjectsList.isEmpty() ) {
        
           sfObjectsList.clear(); 
        }
      
       if( selectedObject != '' )  {       //  If given input is not null the loop will be executed
        
            sfObjectsTrimList = (selectedObject.split(','));  
            for( String s : sfObjectsTrimList ) { 
            
                if( s.trim() != '') {             // trim function used to splited string
                    sfObjectsList.add( s.trim());
                }
            }    
          
        
            for( String sfObjectListObj : sfObjectsList ) {   // Given input is splited into strings of SObject api name the add to list 
            
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                if( schemaMap.containsKey(sfObjectListObj) == true ) {
                
                    DescribeSObjectResult res= schemaMap.get(sfObjectListObj).getDescribe();
                    System.Debug(':::::schemaMap' +schemaMap );
                    Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sfObjectListObj).getDescribe().fields.getMap();
                    
                    Integer x = 0;
                    
                    for(Schema.SObjectField field : fieldMap .values()) {   // SObjects fields  iterated by fieldMap values
                        
                        Schema.DescribeFieldResult sdr = field.getDescribe();  // Here each field description get by getDescribe() method 
                        String fieldDataType = String.valueOf(sdr.getType());
                        System.Debug(' yyyy ' + (++x) + ' ::: ' + field + ' ~~~~~ ' + fieldDataType ) ;                   //currentOracleDataType = sfOracleDataTypeMap.get(fieldDataType)
                        sfObjectFieldDataTypeMap.put(sdr.getName(), fieldDataType );         // Fieldname  and its Datatype put to map          
                        System.Debug(':::sfObjectFieldDataTypeMap::::' +sfObjectFieldDataTypeMap);
                        //if any one field datatype is like below then create inner class
                        //  and its some description assign to inner class variables
                                
                        if ( fieldDataType == 'CURRENCY' || fieldDataType == 'NUMBER' || fieldDataType == 'PERCENT' || fieldDataType == 'DOUBLE') {
                        
                            SObjectDescribeFieldResult sObjectDesFieldResObj = new SObjectDescribeFieldResult ();
                            sObjectDesFieldResObj.length = null;
                            sObjectDesFieldResObj.digit = NULL;
                            sObjectDesFieldResObj.scale =  sdr.getScale(); 
                            sObjectDesFieldResObj.precision = sdr.getPrecision(); 
                            sfFieldDescriptionMap.put(String.valueOf(sdr.getName()),sObjectDesFieldResObj); 
                         }
                         else if ( fieldDataType == 'String' || fieldDataType == 'TEXTAREA' || fieldDataType == 'PHONE' ||fieldDataType == 'URL' || fieldDataType == 'EMAIL'
                                || fieldDataType == 'REFERENCE'|| fieldDataType == 'PICKLIST' || fieldDataType == 'ID' 
                                || fieldDataType == 'MULTIPICKLIST' || fieldDataType == 'ANYTYPE' || fieldDataType == 'COMBOBOX'
                                || fieldDataType == 'BASE64' || fieldDataType == 'TIME') {
                                
                            SObjectDescribeFieldResult sObjectDesFieldResObj = new SObjectDescribeFieldResult();    // Inner class instance is created and field some description
                                sObjectDesFieldResObj.length = sdr.getLength();                                            // fields assign to inner class variables
                                sObjectDesFieldResObj.digit = NULL;  
                            sObjectDesFieldResObj.scale =  null; 
                            sObjectDesFieldResObj.precision = null; 
                            sfFieldDescriptionMap.put(String.valueOf(sdr.getName()),sObjectDesFieldResObj);
                                 
                        } else if ( fieldDataType == 'INTEGER') { 
                        
                            SObjectDescribeFieldResult sObjectDesFieldResObj = new SObjectDescribeFieldResult();
                            sObjectDesFieldResObj.length = NULL;
                            sObjectDesFieldResObj.digit = sdr.getDigits();
                            sObjectDesFieldResObj.scale =  null; 
                            sObjectDesFieldResObj.precision = null; 
                            sfFieldDescriptionMap.put(String.valueOf(sdr.getName()),sObjectDesFieldResObj);    
                        }  
                        if( sdr.isCustom() == true ) {
                         
                           sfObjectCustomFieldsList.add(String.ValueOf(sdr.getName()));   // here custom fields added to list
                        } else {
                        
                            boolean availble = false;     //  Standardfields added to this list                                         
                            for( integer i = 0; sfObjectDefaultStandardFieldList.size()>i ; i++ ) {
                            
                                if( sfObjectDefaultStandardFieldList[i] == String.ValueOf(sdr.getName())) {
                                   availble = true ;
                                }  
                            }      
                            if ( availble == false ) {      // if it is not already available then added to list   
                            
                                sfObjectStandardFieldsList.add(String.ValueOf(sdr.getName()));
                                   
                            }
                        }
                    }    
                     
                    sfObjectCustomFieldsList.sort();       // sfObjectCustomFieldsList is sorted for alphapetical order
                    sfObjectStandardFieldsList.sort();     // sfObjectStandardFieldsList is sorted for alphapetical order
                    sfObjectAllFieldList.addAll(sfObjectDefaultStandardFieldList);
                    sfObjectAllFieldList.addAll(sfObjectStandardFieldsList);
                    sfObjectAllFieldList.addAll(sfObjectCustomFieldsList);
                    System.Debug(':::sfObjectStandardFieldsList :::'+ sfObjectStandardFieldsList);
                     
                     for( String s : sfObjectAllFieldList ) {  // Iterate each field for making querystring
                     
                         if( sfObjectFieldDataTypeMap.ContainsKey(s) == true ) {
                         
                             SObjectDescribeFieldResult SObjDesFieResObject;
                             String fieldDataType = sfObjectFieldDataTypeMap.get(s);
                              
                             if ( sfFieldDescriptionMap.containsKey(s) == true ) {
                             
                                  SObjDesFieResObject= sfFieldDescriptionMap.get(s);
                                  System.Debug(':::SObjDesFieResObject:::'+SObjDesFieResObject);
                             }    
                             System.Debug('::::Fields:::'+ s);
                             
                             
                             
                             // If the field datatype like the following types querystring make like this
                             
                             if( fieldDataType == 'CURRENCY' || fieldDataType == 'NUMBER' || fieldDataType == 'PERCENT' || fieldDataType == 'DOUBLE') {
                             
                                 finalQueryString += '\n\t' + s + ' ' +sfOracleDataTypeMap.get(sfObjectFieldDataTypeMap.get(s))+'(' + (SObjDesFieResObject.precision - SObjDesFieResObject.scale )+ ',' + SObjDesFieResObject.scale + ')' + ',';
                                 System.Debug(':::currency fields :::'+s);
                                 
                              }
                              else if ( fieldDataType == 'STRING'|| fieldDataType == 'TEXTAREA' 
                                           || fieldDataType == 'PHONE' ||fieldDataType == 'URL' || fieldDataType == 'EMAIL'
                                           || fieldDataType == 'REFERENCE'|| fieldDataType == 'PICKLIST' || fieldDataType == 'ID'
                                           || fieldDataType == 'MULTIPICKLIST' || fieldDataType == 'ANYTYPE' || fieldDataType == 'COMBOBOX'
                                           || fieldDataType == 'BASE64' || fieldDataType == 'TIME' ) {
                                           
                                  System.Debug(':::String fields :::'+s);
                                  finalQueryString += '\n\t' + s + ' ' +sfOracleDataTypeMap.get(sfObjectFieldDataTypeMap.get(s))+'(' + SObjDesFieResObject.length + ')' + ',';
                                  
                              }else if ( fieldDataType == 'INTEGER' ) {   // If datatype is integer the make querystring like this
                              
                                  finalQueryString += '\n\t' + s + ' ' +sfOracleDataTypeMap.get(sfObjectFieldDataTypeMap.get(s))+'(' +  SObjDesFieResObject.digit + ')' + ',';   
                                  
                              } else if ( fieldDataType == 'BOOLEAN' ) {
                              
                                  finalQueryString += '\n\t' + s + ' ' +sfOracleDataTypeMap.get(sfObjectFieldDataTypeMap.get(s))+'(1)' + ',';   
                              } else {
                              
                                  System.Debug(':::other fields :::'+s);
                                  finalQueryString += '\n\t' + s +' '+  sfOracleDataTypeMap.get(sfObjectFieldDataTypeMap.get(s))+',';
                                 
                              }    
                          }
                        
                       }  
                     
                     finalQueryString = finalQueryString.substring(0,finalQueryString.length()-1);
                     finalQueryString = 'CREATE TABLE'+' '+sfObjectListObj +'('+finalQueryString +'\n)'+';';
                     sfobjectNameQueryStringMap.put(sfObjectListObj, finalQueryString);
                     finalQueryString = '';
                     System.Debug(':::sfobjectNameQueryStringMap:::' +sfobjectNameQueryStringMap);
                     
                     
                     // If below list is not empty then clear the list 
                     if( !sfObjectCustomFieldsList.isEmpty() ) {    
                     
                         sfObjectCustomFieldsList.clear();
                     } 
                     if( !sfObjectStandardFieldsList.isEmpty() ) {
                     
                          sfObjectStandardFieldsList.clear();
                     }     
                     if(  !sfObjectAllFieldList.isEmpty() )  {
                        
                         sfObjectAllFieldList.clear();
                     }
                     if( !sfObjectFieldDataTypeMap.isEmpty()) {
                         
                         sfObjectFieldDataTypeMap.clear();
                     }
                     if( !sfFieldDescriptionMap.isEmpty())  { 
                        
                        sfFieldDescriptionMap.clear(); 
                     }
                     
                } else {
                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'You must enter correct sfObject API name'+' '+ sfObjectListObj+''+ ' is wrong' );
                    ApexPages.addMessage(myMsg);
                } 
            }    
        }
        
        
        for ( String s : sfObjectsList ) {    // list for iterate all input SObject api name
    
            String ss = sfobjectNameQueryStringMap.get(s);
            if( ss != null ) {
        
                Oracle oracleObj = new Oracle();   // Here oracle class instance created  
                oracleObj .sfObjectName = s;
                oracleObj .sfObjectOraclequeryString = sfobjectNameQueryStringMap.get(s);
                oracleQueryStringList.add( oracleObj);
            }    
        
        }
        return null; 
       
    }   
}