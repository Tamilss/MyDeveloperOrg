trigger updateTotalPriceOnOpportunity on OpportunityLineItem ( after insert, after update ) {
    
    if( trigger.isInsert) {
    
        for( OpportunityLineItem oppPrd : Trigger.New ) {
            
                
        }
    }

}