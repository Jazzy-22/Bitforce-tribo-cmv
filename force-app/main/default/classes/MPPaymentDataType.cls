global class MPPaymentDataType {
        @AuraEnabled
        public Decimal transaction_amount_refunded;
        
        @AuraEnabled
        public Decimal collector_id;
        
        // @AuraEnabled
        // public String counter_currency;
        
        @AuraEnabled
        public String currency_id;
        
        @AuraEnabled
        public String date_approved;
        
        @AuraEnabled
        public String date_created;
        
        @AuraEnabled
        public String date_last_updated;
        
        // @AuraEnabled
        // public String date_of_expiration;
        
        @AuraEnabled
        public String external_reference;

        @AuraEnabled
        public MPMetadata metadata;
        
        @AuraEnabled
        public String money_release_date;
        
        // @AuraEnabled
        // public String money_release_schema;
        
        @AuraEnabled
        public Decimal id;
        
        @AuraEnabled
        public String operation_type;
        
        // @AuraEnabled
        // public MPPayer payer;
        
        // @AuraEnabled
        // public String payment_method;
        
        @AuraEnabled
        public String payment_type_id;
        
        @AuraEnabled
        public String status;
        
        @AuraEnabled
        public String status_detail;
        
        @AuraEnabled
        public Decimal transaction_amount;

        @AuraEnabled
        public MPTransactionDetails transaction_details;
        
        
        public MPPaymentDataType(){}

        public with sharing class MPPayer {
                @AuraEnabled
                public String email;
                
                // @AuraEnabled
                // public String first_name;    viene null
                
                @AuraEnabled
                public Decimal id;
                
                // @AuraEnabled
                // public String last_name;     viene null
                
                // @AuraEnabled
                // public String type;          viene null
        }
        
}