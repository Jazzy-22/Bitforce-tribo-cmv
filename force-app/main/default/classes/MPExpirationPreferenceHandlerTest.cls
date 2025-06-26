@isTest
private class MPExpirationPreferenceHandlerTest {

    @isTest(seeAllData = true)
    static void expirationDateTest() {
        List<Pago__c> pagos = new List<Pago__c>();
        List<String> pagosIds = new List<String>();

        Contact cont = new Contact(LastName='testingClass');
        insert cont;
        Acreditaci_n__c acred = new Acreditaci_n__c(Contacto__c = cont.id);
        insert acred;

        // insert 10 accounts
        for (Integer i = 0; i < 10; i++ ) {
            pagos.add(new Pago__c(Link_de_Pago__c = 'https://www.mercadopago.cl/checkout/v1/redirect?pref_id=prefOk', Estado__c = 'Pendiente', Acreditaci_n_Certificaci_n__c = acred.Id, Importe__c = 200));
        }
        insert pagos;

        for (Pago__c pago : pagos) {
            
            pagosIds.add(pago.Id);
        }

        Test.setMock(HttpCalloutMock.class, new MPPreferenceCalloutMock());
        Test.startTest();
            MPExpirationPreferenceHandler.expiratePreferences(pagos);
        Test.stopTest();

        Llamada_Api__c[] llamadasApi =  [SELECT Id, C_digo_respuesta__c, Con_error__c, Endpoint__c, M_todo__c FROM Llamada_Api__c WHERE Id_objeto__c IN :pagosIds];
        System.assertEquals(10, llamadasApi.size());
        for (Llamada_API__c llamada : llamadasApi) {
            System.assertEquals(200, llamada.C_digo_respuesta__c);
            System.assertEquals(false, llamada.Con_error__c);
        }
    }

    @isTest(seeAllData = true)
    static void expirationDateTestWithError() {
        List<Pago__c> pagos = new List<Pago__c>();
        List<String> pagosIds = new List<String>();

        Contact cont = new Contact(LastName='testingClass');
        insert cont;
        Acreditaci_n__c acred = new Acreditaci_n__c(Contacto__c = cont.id);
        insert acred;

        // insert 10 accounts
        for (Integer i = 0; i < 10; i++ ) {
            pagos.add(new Pago__c(Link_de_Pago__c = 'https://www.mercadopago.cl/checkout/v1/redirect?pref_id=prefEr', Estado__c = 'Pendiente', Acreditaci_n_Certificaci_n__c = acred.Id, Importe__c = 200));
        }
        insert pagos;

        for (Pago__c pago : pagos) {
            
            pagosIds.add(pago.Id);
        }

        Test.setMock(HttpCalloutMock.class, new MPPreferenceCalloutMock());
        Test.startTest();
            MPExpirationPreferenceHandler.expiratePreferences(pagos);
        Test.stopTest();

        Llamada_Api__c[] llamadasApi =  [SELECT Id, C_digo_respuesta__c, Con_error__c, Endpoint__c, M_todo__c FROM Llamada_Api__c WHERE Id_objeto__c IN :pagosIds];
        System.assertEquals(10, llamadasApi.size());
        for (Llamada_API__c llamada : llamadasApi) {
            System.assertEquals(400, llamada.C_digo_respuesta__c);
            System.assertEquals(true, llamada.Con_error__c);
        }
    }

    @isTest(seeAllData = true)
        static void expirationDateTestWithException() {
        List<Pago__c> pagos = new List<Pago__c>();
        List<String> pagosIds = new List<String>();

        Contact cont = new Contact(LastName='testingClass');
        insert cont;
        Acreditaci_n__c acred = new Acreditaci_n__c(Contacto__c = cont.id);
        insert acred;

        // insert 10 accounts
        for (Integer i = 0; i < 10; i++ ) {
            pagos.add(new Pago__c(Link_de_Pago__c = 'https://www.mercadopago.cl/checkout/v1/redirect?pref_id=prefEx', Estado__c = 'Pendiente', Acreditaci_n_Certificaci_n__c = acred.Id, Importe__c = 200));
        }
        insert pagos;

        for (Pago__c pago : pagos) {
            
            pagosIds.add(pago.Id);
        }

        Test.setMock(HttpCalloutMock.class, new MPPreferenceCalloutMock());
        Test.startTest();
            MPExpirationPreferenceHandler.expiratePreferences(pagos);
        Test.stopTest();

        Llamada_Api__c[] llamadasApi =  [SELECT Id, C_digo_respuesta__c, Con_error__c, Endpoint__c, M_todo__c FROM Llamada_Api__c WHERE Id_objeto__c IN :pagosIds];
        System.assertEquals(10, llamadasApi.size());
        for (Llamada_API__c llamada : llamadasApi) {
            System.assertEquals(null, llamada.C_digo_respuesta__c);
            System.assertEquals(true, llamada.Con_error__c);
        }
    }
}