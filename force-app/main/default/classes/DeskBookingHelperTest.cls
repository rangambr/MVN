@isTest
private class DeskBookingHelperTest {
    @TestSetup
    private static void setupData() {

        User testUser = TestDataFactory.createUser(true, 'Standard Platform User', 'Desk Booking', 'test@test.com', 'mvntest@test-ne2cv4zrs1g2.com', 'testmvnX');
        List<Office__c> offices = TestDataFactory.createOffices(true, 'Test Office', 4, 2);

        List<Desk__c> off1Fl1 = TestDataFactory.createDesks(true, offices[0].Id, TestDataFactory.FLOOR_1, 16);
        List<Desk__c> off1Fl2 = TestDataFactory.createDesks(true, offices[0].Id, TestDataFactory.FLOOR_2, 16);
        List<Desk__c> off2Fl1 = TestDataFactory.createDesks(true, offices[1].Id, TestDataFactory.FLOOR_1, 16);
        List<Desk__c> off2Fl2 = TestDataFactory.createDesks(true, offices[1].Id, TestDataFactory.FLOOR_2, 16);

        TestDataFactory.createDeskBooking(true, off1Fl1[0].Id, testUser.Id, Date.newInstance(2020, 01, 01));
        TestDataFactory.createDeskBooking(true, off1Fl1[1].Id, UserInfo.getUserId(), Date.newInstance(2020, 01, 02));
        TestDataFactory.createDeskBooking(true, off1Fl1[2].Id, testUser.Id, Date.newInstance(2020, 01, 03));
    }
}