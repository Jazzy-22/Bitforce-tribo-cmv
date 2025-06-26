global class MPNotificationListenerCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String pagoId = req.getEndpoint().right(18);
        res.setHeader('Content-Type', 'application/json');
        if (pagoId == '123456789012345678') {
            res.setBody('{"error": "payment not found"}');
            res.setStatusCode(404);
        } else if (pagoId == '111111111111111111') {
            res.setStatusCode(200);
        } else {
            res.setBody('{"external_reference": "'+pagoId+'", "status": "approved", "id": 123456}');
            res.setStatusCode(200);
        }
        return res;
    }
}