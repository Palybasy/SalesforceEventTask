public class EventHandler {

    public static void findSimilarEvents(List<Event__c> newEvents) {
        System.debug('New events' + newEvents);
        /**
         * Firstly we check new upcoming  events either they overlap each other
         * if so - we throw exception and avoid doing SOQL query
         *
         */
        EventService.checkEventOverlap(newEvents);
    
    
        /** 
         * Create dynamic string and make query to DB
         * if any of new dates matches any of date time range for existing events we throw exception
         * Otherwise DML will be successfully finished
         */
        List<Event__c> dataBaseEvents = EventService.createStringAndQuery(newEvents);
        System.debug(dataBaseEvents);
        if (!dataBaseEvents.isEmpty()) {
            throw new EventService.EventDMLException(EventService.OVERLAP_ERROR_EXISTING);
        }
    }

    public static List<Event__c> analyzeDatesChanges(List<Event__c> newEvents, Map<Id,Event__c> oldEvents) {
        List<Event__c> changedEvents = new List<Event__c>();
        for (Event__c evt : newEvents) {
            if ((evt.get(EventService.EVENT_START_DATE_API_NAME) != oldEvents.get(evt.Id).get(EventService.EVENT_START_DATE_API_NAME))
             || (evt.get(EventService.EVENT_END_DATE_API_NAME) != oldEvents.get(evt.Id).get(EventService.EVENT_END_DATE_API_NAME)))
            {
                changedEvents.add(evt);
            }
        }
        return changedEvents;
    }
}
