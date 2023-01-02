@isTest
public with sharing class MaintenanceRequestHelperTest {
    private static final String TYPE_ROUTINE_MAINTENANCE = 'Routine Maintenance';

   @TestSetup
   static void makeData(){

        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        vehicles.add(new Vehicle__c(Name = 'Toy Hauler RV', Air_Conditioner__c = true, Bathrooms__c = 1, Bedrooms__c = 1, Model__c = 'Toy Hauler RV'));
        vehicles.add(new Vehicle__c(Name = 'Travel Trailer RV', Air_Conditioner__c = true, Bathrooms__c = 2, Bedrooms__c = 2, Model__c = 'Travel Trailer RV'));
        insert vehicles;

        List<Product2> equipments = new List<Product2>();
        equipments.add(new Product2(Warehouse_SKU__c = '55d66226726b611100aaf741',name = 'Generator 1000 kW', Replacement_Part__c = true,Cost__c = 100 ,Maintenance_Cycle__c = 100));
        equipments.add(new Product2(name = 'Fuse 20B',Replacement_Part__c = true,Cost__c = 1000, Maintenance_Cycle__c = 30  ));
        equipments.add(new Product2(name = 'Breaker 13C',Replacement_Part__c = true,Cost__c = 100  , Maintenance_Cycle__c = 15));
        insert equipments;

        List<Case> maintenanceRequests = new List<Case>();
        maintenanceRequests.add(new Case(Vehicle__c = vehicles.get(0).Id, Type = TYPE_ROUTINE_MAINTENANCE, Date_Reported__c = Date.today()));
        maintenanceRequests.add(new Case(Vehicle__c = vehicles.get(1).Id, Type = TYPE_ROUTINE_MAINTENANCE, Date_Reported__c = Date.today()));
        insert maintenanceRequests;

        List<Equipment_Maintenance_Item__c> joinRecords = new List<Equipment_Maintenance_Item__c>();
        joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipments.get(0).Id, Maintenance_Request__c = maintenanceRequests.get(0).Id));
        joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipments.get(1).Id, Maintenance_Request__c = maintenanceRequests.get(0).Id));
        joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipments.get(2).Id, Maintenance_Request__c = maintenanceRequests.get(0).Id));
        joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipments.get(0).Id, Maintenance_Request__c = maintenanceRequests.get(1).Id));
        joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipments.get(1).Id, Maintenance_Request__c = maintenanceRequests.get(1).Id));
        joinRecords.add(new Equipment_Maintenance_Item__c(Equipment__c = equipments.get(2).Id, Maintenance_Request__c = maintenanceRequests.get(1).Id));
        insert joinRecords;
   }

   @isTest
   public static void testPositiveOutcomes() {
    List<Case> cases = [ SELECT Id FROM Case ];

    List<Case> casesToBeUpdated = new List<Case>();
    for(Case c: cases ) {
        c.Status = 'Closed';
        casesToBeUpdated.add(c);
    }

    Test.startTest();
    update casesToBeUpdated;
    Test.stopTest();

    System.assertEquals(2, [SELECT Count() FROM Case WHERE Status = 'New'], '2 cases should be created when 2 old cases are closed in Routine Maintenance type');
   }    

   @isTest
   public static void testNegativeOutcomes() {
    List<Case> cases = [ SELECT Id FROM Case ];

    List<Case> casesToBeUpdated = new List<Case>();
    for(Case c: cases ) {
        c.Status = 'Working';
        casesToBeUpdated.add(c);
    }

    Test.startTest();
    update casesToBeUpdated;
    Test.stopTest();
    System.assertEquals(0, [SELECT Count() FROM Case WHERE Status = 'New'], 'No cases should be created as old cases are not in closed status');
   }
   
   @isTest
   public static void testBulkOutcomes() {
    Vehicle__c vehicle = new Vehicle__c(Name = 'Bulk Test Vehicle', Air_Conditioner__c = true, Bathrooms__c = 1, Bedrooms__c = 1, Model__c = 'Toy Hauler RV'); 
    insert vehicle;

    List<Case> cases = new List<Case>();
    for(Integer i=0; i<300; i++) {
        cases.add(new Case(Vehicle__c = vehicle.Id, Type = TYPE_ROUTINE_MAINTENANCE, Date_Reported__c = Date.today(), Subject='Bulk test '+i));
    }
    insert cases;

    List<Case> casesToBeUpdated = new List<Case>();
    for(Case c: cases ) {
        c.Status = 'Closed';
        casesToBeUpdated.add(c);
    }

    Test.startTest();
    update casesToBeUpdated;
    Test.stopTest();
    System.assertEquals(300, [SELECT Count() FROM Case WHERE Status = 'New' AND Subject = 'Routine Maintenance check'], '300 cases should be created when 300 old cases are closed in Routine Maintenance type');
   }
}