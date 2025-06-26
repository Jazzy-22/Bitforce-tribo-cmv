@isTest
private class MPNotificationListenerTest {

    @TestSetup
    static void makeData(){
        Contact cont = new Contact(LastName='testing');
        insert cont;
        Acreditaci_n__c acred = new Acreditaci_n__c(Contacto__c = cont.id);
        insert acred;
        Pago__c pago = new Pago__c(Estado__c = 'Pendiente', Acreditaci_n_Certificaci_n__c = acred.Id, Importe__c = 501, Collector_Id__c = 'testpayment');
        insert pago;
    }
    
    @isTest
    static void testReceiveMPNotificationNoId() {
        RestContext.response = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestUri = '/notification/';
        req.httpMethod = 'POST';
        req.params.put('topic', 'payment');
        RestContext.request = req;
        Test.startTest();
        MPNotificationListener.receiveMPNotification();
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode);
    }

    @isTest
    static void testReceiveMPNotificationOtherTopic() {
        RestContext.response = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestUri = '/notification/';
        req.httpMethod = 'POST';
        req.params.put('topic', null);
        RestContext.request = req;
        Test.startTest();
        MPNotificationListener.receiveMPNotification();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @isTest
    static void testReceiveMPNotificationSuccess() {
        Pago__c pago = [SELECT Id FROM Pago__c WHERE Collector_Id__c = 'testpayment' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MPNotificationListenerCalloutMock());
        RestContext.response = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestUri = '/notification/';
        req.httpMethod = 'POST';
        req.params.put('topic', 'payment');
        req.params.put('id', pago.Id);
        RestContext.request = req;
        Test.startTest();
        MPNotificationListener.receiveMPNotification();
        Test.stopTest();
        Pago__c updatedPago = [SELECT Id, Estado__c FROM Pago__c WHERE Id =:pago.Id LIMIT 1];

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(updatedPago.Estado__c, 'Pagado');
    }

    @isTest
    static void testReceiveMPNotificationPaymentException() {
        Pago__c pago = [SELECT Id FROM Pago__c WHERE Collector_Id__c = 'testpayment' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MPNotificationListenerCalloutMock());
        RestContext.response = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestUri = '/notification/';
        req.httpMethod = 'POST';
        req.params.put('topic', 'payment');
        req.params.put('id', '123456789012345678');
        RestContext.request = req;
        Test.startTest();
        MPNotificationListener.receiveMPNotification();
        Test.stopTest();
        Pago__c updatedPago = [SELECT Id, Estado__c FROM Pago__c WHERE Id =:pago.Id LIMIT 1];

        System.assertEquals(502, RestContext.response.statusCode);
    }

    @isTest
    static void testReceiveMPNotificationCalloutException() {
        Pago__c pago = [SELECT Id FROM Pago__c WHERE Collector_Id__c = 'testpayment' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MPNotificationListenerCalloutMock());
        RestContext.response = new RestResponse();
        RestRequest req = new RestRequest();
        req.requestUri = '/notification/';
        req.httpMethod = 'POST';
        req.params.put('topic', 'payment');
        req.params.put('id', '111111111111111111');
        RestContext.request = req;
        Test.startTest();
        MPNotificationListener.receiveMPNotification();
        Test.stopTest();
        Pago__c updatedPago = [SELECT Id, Estado__c FROM Pago__c WHERE Id =:pago.Id LIMIT 1];

        System.assertEquals(500, RestContext.response.statusCode);
    }
}