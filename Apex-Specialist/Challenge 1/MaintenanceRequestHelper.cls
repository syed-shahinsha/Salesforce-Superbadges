public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> newRequests) {
        List<Case> newCases = new List<Case>();
        Set<Id> requestIds = new Set<Id>();
        List<Case> requestsToProcess = new List<Case>();

        for(Case req: newRequests) {
            if((req.Type == 'Required' || req.Type == 'Routine Maintenance') && req.Status == 'Closed') {
               requestIds.add(req.Id);
               requestsToProcess.add(req);
            }
        }

        Map<Id, List<Equipment_Maintenance_Item__c>> caseIdToEquipmentItems = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        for(Equipment_Maintenance_Item__c item : [
            SELECT Id, Maintenance_Request__c, Equipment__r.Maintenance_Cycle__c, Quantity__c, Equipment__c
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN: requestIds
        ]) {
            if(caseIdToEquipmentItems.containsKey(item.Maintenance_Request__c)) {
                caseIdToEquipmentItems.get(item.Maintenance_Request__c).add(item);
            } else {
                caseIdToEquipmentItems.put(item.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c> {item});
            }
        }
        List<Equipment_Maintenance_Item__c> newEMItems = new List<Equipment_Maintenance_Item__c>();
        for(Case req: requestsToProcess) {
            Case newCase = new Case();
            Date today = Date.today();
            newCase.Type = 'Routine Maintenance';
            newCase.Vehicle__c = req.Vehicle__c;
            newCase.Status = 'New';
            newCase.Origin ='Web';
            newCase.Product__c	= req.Product__c;
            newCase.Subject = 'Routine Maintenance check';
            newCase.Date_Reported__c = today;
            newCase.ProductId = req.ProductId;
            newCase.ParentId = req.Id;
            Integer minMaintenanceDays = 100000;
            Boolean noRecordFlag = true;
            if(caseIdToEquipmentItems.containsKey(req.Id)) {
                for(Equipment_Maintenance_Item__c item : caseIdToEquipmentItems.get(req.Id)) {
                    noRecordFlag = false;
                    minMaintenanceDays = item.Equipment__r.Maintenance_Cycle__c.intValue() < minMaintenanceDays ? item.Equipment__r.Maintenance_Cycle__c.intValue() : minMaintenanceDays;
                    newEMItems.add(new Equipment_Maintenance_Item__c(
                        Maintenance_Request__c= req.Id,
                        Equipment__c=item.Equipment__c,
                        Quantity__c=item.Quantity__c
                    ));
                }
            }
            newCase.Date_Due__c = noRecordFlag ? today : today.addDays(minMaintenanceDays) ;
            newCases.add(newCase);
        }
        if(newCases.size() > 0) {
            insert newCases;
            for(Case c: newCases) {
                for(Equipment_Maintenance_Item__c item: newEMItems) {
                    if(c.ParentId == item.Maintenance_Request__c)
                        item.Maintenance_Request__c = c.Id;
                }
            }
        }
        if(newEMItems.size() > 0) {
            insert newEMItems;
        }
    }        
    
}