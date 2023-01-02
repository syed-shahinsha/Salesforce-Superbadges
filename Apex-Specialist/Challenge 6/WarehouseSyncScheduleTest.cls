@isTest
public class WarehouseSyncScheduleTest {
    @isTest
    private static void testScheduleProcess() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseSyncSchedule schedulingClassToTest = new WarehouseSyncSchedule();
        String cronExp = '0 0 1 ? * *';
        Test.startTest();
        System.schedule('wareHouseScheduleJob', cronExp, schedulingClassToTest);
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM AsyncApexJob where JobType = 'ScheduledApex' AND Status = 'Queued']);
    }
}