/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public without sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
            
        CollaborationGroup collab = new CollaborationGroup();
        collab.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
        collab.CollaborationType = 'Public';
        return collab;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> products = new List<Product2>();
        
        for(Integer i = 0; i < cnt; i++) {
            Product2 product = new Product2();
            product.Name = 'Test' + i;
            product.IsActive = true;
            product.Initial_Inventory__c = 10;
            product.Family = Constants.PRODUCT_FAMILY[Math.mod(i, Constants.PRODUCT_FAMILY.size())].getValue();
            products.add(product);
        }
        return products;
        
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for(Product2 product : prods) {
            PricebookEntry entry = new PricebookEntry();
            entry.IsActive = true;
            entry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            entry.Product2Id = product.Id;
            entry.UnitPrice = 100;
            entries.add(entry);
        }
        return entries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accts = new List<Account>();
        for(Integer i = 0; i < cnt; i++) {
            Account acct = new Account();
            acct.Name = 'TestAcct' + i;
            accts.add(acct);
        }
        return accts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> contacts = new List<Contact>();
        for(Account acct : accts) {
            Contact contact = new Contact();
            contact.LastName = 'TestLast' + acct.Name;
            contact.AccountId = acct.Id;
            if(contacts.size() < cnt) {
                contacts.add(contact);
            }
        }
        return contacts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> orders = new List<Order>();
        
        for(Integer i = 0; i < cnt; i++) {
            Order ord = new Order();
            ord.AccountId = accts[i].Id;
            ord.EffectiveDate = Date.today();
            ord.Status = Constants.DRAFT_ORDER_STATUS;
            ord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            orders.add(ord);
        }
        return orders;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> orderItems = new List<OrderItem>();
        
        for(Integer i = 0; i < cnt; i++) {
            OrderItem item = new OrderItem();
            item.OrderId = ords[i].Id;
            item.PricebookEntryId = pbes[i].Id;
            item.Quantity = Constants.DEFAULT_ROWS;
            item.UnitPrice = i + 1;
            orderItems.add(item);
        }
        return orderItems;
    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        System.assertEquals(originalProduct.Quantity_Ordered__c + qtyOrdered, updatedProduct.Quantity_Ordered__c);
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        insert ConstructCollaborationGroup();
        
		List<Product2> prods = ConstructProducts(cnt);
        insert prods;
        List<PricebookEntry> entries = ConstructPricebookEntries(prods);
        insert entries;
        
        List<Account> accts = ConstructAccounts(cnt);
        insert accts;
        
        List<Contact> contacts = ConstructContacts(cnt, accts);
        insert contacts;
        
        List<Order> orders = ConstructOrders(cnt, accts);
        insert orders;
        
        List<OrderItem> orderItems = ConstructOrderItems(cnt, entries, orders);
        insert orderItems;
        
    }

}