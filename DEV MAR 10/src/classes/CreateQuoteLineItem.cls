global class CreateQuoteLineItem {
    
    webservice static Void createLineItem(Id quoteId) {
       List<Quote_Apporvals__c> newQuoteApprovalList = new List<Quote_Apporvals__c>();
       List<QuoteLineItem> quoLineItem ;
       Set<Id> quoLItemPriceBookEntry = new Set<Id>();
       Map<Id,Id> pbEntryProductIdMap = new Map<Id,Id>();
       Map<Id,String> pbEntryProductNameMap = new Map<Id,String>();
       quoLineItem = [
                       SELECT 
                         Id,ListPrice,UnitPrice,PriceBookEntryId,
                         Quantity,Subtotal,Discount,
                         TotalPrice FROM QuoteLineItem
                         WHERE QuoteId =: quoteId
                      ];
      for(QuoteLineItem quoLItem : quoLineItem) {
          quoLItemPriceBookEntry.add(quoLItem.PriceBookEntryId);
      }
      system.debug('::quoLItemPriceBookEntry::'+quoLItemPriceBookEntry);
      for( PriceBookEntry pbEntry : [
                                      SELECT Id,
                                      Product2Id 
                                      FROM PriceBookEntry 
                                      WHERE Id 
                                      IN:quoLItemPriceBookEntry
                                      ] ) {
          pbEntryProductIdMap.put(pbEntry.Product2Id, pbEntry.Id);                                
                                       
                                      
      }   
      system.debug('::pbEntryProductIdMap::'+pbEntryProductIdMap);
      for( Product2 product : [ 
                        SELECT 
                        Id,
                        Name 
                        FROM Product2 
                        WHERE 
                        Id IN: pbEntryProductIdMap.keySet()] ) {
           pbEntryProductNameMap.put(pbEntryProductIdMap.get(product.Id),product.Name);
      } 
      system.debug('::pbEntryProductNameMap::'+pbEntryProductNameMap);
      String listOfLineItems = ''; 
      for(QuoteLineItem quoLiItem : quoLineItem) {
          system.debug('::entry string value:::'+listOfLineItems);
          listOfLineItems = listOfLineItems+ 
                            String.valueOf(pbEntryProductNameMap.get(quoLiItem.PriceBookEntryId))+':'
                            +String.valueOf(quoLiItem.ListPrice)+':' 
                            +String.valueOf(quoLiItem.UnitPrice)+':'  
                            +String.valueOf(quoLiItem.Quantity)+':'
                            +String.valueOf(quoLiItem.Subtotal)+':'
                            +String.valueOf(quoLiItem.Discount)+':'
                            +String.valueOf(quoLiItem.TotalPrice)+'::';
                           
      system.debug('::listOfLineItems ::'+listOfLineItems );  
      } 
                 
                       
            
                 
      List<Attachment> quoteAttachments = [ 
                                             SELECT
                                                 Id,
                                                 ContentType,
                                                 Name,
                                                 Body,
                                                 ParentId,
                                                 CreatedDate
                                                 FROM
                                                 Attachment
                                                 WHERE
                                                 ParentId =:quoteId 
                                                 AND
                                                 ((ContentType =:'application/vnd.ms-excel')
                                                 OR
                                                 (ContentType =:'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'))
                                                 ORDER BY CreatedDate DESC  Limit 1
                                                 
                                              ]; 
  
    Quote_Apporvals__c quoApproval = new Quote_Apporvals__c();
    quoApproval.Quotes_Line_Item__c = listOfLineItems;
    insert quoApproval;
    Quote_Apporvals__c  quotoApp = [
                                    SELECT 
                                    Id,
                                    Name 
                                    FROM Quote_Apporvals__c  
                                    WHERE 
                                    Id =:quoApproval.Id
                                    ];
    Attachment att = new Attachment();
    att.ParentId = quotoApp.Id;
    att.Body = quoteAttachments.get(0).Body;
    att.Name = quoteAttachments.get(0).Name;
    insert att;
    system.debug('::att:'+att);    
    system.debug('::quoApproval::'+quoApproval);                    
                       
                       
       
       
        
    }
}