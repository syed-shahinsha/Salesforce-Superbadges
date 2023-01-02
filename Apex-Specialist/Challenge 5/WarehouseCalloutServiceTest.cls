@IsTest
private class WarehouseCalloutServiceTest {
    @TestSetup
    static void makeData(){
        List<Product2> equipments = new List<Product2>();
        equipments.add(new Product2(Warehouse_SKU__c = '55d66226726b611100aaf741',name = 'Generator 1000 kW', Replacement_Part__c = true,Cost__c = 100 ,Maintenance_Cycle__c = 100));
        insert equipments;
    }

    @isTest
    private static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();
        List<Product2> products = [SELECT Id FROM Product2];
        //Check WarehouseCalloutServiceMock for product response
        System.assertEquals(5, products.size(), '5 equipments are coming from response where 1 equipment will be updated using warehouse_SKU, others will be created');
    }
}