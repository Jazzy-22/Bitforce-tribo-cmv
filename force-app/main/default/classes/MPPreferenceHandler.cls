public with sharing class MPPreferenceHandler {


    public static Map<String, String> getExpirationDateFormatted(){
        try{
            List<Expiration_Date_Days__mdt> daysRecords = [SELECT Days__c FROM Expiration_Date_Days__mdt LIMIT 1];

	    DateTime now = DateTime.newInstance(DateTime.now().DateGmt(),DateTime.now().timeGmt());    
            return new Map<String, String>{
                'from' => String.ValueOf(now).replace(' ','T'),
                'to' => String.ValueOf(now.addDays(Integer.ValueOf(daysRecords[0].Days__c))).replace(' ','T')
            };
        } catch(Exception e){
            return new Map<String, String>();
        }
    }

    @InvocableMethod(label='CreateMPPreference' description = 'Recibe los Ids de los registro de tipo Pago__c y crea links de pago para cada registro mediante una clase Queueable.')
    public static void CreateMPPreferenceAction(List<String> Id) {
        System.enqueueJob(new MPPreferenceCreationQueueable(Id));
    }


    public static void createLlamadaAPIRecord(String objName, String objId, HttpResponse httpResponse , HttpRequest httpRequest, String errorMessage ) {
       	String endpoint = ConnectApi.NamedCredentials.getNamedCredential('MP_Preference').calloutUrl;
        
        Llamada_API__c llamadaApi = new Llamada_API__c();
        if (httpResponse != null) {
            llamadaApi.C_digo_respuesta__c = httpResponse.getStatusCode();
            llamadaApi.Respuesta__c = httpResponse.getBody().abbreviate(131072);
            llamadaApi.Con_error__c = httpResponse.getStatusCode() == 201 || httpResponse.getStatusCode() == 200 ? false : true;
        } else {
            llamadaApi.Con_error__c = true;
            llamadaApi.Respuesta__c = errorMessage;
        }
        
        llamadaApi.Endpoint__c = endpoint;
        llamadaApi.Id_objeto__c = objId;
        llamadaApi.M_todo__c = httpRequest.getMethod();
        llamadaApi.Solicitud__c = httpRequest.getBody();
        llamadaApi.Objeto__c = objName;
        insert llamadaApi; 
        
    }
}
