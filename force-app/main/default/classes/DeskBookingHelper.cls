public with sharing class DeskBookingHelper {

    @AuraEnabled(cacheable=true)
    public static String getOffices() {
        List<Office__c> offices = [SELECT Id, Name, Number_of_Columns__c FROM Office__c ORDER BY Name LIMIT 10 ];
        return JSON.serialize(offices);
    }
    
    @AuraEnabled
    public static String getDeskBookingData(Id officeId, Date bookingDate) {
        List<Desk__c> desks = [SELECT Id, Name, Desk_No__c, Floor__c, Office__r.Number_of_Columns__c,
            (SELECT Id, Desk__c, User__c, User__r.Name, User__r.FirstName,  User__r.SmallPhotoUrl 
                FROM Desk_Bookings__r WHERE Date_of_Booking__c = :bookingDate)
            FROM Desk__c WHERE Office__c = :officeId ORDER BY Floor__c, Desk_No__c];
        return JSON.serialize(desks);
    }

    @AuraEnabled
    public static String createDeskBooking(Id deskId, Date bookingDate) {
        try {
            ManageBookings.deleteBooking(deskId, bookingDate);
            Desk_Booking__c deskBooking = ManageBookings.insertBooking(deskId, bookingDate);

            deskBooking = getUserDeskBooking(deskBooking.Id);
            return JSON.serialize(deskBooking);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteDeskBooking(Id deskId, Date bookingDate) {
        try {
            ManageBookings.deleteBooking(deskId, bookingDate);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static Desk_Booking__c getUserDeskBooking(Id bookingId) {
        Desk_Booking__c deskBooking = [SELECT Id, Desk__c, User__c, User__r.Name, User__r.FirstName,  User__r.SmallPhotoUrl FROM Desk_Booking__c WHERE Id = :bookingId LIMIT 1];
        return deskBooking;
    }
}
