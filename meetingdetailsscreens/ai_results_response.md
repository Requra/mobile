{
    "isSuccess": true,
    "data": {
        "artifacts": {
            "excel_file": {
                "available": false,
                "file_name": "",
                "file_url": "",
                "mime_type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            }
        },
        "contract_version": "1.0",
        "error": null,
        "error_message": null,
        "export_rows": [],
        "exports": {
            "excel": {
                "available": true,
                "columns": [
                    "id",
                    "requirement_id",
                    "title",
                    "user_story",
                    "acceptance_criteria",
                    "type",
                    "priority",
                    "actor",
                    "confidence",
                    "labels",
                    "source_requirement_id",
                    "source_quotes",
                    "quality_score",
                    "quality_issues",
                    "source_refs"
                ],
                "rows": [
                    {
                        "acceptance_criteria": "Given an account owner in the customer workspace, when they create a project, then the project is successfully created.",
                        "actor": "Account Owner",
                        "confidence": 1,
                        "id": "US-001",
                        "labels": "FR",
                        "priority": "Medium",
                        "quality_issues": "",
                        "quality_score": 1,
                        "requirement_id": "REQ-001",
                        "source_quotes": "The customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role. | Acceptance review\n\nThe customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                        "source_refs": [
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "The customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            },
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c2",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "Acceptance review\n\nThe customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            }
                        ],
                        "source_requirement_id": "REQ-001",
                        "title": "Create a project and invite collaborators",
                        "type": "Functional",
                        "user_story": "As an account owner, I want to create a project and invite named collaborators with a project-scoped role, so that I can manage the project effectively."
                    },
                    {
                        "acceptance_criteria": "Given the required preconditions are satisfied, when Service attempts to issue single-use email invitation links, then the service issues a single-use email invitation link that expires after twenty-four hours.; Given the required preconditions are satisfied, when Service attempts to issue single-use email invitation links, then records its redemption time.",
                        "actor": "Service",
                        "confidence": 1,
                        "id": "US-002",
                        "labels": "FR",
                        "priority": "Medium",
                        "quality_issues": "Generated story failed validation: duplicate_acceptance_criteria. Story 1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2 has redundant acceptance criteria: 1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2_ac_2.",
                        "quality_score": 0.85,
                        "requirement_id": "REQ-002",
                        "source_quotes": "The service shall issue a single-use email invitation link that expires after twenty-four hours and records its redemption time.",
                        "source_refs": [
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "The service shall issue a single-use email invitation link that expires after twenty-four hours and records its redemption time.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            }
                        ],
                        "source_requirement_id": "REQ-002",
                        "title": "Issue single-use email invitation links",
                        "type": "Functional",
                        "user_story": "As a system operator, I want to issue single-use email invitation links, so that the documented requirement is fulfilled."
                    },
                    {
                        "acceptance_criteria": "Given the required preconditions are satisfied, when Workspace attempts to require multi-factor authentication for administrators, then the workspace requires multi-factor authentication for administrators before they can change organization settings or billing contacts.",
                        "actor": "Workspace",
                        "confidence": 1,
                        "id": "US-003",
                        "labels": "FR",
                        "priority": "Medium",
                        "quality_issues": "",
                        "quality_score": 1,
                        "requirement_id": "REQ-003",
                        "source_quotes": "The workspace shall require multi-factor authentication for administrators before they can change organization settings or billing contacts.",
                        "source_refs": [
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "The workspace shall require multi-factor authentication for administrators before they can change organization settings or billing contacts.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            }
                        ],
                        "source_requirement_id": "REQ-003",
                        "title": "Require multi-factor authentication for administrators",
                        "type": "Functional",
                        "user_story": "As a system operator, I want to require multi-factor authentication for administrators before they can change organization settings or billing contacts, so that I can enhance security."
                    },
                    {
                        "acceptance_criteria": "Given an invitation is created, when the event is logged, then it is recorded as an immutable audit event.",
                        "actor": "System",
                        "confidence": 1,
                        "id": "US-004",
                        "labels": "FR",
                        "priority": "Medium",
                        "quality_issues": "",
                        "quality_score": 1,
                        "requirement_id": "REQ-004",
                        "source_quotes": "The system shall record immutable audit events for invitation creation, role changes, sign-in failures, and export requests.",
                        "source_refs": [
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "The system shall record immutable audit events for invitation creation, role changes, sign-in failures, and export requests.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            }
                        ],
                        "source_requirement_id": "REQ-004",
                        "title": "Record immutable audit events",
                        "type": "Functional",
                        "user_story": "As a system operator, I want to record immutable audit events for invitation creation, role changes, sign-in failures, and export requests, so that I can maintain a secure and traceable log."
                    },
                    {
                        "acceptance_criteria": "Given the required preconditions are satisfied, when the User attempts to filter audit search results, then the audit search screen filters by actor.",
                        "actor": "User",
                        "confidence": 1,
                        "id": "US-005",
                        "labels": "FR",
                        "priority": "Medium",
                        "quality_issues": "Generated story failed validation: duplicate_acceptance_criteria.",
                        "quality_score": 0.85,
                        "requirement_id": "REQ-005",
                        "source_quotes": "The audit search screen shall filter by actor, action, target project, and a caller-selected date range.",
                        "source_refs": [
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "The audit search screen shall filter by actor, action, target project, and a caller-selected date range.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            }
                        ],
                        "source_requirement_id": "REQ-005",
                        "title": "Filter audit search results",
                        "type": "Functional",
                        "user_story": "As a user, I want to filter audit search results by actor, action, target project, and a caller-selected date range, so that I can find relevant audit events easily."
                    },
                    {
                        "acceptance_criteria": "Given the required preconditions are satisfied, when the system attempts to generate audit reports in CSV and PDF formats, then the export service produces CSV and PDF audit reports.; Given the required preconditions are satisfied, when the system generates an audit report, then it includes the applied filters in each generated artifact.",
                        "actor": "System",
                        "confidence": 1,
                        "id": "US-006",
                        "labels": "FR",
                        "priority": "Medium",
                        "quality_issues": "Generated story failed validation: duplicate_acceptance_criteria.",
                        "quality_score": 0.85,
                        "requirement_id": "REQ-006",
                        "source_quotes": "The export service shall produce CSV and PDF audit reports and include the applied filters in each generated artifact.",
                        "source_refs": [
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "The export service shall produce CSV and PDF audit reports and include the applied filters in each generated artifact.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            }
                        ],
                        "source_requirement_id": "REQ-006",
                        "title": "Generate audit reports in CSV and PDF formats",
                        "type": "Functional",
                        "user_story": "As a system operator, I want to produce CSV and PDF audit reports and include the applied filters in each generated artifact, so that users can have formatted records of audit events."
                    },
                    {
                        "acceptance_criteria": "Given an exported report is generated, when it is stored, then it is retained for thirty days.; Given a report is retained, when a non-administrator attempts to retrieve it, then access is denied.",
                        "actor": "Administrator",
                        "confidence": 1,
                        "id": "US-007",
                        "labels": "FR, BR",
                        "priority": "Medium",
                        "quality_issues": "",
                        "quality_score": 1,
                        "requirement_id": "REQ-007",
                        "source_quotes": "The application shall retain exported reports for thirty days and allow only administrators to retrieve a retained report.",
                        "source_refs": [
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "The application shall retain exported reports for thirty days and allow only administrators to retrieve a retained report.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            }
                        ],
                        "source_requirement_id": "REQ-007",
                        "title": "Manage exported reports retention",
                        "type": "Functional",
                        "user_story": "As an administrator, I want to retain exported reports for thirty days and allow only administrators to retrieve a retained report, so that the documented requirement is fulfilled."
                    },
                    {
                        "acceptance_criteria": "Given a new administrator role is granted, when the action is completed, then the account owner receives an alert notification.",
                        "actor": "Account Owner",
                        "confidence": 1,
                        "id": "US-008",
                        "labels": "FR",
                        "priority": "Medium",
                        "quality_issues": "",
                        "quality_score": 1,
                        "requirement_id": "REQ-008",
                        "source_quotes": "The notification service shall alert account owners when a new administrator role is granted or when an export is downloaded.",
                        "source_refs": [
                            {
                                "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                                "confidence_score": 1,
                                "document_name": "customer_workspace_requirements.docx",
                                "page": null,
                                "quote": "The notification service shall alert account owners when a new administrator role is granted or when an export is downloaded.",
                                "source_id": "doc_fbc0505ae0491db7",
                                "source_type": "document"
                            }
                        ],
                        "source_requirement_id": "REQ-008",
                        "title": "Receive alerts for administrator role changes and exports",
                        "type": "Functional",
                        "user_story": "As an account owner, I want to receive alerts when a new administrator role is granted or when an export is downloaded, so that I can stay informed about important changes."
                    }
                ]
            },
            "jira": {
                "rows": [
                    {
                        "acceptance_criteria": [
                            "Given an account owner in the customer workspace, when they create a project, then the project is successfully created."
                        ],
                        "components": [],
                        "description": "As an account owner, I want to create a project and invite named collaborators with a project-scoped role, so that I can manage the project effectively.",
                        "epic_name": "",
                        "issue_type": "Story",
                        "labels": [
                            "FR"
                        ],
                        "priority": "Medium",
                        "source_quotes": "The customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role. | Acceptance review\n\nThe customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                        "source_requirement_id": "REQ-001",
                        "story_points": 5,
                        "summary": "Create a project and invite collaborators"
                    },
                    {
                        "acceptance_criteria": [
                            "Given the required preconditions are satisfied, when Service attempts to issue single-use email invitation links, then the service issues a single-use email invitation link that expires after twenty-four hours.",
                            "Given the required preconditions are satisfied, when Service attempts to issue single-use email invitation links, then records its redemption time."
                        ],
                        "components": [],
                        "description": "As a system operator, I want to issue single-use email invitation links, so that the documented requirement is fulfilled.",
                        "epic_name": "",
                        "issue_type": "Story",
                        "labels": [
                            "FR"
                        ],
                        "priority": "Medium",
                        "source_quotes": "The service shall issue a single-use email invitation link that expires after twenty-four hours and records its redemption time.",
                        "source_requirement_id": "REQ-002",
                        "story_points": 3,
                        "summary": "Issue single-use email invitation links"
                    },
                    {
                        "acceptance_criteria": [
                            "Given the required preconditions are satisfied, when Workspace attempts to require multi-factor authentication for administrators, then the workspace requires multi-factor authentication for administrators before they can change organization settings or billing contacts."
                        ],
                        "components": [],
                        "description": "As a system operator, I want to require multi-factor authentication for administrators before they can change organization settings or billing contacts, so that I can enhance security.",
                        "epic_name": "",
                        "issue_type": "Story",
                        "labels": [
                            "FR"
                        ],
                        "priority": "Medium",
                        "source_quotes": "The workspace shall require multi-factor authentication for administrators before they can change organization settings or billing contacts.",
                        "source_requirement_id": "REQ-003",
                        "story_points": 5,
                        "summary": "Require multi-factor authentication for administrators"
                    },
                    {
                        "acceptance_criteria": [
                            "Given an invitation is created, when the event is logged, then it is recorded as an immutable audit event."
                        ],
                        "components": [],
                        "description": "As a system operator, I want to record immutable audit events for invitation creation, role changes, sign-in failures, and export requests, so that I can maintain a secure and traceable log.",
                        "epic_name": "",
                        "issue_type": "Story",
                        "labels": [
                            "FR"
                        ],
                        "priority": "Medium",
                        "source_quotes": "The system shall record immutable audit events for invitation creation, role changes, sign-in failures, and export requests.",
                        "source_requirement_id": "REQ-004",
                        "story_points": 5,
                        "summary": "Record immutable audit events"
                    },
                    {
                        "acceptance_criteria": [
                            "Given the required preconditions are satisfied, when the User attempts to filter audit search results, then the audit search screen filters by actor."
                        ],
                        "components": [],
                        "description": "As a user, I want to filter audit search results by actor, action, target project, and a caller-selected date range, so that I can find relevant audit events easily.",
                        "epic_name": "",
                        "issue_type": "Story",
                        "labels": [
                            "FR"
                        ],
                        "priority": "Medium",
                        "source_quotes": "The audit search screen shall filter by actor, action, target project, and a caller-selected date range.",
                        "source_requirement_id": "REQ-005",
                        "story_points": 3,
                        "summary": "Filter audit search results"
                    },
                    {
                        "acceptance_criteria": [
                            "Given the required preconditions are satisfied, when the system attempts to generate audit reports in CSV and PDF formats, then the export service produces CSV and PDF audit reports.",
                            "Given the required preconditions are satisfied, when the system generates an audit report, then it includes the applied filters in each generated artifact."
                        ],
                        "components": [],
                        "description": "As a system operator, I want to produce CSV and PDF audit reports and include the applied filters in each generated artifact, so that users can have formatted records of audit events.",
                        "epic_name": "",
                        "issue_type": "Story",
                        "labels": [
                            "FR"
                        ],
                        "priority": "Medium",
                        "source_quotes": "The export service shall produce CSV and PDF audit reports and include the applied filters in each generated artifact.",
                        "source_requirement_id": "REQ-006",
                        "story_points": 5,
                        "summary": "Generate audit reports in CSV and PDF formats"
                    },
                    {
                        "acceptance_criteria": [
                            "Given an exported report is generated, when it is stored, then it is retained for thirty days.",
                            "Given a report is retained, when a non-administrator attempts to retrieve it, then access is denied."
                        ],
                        "components": [],
                        "description": "As an administrator, I want to retain exported reports for thirty days and allow only administrators to retrieve a retained report, so that the documented requirement is fulfilled.",
                        "epic_name": "",
                        "issue_type": "Story",
                        "labels": [
                            "FR",
                            "BR"
                        ],
                        "priority": "Medium",
                        "source_quotes": "The application shall retain exported reports for thirty days and allow only administrators to retrieve a retained report.",
                        "source_requirement_id": "REQ-007",
                        "story_points": 3,
                        "summary": "Manage exported reports retention"
                    },
                    {
                        "acceptance_criteria": [
                            "Given a new administrator role is granted, when the action is completed, then the account owner receives an alert notification."
                        ],
                        "components": [],
                        "description": "As an account owner, I want to receive alerts when a new administrator role is granted or when an export is downloaded, so that I can stay informed about important changes.",
                        "epic_name": "",
                        "issue_type": "Story",
                        "labels": [
                            "FR"
                        ],
                        "priority": "Medium",
                        "source_quotes": "The notification service shall alert account owners when a new administrator role is granted or when an export is downloaded.",
                        "source_requirement_id": "REQ-008",
                        "story_points": 3,
                        "summary": "Receive alerts for administrator role changes and exports"
                    }
                ],
                "available": true,
                "issue_type": "Story"
            }
        },
        "is_useful": true,
        "job_id": "1eef1953-22c9-40dc-b2e8-deb755fa921a",
        "processing_time_ms": 47441,
        "project_id": "00ae578f-5959-4ccd-a37d-8ba85856efe5",
        "quality_issues": [
            {
                "details": "Generated story failed validation: duplicate_acceptance_criteria. Story 1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2 has redundant acceptance criteria: 1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2_ac_2.",
                "item_id": 2,
                "item_type": "story",
                "rule_violated": "duplicate_acceptance_criterion",
                "severity": "medium"
            },
            {
                "details": "Generated story failed validation: duplicate_acceptance_criteria.",
                "item_id": 5,
                "item_type": "story",
                "rule_violated": "duplicate_acceptance_criterion",
                "severity": "medium"
            },
            {
                "details": "Generated story failed validation: duplicate_acceptance_criteria.",
                "item_id": 6,
                "item_type": "story",
                "rule_violated": "duplicate_acceptance_criterion",
                "severity": "medium"
            }
        ],
        "quality_report": {
            "acceptance_criteria_quality": 0.9091,
            "duplicate_risk": 0,
            "groundedness_score": 1,
            "high_severity_issue_count": 0,
            "overall_score": 0.9818,
            "requirement_count": 8,
            "story_completeness": 1,
            "story_count": 8,
            "traceability_coverage": 1
        },
        "relevance_score": 1,
        "requirement_coverages": [
            {
                "requirement_id": "REQ-001",
                "coverage_type": "covered_by_story",
                "story_ids": [
                    "US-001"
                ],
                "acceptance_criteria_ids": [
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_1_ac_1"
                ],
                "reason": null
            },
            {
                "requirement_id": "REQ-002",
                "coverage_type": "covered_by_story",
                "story_ids": [
                    "US-002"
                ],
                "acceptance_criteria_ids": [
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2_ac_1",
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2_ac_2"
                ],
                "reason": null
            },
            {
                "requirement_id": "REQ-003",
                "coverage_type": "covered_by_story",
                "story_ids": [
                    "US-003"
                ],
                "acceptance_criteria_ids": [
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_3_ac_1"
                ],
                "reason": null
            },
            {
                "requirement_id": "REQ-004",
                "coverage_type": "covered_by_story",
                "story_ids": [
                    "US-004"
                ],
                "acceptance_criteria_ids": [
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_4_ac_1"
                ],
                "reason": null
            },
            {
                "requirement_id": "REQ-005",
                "coverage_type": "covered_by_story",
                "story_ids": [
                    "US-005"
                ],
                "acceptance_criteria_ids": [
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_5_ac_1"
                ],
                "reason": null
            },
            {
                "requirement_id": "REQ-006",
                "coverage_type": "covered_by_story",
                "story_ids": [
                    "US-006"
                ],
                "acceptance_criteria_ids": [
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_6_ac_1",
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_6_ac_2"
                ],
                "reason": null
            },
            {
                "requirement_id": "REQ-007",
                "coverage_type": "covered_by_story",
                "story_ids": [
                    "US-007"
                ],
                "acceptance_criteria_ids": [
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_7_ac_1",
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_7_ac_2"
                ],
                "reason": null
            },
            {
                "requirement_id": "REQ-008",
                "coverage_type": "covered_by_story",
                "story_ids": [
                    "US-008"
                ],
                "acceptance_criteria_ids": [
                    "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_8_ac_1"
                ],
                "reason": null
            }
        ],
        "requirements": [
            {
                "actor": "Account Owner",
                "category": "Security & Access Control",
                "confidence_score": 1,
                "deduplication_key": "create-a-project-and-invite-collaborators",
                "description": "Acceptance review The customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                "id": "REQ-001",
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    },
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c2",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "Acceptance review\n\nThe customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Create a project and invite collaborators",
                "type": "Functional"
            },
            {
                "actor": "Service",
                "category": "Functional Capability",
                "confidence_score": 1,
                "deduplication_key": "issue-single-use-email-invitation-links",
                "description": "The service shall issue a single-use email invitation link that expires after twenty-four hours and records its redemption time.",
                "id": "REQ-002",
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The service shall issue a single-use email invitation link that expires after twenty-four hours and records its redemption time.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Issue single-use email invitation links",
                "type": "Functional"
            },
            {
                "actor": "Workspace",
                "category": "Security & Access Control",
                "confidence_score": 1,
                "deduplication_key": "require-multi-factor-authentication-for-administrators",
                "description": "The workspace shall require multi-factor authentication for administrators before they can change organization settings or billing contacts.",
                "id": "REQ-003",
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The workspace shall require multi-factor authentication for administrators before they can change organization settings or billing contacts.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Require multi-factor authentication for administrators",
                "type": "Functional"
            },
            {
                "actor": "System",
                "category": "Security & Access Control",
                "confidence_score": 1,
                "deduplication_key": "record-immutable-audit-events",
                "description": "The system shall record immutable audit events for invitation creation, role changes, sign-in failures, and export requests.",
                "id": "REQ-004",
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The system shall record immutable audit events for invitation creation, role changes, sign-in failures, and export requests.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Record immutable audit events",
                "type": "Functional"
            },
            {
                "actor": "User",
                "category": "Audit & Compliance",
                "confidence_score": 1,
                "deduplication_key": "filter-audit-search-results",
                "description": "The audit search screen shall filter by actor, action, target project, and a caller-selected date range.",
                "id": "REQ-005",
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The audit search screen shall filter by actor, action, target project, and a caller-selected date range.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Filter audit search results",
                "type": "Functional"
            },
            {
                "actor": "System",
                "category": "Audit & Compliance",
                "confidence_score": 1,
                "deduplication_key": "generate-audit-reports-in-csv-and-pdf-formats",
                "description": "The export service shall produce CSV and PDF audit reports and include the applied filters in each generated artifact.",
                "id": "REQ-006",
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The export service shall produce CSV and PDF audit reports and include the applied filters in each generated artifact.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Generate audit reports in CSV and PDF formats",
                "type": "Functional"
            },
            {
                "actor": "Administrator",
                "category": "Reporting & Export",
                "confidence_score": 1,
                "deduplication_key": "manage-exported-reports-retention",
                "description": "The application shall retain exported reports for thirty days and allow only administrators to retrieve a retained report.",
                "id": "REQ-007",
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The application shall retain exported reports for thirty days and allow only administrators to retrieve a retained report.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Manage exported reports retention",
                "type": "Functional"
            },
            {
                "actor": "Account Owner",
                "category": "Security & Access Control",
                "confidence_score": 1,
                "deduplication_key": "receive-alerts-for-administrator-role-changes-and-exports",
                "description": "The notification service shall alert account owners when a new administrator role is granted or when an export is downloaded.",
                "id": "REQ-008",
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The notification service shall alert account owners when a new administrator role is granted or when an export is downloaded.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Receive alerts for administrator role changes and exports",
                "type": "Functional"
            }
        ],
        "source_documents": [
            {
                "file_name": "customer_workspace_requirements.docx",
                "language": "en",
                "mime_type": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                "source_id": "doc_fbc0505ae0491db7",
                "source_type": "docx"
            }
        ],
        "status": "partial",
        "summary": {
            "action_items": [],
            "assumptions": [],
            "executive_summary": "The document outlines the requirements for a customer workspace that allows project creation, collaboration, and auditing functionalities. Key features include multi-factor authentication, single-use email invitations, and audit event recording.",
            "key_decisions": [],
            "open_questions": [],
            "risks": [],
            "out_of_scope": [],
            "scope": [
                "Creation of projects and inviting collaborators",
                "Issuing single-use email invitations",
                "Implementing multi-factor authentication for administrators",
                "Recording immutable audit events",
                "Filtering audit search results",
                "Generating audit reports in CSV and PDF formats",
                "Managing retention of exported reports",
                "Sending alerts for administrator role changes and exports",
                "Acceptance review The customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                "The service shall issue a single-use email invitation link that expires after twenty-four hours and records its redemption time.",
                "The workspace shall require multi-factor authentication for administrators before they can change organization settings or billing contacts.",
                "The audit search screen shall filter by actor, action, target project, and a caller-selected date range.",
                "The application shall retain exported reports for thirty days and allow only administrators to retrieve a retained report."
            ],
            "stakeholders": [
                "Account Owner",
                "Users",
                "Administrators"
            ]
        },
        "user_stories": [
            {
                "acceptance_criteria": [
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_1_ac_1",
                        "text": "Given an account owner in the customer workspace, when they create a project, then the project is successfully created."
                    }
                ],
                "deduplication_key": "create-a-project-and-invite-collaborators",
                "id": "US-001",
                "jira_fields": {
                    "acceptance_criteria": [
                        "Given an account owner in the customer workspace, when they create a project, then the project is successfully created."
                    ],
                    "components": [],
                    "description": "As an account owner, I want to create a project and invite named collaborators with a project-scoped role, so that I can manage the project effectively.",
                    "epic_name": "",
                    "issue_type": "Story",
                    "labels": [
                        "FR"
                    ],
                    "priority": "Medium",
                    "story_points": 5,
                    "summary": "Create a project and invite collaborators"
                },
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "requirement_id": "REQ-001",
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    },
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c2",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "Acceptance review\n\nThe customer workspace shall let an account owner create a project and invite named collaborators with a project-scoped role.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Create a project and invite collaborators",
                "type": "Functional",
                "user_story": "As an account owner, I want to create a project and invite named collaborators with a project-scoped role, so that I can manage the project effectively."
            },
            {
                "acceptance_criteria": [
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2_ac_1",
                        "text": "Given the required preconditions are satisfied, when Service attempts to issue single-use email invitation links, then the service issues a single-use email invitation link that expires after twenty-four hours."
                    },
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2_ac_2",
                        "text": "Given the required preconditions are satisfied, when Service attempts to issue single-use email invitation links, then records its redemption time."
                    }
                ],
                "deduplication_key": "issue-single-use-email-invitation-links",
                "id": "US-002",
                "jira_fields": {
                    "acceptance_criteria": [
                        "Given the required preconditions are satisfied, when Service attempts to issue single-use email invitation links, then the service issues a single-use email invitation link that expires after twenty-four hours.",
                        "Given the required preconditions are satisfied, when Service attempts to issue single-use email invitation links, then records its redemption time."
                    ],
                    "components": [],
                    "description": "As a system operator, I want to issue single-use email invitation links, so that the documented requirement is fulfilled.",
                    "epic_name": "",
                    "issue_type": "Story",
                    "labels": [
                        "FR"
                    ],
                    "priority": "Medium",
                    "story_points": 3,
                    "summary": "Issue single-use email invitation links"
                },
                "priority": "Medium",
                "quality": {
                    "issues": [
                        "Generated story failed validation: duplicate_acceptance_criteria. Story 1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2 has redundant acceptance criteria: 1eef1953-22c9-40dc-b2e8-deb755fa921a_story_2_ac_2."
                    ],
                    "score": 0.85,
                    "warnings": []
                },
                "requirement_id": "REQ-002",
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The service shall issue a single-use email invitation link that expires after twenty-four hours and records its redemption time.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Issue single-use email invitation links",
                "type": "Functional",
                "user_story": "As a system operator, I want to issue single-use email invitation links, so that the documented requirement is fulfilled."
            },
            {
                "acceptance_criteria": [
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_3_ac_1",
                        "text": "Given the required preconditions are satisfied, when Workspace attempts to require multi-factor authentication for administrators, then the workspace requires multi-factor authentication for administrators before they can change organization settings or billing contacts."
                    }
                ],
                "deduplication_key": "require-multi-factor-authentication-for-administrators",
                "id": "US-003",
                "jira_fields": {
                    "acceptance_criteria": [
                        "Given the required preconditions are satisfied, when Workspace attempts to require multi-factor authentication for administrators, then the workspace requires multi-factor authentication for administrators before they can change organization settings or billing contacts."
                    ],
                    "components": [],
                    "description": "As a system operator, I want to require multi-factor authentication for administrators before they can change organization settings or billing contacts, so that I can enhance security.",
                    "epic_name": "",
                    "issue_type": "Story",
                    "labels": [
                        "FR"
                    ],
                    "priority": "Medium",
                    "story_points": 5,
                    "summary": "Require multi-factor authentication for administrators"
                },
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "requirement_id": "REQ-003",
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The workspace shall require multi-factor authentication for administrators before they can change organization settings or billing contacts.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Require multi-factor authentication for administrators",
                "type": "Functional",
                "user_story": "As a system operator, I want to require multi-factor authentication for administrators before they can change organization settings or billing contacts, so that I can enhance security."
            },
            {
                "acceptance_criteria": [
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_4_ac_1",
                        "text": "Given an invitation is created, when the event is logged, then it is recorded as an immutable audit event."
                    }
                ],
                "deduplication_key": "record-immutable-audit-events",
                "id": "US-004",
                "jira_fields": {
                    "acceptance_criteria": [
                        "Given an invitation is created, when the event is logged, then it is recorded as an immutable audit event."
                    ],
                    "components": [],
                    "description": "As a system operator, I want to record immutable audit events for invitation creation, role changes, sign-in failures, and export requests, so that I can maintain a secure and traceable log.",
                    "epic_name": "",
                    "issue_type": "Story",
                    "labels": [
                        "FR"
                    ],
                    "priority": "Medium",
                    "story_points": 5,
                    "summary": "Record immutable audit events"
                },
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "requirement_id": "REQ-004",
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c0",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The system shall record immutable audit events for invitation creation, role changes, sign-in failures, and export requests.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Record immutable audit events",
                "type": "Functional",
                "user_story": "As a system operator, I want to record immutable audit events for invitation creation, role changes, sign-in failures, and export requests, so that I can maintain a secure and traceable log."
            },
            {
                "acceptance_criteria": [
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_5_ac_1",
                        "text": "Given the required preconditions are satisfied, when the User attempts to filter audit search results, then the audit search screen filters by actor."
                    }
                ],
                "deduplication_key": "filter-audit-search-results",
                "id": "US-005",
                "jira_fields": {
                    "acceptance_criteria": [
                        "Given the required preconditions are satisfied, when the User attempts to filter audit search results, then the audit search screen filters by actor."
                    ],
                    "components": [],
                    "description": "As a user, I want to filter audit search results by actor, action, target project, and a caller-selected date range, so that I can find relevant audit events easily.",
                    "epic_name": "",
                    "issue_type": "Story",
                    "labels": [
                        "FR"
                    ],
                    "priority": "Medium",
                    "story_points": 3,
                    "summary": "Filter audit search results"
                },
                "priority": "Medium",
                "quality": {
                    "issues": [
                        "Generated story failed validation: duplicate_acceptance_criteria."
                    ],
                    "score": 0.85,
                    "warnings": []
                },
                "requirement_id": "REQ-005",
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The audit search screen shall filter by actor, action, target project, and a caller-selected date range.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Filter audit search results",
                "type": "Functional",
                "user_story": "As a user, I want to filter audit search results by actor, action, target project, and a caller-selected date range, so that I can find relevant audit events easily."
            },
            {
                "acceptance_criteria": [
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_6_ac_1",
                        "text": "Given the required preconditions are satisfied, when the system attempts to generate audit reports in CSV and PDF formats, then the export service produces CSV and PDF audit reports."
                    },
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_6_ac_2",
                        "text": "Given the required preconditions are satisfied, when the system generates an audit report, then it includes the applied filters in each generated artifact."
                    }
                ],
                "deduplication_key": "generate-audit-reports-in-csv-and-pdf-formats",
                "id": "US-006",
                "jira_fields": {
                    "acceptance_criteria": [
                        "Given the required preconditions are satisfied, when the system attempts to generate audit reports in CSV and PDF formats, then the export service produces CSV and PDF audit reports.",
                        "Given the required preconditions are satisfied, when the system generates an audit report, then it includes the applied filters in each generated artifact."
                    ],
                    "components": [],
                    "description": "As a system operator, I want to produce CSV and PDF audit reports and include the applied filters in each generated artifact, so that users can have formatted records of audit events.",
                    "epic_name": "",
                    "issue_type": "Story",
                    "labels": [
                        "FR"
                    ],
                    "priority": "Medium",
                    "story_points": 5,
                    "summary": "Generate audit reports in CSV and PDF formats"
                },
                "priority": "Medium",
                "quality": {
                    "issues": [
                        "Generated story failed validation: duplicate_acceptance_criteria."
                    ],
                    "score": 0.85,
                    "warnings": []
                },
                "requirement_id": "REQ-006",
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The export service shall produce CSV and PDF audit reports and include the applied filters in each generated artifact.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Generate audit reports in CSV and PDF formats",
                "type": "Functional",
                "user_story": "As a system operator, I want to produce CSV and PDF audit reports and include the applied filters in each generated artifact, so that users can have formatted records of audit events."
            },
            {
                "acceptance_criteria": [
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_7_ac_1",
                        "text": "Given an exported report is generated, when it is stored, then it is retained for thirty days."
                    },
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_7_ac_2",
                        "text": "Given a report is retained, when a non-administrator attempts to retrieve it, then access is denied."
                    }
                ],
                "deduplication_key": "manage-exported-reports-retention",
                "id": "US-007",
                "jira_fields": {
                    "acceptance_criteria": [
                        "Given an exported report is generated, when it is stored, then it is retained for thirty days.",
                        "Given a report is retained, when a non-administrator attempts to retrieve it, then access is denied."
                    ],
                    "components": [],
                    "description": "As an administrator, I want to retain exported reports for thirty days and allow only administrators to retrieve a retained report, so that the documented requirement is fulfilled.",
                    "epic_name": "",
                    "issue_type": "Story",
                    "labels": [
                        "FR",
                        "BR"
                    ],
                    "priority": "Medium",
                    "story_points": 3,
                    "summary": "Manage exported reports retention"
                },
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "requirement_id": "REQ-007",
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The application shall retain exported reports for thirty days and allow only administrators to retrieve a retained report.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Manage exported reports retention",
                "type": "Functional",
                "user_story": "As an administrator, I want to retain exported reports for thirty days and allow only administrators to retrieve a retained report, so that the documented requirement is fulfilled."
            },
            {
                "acceptance_criteria": [
                    {
                        "criterion_type": "Given-When-Then",
                        "id": "1eef1953-22c9-40dc-b2e8-deb755fa921a_story_8_ac_1",
                        "text": "Given a new administrator role is granted, when the action is completed, then the account owner receives an alert notification."
                    }
                ],
                "deduplication_key": "receive-alerts-for-administrator-role-changes-and-exports",
                "id": "US-008",
                "jira_fields": {
                    "acceptance_criteria": [
                        "Given a new administrator role is granted, when the action is completed, then the account owner receives an alert notification."
                    ],
                    "components": [],
                    "description": "As an account owner, I want to receive alerts when a new administrator role is granted or when an export is downloaded, so that I can stay informed about important changes.",
                    "epic_name": "",
                    "issue_type": "Story",
                    "labels": [
                        "FR"
                    ],
                    "priority": "Medium",
                    "story_points": 3,
                    "summary": "Receive alerts for administrator role changes and exports"
                },
                "priority": "Medium",
                "quality": {
                    "issues": [],
                    "score": 1,
                    "warnings": []
                },
                "requirement_id": "REQ-008",
                "source_refs": [
                    {
                        "chunk_id": "chk_1eef1953-22c9-40dc-b2e8-deb755fa921a_doc_fbc0505ae0491db7_pNone_c1",
                        "confidence_score": 1,
                        "document_name": "customer_workspace_requirements.docx",
                        "page": null,
                        "quote": "The notification service shall alert account owners when a new administrator role is granted or when an export is downloaded.",
                        "source_id": "doc_fbc0505ae0491db7",
                        "source_type": "document"
                    }
                ],
                "title": "Receive alerts for administrator role changes and exports",
                "type": "Functional",
                "user_story": "As an account owner, I want to receive alerts when a new administrator role is granted or when an export is downloaded, so that I can stay informed about important changes."
            }
        ],
        "warnings": [
            {
                "code": "DUPLICATE_REQUIREMENT_MERGED",
                "message": "Merged 9 duplicate requirement(s) into canonical entries.",
                "node_name": "dedupe_requirements"
            },
            {
                "code": "GENERATE_STORY_QUALITY",
                "message": "Generated story quality issues: 3 story(ies) with issues (duplicate_acceptance_criteria).",
                "node_name": "generate"
            }
        ]
    },
    "message": "Results retrieved successfully",
    "statusCode": 200,
    "errors": []
}