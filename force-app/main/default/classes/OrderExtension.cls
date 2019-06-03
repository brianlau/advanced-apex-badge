/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        refreshStandardSetController();
        
        total = 0;
        pieData = new List<chartHelper.ChartData>();
        for(OrderItem ordItem : orderRecord.OrderItems) {
            orderItemMap.put(ordItem.Product2Id, ordItem);
            if(ordItem.Quantity > 0) {
                total += ordItem.Quantity;
                pieData.add(new ChartHelper.ChartData(ordItem.Product2.Name, ordItem.Quantity * ordItem.UnitPrice));
            }
        }
        loadData();
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    private void refreshStandardSetController() {
        String query = 'Select Id, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c from PricebookEntry where IsActive = true';
        if(String.isNotBlank(selectedFamily)) {
            query += ' AND Product2.Family = \'' + String.escapeSingleQuotes(selectedFamily) + '\'';
        }
        query += ' ORDER BY Name';
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
    
    private void loadData() {
        orderItemList = new List<OrderItem>();
        for(SObject obj : standardSetController.getRecords()) {
            PricebookEntry pbe = (PricebookEntry)obj;
            if(orderItemMap.containsKey(pbe.Product2Id)) {
                orderItemList.add(orderItemMap.get(pbe.Product2Id));
            } else {
                OrderItem ordItem = new OrderItem();
                ordItem.PricebookEntryId = pbe.Id;
                ordItem.Product2Id = pbe.Product2Id;
                ordItem.UnitPrice = pbe.UnitPrice;
                ordItem.Quantity = 0;
                ordItem.Product2 = pbe.Product2;
                orderItemList.add(ordItem);
                orderItemMap.put(pbe.Product2Id, ordItem);
            }
        }
    }

    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        for(OrderItem ordItem : orderItemList) {
            orderItemMap.put(ordItem.Product2Id, ordItem);
        }
        
        total = 0;
        pieData = new List<ChartHelper.ChartData>();
        
        for(OrderItem ordItem : orderItemMap.values()) {
            if(ordItem.Quantity > 0) {
                pieData.add(new ChartHelper.ChartData(ordItem.Product2.Name, ordItem.UnitPrice * ordItem.Quantity));
                total += ordItem.UnitPrice * ordItem.Quantity;
            }
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        refreshStandardSetController();
        loadData();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        Savepoint sp = Database.setSavepoint();
        try {
            if(String.isBlank(orderRecord.Pricebook2Id)) {
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;
            
            List<OrderItem> upsertOrderItems = new List<OrderItem>();
            List<OrderItem> deleteOrderItems = new List<OrderItem>();
            
            for(OrderItem ordItem : orderItemMap.values()) {
                if(ordItem.Quantity > 0 ) {
                    if(String.isBlank(ordItem.OrderId)) {
                        ordItem.OrderId = orderRecord.Id;
                    }
                    upsertOrderItems.add(ordItem);
                } else if(ordItem.Quantity == 0 && String.isNotBlank(ordItem.Id)) {
                    deleteOrderItems.add(ordItem);
                }
            }
            upsert upsertOrderItems;
            delete deleteOrderItems;
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.Message message = new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE);
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
		standardSetController.first();
        loadData();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
		standardSetController.next();
        loadData();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
		standardSetController.previous();
        loadData();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
		standardSetController.last();
        loadData();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return Integer.valueOf(Math.ceil(standardSetController.getResultSize() / standardSetController.getPageSize())) + 1;
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', Constants.SELECT_ONE));
        for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}