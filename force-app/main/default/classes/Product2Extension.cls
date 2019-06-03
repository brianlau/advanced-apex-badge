public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }
    
    public List<SelectOption> getFamilyOptions() {
        List<SelectOption> familyOptions = new List<SelectOption>();
        familyOptions.add(new SelectOption('', Constants.SELECT_ONE));
        
        for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY) {
            familyOptions.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return familyOptions;
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference save(){
        Savepoint sp = Database.setSavepoint();
        try {
            List<Product2> products = new List<Product2>();
            List<PricebookEntry> entries = new List<PricebookEntry>();
            
            for(ProductWrapper product : productsToInsert) {
                if(String.isNotBlank(product.productRecord.Name) && String.isNotBlank(product.productRecord.Family) &&
                           product.pricebookEntryRecord.isActive && product.productRecord.Initial_Inventory__c != null &&
                           product.productRecord.Initial_Inventory__c != 0 && product.pricebookEntryRecord.UnitPrice != null &&
                           product.pricebookEntryRecord.UnitPrice != 0)
             	{
                	products.add(product.productRecord);
                }
            }
            insert products;
            
            for(ProductWrapper entry : productsToInsert) {
                entry.pricebookEntryRecord.Product2Id = entry.productRecord.Id;
                entry.pricebookEntryRecord.IsActive = true;
                if(String.isNotBlank(entry.pricebookEntryRecord.Product2Id)) {
                	entries.add(entry.pricebookEntryRecord);
                }
            }
            insert entries;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,products.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            System.debug('Exception occured:'+e.getMessage());
			Database.rollback(sp);
            ApexPages.Message message = new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE);
            ApexPages.addMessage(message);
        }
        return null;
    }
    
    public class ProductWrapper {
        public Product2 productRecord {get; set;}
        public PriceBookEntry pricebookEntryRecord {get; set;}
        
        public ProductWrapper() {
            productRecord = new Product2();
            pricebookEntryRecord = new PriceBookEntry(PriceBook2Id=Constants.STANDARD_PRICEBOOK_ID);
        }
    }

}