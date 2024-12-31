public with sharing class CandidateSummaryController {
    @AuraEnabled(cacheable=true)
    public static List<CandidateSummaryDTO> getCandidateSummaries() {
        List<CandidateSummaryDTO> summaries = new List<CandidateSummaryDTO>();

        // Fetch all candidates
        List<Candidate_Information__c> candidates = [
            SELECT Id, Name, LinkedIn_URL__c, Trailblazer_URL__c
            FROM Candidate_Information__c
        ];

        for (Candidate_Information__c candidate : candidates) {
            CandidateSummaryDTO summary = new CandidateSummaryDTO();
            summary.CandidateName = candidate.Name;
            summary.LinkedInURL = candidate.LinkedIn_URL__c;
            summary.TrailblazerURL = candidate.Trailblazer_URL__c;

            // Fetch Total Skills for the candidate
            Integer totalSkills = [
                SELECT COUNT()
                FROM Candidate_Skill__c
                WHERE Candidate_Information__c = :candidate.Id
            ];
            summary.TotalSkills = totalSkills;

            // Fetch Total Certifications for the candidate
            Integer totalCertifications = [
                SELECT COUNT()
                FROM Candidate_Certification__c
                WHERE Candidate_Information__c = :candidate.Id
            ];
            summary.TotalCertifications = totalCertifications;

            // Fetch Overall Rating for the candidate
            Decimal overallRating = 0;
            List<AggregateResult> ratingResult = [
                SELECT AVG(Overall_Rating_Out_of_10__c) avgRating
                FROM Review__c
                WHERE Candidate_Information__c = :candidate.Id
            ];
            if (!ratingResult.isEmpty() && ratingResult[0].get('avgRating') != null) {
                overallRating = (Decimal) ratingResult[0].get('avgRating');
            }
            summary.OverallRating = overallRating;

            // Fetch Top Skills with the highest expertise level
            List<Candidate_Skill__c> topSkills = [
                SELECT Skill__r.Name, Expertise_Level__c
                FROM Candidate_Skill__c
                WHERE Candidate_Information__c = :candidate.Id
                ORDER BY Expertise_Level__c DESC
            ];

            if (!topSkills.isEmpty()) {
                Decimal highestExpertise = topSkills[0].Expertise_Level__c; 
                List<String> skillsWithSameLevel = new List<String>();
                
                for (Candidate_Skill__c skill : topSkills) {
                    // Check if the expertise level matches the highest expertise level
                    if (skill.Expertise_Level__c == highestExpertise) {
                        skillsWithSameLevel.add(skill.Skill__r.Name + ' - ' + highestExpertise);
                    } else {
                        break; 
                    }
                }
                
                
                summary.TopSkillsWithRating = String.join(skillsWithSameLevel, ', ');
            } else {
                summary.TopSkillsWithRating = ''; 
            }

            // Fetch Daily Status details for evaluation
            List<Daily_Status__c> dailyStatuses = [
                SELECT Evaluation_Task__r.Name, Evaluation_Task__r.Evaluation_Status__c, Submission_Date__c
                FROM Daily_Status__c
                WHERE Candidate_Information__c = :candidate.Id
                ORDER BY Submission_Date__c DESC
            ];

            if (!dailyStatuses.isEmpty()) {
                summary.TotalEvaluatedDays = dailyStatuses.size();

                // Set TaskLastWorkedOn if available
                if (dailyStatuses[0].Evaluation_Task__r != null && dailyStatuses[0].Evaluation_Task__r.Name != null) {
                    summary.TaskLastWorkedOn = dailyStatuses[0].Evaluation_Task__r.Name;
                } else {
                    summary.TaskLastWorkedOn = '';
                }

                // Set EvaluationStatus
                if (dailyStatuses[0].Evaluation_Task__r != null && dailyStatuses[0].Evaluation_Task__r.Evaluation_Status__c != null) {
                    summary.EvaluationStatus = dailyStatuses[0].Evaluation_Task__r.Evaluation_Status__c;
                } else {
                    summary.EvaluationStatus = 'Not Evaluated';
                }
            } else {
                summary.TotalEvaluatedDays = 0;
                summary.TaskLastWorkedOn = 'N/A';
                summary.EvaluationStatus = 'Not Evaluated';
            }

            summaries.add(summary);
        }

        return summaries;
    }

    // Data Transfer Object (DTO) for Candidate Summary
    public class CandidateSummaryDTO {
        @AuraEnabled public String CandidateName { get; set; }
        @AuraEnabled public String LinkedInURL { get; set; }
        @AuraEnabled public String TrailblazerURL { get; set; }
        @AuraEnabled public Integer TotalSkills { get; set; }
        @AuraEnabled public Integer TotalCertifications { get; set; }
        @AuraEnabled public Decimal OverallRating { get; set; }
        @AuraEnabled public String TopSkillsWithRating { get; set; }
        @AuraEnabled public Integer TotalEvaluatedDays { get; set; }
        @AuraEnabled public String TaskLastWorkedOn { get; set; }
        @AuraEnabled public String EvaluationStatus { get; set; }
    }
}