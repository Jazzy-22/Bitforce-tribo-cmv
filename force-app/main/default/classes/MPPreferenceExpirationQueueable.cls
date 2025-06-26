public with sharing class MPPreferenceExpirationQueueable implements Queueable, Database.AllowsCallouts{
    
    List<Pago__c> payments = new List<Pago__c>();

    public MPPreferenceExpirationQueueable(List<Pago__c> pagos) {
       payments = pagos;
    }

    public void execute(QueueableContext context){
        Integer diff = payments.size() - 101 >= 0 ? payments.size() - 101 : -1;

        List<Map<String, Object>> llamadasAPI= new List<Map<String, Object>>();

        // Loopeo los pagos con link de pago
        for(Integer i = payments.size() - 1; i > diff; i-- ) {
            // Set el callout
            String endpoint = 'callout:MP_Preference/'+ payments[i].Link_de_Pago__c.right(47);
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod('PUT');  
            Map<String, Object> preference = new Map<String, Object>{'expiration_date_to' => String.ValueOf(DateTime.newInstance(DateTime.now().DateGmt(),DateTime.now().timeGmt())).replace(' ', 'T')};
            httpRequest.setBody(JSON.serialize(preference));
            Map<String, Object> llamada = new Map<String, Object>();
            try {
                HttpResponse httpResponse = http.send(httpRequest);
                llamada.put('id', payments[i].Id);
                llamada.put('response', httpResponse);
                llamada.put('request', httpRequest);
                
                if (httpResponse.getStatusCode() == 200) {
                    llamada.put('message', null);
                } else {
                    llamada.put('message', 'Error al expirar Link de Pago');
                }

            } catch(Exception ex) {
                llamada.put('id', payments[i].Id);
                llamada.put('response', null);
                llamada.put('request', httpRequest);
                llamada.put('message', 'ERROR: '+ ex.getMessage());
            }  
            llamadasAPI.add(llamada);    
            payments.remove(i);     
        }
        for ( Map<String, Object> llamada : llamadasAPI ) {
            MPPreferenceHandler.createLlamadaAPIRecord('Pago', (String) llamada.get('id') , (HttpResponse) llamada.get('response'), (HttpRequest) llamada.get('request'), (String) llamada.get('message'));
        } 
        if(!payments.isEmpty()){
            System.enqueueJob(new MPPreferenceExpirationQueueable(payments));
        }
    }
}