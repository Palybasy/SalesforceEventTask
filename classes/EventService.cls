public without sharing class EventService {
    private static final String EVENT_API_NAME              = Schema.sObjectType.Event__c.getName();
    public static final String EVENT_START_DATE_API_NAME    = Schema.sObjectType.Event__c.fields.StartDate__c.getName();
    public static final String EVENT_END_DATE_API_NAME      = Schema.sObjectType.Event__c.fields.EndDate__c.getName();
    private static final String OVERLAP_ERROR_UPCOMING      = 'New event has the similar time range with other new events';
    public static final String OVERLAP_ERROR_EXISTING       = 'New event has the similar time range with existing ones in DB.';

    public class EventDMLException extends Exception{}

    public static void checkEventOverlap (List<Event__c> newEvents) {
        for (Event__c evt : newEvents) {
            for (Event__c evtNeighbour : newEvents) {
                if (evt.Id == evtNeighbour.Id) { continue; }
                if ((evt.StartDate__c >= evtNeighbour.StartDate__c && evt.StartDate__c <= evtNeighbour.EndDate__c) || 
                    (evt.EndDate__c >= evtNeighbour.StartDate__c && evt.EndDate__c <= evtNeighbour.EndDate__c) ||
                    (evt.StartDate__c < evtNeighbour.StartDate__c && evt.EndDate__c > evtNeighbour.EndDate__c)) 
                {
                    throw new EventDMLException(OVERLAP_ERROR_UPCOMING);
                }
            }
        }
    }
   
    public static List<Event__c> createStringAndQuery (List<Event__c> events) {
        String defaultRequestBody   = 'SELECT Id,StartDate__c, EndDate__c FROM ' + EVENT_API_NAME;
        String excludeClause        = ' WHERE (Id  NOT IN :events) AND ';
        String whereClauses         = '';

        for (Event__c evt : events ) {
            whereClauses += createSOQLClause(evt.StartDate__c, String.isEmpty(whereClauses));
            whereClauses += createSOQLClause(evt.EndDate__c, String.isEmpty(whereClauses));
            whereClauses += createSOQLClause(evt.StartDate__c, evt.EndDate__c);
        } 
        return Database.query(defaultRequestBody + excludeClause + '(' + whereClauses + ')');
    }


    private static String createSOQLClause (Date currentDate, Boolean isFirstClause) {
        DateTime dTime = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0));
        return  (isFirstClause ? '(' : ' OR (')  + EVENT_START_DATE_API_NAME + ' <=  ' + dTime.format('yyyy-MM-dd') +
        + ' AND ' + EVENT_END_DATE_API_NAME + ' >= ' + dTime.format('yyyy-MM-dd') +')';
    }

    private static String createSOQLClause (Date startDate, Date endDate) {
        DateTime dTimeStart = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        DateTime dTimeEnd = DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0));
        return  ' OR ('  + EVENT_START_DATE_API_NAME + ' >  ' + dTimeStart.format('yyyy-MM-dd') +
        + ' AND ' + EVENT_END_DATE_API_NAME + ' < ' + dTimeEnd.format('yyyy-MM-dd') +')';
    }
}
