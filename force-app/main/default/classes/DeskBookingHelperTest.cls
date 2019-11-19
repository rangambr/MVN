@isTest
private class DeskBookingHelperTest {

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
    private static void testGetOffices() {
        
        System.runAs(getRunningUser()) {

            Test.startTest();
            String officeInfo = DeskBookingHelper.getOffices();
            Test.stopTest();

            List<Office__c> offices = (List<Office__c>) JSON.deserialize(officeInfo, List<Office__c>.class);
            System.assertEquals(2, offices.size(), 'Office records not generated.');

            for(Office__c office : offices) {
                System.assertEquals(4, office.Number_of_Columns__c, 'Number of columns not set correctly.');
            }
        }
    }

    @IsTest
    private static void testGetOfficesWithException() {
        System.runAs(getRunningUser()) {
            DeskBookingHelper.simulateException = true;
            try{
                Test.startTest();
                DeskBookingHelper.getOffices();
                Test.stopTest();

                System.assert(false, 'Query exception is expected.');
            } catch(Exception ex) {
                System.assertNotEquals(null, ex, 'Query exception is expected.');
            }
        }
    }

    @IsTest
    private static void testGetDeskBookingDataWithValidInputs() {
        
        System.runAs(getRunningUser()) {
            Office__c office = [SELECT Id FROM Office__c LIMIT 1];
            Date  dt = Date.newInstance(2020, 01, 01);

            Test.startTest();
            String deskInfo = DeskBookingHelper.getDeskBookingData(office.Id, dt);
            Test.stopTest();

            List<Desk__c> desks = (List<Desk__c>)JSON.deserialize(deskInfo, List<Desk__c>.class);

            System.assertEquals(32, desks.size(), 'Desks not retrieved.');
        }
    }

    @IsTest
    private static void testGetDeskBookingDataWithInValidInputs() {
        
        System.runAs(getRunningUser()) {
            try {
                Test.startTest();
                DeskBookingHelper.getDeskBookingData('!@£$%^&', null);
                Test.stopTest();

                System.assert(false, 'Exception is expected by setting an invalid Id');
            } catch (Exception ex) {
                System.assertNotEquals(null, ex, 'Invalid Id exception expected.');
            }
           
        }
    }

    @IsTest
    private static void testGetDeskBookingDataWithNullInputs() {
        System.runAs(getRunningUser()) {
            try {
                Test.startTest();
                String deskInfo = DeskBookingHelper.getDeskBookingData(null, null);
                Test.stopTest();

                System.assert(false, 'Date validation exception is expected');
            } catch (Exception ex) {
                System.assertNotEquals(null, ex, 'Date validation exception is expected');
            }
        }
    }

    @IsTest
    private static void testCreateBookingWithValidData() {
        User runningUser = getRunningUser();
        System.runAs(runningUser) {

            Desk_Booking__c booking = [SELECT Id, Desk__c FROM Desk_Booking__c WHERE User__c = :runningUser.Id LIMIT 1];
            Desk__c newDesk = [SELECT Id FROM Desk__c WHERE Id != :booking.Desk__c LIMIT 1];
            Date dateOfBooking = Date.newInstance(2020, 01, 01);

            Test.startTest();
            DeskBookingHelper.createDeskBooking(newDesk.Id, dateOfBooking);
            Test.stopTest();

            Desk_Booking__c[] newBooking = [SELECT Id, Desk__c, User__c, Date_of_Booking__c FROM Desk_Booking__c WHERE User__c = :runningUser.Id];
            
            System.assertEquals(1, newBooking.size(), 'Duplicate booking record created');
            System.assertEquals(newDesk.Id, newBooking[0].Desk__c, 'Booked desk is incorrect.');
            System.assertEquals(runningUser.Id, newBooking[0].User__c, 'Booked user is incorrect.');
            System.assertEquals(dateOfBooking, newBooking[0].Date_of_Booking__c, 'Booked date is incorrect.');
        }
    }

    @IsTest
    private static void testCreateBookingWithInvalidData() {
        
        System.runAs(getRunningUser()) {
            try {
                Test.startTest();
                DeskBookingHelper.createDeskBooking('!@£$%^&*', null);
                Test.stopTest();

                System.assert(false, 'Exception is expected by setting an invalid Id');
            } catch (Exception ex) {
                System.assertNotEquals(null, ex, 'Invalid Id exception expected.');
            }
        }
    }

    @IsTest
    private static void testCreateDeskBookingWithNullInputs() {
        System.runAs(getRunningUser()) {
            try {
                Test.startTest();
                DeskBookingHelper.createDeskBooking(null, null);
                Test.stopTest();
                System.assert(false, 'Date validation exception is expected.');
            } catch (Exception ex) {
                System.assertNotEquals(null, ex, 'Date validation exception is expected.');
            }
        }
    }

    @IsTest
    private static void testCreateDeskBookingWithInvalidId() {
        System.runAs(getRunningUser()) {
            try {
                Test.startTest();
                DeskBookingHelper.createDeskBooking(null, Date.newInstance(2020, 02, 01));
                Test.stopTest();
                System.assert(false, 'Invalid Id exception expected');
            } catch (Exception ex) {
                System.assertNotEquals(null, ex, 'Invalid Id exception expected.');
            }
        }
    }

    @IsTest
    private static void testDeleteBookingWithValidData() {
        User runningUser = getRunningUser();
        System.runAs(runningUser) {

            Desk_Booking__c booking = [SELECT Id, Desk__c FROM Desk_Booking__c WHERE User__c = :runningUser.Id LIMIT 1];
            Date dateOfBooking = Date.newInstance(2020, 01, 01);

            Test.startTest();
            DeskBookingHelper.deleteDeskBooking(booking.Desk__c, dateOfBooking);
            Test.stopTest();

            Desk_Booking__c[] newBooking = [SELECT Id, Desk__c, User__c, Date_of_Booking__c FROM Desk_Booking__c WHERE User__c = :runningUser.Id];
            
            System.assertEquals(0, newBooking.size(), 'Desk booking must be deleted.');
        }
    }

    @IsTest
    private static void testDeleteBookingWithNullValues() {
        User runningUser = getRunningUser();
        System.runAs(runningUser) {
            try {
                Test.startTest();
                DeskBookingHelper.deleteDeskBooking(null, null);
                Test.stopTest();
                System.assert(false, 'Date validation exception is expected.');
            } catch (Exception ex) {
                System.assertNotEquals(null, ex, 'Date validation exception is expected.');
            }
        }
    }
}