public class CaseList
{
    private ApexPages.StandardSetController ssc;

    public CaseList() 
    {
        List<Case> caseList = [SELECT Id FROM Case LIMIT 10];

        ssc = new ApexPages.StandardSetController( caseList );
        ssc.setFilterID('00B90000002yKAJ');
    }

    public List<Case> getCases() 
    {
        return (List<Case>)ssc.getRecords();
    }
}