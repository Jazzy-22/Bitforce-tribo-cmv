public with sharing class MPPreferenceCreationQueueable implements Queueable, Database.AllowsCallouts{
    List<Pago__c> payments = new List<Pago__c>();

    public MPPreferenceCreationQueueable(List<String> pagosIds) {
        payments = [SELECT Id, Name, Importe__c FROM Pago__c WHERE Id IN :pagosIds];
    }
    
    public void execute(QueueableContext context){

        System.debug('execute ' + payments);
        Integer diff = payments.size() - 101 >= 0 ? payments.size() - 101 : -1;

        List<Map<String, Object>> llamadasAPI= new List<Map<String, Object>>();
        List<Pago__c> pagosToUpdate = new List<Pago__c>();

        for(Integer i = payments.size() - 1; i > diff; i-- ) {
            
            Map<String, Object> body = new Map<String, Object>();
            Map<String, Object> item = new Map<String, Object>();

            item.put('id', payments[i].Id);
            item.put('title', 'Pago CMV Chile');
            item.put('quantity', 1);
            item.put('unit_price', payments[i].Importe__c);

            List<Map<String, Object>> items = new List<Map<String, Object>>();
            items.add(item);

            Map<String, String> expDate = MPPreferenceHandler.getExpirationDateFormatted();

            body.put('items', items);
            body.put('external_reference', payments[i].Id);
            body.put('expires', expDate.keySet().size() > 0);
            body.put('expiration_date_from', expDate.get('from'));
            body.put('expiration_date_to', expDate.get('to'));
            
            String JSONBody = JSON.serialize(body);
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('POST');
            httpRequest.setEndpoint('callout:MP_Preference');
            httpRequest.setBody(JSONBody);

            Map<String, Object> llamada = new Map<String, Object>();
            try {
                HttpResponse httpResponse = http.send(httpRequest);
                
                llamada.put('id', payments[i].Id);
                llamada.put('response', httpResponse);
                llamada.put('request', httpRequest);

                if (httpResponse.getStatusCode() == 201) {      
                          
                    Map<String, Object> MapResp = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    llamada.put('message', null);
                    payments[i].Link_de_pago__c = String.ValueOf(MapResp.get('init_point'));
                } else {
                    llamada.put('message', 'Error al crear de la pref: ' + httpResponse.getBody());
                    payments[i].Link_de_pago__c = 'Error al crear de la pref: ' + httpResponse.getBody();
                }
                llamadasAPI.add(llamada);
            } catch (Exception e) {
                llamada.put('id', payments[i].Id);
                llamada.put('response', null);
                llamada.put('request', httpRequest);
                llamada.put('message', 'ERROR: '+e.getMessage());
                llamadasAPI.add(llamada);
                payments[i].Link_de_pago__c = 'Error al crear de la pref: ' + e.getMessage();
            }
            pagosToUpdate.add(payments[i]);
            payments.remove(i);
        }   
        update pagosToUpdate;
        for ( Map<String, Object> llamada : llamadasAPI ) {
            MPPreferenceHandler.createLlamadaAPIRecord('Pago', (String) llamada.get('id') , (HttpResponse) llamada.get('response'), (HttpRequest) llamada.get('request'), (String) llamada.get('message'));
        }  

        if(!payments.isEmpty()){
            List<String> Ids = new List<String>();
            for (Pago__c p : payments) {
                Ids.add(p.Id);
            }
            System.enqueueJob(new MPPreferenceCreationQueueable(Ids));
        }
    }
}