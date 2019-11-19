@isTest
private class ManageBookingsTest {

    @TestSetup
    private static void setupData() {
        User testUser = TestDataFactory.createUser(true, 'Standard Platform User', 'test@test.com', 'mvntest@test-ne2cv4zrs1g2.com', 'testmvnX');
        List<Office__c> offices = TestDataFactory.createOffices(true, 'Test Office', 4, 2);

        List<String> floors = new List<String>{TestDataFactory.FLOOR_1, TestDataFactory.FLOOR_1};
        List<Desk__c> desks = TestDataFactory.createDesks(true, offices, floors, 16);
        
        TestDataFactory.createDeskBooking(true, desks[0].Id, testUser.Id, Date.newInstance(2020, 01, 01));
        TestDataFactory.createDeskBooking(true, desks[1].Id, UserInfo.getUserId(), Date.newInstance(2020, 01, 02));
        TestDataFactory.createDeskBooking(true, desks[2].Id, UserInfo.getUserId(), Date.newInstance(2020, 01, 03));
    }

    private static User getRunningUser() {
        User testUser = [SELECT Id FROM User WHERE Username = 'mvntest@test-ne2cv4zrs1g2.com' LIMIT 1];
        TestDataFactory.assignPermissionSet(testUser.Id, 'Desk_Booking');
        return testUser;
    }

    @IsTest
    private static void testDeleteBooking() {
        User runningUser = getRunningUser();
        System.runAs(runningUser) {

            Desk_Booking__c booking = [SELECT Id, Desk__c FROM Desk_Booking__c WHERE User__c = :runningUser.Id LIMIT 1];
            Date dateOfBooking = Date.newInstance(2020, 01, 01);

            Test.startTest();
            ManageBookings.deleteBooking(booking.Desk__c, dateOfBooking);
            Test.stopTest();

            Desk_Booking__c[] newBooking = [SELECT Id, Desk__c, User__c, Date_of_Booking__c FROM Desk_Booking__c WHERE User__c = :runningUser.Id];
            
            System.assertEquals(0, newBooking.size(), 'Desk booking must be deleted.');
        }
    }

    @IsTest
    private static void testInsertBooking() {
        User runningUser = getRunningUser();
        System.runAs(runningUser) {

            Desk_Booking__c booking = [SELECT Id, Desk__c FROM Desk_Booking__c WHERE User__c = :runningUser.Id LIMIT 1];
            Desk__c newDesk = [SELECT Id FROM Desk__c WHERE Id != :booking.Desk__c LIMIT 1];
            Date dateOfBooking = Date.newInstance(2020, 01, 01);

            Test.startTest();
            ManageBookings.insertBooking(newDesk.Id, dateOfBooking);
            Test.stopTest();

            Desk_Booking__c[] newBooking = [SELECT Id, Desk__c, User__c, Date_of_Booking__c FROM Desk_Booking__c WHERE User__c = :runningUser.Id];
            System.assertEquals(2, newBooking.size(), 'Duplicate booking record created');
        }
    }
}
