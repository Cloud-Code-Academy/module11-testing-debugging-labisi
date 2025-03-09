/*
 * The `LeadTrigger` is designed to automate certain processes around the Lead object in Salesforce. 
 * This trigger invokes various methods from the `LeadTriggerHandler` class based on different trigger 
 * events like insert and update.
 * 
 * Here's a brief rundown of the operations:
 * 1. BEFORE INSERT and BEFORE UPDATE:
 *    - Normalize the Lead's title for consistency using `handleTitleNormalization` method.
 *    - Score leads based on certain criteria using the `handleAutoLeadScoring` method.
 * 2. AFTER INSERT and AFTER UPDATE:
 *    - Check if the Lead can be auto-converted using the `handleLeadAutoConvert` method.
 *
 * Students should note:
 * - This trigger contains intentional errors that need to be identified and corrected.
 * - It's essential to test the trigger thoroughly after making any changes to ensure its correct functionality.
 * - Debugging skills will be tested, so students should look out for discrepancies between the expected and actual behavior.
 */
// 
trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT, BEFORE_UPDATE {
            // Normalize Lead titles and auto-score leads before insert or update
            LeadTriggerHandler.handleTitleNormalization(Trigger.new);
            LeadTriggerHandler.handleAutoLeadScoring(Trigger.new);
        }
        when AFTER_INSERT, AFTER_UPDATE {
            // Identify eligible leads for conversion
            Map<Id, String> leadToEmailMap = new Map<Id, String>();
            for (Lead lead : Trigger.new) {
                // Skip if lead is already converted or if email is null
                if (lead.IsConverted || lead.Email == null) {
                    continue;
                }
                
                // For update operations, only process if the email has changed
                if (Trigger.isUpdate) {
                    Lead oldLead = (Lead) Trigger.oldMap.get(lead.Id);
                    if (oldLead != null && oldLead.Email == lead.Email) {
                        continue;
                    }
                }
                
                leadToEmailMap.put(lead.Id, lead.Email);
            }
            
            // If there are eligible leads, process them
            if (!leadToEmailMap.isEmpty()) {
                // Find matching contacts based on email
                Map<String, Contact> emailToContactMap = new Map<String, Contact>();
                for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :leadToEmailMap.values()]) {
                    // If more than one contact exists for an email, remove it
                    if (emailToContactMap.containsKey(c.Email)) {
                        emailToContactMap.remove(c.Email);
                    } else {
                        emailToContactMap.put(c.Email, c);
                    }
                }
                
                // Get the leads to convert
                List<Lead> leadsToConvert = [SELECT Id, Email FROM Lead WHERE Id IN :leadToEmailMap.keySet()];
                
                // Call the handler to perform the conversion
                LeadTriggerHandler.handleLeadAutoConvert(leadsToConvert, emailToContactMap);
            }
        }
    }
}