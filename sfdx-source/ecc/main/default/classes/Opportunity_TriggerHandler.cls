public class Opportunity_TriggerHandler {
  public static void handleTrigger(List<Opportunity> newRecords, List<Opportunity> oldRecords, Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, System.TriggerOperation triggerEvent
  ) {
    switch on triggerEvent { // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_context_variables.htm
      when BEFORE_INSERT {
        //set value on record create
        system.debug('#### Opportunity_TriggerHandler when BEFORE_INSERT'); 
      }
      when AFTER_INSERT {
        system.debug('#### Opportunity_TriggerHandler when AFTER_INSERT');
      }
      when BEFORE_UPDATE {
        //set value on record update
        system.debug('#### Opportunity_TriggerHandler when BEFORE_UPDATE');
      }
      when AFTER_UPDATE {
        //create related records when After Update
        system.debug('#### Opportunity_TriggerHandler when AFTER_UPDATE');
      }
      when BEFORE_DELETE {
        //prevent deletion of sensitive data
        system.debug('#### Opportunity_TriggerHandler when BEFORE_DELETE');

      }
      when AFTER_DELETE {
        system.debug('#### Opportunity_TriggerHandler when AFTER_DELETE');
      }
      when else {
        //do nothing for AFTER_UNDELETE
        system.debug('#### Opportunity_TriggerHandler when else - Do Nothing');

      }
    }
  }
}
