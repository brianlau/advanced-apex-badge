/**
 * @name product2Trigger
 * @description Trigger to notify staff of low levels of inventory
**/
trigger product2Trigger on Product2 (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    try {
        if(Trigger.isUpdate && Trigger.isAfter) {
            Product2Helper.AfterUpdate(Trigger.new, Trigger.old);
        }
    } catch ( Exception e ){
        //A good developer would do something with this Exception!
    }
}