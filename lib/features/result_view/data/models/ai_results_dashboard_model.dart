import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';

class AiResultsDashboardModel extends AiResultsDashboard {
  const AiResultsDashboardModel({
    required super.projectId,
    required super.analysisRunId,
    required super.status,
    super.generatedAt,
    required super.contractVersion,
    required super.isUseful,
    required super.relevanceScore,
    required super.sourceDocuments,
    required super.summary,
    required super.metrics,
    required super.requirements,
    required super.userStories,
    super.qualityReport,
    super.rawJson,
  });

  factory AiResultsDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawRequirements = (json['requirements'] as List<dynamic>?) ?? [];
    final requirements = rawRequirements.map((e) => AiRequirementModel.fromJson(e)).toList();
    
    final rawUserStories = (json['user_stories'] as List<dynamic>?) ?? [];
    final userStories = rawUserStories.map((e) => AiUserStoryModel.fromJson(e)).toList();
    
    final summary = AiSummaryModel.fromJson(json['summary'] ?? {});
    
    // Calculate metrics
    final totalRequirements = requirements.length;
    final functionalRequirements = requirements.where((r) => r.type.toLowerCase() == 'functional').length;
    final nonFunctionalRequirements = requirements.where((r) => r.type.toLowerCase() == 'non-functional').length;
    final businessRequirements = requirements.where((r) => r.type.toLowerCase() == 'business').length;
    final userStoriesCount = userStories.length;
    final highPriorityItems = requirements.where((r) => r.priority.toLowerCase() == 'high').length +
        userStories.where((us) => us.priority.toLowerCase() == 'high').length;
    final risksCount = summary.risks.length;
    final openQuestionsCount = summary.openQuestions.length;
    final warningsCount = (json['warnings'] as List<dynamic>?)?.length ?? 0;
    final qualityIssuesCount = (json['quality_issues'] as List<dynamic>?)?.length ?? 0;

    final metrics = AiMetricsModel(
      totalRequirements: totalRequirements,
      functionalRequirements: functionalRequirements,
      nonFunctionalRequirements: nonFunctionalRequirements,
      businessRequirements: businessRequirements,
      userStories: userStoriesCount,
      highPriorityItems: highPriorityItems,
      risksCount: risksCount,
      openQuestionsCount: openQuestionsCount,
      warningsCount: warningsCount,
      qualityIssuesCount: qualityIssuesCount,
    );

    return AiResultsDashboardModel(
      projectId: json['project_id']?.toString() ?? '',
      analysisRunId: json['job_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      generatedAt: null,
      contractVersion: json['contract_version']?.toString() ?? '',
      isUseful: json['is_useful'] ?? false,
      relevanceScore: (json['relevance_score'] ?? 0).toDouble(),
      sourceDocuments: (json['source_documents'] as List<dynamic>?)
              ?.map((e) => SourceDocumentModel.fromJson(e))
              .toList() ??
          [],
      summary: summary,
      metrics: metrics,
      requirements: requirements,
      userStories: userStories,
      qualityReport: json['quality_report'] != null
          ? QualityReportModel.fromJson(json['quality_report'])
          : null,
      rawJson: json,
    );
  }
}

class SourceDocumentModel extends SourceDocument {
  const SourceDocumentModel({
    required super.id,
    required super.title,
    super.type,
    super.language,
    required super.mimeType,
    super.fileUrl,
  });

  factory SourceDocumentModel.fromJson(Map<String, dynamic> json) {
    return SourceDocumentModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString(),
      language: json['language']?.toString(),
      mimeType: json['mime_type']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
    );
  }
}

class AiSummaryModel extends AiSummary {
  const AiSummaryModel({
    required super.executiveSummary,
    required super.keyDecisions,
    required super.openQuestions,
    required super.risks,
    required super.assumptions,
    required super.actionItems,
    required super.stakeholders,
    required super.scope,
    required super.outOfScope,
  });

