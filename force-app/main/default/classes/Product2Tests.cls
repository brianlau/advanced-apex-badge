@isTest
private class Product2Tests {
    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.startTest();
        	PageReference productPage = Page.Product2New;
       		Test.setCurrentPage(productPage);
        	ApexPages.StandardController cont = new ApexPages.StandardController(new Product2());
            Product2Extension ext = new Product2Extension(cont);
        	System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
            ext.addRows();
        	System.assertEquals(2*Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        	Integer i = 0;
        for(Product2Extension.ProductWrapper wrapper : ext.productsToInsert) {
            if( i < 5) {
                wrapper.productRecord.IsActive = true;
                wrapper.productRecord.Family = Constants.PRODUCT_FAMILY[Math.mod(i, Constants.PRODUCT_FAMILY.size())].getValue();
                wrapper.productRecord.Initial_Inventory__c = i + 1;
                wrapper.productRecord.Name = 'Test' + i;
                wrapper.pricebookEntryRecord.UnitPrice = i + 1;
                i++;
            }
        }
            ext.save();
        	ext.getFamilyOptions();
        ext.GetInventory();
        List<Product2> products = [Select Id from Product2];
        System.assertEquals(5, products.size());
        Test.stopTest();
    }
    
    static testmethod void Product2Trigger_UnitTest () {
        Test.startTest();
       	Product2 p = TestDataFactory.ConstructProducts(1)[0];
        p.Family = 'Entree';
        p.Quantity_Ordered__c = 50;
        p.Initial_Inventory__c = 100;
       	insert p;
        
        CollaborationGroup gr = TestDataFactory.ConstructCollaborationGroup();
        insert gr;
        
        p.Quantity_Ordered__c = 96;
        update p;
        Test.stopTest();
    }

}