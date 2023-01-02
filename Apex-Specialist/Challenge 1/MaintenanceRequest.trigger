trigger MaintenanceRequest on Case (before update, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            MaintenanceRequestHelper.updateWorkOrders(Trigger.new);
        }
    }
}