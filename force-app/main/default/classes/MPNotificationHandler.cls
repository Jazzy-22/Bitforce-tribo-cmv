public without sharing class MPNotificationHandler {
    public static Integer processNotification(RestRequest req) {
        String topic = req.params.get('topic');
        String id = req.params.get('id');

        try {
            if(topic == 'payment'){
                Boolean processed = getPaymentInfo(id);
                if (processed == true) {
                    return 200;
                } else {
                    return 502;
                }
            } else {
                return 200; 
            }
        } catch (Exception ex) {
            return 500;
        }
    }
    
    private static boolean getPaymentInfo(String id) {
        if (String.isEmpty(id)) {
            throw new IllegalArgumentException('El id es obligatorio.');
        }

        String endpoint = 'callout:MP_Payments/' + id;
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setEndpoint(endpoint);
        
        try {
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 200) {
                MPPaymentDataType payment = (MPPaymentDataType) JSON.deserialize(httpResponse.getBody(), MPPaymentDataType.class);
                Map<String, Object> inputMap = new Map<String, Object>();
                inputMap.put('inputPayment', payment);

                Flow.Interview.PagoRecordFlow myFlow = new Flow.Interview.PagoRecordFlow(inputMap);
                myFlow.start();

                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            throw new CalloutException('Error al comunicarse con Mercado Pago: ' + e.getMessage());
        }
    }

}