public with sharing class MPExpirationPreferenceHandler {

    @InvocableMethod(label='Expirate Preference' description= 'Recibe los pagos con sus links a expirar y expira los links.')
    public static void expiratePreferences(List<Pago__c> pagos) {
        System.enqueueJob(new MPPreferenceExpirationQueueable(pagos));
    } 

}