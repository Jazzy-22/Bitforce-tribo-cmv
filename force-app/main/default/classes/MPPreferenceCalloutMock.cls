global class MPPreferenceCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String method = req.getMethod();
        String id = req.getEndpoint().right(6);
        string body = req.getBody();      
        Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(body);
        
        if(method == 'POST' && String.valueOf(bodyMap.get('items')).contains('200')) {
            if (String.valueOf(bodyMap.get('items')).contains('200')) {
            res.setBody('{"init_point": "https://www.example.com/"}');
            res.setStatusCode(201);
            } else if (String.valueOf(bodyMap.get('items')).contains('500')) {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                throw e;
            } else {
                res.setBody('{"status": "error"}');
                res.setStatusCode(400);
            }

        } else if (method == 'PUT' && String.valueOf(bodyMap.get('expiration_date_to')) != null ) {
            if(id == 'prefOk') {
                res.setStatusCode(200);
            } else if (id == 'prefEr') {
                res.setStatusCode(400);
            } else if (id == 'prefEx') {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                throw e;
            }
        }

        
        return res;
    } 
}