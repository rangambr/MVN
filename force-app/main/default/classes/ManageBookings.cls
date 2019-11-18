public without sharing class ManageBookings {

    public static void deleteBooking(Id deskId, Date bookingDate) {
        List<Desk_Booking__c> existingBookings = [SELECT Id FROM Desk_Booking__c WHERE Date_of_Booking__c = :bookingDate AND User__c = :UserInfo.getUserId()];
        delete existingBookings;
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
