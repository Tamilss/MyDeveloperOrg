/* Algorithm
    1.Get the SF object API name and  get description of all fields in object through Schema.DescribrFieldResult
        and sort fieldName alphapetical order .and some standard fields (It is comman to all object)
       already   added to list.That object remaining Standard and custom fields get from DescribeResult
       sort them added to same standardfield list.
    2.SFOracleDataTypeMap created in Constructor for map SF and Oracle datatype
    3.Inner class variables for assign some field of  description result values (Like length,Scale,precision)assign to inner class variables .Then put to map like 
        (fieldname,innerclass instance) here inner class instance have SObject field description result of some information .
    4. finallay Iterate the List the access the inner class using the field name( Map name :SFFieldScalePrecisionMap ) then make querystring
    5.finally it displays the output text 
        
     */       
public class CreateOracleQueryStringController {
    public String selectedObject{get;set;}    // For Store selected SF Object name
    
    Public String finalQueryString {get;set;}   // Strore Final result of  querystring
    //Map<String,Schema.DescribeFieldResult> SfFieldNameFieldDescribeMap= new Map<String,Schema.DescribeFieldResult>();
    Map<String,String> SFOracleDataTypeMap = new Map<String,String>();
    Map<String,String> SFObjectFieldDataTypeMap = new Map<String,String>();
    List<String> SFObjectDefaultStandardFieldList = new List<String>();
    Map<String,DescribeFieldResultInnerClass> SFFieldScalePrecisionMap = new Map<String,DescribeFieldResultInnerClass>(); 
    List<String> SFObjectCustomFieldsList = new List<String>();
    List<String> SFObjectStandardFieldsList = new List<String>();
    
