/*
 * The `LeadTriggerHandler` class contains methods designed to handle various business requirements around
 * the Lead object in Salesforce. This includes functionality like normalizing the title field of a lead, 
 * automatically scoring leads based on certain criteria, and auto-converting leads when certain conditions are met.
 * - Create a test class for `LeadTriggerHandler` to ensure all methods work as expected.
 * - Update the LeadTrigger class to call the `LeadTriggerHandler` methods as needed.
 *
 * Students should note:
 * - This class may contain intentional errors that need to be fixed for proper functionality.
 * - Create a corresponding test class for `LeadTriggerHandler` to ensure all methods work as expected.
 *   Both positive and negative test cases should be considered.
 *
 * Documentation on Lead conversion and Test Classes can be found here:
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_convertLead.htm
 * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_test.htm
 */
public with sharing class LeadTriggerHandler {
	/* 
	 * Question 1
	 * Requirement Lead Title Normalization - handleTitleNormalization
	 * Occasionally, users input titles in a variety of ways. Streamline these titles for consistency:
	 *
	 * Criteria:
	 * - If the title contains terms such as 'vp', 'v.p.', or 'vice president',
	 *   change the title to 'Vice President'.
	 * - If the title contains terms like 'mgr', 'manage', or 'head of department',
	 *   change the title to 'Manager'.
	 * - Should the title include words like 'exec', 'chief', or 'head',
	 *   change the title to 'Executive'.
	 * - If the title contains terms like 'assist', 'deputy', or 'jr',
	 *   change the title to 'Assistant'.
	 */
	public static void handleTitleNormalization(List<Lead> leadsToNormalize) {
		for (Lead ld : leadsToNormalize) {
			if (ld.Title != null) {
			if (ld.title.contains('vp') || ld.title.contains('v.p.') || ld.title.contains('vice president')) {
				ld.Title = 'Vice President';
			} else if (
				ld.title.contains('mgr') ||
				ld.title.contains('manage') ||
				ld.title.contains('head of department')
			) {
				ld.Title = 'Manager';
			} else if (ld.title.contains('exec') || ld.title.contains('chief') || ld.title.contains('head')) {
				ld.Title = 'Executive';
			} else if (ld.title.contains('assist') || ld.title.contains('deputy') || ld.title.contains ('jr')) {
				ld.Title = 'Assistant';
			}
		}
	}
	}

	/* 
	 * Question 2
	 * Requirement Auto Lead Scoring - handleAutoLeadScoring
	 * Implement logic to automatically assign scores to leads based on specific criteria.
	 * 18 should be highest possible score a lead can have.
	 *
	 * Criteria:
	 * - If the lead source is from the website and an email exists, increment score by 3 points.
	 * - If the lead provides a phone number, increment score by 5 points.
	 * - If the lead belongs to the 'Technology' industry, increment score by another 10 points.
	 */
	public static void handleAutoLeadScoring(List<Lead> leadsToScore) {
		for (Lead ld : leadsToScore) {
			Integer score = 0;

			// Check and add points based on the specified conditions
			if (ld.LeadSource == 'Website' && ld.Email != null) {
				score += 3;
			}

			if (ld.Phone != null) {
				score += 5;
			}

			if (ld.Industry == 'Technology') {
				score += 10;
			}

			ld.Lead_Score__c = score; // Set the computed score back to the lead
		}
	}

	/* 
	 * Question 3
	 * Requirement Automatic Lead Conversion Based on Email Match - handleLeadAutoConvert
	 * Whenever a new Lead is created or an existing Lead's email address is updated,
	 * check for a matching Contact based on the email address. If a single matching
	 * Contact is identified, auto-convert the Lead.
	 * Use the Salesforce report Converted Lead to verify that the Lead was converted to the correct Contact.
	 *
	 * Criteria:
	 * - Monitor the "Email" field on the Lead object for creation or updates.
	 * - On Lead creation or email update, search the Contact object for records with the
	 *   same email address.
	 * - If a single matching Contact is identified:
	 *     - Auto-convert the Lead.
	 *     - Merge the Lead details with the existing Contact, ensuring that crucial
	 *       Contact information is preserved.
	 * - If multiple Contacts with the same email are found or no match is identified,
	 *   leave the Lead unconverted.
	 * 
	 * Hint: 
	 * - One of the errors is recursion related. Check if the lead is already converted or check if the email has changed/is null
	 * - One of the errors is map related. Make sure you are using the correct contact map key
	 */
	public static void handleLeadAutoConvert(List<Lead> leadsToConvert, Map<String, Contact> existingEmails) {
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
		
		for (Lead lead : leadsToConvert) {
			if (existingEmails.containsKey(lead.Email)) {
				Contact matchingContact = existingEmails.get(lead.Email);
				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(lead.Id);
				lc.setContactId(matchingContact.Id);
				lc.setAccountId(matchingContact.AccountId);
				lc.setDoNotCreateOpportunity(true);
				lc.setConvertedStatus(convertStatus.MasterLabel);
				leadConverts.add(lc);
			}
		}
		
		if (!leadConverts.isEmpty()) {
			Database.convertLead(leadConverts);
		}
	}
	// public static void handleLeadAutoConvert(List<Lead> leads) {
	// 	// Step 1: Gather eligible leads (new leads or leads with an updated email)
	// 	Map<Id, String> leadToEmailMap = new Map<Id, String>();
	// 	for (Lead lead : leads) {
	// 		// Skip if lead is already converted or if email is null
	// 		if (lead.IsConverted || lead.Email == null) {
	// 			continue;
	// 		}
	// 		if(Trigger.new == null){
	// 			continue;
	// 		}
	// 		// For update operations, only process if the email has changed
	// 		//system.debug(trigger.isUpdate);
	// 		if (Trigger.isUpdate)  {
	// 			Lead oldLead = (Lead) Trigger.oldMap.get(lead.Id);
	// 			if (oldLead != null && oldLead.Email == lead.Email) {
	// 				continue;
	// 			}
	// 		}
			
	// 		leadToEmailMap.put(lead.Id, lead.Email);
	// 	}
		
	// 	// If there are no eligible leads, exit the method
	// 	if (leadToEmailMap.isEmpty()) {
	// 		return;
	// 	}
		
	// 	// Step 2: Find matching contacts based on email
	// 	Map<String, Contact> emailToContactMap = new Map<String, Contact>();
	// 	for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :leadToEmailMap.values()]) {
	// 		// If more than one contact exists for an email, remove it
	// 		if (emailToContactMap.containsKey(c.Email)) {
	// 			emailToContactMap.remove(c.Email);
	// 		} else {
	// 			emailToContactMap.put(c.Email, c);
	// 		}
	// 	}
		
	// 	// Step 3: Auto-convert leads for which a single matching Contact is identified
	// 	List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
	// 	// Retrieve the lead status used for conversion
	// 	LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
		
	// 	for (Id leadId : leadToEmailMap.keySet()) {
	// 		String leadEmail = leadToEmailMap.get(leadId);
	// 		if (emailToContactMap.containsKey(leadEmail)) {
	// 			Database.LeadConvert lc = new Database.LeadConvert();
	// 			lc.setLeadId(leadId);
	// 			lc.setContactId(emailToContactMap.get(leadEmail).Id);
	// 			lc.setAccountId(emailToContactMap.get(leadEmail).AccountId);
	// 			lc.setDoNotCreateOpportunity(true);
	// 			lc.setConvertedStatus(convertStatus.MasterLabel);
	// 			leadConverts.add(lc);
	// 		}
	// 	}
		
	// 	// Step 4: Convert eligible leads
	// 	if (!leadConverts.isEmpty()) {
	// 		Database.convertLead(leadConverts);
	// 	}
	// }
	
	
}