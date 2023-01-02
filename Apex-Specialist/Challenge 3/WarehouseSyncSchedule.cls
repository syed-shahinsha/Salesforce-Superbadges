public class WarehouseSyncSchedule implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        System.enqueueJob(new WarehouseCalloutService()); 
     }
}