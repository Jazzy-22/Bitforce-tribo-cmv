public with sharing class MPTransactionDetails {
    @AuraEnabled
    public Decimal net_received_amount;

    @AuraEnabled
    public Decimal total_paid_amount;

    @AuraEnabled
    public Decimal overpaid_amount;

    @AuraEnabled
    public String external_resource_url;

    @AuraEnabled
    public Decimal installment_amount;

    @AuraEnabled
    public String financial_institution;

    @AuraEnabled
    public String payment_method_reference_id;

    @AuraEnabled
    public String payable_deferral_period;

    @AuraEnabled
    public String acquirer_reference;
}