    // Inner class for store some Sobject field description result
    Public Class DescribeFieldResultInnerClass{
    
        Public Integer precisionValue;   // Inner class variables store DescribeResult values
        Public Integer scaleValue;
        Public Integer lengthValue;
        Public String  dataType; 
    }
    public CreateOracleQueryStringController () {
        // Salesforce Oracle datatype map
        SFOracleDataTypeMap.put('BOOLEAN','varchar2(1)');
        SFOracleDataTypeMap.put('DATE','date');
        SFOracleDataTypeMap.put('DATETIME','date');
        SFOracleDataTypeMap.put('CURRENCY','number(precision,scale)');
        SFOracleDataTypeMap.put('DOUBLE','number(precision,scale)');
        SFOracleDataTypeMap.put('INTEGER','number(10)');
        SFOracleDataTypeMap.put('PICKLIST','varchar2(255)');
        SFOracleDataTypeMap.put('ID','varchar2(18)');
        SFOracleDataTypeMap.put('REFERENCE','varchar2(18)');
        SFOracleDataTypeMap.put('TEXTAREA','varchar2(4000)');
        SFOracleDataTypeMap.put('EMAIL','varchar2(255)');
        SFOracleDataTypeMap.put('PHONE','varchar2(255)');
        SFOracleDataTypeMap.put('URL','varchar2(255)');
        SFOracleDataTypeMap.put('MULTIPICLIST','varchar2(4000)');
        SFOracleDataTypeMap.put('ANYTYPE','varchar2(4000)');
        SFOracleDataTypeMap.put('PERCENT','number(5,2)');
        SFOracleDataTypeMap.put('COMBOBOX','varchar2(4000)');
        SFOracleDataTypeMap.put('BASE64','varchar2(4000)');
        SFOracleDataTypeMap.put('TIME','varchar2(255)');
        SFOracleDataTypeMap.put('STRING','varchar2(255)');
        System.Debug(':::select value::'+selectedObject);
        System.Debug(':::Map values:::'+SFOracleDataTypeMap); 
        
        // some standard fields added to list for making order of querystring
        SFObjectDefaultStandardFieldList.add('Id');
        SFObjectDefaultStandardFieldList.add('OwnerId');
        SFObjectDefaultStandardFieldList.add('IsDeleted');
        SFObjectDefaultStandardFieldList.add('Name');
        SFObjectDefaultStandardFieldList.add('CreatedDate');
        SFObjectDefaultStandardFieldList.add('CreatedById');
        SFObjectDefaultStandardFieldList.add('LastModifiedDate');
        SFObjectDefaultStandardFieldList.add('LastModifiedById');
           
    }  
    public pageReference submit() {
        
        String currentOracleDataType;
        finalQueryString = '';
        if( selectedObject != '' )  {
        
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            DescribeSObjectResult res= schemaMap.get(selectedObject).getDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(selectedObject).getDescribe().fields.getMap();
            
            System.Debug('xxxx  :: ' + fieldMap);
            Integer x = 0;
            for(Schema.SObjectField field: fieldMap .values()) {
            
                Schema.DescribeFieldResult sdr = field.getDescribe();
                String fieldDataType = String.valueOf(sdr.getType());
                System.Debug(' yyyy ' + (++x) + ' ::: ' + field + ' ~~~~~ ' + fieldDataType );
                //currentOracleDataType = SFOracleDataTypeMap.get(fieldDataType);
                SFObjectFieldDataTypeMap.put(sdr.getName(),fieldDataType );
                
                //if any one field datatype is like below then create inner class
                //  and its some description assign to inner class variables
                    
                if ( fieldDataType == 'currency' || fieldDataType == 'number' || fieldDataType == 'percent' || fieldDataType == 'DOUBLE') {
                    // Here 
                    DescribeFieldResultInnerClass innClassObj = new DescribeFieldResultInnerClass ();
                    innClassObj.lengthValue = null;
                    innClassObj.dataType = String.valueOf(sdr.getType());
                    innClassObj.scaleValue =  sdr.getScale(); 
                    innClassObj.precisionValue = sdr.getPrecision(); 
                    SFFieldScalePrecisionMap.put(String.valueOf(sdr.getName()),innClassObj); 
                }
                if ( fieldDataType == 'String' || fieldDataType == 'TEXTAREA' || fieldDataType == 'PHONE' ||fieldDataType == 'URL' || fieldDataType == 'EMAIL'
                               || fieldDataType == 'REFERENCE'|| fieldDataType == 'PICKLIST' || fieldDataType == 'ID'
                               || fieldDataType == 'MULTIPICKLIST' || fieldDataType == 'ANYTYPE' || fieldDataType == 'COMBOBOX'
                               || fieldDataType == 'BASE64' || fieldDataType == 'TIME') {
                    DescribeFieldResultInnerClass innClassObj = new DescribeFieldResultInnerClass ();
                    innClassObj.lengthValue = sdr.getLength();
                    innClassObj.dataType = String.valueOf(sdr.getType());
                    innClassObj.scaleValue =  null; 
                    innClassObj.precisionValue = null; 
                    SFFieldScalePrecisionMap.put(String.valueOf(sdr.getName()),innClassObj);     
                }
               
                if( sdr.isCustom() == true ) { 
                    SFObjectCustomFieldsList.add(String.ValueOf(sdr.getName()));   // here custom fields added to list
                }else {
                    boolean availble = false;     //  Standardfields added to this list                                         
                    for( integer i = 0; SFObjectDefaultStandardFieldList.size()>i ; i++ ) {
                        if( SFObjectDefaultStandardFieldList[i] == String.ValueOf(sdr.getName())) {
                            availble = true ;
                        }  
                    }      
                    if ( availble == false ) {      // if it is not already available then added to list   
                            SFObjectStandardFieldsList.add(String.ValueOf(sdr.getName()));
                       
                     }
                 } 
             }
             SFObjectCustomFieldsList.sort();  // SFObjectCustomFieldsList is sorted for alphapetical order
             SFObjectStandardFieldsList.sort(); // SFObjectStandardFieldsList is sorted for alphapetical order
             SFObjectDefaultStandardFieldList.addAll(SFObjectStandardFieldsList);
             SFObjectDefaultStandardFieldList.addAll(SFObjectCustomFieldsList);
             System.Debug(':::SFObjectStandardFieldsList :::'+ SFObjectStandardFieldsList);
             
             for(String s : SFObjectDefaultStandardFieldList ) {  // Iterate each field for making querystring
                 DescribeFieldResultInnerClass obj1;
                 String fieldDataType = SFObjectFieldDataTypeMap.get(s);
                  
                 if ( SFFieldScalePrecisionMap.containsKey(s) == true ) {
                      obj1 = SFFieldScalePrecisionMap.get(s);
                      System.Debug(':::obj:::'+obj1);
                 }    
                 System.Debug('::::DataType:::'+fieldDataType );
                 
                 if( fieldDataType == 'CURRENCY' || fieldDataType == 'NUMBER' || fieldDataType == 'PERCENT' || fieldDataType == 'DOUBLE') {
                     finalQueryString += '\n\t' + s + ' ' +'number(' + obj1.precisionValue + ',' + obj1.scaleValue + ')' + ',';
                     System.Debug(':::currency fields :::'+s);
                  }
                  else if ( fieldDataType == 'STRING'|| fieldDataType == 'TEXTAREA' 
                               || fieldDataType == 'PHONE' ||fieldDataType == 'URL' || fieldDataType == 'EMAIL'
                               || fieldDataType == 'REFERENCE'|| fieldDataType == 'PICKLIST' || fieldDataType == 'ID'
                               || fieldDataType == 'MULTIPICKLIST' || fieldDataType == 'ANYTYPE' || fieldDataType == 'COMBOBOX'
                               || fieldDataType == 'BASE64' || fieldDataType == 'TIME' ) {
                      System.Debug(':::String fields :::'+s);
                      finalQueryString += '\n\t' + s + ' ' +'varchar2(' + obj1.lengthValue + ')' + ',';
                  } else {
                      System.Debug(':::other fields :::'+s);
                      finalQueryString += '\n\t' + s +' '+  SFOracleDataTypeMap.get(SFObjectFieldDataTypeMap.get(s))+',';
                      System.Debug(':::finalQueryString :::'+finalQueryString);
                  }    
              }
             
             //System.Debug(':::currentOracleDataType :::'+currentOracleDataType  );
             finalQueryString = finalQueryString.substring(0,finalQueryString.length()-1);
             System.Debug(':::fullqueryStringwithoutcomma:::'+finalQueryString );
             finalQueryString = 'CREATE TABLE'+' '+selectedObject+'('+finalQueryString +'\n)'+';';
             //System.Debug(':::finalQueryString :::'+finalQueryString);
         } 
          
          
      return null; 
       
     }   
}