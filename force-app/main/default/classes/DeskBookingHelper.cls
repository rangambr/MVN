/**
 * @description Helper class to support retrieve and manipulate Desk Booking data. Used within "deskBooking" lwc.
 */
public with sharing class DeskBookingHelper {

    @TestVisible
    private static Boolean simulateException = false;

    /**
     * @description Retrieves office records from the database. 
     *              Assumption: Maximum number of office records are limited to 10.
     */
    @AuraEnabled(cacheable=true)
    public static String getOffices() {
        try {
            if(simulateException) {
                throw new QueryException();
            }
            List<Office__c> offices = [SELECT Id, Name, Number_of_Columns__c FROM Office__c ORDER BY Name LIMIT 10 ];
            return JSON.serialize(offices);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
     * @description Retrives desk records and related bookings for a given office and a date of booking.   
     */
    @AuraEnabled
    public static String getDeskBookingData(Id officeId, Date bookingDate) {
        try {
            if(bookingDate == null) {
                throw new AuraHandledException(System.Label.Booking_Date_Null);
            }
            List<Desk__c> desks = [SELECT Id, Name, Desk_No__c, Floor__c, Office__r.Number_of_Columns__c,
                (SELECT Id, Desk__c, User__c, User__r.Name, User__r.FirstName,  User__r.SmallPhotoUrl 
                    FROM Desk_Bookings__r WHERE Date_of_Booking__c = :bookingDate)
                FROM Desk__c WHERE Office__c = :officeId WITH SECURITY_ENFORCED ORDER BY Floor__c, Desk_No__c ];
            return JSON.serialize(desks);
        } catch (Exception ex) {
            System.debug(ex.getMessage()+'-'+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Creates a single desk booking for the currently logged in user,  
     *              for a given desk and a date. Also removes any existing bookings for that date
     *              as only one user can be booked in for a given desk on a single day.
     */
    @AuraEnabled
    public static void createDeskBooking(Id deskId, Date bookingDate) {
        if(bookingDate == null) {
            throw new AuraHandledException(System.Label.Booking_Date_Null);
        }
        try {
            ManageBookings.deleteBooking(deskId, bookingDate);
            ManageBookings.insertBooking(deskId, bookingDate);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Delete desk booking for the current user for a given desk and a date.
     */
    @AuraEnabled
    public static void deleteDeskBooking(Id deskId, Date bookingDate) {
        try {
            if(bookingDate == null) {
                throw new AuraHandledException(System.Label.Booking_Date_Null);
            }
            ManageBookings.deleteBooking(deskId, bookingDate);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
