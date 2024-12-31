import { LightningElement, wire, track } from "lwc";
import getCandidateSummary from "@salesforce/apex/CandidateSummaryController.getCandidateSummaries";

export default class CandidateSummary extends LightningElement {
  @track candidates = {
    data: null,
    error: null,
  };

  columns = [
    { label: "Candidate Name", fieldName: "CandidateName", type: "text" },
    { label: "LinkedIn", fieldName: "LinkedInURL", type: "url", typeAttributes: { label: { fieldName: "LinkedInLabel" }, target: "_blank" } },
    { label: "Trailblazer", fieldName: "TrailblazerURL", type: "url", typeAttributes: { label: { fieldName: "TrailblazerLabel" }, target: "_blank" } },
    { label: "Overall Rating", fieldName: "OverallRating", type: "number", cellAttributes: { alignment: "center" } },
    { label: "Total Certifications", fieldName: "TotalCertifications", type: "number", cellAttributes: { alignment: "center" } },
    { label: "Total Skills", fieldName: "TotalSkills", type: "number", cellAttributes: { alignment: "center" } },
    { label: "Top Skill(s) with Rating", fieldName: "TopSkillsWithRating", type: "text" },
    { label: "Total Evaluated Days", fieldName: "TotalEvaluatedDays", type: "number", cellAttributes: { alignment: "center" } },
    { label: "Task Last Worked On", fieldName: "TaskLastWorkedOn", type: "text" },
    { label: "Evaluation Status", fieldName: "EvaluationStatus", type: "text" },
  ];

  @wire(getCandidateSummary)
  wiredCandidates({ data, error }) {
    if (data) {
      this.candidates.data = data;
      this.candidates.error = null;
    } else if (error) {
      this.candidates.data = null;
      this.candidates.error = error.body.message;
    }
  }
}