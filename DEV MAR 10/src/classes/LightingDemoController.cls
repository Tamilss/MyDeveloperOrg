public class LightingDemoController {
    @AuraEnabled
    public static List<Contact> getContacts() {
        return [SELECT id, name FROM Contact LIMIT 10];
    }
}