  factory AiSummaryModel.fromJson(Map<String, dynamic> json) {
    return AiSummaryModel(
      executiveSummary: json['executive_summary']?.toString() ?? '',
      keyDecisions: (json['key_decisions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      openQuestions: (json['open_questions'] as List<dynamic>?)
              ?.map((e) => AiOpenQuestionModel.fromJson(e))
              .toList() ??
          [],
      risks: (json['risks'] as List<dynamic>?)
              ?.map((e) => AiRiskModel.fromJson(e))
              .toList() ??
          [],
      assumptions: (json['assumptions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      actionItems: (json['action_items'] as List<dynamic>?)
              ?.map((e) => AiActionItemModel.fromJson(e))
              .toList() ??
          [],
      stakeholders: (json['stakeholders'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      scope: (json['scope'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      outOfScope: (json['out_of_scope'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AiOpenQuestionModel extends AiOpenQuestion {
  const AiOpenQuestionModel({
    required super.id,
    required super.question,
    required super.sourceDocumentIds,
    required super.sourceRefs,
  });

  factory AiOpenQuestionModel.fromJson(Map<String, dynamic> json) {
    return AiOpenQuestionModel(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      sourceDocumentIds: (json['source_document_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sourceRefs: (json['source_refs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AiRiskModel extends AiRisk {
  const AiRiskModel({
    required super.id,
    required super.title,
    required super.severity,
    required super.description,
  });

  factory AiRiskModel.fromJson(Map<String, dynamic> json) {
    return AiRiskModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class AiActionItemModel extends AiActionItem {
  const AiActionItemModel({
    required super.id,
    required super.title,
    super.owner,
    required super.priority,
  });

  factory AiActionItemModel.fromJson(Map<String, dynamic> json) {
    return AiActionItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      owner: json['owner']?.toString(),
      priority: json['priority']?.toString() ?? '',
    );
  }
}

class SourceRefModel extends SourceRef {
  const SourceRefModel({
    super.documentId,
    super.sourceId,
    super.documentTitle,
    super.sourceType,
    super.chunkId,
    super.confidenceScore,
    super.fileUrl,
    super.quote,
  });

  factory SourceRefModel.fromJson(Map<String, dynamic> json) {
    return SourceRefModel(
      documentId: json['document_id']?.toString(),
      sourceId: json['source_id']?.toString(),
      documentTitle: json['document_title']?.toString(),
      sourceType: json['source_type']?.toString(),
      chunkId: json['chunk_id']?.toString(),
      confidenceScore: json['confidence_score'] != null ? (json['confidence_score'] as num).toDouble() : null,
      fileUrl: json['file_url']?.toString(),
      quote: json['quote']?.toString(),
    );
  }
}

class QualityInfoModel extends QualityInfo {
  const QualityInfoModel({
    super.score,
    super.level,
    super.issues,
    super.warnings,
  });

  factory QualityInfoModel.fromJson(Map<String, dynamic> json) {
    return QualityInfoModel(
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      level: json['level']?.toString(),
      issues: (json['issues'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      warnings: (json['warnings'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}

class QualityReportModel extends QualityReport {
  const QualityReportModel({
    super.overallScore,
    super.traceabilityCoverage,
    super.groundednessScore,
    super.storyCompleteness,
    super.acceptanceCriteriaQuality,
    super.duplicateRisk,
    super.highSeverityIssueCount,
    super.requirementCount,
    super.storyCount,
  });

  factory QualityReportModel.fromJson(Map<String, dynamic> json) {
    return QualityReportModel(
      overallScore: json['overall_score'] != null ? (json['overall_score'] as num).toDouble() : null,
      traceabilityCoverage: json['traceability_coverage'] != null ? (json['traceability_coverage'] as num).toDouble() : null,
      groundednessScore: json['groundedness_score'] != null ? (json['groundedness_score'] as num).toDouble() : null,
      storyCompleteness: json['story_completeness'] != null ? (json['story_completeness'] as num).toDouble() : null,
      acceptanceCriteriaQuality: json['acceptance_criteria_quality'] != null ? (json['acceptance_criteria_quality'] as num).toDouble() : null,
      duplicateRisk: json['duplicate_risk'] != null ? (json['duplicate_risk'] as num).toDouble() : null,
      highSeverityIssueCount: json['high_severity_issue_count'] as int?,
      requirementCount: json['requirement_count'] as int?,
      storyCount: json['story_count'] as int?,
    );
  }
}

class AiMetricsModel extends AiMetrics {
  const AiMetricsModel({
    required super.totalRequirements,
    required super.functionalRequirements,
    required super.nonFunctionalRequirements,
    required super.businessRequirements,
    required super.userStories,
    required super.highPriorityItems,
    required super.risksCount,
    required super.openQuestionsCount,
    required super.warningsCount,
    required super.qualityIssuesCount,
  });

  factory AiMetricsModel.fromJson(Map<String, dynamic> json) {
    return AiMetricsModel(
      totalRequirements: json['totalRequirements'] ?? 0,
      functionalRequirements: json['functionalRequirements'] ?? 0,
      nonFunctionalRequirements: json['nonFunctionalRequirements'] ?? 0,
      businessRequirements: json['businessRequirements'] ?? 0,
      userStories: json['userStories'] ?? 0,
      highPriorityItems: json['highPriorityItems'] ?? 0,
      risksCount: json['risksCount'] ?? 0,
      openQuestionsCount: json['openQuestionsCount'] ?? 0,
      warningsCount: json['warningsCount'] ?? 0,
      qualityIssuesCount: json['qualityIssuesCount'] ?? 0,
    );
  }
}

class AiRequirementModel extends AiRequirement {
  const AiRequirementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    super.category,
    required super.priority,
    super.actor,
    required super.confidenceScore,
    super.quality,
    required super.sourceDocumentIds,
    required super.sourceRefs,
    super.workflowStatus,
    super.version,
    super.qualityStatus,
  });

  factory AiRequirementModel.fromJson(Map<String, dynamic> json) {
    return AiRequirementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString(),
      priority: json['priority']?.toString() ?? '',
      actor: json['actor']?.toString(),
      confidenceScore: (json['confidence_score'] ?? 0).toDouble(),
      quality: json['quality'] != null ? QualityInfoModel.fromJson(json['quality']) : null,
      sourceDocumentIds: (json['source_document_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sourceRefs: (json['source_refs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
      workflowStatus: json['workflow_status']?.toString(),
      version: json['version'] as int?,
      qualityStatus: json['quality_status']?.toString(),
    );
  }
}

class AiUserStoryModel extends AiUserStory {
  const AiUserStoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.userStory,
    required super.acceptanceCriteria,
    required super.priority,
    super.type,
    required super.requirementId,
    super.quality,
    required super.sourceRefs,
    super.workflowStatus,
    super.version,
    super.qualityStatus,
    super.revisionNumber,
    super.revisionSource,
  });

  factory AiUserStoryModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedAC = [];
    if (json['acceptance_criteria'] != null) {
      for (var item in json['acceptance_criteria']) {
        if (item is String) {
          parsedAC.add(item);
        } else if (item is Map<String, dynamic> && item['text'] != null) {
          parsedAC.add(item['text'].toString());
        } else {
          parsedAC.add(item.toString());
        }
      }
    }

    return AiUserStoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      userStory: json['user_story']?.toString() ?? '',
      acceptanceCriteria: parsedAC,
      priority: json['priority']?.toString() ?? '',
      type: json['type']?.toString(),
      requirementId: json['requirement_id']?.toString() ?? '',
      quality: json['quality'] != null ? QualityInfoModel.fromJson(json['quality']) : null,
      sourceRefs: (json['source_refs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
      workflowStatus: json['workflow_status']?.toString(),
      version: json['version'] as int?,
      qualityStatus: json['quality_status']?.toString(),
      revisionNumber: json['revision_number'] as int?,
      revisionSource: json['revision_source']?.toString(),
    );
  }
}
