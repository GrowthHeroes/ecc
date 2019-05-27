trigger Opportunity_Trigger on Opportunity(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  //Do Nothing if Enable feature is FALSE
  //if (!FeatureCheck.isSwitchDisabled('Enable Opps Trigger')) {return;}
  // Send everything to the Handler
  Opportunity_TriggerHandler.handleTrigger(
    Trigger.new,
    Trigger.old,
    Trigger.newMap,
    Trigger.oldMap,
    Trigger.operationType
  );
}
