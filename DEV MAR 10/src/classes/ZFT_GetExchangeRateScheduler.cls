global class ZFT_GetExchangeRateScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        
        System.debug('::::Before Execute:::::');
        Database.executeBatch(new AccountWrecker());
        System.debug('::::After Execute:::::');
    }
}