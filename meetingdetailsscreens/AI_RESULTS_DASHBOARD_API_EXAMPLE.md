# AI Results Dashboard API Example (BA/PM Side)

This document provides a comprehensive guide and a full JSON payload example of the **AI Results Dashboard** endpoint used by Project Managers and Business Analysts. This resource is intended for the mobile development team to design, mock, and integrate the primary AI results workspace on iOS and Android.

---

## 1. API Endpoint Details

To retrieve the generated AI requirements analysis dashboard for a project, hit the following authenticated endpoint.

* **Endpoint:** `GET /api/projects/{projectId}/ai/results-dashboard?runId={runId}`
* **Method:** `GET`
* **Query Parameters:**
  * `runId` (optional, string): The specific analysis run ID. If omitted, the backend returns the latest completed run.
* **Authentication:** Bearer JWT Token (`Authorization: Bearer {accessToken}`)
* **Headers:** 
  * `Accept: application/json`

---

## 2. TypeScript Data Structures

These types represent the exact schema defined in [aiResults.ts](file:///d:/ITI/GP/frontend/src/features/projects/types/aiResults.ts):

```typescript
export type AiRunStatus =
  | "QUEUED"
  | "PROCESSING"
  | "COMPLETED"
  | "PARTIAL"
  | "NEEDS_REVIEW"
  | "REJECTED"
  | "FAILED"
  | "CANCELLED";

export type ItemWorkflowStatus =
  | "GENERATED"
  | "NEEDS_REVIEW"
  | "EDITED"
  | "APPROVED"
  | "REJECTED";

export type ItemQualityStatus = "FRESH" | "STALE" | "NOT_EVALUATED";
export type RevisionSource = "AI_GENERATED" | "HUMAN_EDITED" | "AI_REGENERATED";

export interface SourceRef {
  documentId?: string | null;
  sourceId?: string | null;
  documentTitle?: string | null;
  sourceType?: string | null;
  chunkId?: string | null;
  confidenceScore?: number | null;
  fileUrl?: string | null;
  quote?: string | null;
}

export interface SourceDocument {
  id?: string | null;
  title?: string | null;
  type?: number | string | null;
  language?: number | string | null;
  mimeType?: string | null;
  fileUrl?: string | null;
}

export interface QualityInfo {
  score?: number | null;
  level?: string | null;
  issues?: string[] | null;
  warnings?: string[] | null;
}

export interface AcceptanceCriterion {
  id?: string | null;
  text?: string | null;
  format?: string | null;
  given?: string | null;
  when?: string | null;
  then?: string | null;
}

export interface ItemWorkflowFields {
  workflowStatus?: ItemWorkflowStatus;
  reviewFeedback?: string | null;
  reviewedBy?: string | null;
  reviewedAt?: string | null;
  createdAt?: string | null;
  updatedAt?: string | null;
  lastModifiedBy?: string | null;
  version?: number;
  qualityStatus?: ItemQualityStatus | null;
}

export interface DashboardRequirement extends ItemWorkflowFields {
  id: string;
  title: string;
  description?: string | null;
  type?: string | null;         // e.g., "Functional", "Non-Functional"
  category?: string | null;
  priority?: string | null;
  actor?: string | null;
  confidenceScore?: number | null;
  quality?: QualityInfo | null;
  sourceRefs?: SourceRef[] | null;
  sourceDocumentIds?: string[] | null;
}

export interface DashboardUserStory extends ItemWorkflowFields {
  id: string;
  title: string;
  description?: string | null;
  userStory?: string | null;     // Standard story: "As a... I want... So that..."
  acceptanceCriteria?: Array<AcceptanceCriterion | string> | null;
  priority?: string | null;
  type?: string | null;          // "Story"
  requirementId?: string | null; // Parent requirement link
  quality?: QualityInfo | null;
  sourceRefs?: SourceRef[] | null;
  revisionNumber?: number;
  revisionSource?: RevisionSource;
}

export interface ResultsSummary {
  executiveSummary?: string | null;
  keyDecisions?: string[] | null;
  openQuestions?: Array<OpenQuestion | string> | null;
  risks?: Array<Risk | string> | null;
  assumptions?: string[] | null;
  actionItems?: Array<ActionItem | string> | null;
  stakeholders?: string[] | null;
  scope?: string[] | null;
  outOfScope?: string[] | null;
}

export interface ResultsMetrics {
  totalRequirements: number;
  functionalRequirements: number;
  nonFunctionalRequirements: number;
  businessRequirements: number;
  userStories: number;
  highPriorityItems: number;
  risksCount: number;
  openQuestionsCount: number;
  warningsCount: number;
  qualityIssuesCount: number;
}

export interface QualityReport {
  overallScore?: number | null;
  traceabilityCoverage?: number | null;
  groundednessScore?: number | null;
  storyCompleteness?: number | null;
  acceptanceCriteriaQuality?: number | null;
  duplicateRisk?: number | null;
  highSeverityIssueCount?: number | null;
  requirementCount?: number | null;
  storyCount?: number | null;
}

export interface ResultsDashboard {
  projectId: string;
  analysisRunId: string;
  analysisRunStatus: AiRunStatus;
  generatedAt?: string | null;
  contractVersion?: string | null;
  isUseful?: boolean | null;
  relevanceScore?: number | null;
  sourceDocuments?: SourceDocument[] | null;
  summary?: ResultsSummary | null;
  metrics?: Partial<ResultsMetrics> | null;
  requirements?: DashboardRequirement[] | null;
  userStories?: DashboardUserStory[] | null;
  qualityReport?: QualityReport | null;
}
```

---

## 3. Full JSON Example Payload

Below is a complete, production-realistic JSON response payload containing a full project summary, metrics, traceability coverage, quality indicators, requirements, and user stories.

```json
{
  "isSuccess": true,
  "statusCode": 200,
  "message": "AI Results Dashboard retrieved successfully.",
  "errors": [],
  "data": {
    "projectId": "57",
    "analysisRunId": "run-982c7f1a-b68c-4f76-9051-789a7123def4",
    "analysisRunStatus": "COMPLETED",
    "generatedAt": "2026-08-08T14:45:00Z",
    "contractVersion": "1.0",
    "isUseful": true,
    "relevanceScore": 0.94,
    "sourceDocuments": [
      {
        "id": "sim-doc-1",
        "title": "Stakeholder Discovery Notes",
        "type": "Notes",
        "language": "English",
        "mimeType": "application/pdf"
      }
    ],
    "summary": {
      "executiveSummary": "The product enables stakeholders to capture unstructured discovery notes and automatically transform them into structured requirements, user stories, and acceptance criteria. The core value is reducing the manual effort of requirement engineering while keeping every item grounded in source evidence.",
      "keyDecisions": [
        "Adopt an async run-based pipeline so long AI jobs never block the UI.",
        "Ground every requirement in at least one source document reference."
      ],
      "openQuestions": [
        {
          "id": "Q-001",
          "question": "Which payment provider should the platform integrate with first?",
          "sourceDocumentIds": ["sim-doc-1"]
        },
        {
          "id": "Q-002",
          "question": "Is multi-tenant data isolation required for the MVP?",
          "sourceDocumentIds": ["sim-doc-1"]
        }
      ],
      "risks": [
        {
          "id": "RISK-001",
          "title": "Payment provider details unspecified",
          "severity": "Medium",
          "description": "Integration details were not present in the provided sources."
        }
      ],
      "assumptions": [
        "Users are authenticated before accessing project workspaces."
      ],
      "actionItems": [
        {
          "id": "ACT-001",
          "title": "Confirm the primary payment provider",
          "owner": "Product Owner",
          "priority": "High"
        }
      ],
      "stakeholders": [
        "Product Owner",
        "Engineering Lead",
        "Client Sponsor"
      ],
      "scope": [
        "Requirement extraction",
        "User story generation",
        "Dashboard insights & export"
      ],
      "outOfScope": [
        "Billing & invoicing",
        "Native mobile applications"
      ]
    },
    "metrics": {
      "totalRequirements": 3,
      "functionalRequirements": 2,
      "nonFunctionalRequirements": 1,
      "businessRequirements": 0,
      "userStories": 2,
      "highPriorityItems": 2,
      "risksCount": 1,
      "openQuestionsCount": 2,
      "warningsCount": 0,
      "qualityIssuesCount": 1
    },
    "requirements": [
      {
        "id": "REQ-001",
        "title": "Transform discovery notes into structured requirements",
        "description": "The system shall parse unstructured notes and extract discrete, testable requirements.",
        "type": "Functional",
        "category": "Requirements Engineering",
        "priority": "High",
        "actor": "Business Analyst",
        "confidenceScore": 0.93,
        "quality": {
          "score": 0.9,
          "level": "High",
          "issues": []
        },
        "sourceRefs": [
          {
            "documentId": "sim-doc-1",
            "documentTitle": "Stakeholder Discovery Notes",
            "quote": "We need the notes turned into a clean requirements list automatically."
          }
        ],
        "sourceDocumentIds": ["sim-doc-1"],
        "workflowStatus": "APPROVED",
        "version": 1,
        "qualityStatus": "FRESH"
      },
      {
        "id": "REQ-002",
        "title": "Generate user stories with acceptance criteria",
        "description": "For each functional requirement, the system shall produce user stories and Given/When/Then criteria.",
        "type": "Functional",
        "category": "Generation",
        "priority": "High",
        "actor": "Product Owner",
        "confidenceScore": 0.88,
        "quality": {
          "score": 0.84,
          "level": "High",
          "issues": []
        },
        "sourceRefs": [],
        "sourceDocumentIds": ["sim-doc-1"],
        "workflowStatus": "NEEDS_REVIEW",
        "version": 1,
        "qualityStatus": "FRESH"
      },
      {
        "id": "REQ-003",
        "title": "Process AI runs without blocking the interface",
        "description": "The system shall process analysis runs asynchronously and expose progress while running.",
        "type": "Non-Functional",
        "category": "Performance",
        "priority": "Medium",
        "actor": "End User",
        "confidenceScore": 0.79,
        "quality": {
          "score": 0.72,
          "level": "Medium",
          "issues": ["Ambiguous latency target"]
        },
        "sourceRefs": [],
        "sourceDocumentIds": [],
        "workflowStatus": "NEEDS_REVIEW",
        "version": 1,
        "qualityStatus": "FRESH"
      }
    ],
    "userStories": [
      {
        "id": "US-001",
        "title": "Extract requirements from notes",
        "userStory": "As a business analyst, I want my discovery notes turned into structured requirements so that I can review them quickly.",
        "description": "As a business analyst, I want my discovery notes turned into structured requirements so that I can review them quickly.",
        "priority": "High",
        "type": "Story",
        "requirementId": "REQ-001",
        "quality": {
          "score": 0.91,
          "level": "High",
          "issues": [],
          "warnings": []
        },
        "sourceRefs": [
          {
            "documentId": "sim-doc-1",
            "documentTitle": "Stakeholder Discovery Notes",
            "quote": "We need the notes turned into a clean requirements list automatically."
          }
        ],
        "acceptanceCriteria": [
          "Given uploaded notes, when analysis completes, then a list of requirements is shown.",
          "Given a requirement, when I open it, then I can see its source evidence."
        ],
        "workflowStatus": "APPROVED",
        "version": 1,
        "qualityStatus": "FRESH",
        "revisionNumber": 1,
        "revisionSource": "AI_GENERATED"
      },
      {
        "id": "US-002",
        "title": "Review generated user stories",
        "userStory": "As a product owner, I want generated user stories with acceptance criteria so that I can plan a sprint.",
        "description": "As a product owner, I want generated user stories with acceptance criteria so that I can plan a sprint.",
        "priority": "Medium",
        "type": "Story",
        "requirementId": "REQ-002",
        "quality": {
          "score": 0.78,
          "level": "Medium",
          "issues": ["The failure and empty-state paths need clearer acceptance criteria."],
          "warnings": []
        },
        "sourceRefs": [],
        "acceptanceCriteria": [
          "Given a generated story, when I view it, then its acceptance criteria are listed."
        ],
        "workflowStatus": "GENERATED",
        "version": 1,
        "qualityStatus": "FRESH",
        "revisionNumber": 1,
        "revisionSource": "AI_GENERATED"
      }
    ],
    "qualityReport": {
      "overallScore": 0.85,
      "traceabilityCoverage": 1.0,
      "groundednessScore": 0.9,
      "storyCompleteness": 0.95,
      "acceptanceCriteriaQuality": 0.88,
      "duplicateRisk": 0.05,
      "highSeverityIssueCount": 0,
      "requirementCount": 3,
      "storyCount": 2
    }
  }
}
```

---
