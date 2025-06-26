@RestResource(urlMapping='/notification/*')

global with sharing class MPNotificationListener {    
    @HttpPost
    global static void receiveMPNotification() {
        RestRequest req = RestContext.request;            
        RestResponse res = RestContext.response;
        Integer resCode = MPNotificationHandler.processNotification(req);
        res.statusCode = resCode;
    }

}