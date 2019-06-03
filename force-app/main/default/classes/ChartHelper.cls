public without sharing class ChartHelper {

    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();
        for(AggregateResult result : [Select Family, SUM(Quantity_Remaining__c) quantity
                                         From Product2
                                         where IsActive = true and Quantity_Remaining__c > 0
                                         Group By Family])
        {
            String family = String.valueOf(result.get('Family'));
            Decimal quantity = Decimal.valueOf(String.valueOf(result.get('quantity'))); 
            ChartData chart = new ChartData(family, quantity);
            cht.add(chart);
        }
        //ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        //  And return a list of chartData
        //  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}