/**
 * @description Utility class set to "without sharing" which is used to delete and create Desk Booking records overriding user sharing.
 *              As OWD on Office__c is set to Public Readonly, sharing has to be overriden in order to users to be 
 *              able to create or delete Desk_Booking__c reocrds.
 */
public without sharing class ManageBookings {

    public static void deleteBooking(Id deskId, Date bookingDate) {
        List<Desk_Booking__c> existingBookings = [SELECT Id FROM Desk_Booking__c WHERE Date_of_Booking__c = :bookingDate AND User__c = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
        if(existingBookings.size() > 0) {
            delete existingBookings;
        }
    }

    public static Desk_Booking__c insertBooking(Id deskId, Date bookingDate) {
        Desk_Booking__c deskBooking = new Desk_Booking__c(
                Desk__c = deskId,
                User__c = UserInfo.getUserId(),
                Date_of_Booking__c = bookingDate);
        
            insert deskBooking;
        return deskBooking;
    } 
}
