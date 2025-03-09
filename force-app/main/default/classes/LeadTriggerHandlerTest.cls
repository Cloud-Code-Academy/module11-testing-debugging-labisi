@isTest 
public class LeadTriggerHandlerTest {

     @TestSetup  static void setupData() {

     List<Account> testAccounts = new List<Account>{
                new Account(Name = 'TestContact1'),
               new Account(Name = 'TestContact2')
              };
    
          insert testAccounts;
             List<Contact> testContacts = new List<Contact>{
                new Contact(LastName = 'TestContact1', Email = 'TL1@TEST.COM',AccountId = testAccounts[0].Id),
                new Contact(LastName = 'TestContact2', Email = 'TL2@TEST.COM',AccountId = testAccounts[0].Id),
                new Contact(LastName = 'TestContact3', Email = 'TL3@TEST.COM',AccountId = testAccounts[1].Id),
                new Contact(LastName = 'TestContact31', Email = 'TL3@TEST.COM',AccountId = testAccounts[1].Id),
                new Contact(LastName = 'TestContact4', Email = 'TL@TEST.COM',AccountId = testAccounts[1].Id)
            };
            insert testContacts;
        
    } 

    // Test method for handleTitleNormalization
    @isTest
    static void testTitleNormalization() {
        // Create test leads with different title variations
        List<Lead> testLeads = new List<Lead>{
            new Lead(FirstName='Test1', LastName='Lead1', Company='Test Co', Title='vp of sales'),
            new Lead(FirstName='Test2', LastName='Lead2', Company='Test Co', Title='v.p. marketing'),
            new Lead(FirstName='Test3', LastName='Lead3', Company='Test Co', Title='head of department'),
            new Lead(FirstName='Test4', LastName='Lead4', Company='Test Co', Title='chief technology'),
            new Lead(FirstName='Test5', LastName='Lead5', Company='Test Co', Title='jr analyst')
        };
        
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(testLeads);
        Test.stopTest();
        
        // Verify title normalizations
        System.assertEquals('Vice President', testLeads[0].Title, 'Title should be normalized to Vice President');
        System.assertEquals('Vice President', testLeads[1].Title, 'Title should be normalized to Vice President');
        System.assertEquals('Manager', testLeads[2].Title, 'Title should be normalized to Manager');
        System.assertEquals('Executive', testLeads[3].Title, 'Title should be normalized to Executive');
        System.assertEquals('Assistant', testLeads[4].Title, 'Title should be normalized to Assistant');
    }
    


    // Test method for handleAutoLeadScoring
    @isTest
    static void testAutoLeadScoring() {
        // Create test leads with different scoring criteria
        List<Lead> testLeads = new List<Lead>{
            new Lead(
                FirstName='Test1',
                LastName='Lead1',
                Company='Test Co',
                LeadSource='Website',
                Email='test1@example.com',
                Phone='1234567890',
                Industry='Technology'
            ),
            new Lead(
                FirstName='Test2',
                LastName='Lead2',
                Company='Test Co',
                LeadSource='Website',
                Email='test2@example.com'
            ),
            new Lead(
                FirstName='Test3',
                LastName='Lead3',
                Company='Test Co',
                Phone='9876543210'
            )
        };
        
        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(testLeads);
        Test.stopTest();
        
        // Verify scores
        System.assertEquals(18, testLeads[0].Lead_Score__c, 'Lead should have maximum score of 18');
        System.assertEquals(3, testLeads[1].Lead_Score__c, 'Lead should have score of 3 for website source and email');
        System.assertEquals(5, testLeads[2].Lead_Score__c, 'Lead should have score of 5 for phone');
    }
 
// Test method for handleLeadAutoConvert (positive case)
 @isTest
 static void testHandleLeadAutoConvert(){
    List <Lead> leadList = new List<Lead>();
    Lead  l1 = new Lead(LastName = 'Test1234', Company = 'Test Comp', Email = 'TL1@TEST.COM');
    Lead  l2 = new Lead(LastName = 'Test123', Company = 'Test Comp', Email = 'L2@TEST.COM');
    leadList.add(l1);
    leadList.add(l2);
    //insert leadList;

     Test.startTest();
     insert leadList;
     //LeadTriggerHandler.handleLeadAutoConvert(leadList);
     Test.stopTest();
    //  Database.LeadConvert lc = new Database.LeadConvert();
    //      lc.setLeadId(l.Id);
   
    Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :l1.Id];
     System.assertEquals(true, convertedLead.IsConverted, 'Lead should have been converted');

    
 }
 

 // Test method for handleLeadAutoConvert (negative case - no matching contact)
 @IsTest
 static void testHandleLeadAutoConvertNegative(){
    List <Lead> leadList = new List<Lead>();
    Lead  lead2 = new Lead(LastName = 'Testlead123', Company = 'Test Comp', Email = 'L2@TEST.COM');
    leadList.add(lead2);
    //insert leadList;

     Test.startTest();
     insert leadList;
     //LeadTriggerHandler.handleLeadAutoConvert(leadList);
     Test.stopTest();
     Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :lead2.Id];
     System.assertEquals(false, convertedLead.IsConverted, 'Lead should not have been converted');
}

 // Test method for handleLeadAutoConvert (multiple contact case )
 @IsTest
 static void testHandleLeadAutoConvertMultiple(){
    List <Lead> leadList = new List<Lead>();
    Lead mLead = new Lead(LastName = 'Testlead123', Company = 'Test Comp', Email = 'TL3@TEST.COM');
    leadList.add(mlead);
    //insert leadList;

    Test.startTest();
    insert leadList;
     //LeadTriggerHandler.handleLeadAutoConvert(leadList);
     Test.stopTest();
     Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :mLead.Id];
     System.assertEquals(false, convertedLead.IsConverted, 'Lead should not have been converted');
 }

 @isTest
 static void testHandleLeadAutoConvertUpdateLead(){
    List <Lead> leadList = new List<Lead>();
    Lead  l1 = new Lead(LastName = 'Testy1', Company = 'Test Comp', Email = 'Testy1@TEST.COM');
    Lead  l2 = new Lead(LastName = 'Testy2', Company = 'Test Comp', Email = 'testy2@TEST.COM');
    leadList.add(l1);
    leadList.add(l2);
    insert leadList;

    // l2.Email = 'TL@TEST.COM';
    //  update l2;

     Test.startTest();
     l2.Email = 'TL@TEST.COM';
     update l2;
    // LeadTriggerHandler.handleLeadAutoConvert(leadList);
     Test.stopTest();
    
   
    Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :l2.Id];
     System.assertEquals(true, convertedLead.IsConverted, 'Lead should have been converted');

    
 }
}