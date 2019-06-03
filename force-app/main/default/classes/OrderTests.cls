@isTest
private class OrderTests {
	@testSetup 
    static void SetupTestData() {
        TestDataFactory.InsertTestData(1);
    }
    
    static testMethod void OrderUpdate_UnitTest() {
        Product2 product = [Select Id, Quantity_Ordered__c from Product2];
        List<Order> originalOrders = [Select Id, Status from Order];
        for(Order ord : originalOrders) {
            ord.Status = Constants.ACTIVATED_ORDER_STATUS;
        }
        update originalOrders;
        Product2 updatedProduct = [Select Id, Quantity_Ordered__c from Product2 where Id =: product.Id];
        
        TestDataFactory.VerifyQuantityOrdered(product, updatedProduct, Constants.DEFAULT_ROWS);
    }
    
    static testMethod void OrderExtension_UnitTest () {
        Test.startTest();
        PageReference pageRef = Page.OrderEdit;
        Order ord = [Select Id from Order LIMIT 1];
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController cont = new ApexPages.StandardController(ord);
        OrderExtension ext = new OrderExtension(cont);
        
        System.assertEquals(1, ext.orderItemMap.size());
        ext.OnFieldChange();
        ext.SelectFamily();
        ext.Save();
        ext.First();
        ext.Next();
        ext.Previous();
        ext.Last();
        ext.GetHasPrevious();
        ext.GetHasNext();
        ext.GetTotalPages();
        ext.GetPageNumber();
        ext.GetFamilyOptions();
        
        Test.stopTest();
    }

}