trigger EventTrigger on Event__c (after insert, before update) {

    if (Trigger.isInsert && Trigger.isAfter) {
        EventHandler.findSimilarEvents(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        //Firstly we are looking for events where start/end dates fields have been changed
        List<Event__c> changedDatesEvents = EventHandler.analyzeDatesChanges(Trigger.new, Trigger.oldMap);
        //if we don't have such events - we don't need to run logic so far 
        if (!changedDatesEvents.isEmpty()) {
            EventHandler.findSimilarEvents(Trigger.new);
        }
    }
}