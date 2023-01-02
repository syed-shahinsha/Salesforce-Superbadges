public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts  {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public void execute(QueueableContext context) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');
        HttpResponse response = http.send(req);
        List<Object> responseMapList = (List<Object>) JSON.deserializeUntyped(response.getBody());
        
        Map<String, Product2> skuToEquipment = new Map<String, Product2>();
        Set<String> skuIds = new Set<String>();
        for(Object resp: responseMapList) {
            Map<String, Object> parsedResp = (Map<String, Object>) resp;
            skuIds.add((String) parsedResp.get('_id'));
        }
        List<Product2> equipmentList= [
            SELECT Id, Replacement_Part__c, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c, Warehouse_SKU__c
            FROM Product2
            WHERE Warehouse_SKU__c IN: skuIds
        ];

        for(Product2 prod: equipmentList) {
            skuToEquipment.put(prod.Warehouse_SKU__c, prod);
        }

        List<Product2> listToBeUpdated = new List<Product2>();
        for(Object resp: responseMapList) {
            Map<String, Object> parsedResp = (Map<String, Object>) resp;
            if(skuToEquipment.containsKey((String)parsedResp.get('_id'))) {
                Product2 prod = skuToEquipment.get((String)parsedResp.get('_id'));
                prod.Name = (String) parsedResp.get('name');
                prod.Replacement_Part__c = true;
                prod.Cost__c = (Decimal) parsedResp.get('cost');
                prod.Current_Inventory__c = (Decimal) parsedResp.get('quantity');
                prod.Lifespan_Months__c = (Decimal) parsedResp.get('lifespan');
                prod.Maintenance_Cycle__c = (Decimal) parsedResp.get('maintenanceperiod');
                prod.Warehouse_SKU__c = (String) parsedResp.get('_id');
                listToBeUpdated.add(prod);
            } else {
                Product2 prod = new Product2();
                prod.Name = (String) parsedResp.get('name');
                prod.Replacement_Part__c = true;
                prod.Cost__c = (Decimal) parsedResp.get('cost');
                prod.Current_Inventory__c = (Decimal) parsedResp.get('quantity');
                prod.Lifespan_Months__c = (Decimal) parsedResp.get('lifespan');
                prod.Maintenance_Cycle__c = (Decimal) parsedResp.get('maintenanceperiod');
                prod.Warehouse_SKU__c = (String) parsedResp.get('_id');
                listToBeUpdated.add(prod);
            }
        }
        if (listToBeUpdated.size() > 0) {
            upsert listToBeUpdated;
        }
    }
}