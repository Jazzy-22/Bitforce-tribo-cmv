@isTest
public class MPPreferenceHandlerTest {
	@isTest(seeAllData = true)
    static void successfulPost() {
        Test.setMock(HttpCalloutMock.class, new MPPreferenceCalloutMock());
        List<Pago__c> pagos = new List<Pago__c>();

        Contact cont = new Contact(LastName='testingClass');
        insert cont;
        Acreditaci_n__c acred = new Acreditaci_n__c(Contacto__c = cont.id);
        insert acred;
        for (Integer i = 0; i < 10; i++ ) {
            pagos.add(new Pago__c(Estado__c = 'Pendiente', Acreditaci_n_Certificaci_n__c = acred.Id, Importe__c = 200));
        }
        insert pagos;

        List<String> Ids = new List<String>();
        for (Pago__c p : pagos) {
            Ids.add(p.Id);
        }
        
        Test.startTest();
        MPPreferenceHandler.CreateMPPreferenceAction(Ids);
        Test.stopTest();
        
        Pago__c[] updatedPagos = [SELECT Id, Link_de_pago__c FROM Pago__c WHERE Id IN :Ids];
        Llamada_Api__c[] llamadasApi =  [SELECT Id, C_digo_respuesta__c, Con_error__c, Endpoint__c, M_todo__c FROM Llamada_Api__c WHERE Id_objeto__c IN :Ids];
        for (Llamada_API__c llamadaApi : llamadasApi) {
            System.assertEquals(201, llamadaApi.C_digo_respuesta__c);
            System.assertEquals(false, llamadaApi.Con_error__c);
            System.assertEquals('POST', llamadaApi.M_todo__c);
            System.assertEquals('https://api.mercadopago.com/checkout/preferences', llamadaApi.Endpoint__c);
        }
        for(Pago__c p : updatedPagos) {
            System.assertEquals('https://www.example.com/', p.Link_de_pago__c);
        }
        
    }

    @isTest(seeAllData = true)
    static void caughtPost() {
        Test.setMock(HttpCalloutMock.class, new MPPreferenceCalloutMock());
        
        List<Pago__c> pagos = new List<Pago__c>();

        Contact cont = new Contact(LastName='testingClass');
        insert cont;
        Acreditaci_n__c acred = new Acreditaci_n__c(Contacto__c = cont.id);
        insert acred;
        for (Integer i = 0; i < 10; i++ ) {
            pagos.add(new Pago__c(Estado__c = 'Pendiente', Acreditaci_n_Certificaci_n__c = acred.Id, Importe__c = 500));
        }
        insert pagos;

        List<String> Ids = new List<String>();
        for (Pago__c p : pagos) {
            Ids.add(p.Id);
        }
        
        Test.startTest();
        try { 
            MPPreferenceHandler.CreateMPPreferenceAction(Ids);
        } catch (Exception e) {
            Llamada_Api__c[] llamadasApi =  [SELECT Id, C_digo_respuesta__c, Con_error__c, Endpoint__c, M_todo__c FROM Llamada_Api__c WHERE Id_objeto__c IN :Ids];
            for (Llamada_API__c llamadaApi : llamadasApi) {
                System.assertNotEquals(201, llamadaApi.C_digo_respuesta__c);
                System.assertEquals(true, llamadaApi.Con_error__c);
                System.assertEquals('POST', llamadaApi.M_todo__c);
                System.assertEquals('https://api.mercadopago.com/checkout/preferences', llamadaApi.Endpoint__c);
                System.assertEquals('Error al comunicarse con Mercado Pago', e.getMessage().substring(0, 37));
            }  
        }
        Test.stopTest();
    }

    @isTest(seeAllData = true)
    static void failedPost() {
        List<Pago__c> pagos = new List<Pago__c>();

        Test.setMock(HttpCalloutMock.class, new MPPreferenceCalloutMock());
        Contact cont = new Contact(LastName='testingClass');
        insert cont;
        Acreditaci_n__c acred = new Acreditaci_n__c(Contacto__c = cont.id);
        insert acred;

        for (Integer i = 0; i < 10; i++ ) {
            pagos.add(new Pago__c(Estado__c = 'Pendiente', Acreditaci_n_Certificaci_n__c = acred.Id, Importe__c = 501));
        }
        insert pagos;

        List<String> Ids = new List<String>();
        for (Pago__c p : pagos) {
            Ids.add(p.Id);
        }
        
        Test.startTest();
        MPPreferenceHandler.CreateMPPreferenceAction(Ids);
        Test.stopTest(); 
        
        Pago__c[] updatedPagos = [SELECT Id, Link_de_pago__c FROM Pago__c WHERE Id IN :Ids];
        Llamada_Api__c[] llamadasApi =  [SELECT Id, C_digo_respuesta__c, Con_error__c, Endpoint__c, M_todo__c FROM Llamada_Api__c WHERE Id_objeto__c IN :Ids];
        for (Llamada_API__c llamadaApi : llamadasApi) {
            System.assertNotEquals(201, llamadaApi.C_digo_respuesta__c);
            System.assertEquals(true, llamadaApi.Con_error__c);
            System.assertEquals('POST', llamadaApi.M_todo__c);
            System.assertEquals('https://api.mercadopago.com/checkout/preferences', llamadaApi.Endpoint__c);
        }
        for(Pago__c p : updatedPagos) {
            System.assertEquals('Error al crear de la pref', p.Link_de_Pago__c.substring(0,25));
        }
        
    }
}