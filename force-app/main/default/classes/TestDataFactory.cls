@isTest
public class TestDataFactory {

    public static final String FLOOR_1 = 'Floor 1';
    public static final String FLOOR_2 = 'Floor 2';

    public static User createUser(Boolean insertToDatabase, String profileName, String permissionSetName, String emailAddress, String userNameString, String alias){
        List<Profile> p = [SELECT Id FROM Profile WHERE Name = :profileName];
        Id queriedProfileId = p[0].Id;

        User u = new User(
            Alias = alias, 
            Email = emailAddress,
            EmailEncodingKey = 'UTF-8', 
            Lastname = 'TESTING-MVN-USR', 
            LanguageLocaleKey = 'en_US',
            LocaleSIDKey = 'en_US', 
            ProfileId = queriedProfileId,
            TimezoneSIDKey = 'America/Los_Angeles', 
            Username = userNameString);

        if(insertToDatabase) {
            insert u;
        }

        if(permissionSetName != null && insertToDatabase) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Id = :permissionSetName LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id);
            insert psa;
        }
        return u;
    }

    public static Office__c createOffice(Boolean insertToDatabase, String name, Integer noOfCols) {
        Office__c office = new Office__c(Name = name, Number_of_Columns__c = noOfCols);

        if(insertToDatabase) {
            insert office;
        }
        return office;
    }

    public static List<Office__c> createOffices(Boolean insertToDatabase, String name, Integer noOfCols, Integer numberOfOffices) {
        List<Office__c> offices = new List<Office__c>();

        for(Integer i = 0; i < numberOfOffices; i++) {
            offices.add(createOffice(false, name + '' + i, noOfCols));
        }

        if(insertToDatabase) {
            insert offices;
        }

        return offices;
    }

    public static Desk__c createDesk(Boolean insertToDatabase, Id officeId, Integer deskNo, String floor) {
        Desk__c desk = new Desk__c(Office__c = officeId, Floor__c = floor, Desk_No__c = deskNo);

        if(insertToDatabase) {
            insert desk;
        }
        return desk;
    }

    public static List<Desk__c> createDesks(Boolean insertToDatabase, Id officeId, String floor, Integer numberOfDesks) {
        List<Desk__c> desks = new List<Desk__c> ();

        for(Integer i = 0; i < numberOfDesks; i++) {
            Desk__c desk = new Desk__c(Office__c = officeId, Floor__c = floor, Desk_No__c = i);
            desks.add(desk);
        }
        
        if(insertToDatabase) {
            insert desks;
        }
        return desks;
    }

    public static Desk_Booking__c createDeskBooking(Boolean insertToDatabase, Id deskId, Id userId, Date dateOfBooking) {

        Desk_Booking__c db = new Desk_Booking__c(Desk__c = deskId, User__c = userId, Date_of_Booking__c = dateOfBooking);

        if(insertToDatabase) {
            insert db;
        }

        return db;
    }
}
