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
    return AiResultsDashboardModel(
      projectId: json['projectId']?.toString() ?? '',
      analysisRunId: json['analysisRunId']?.toString() ?? '',
      status: json['analysisRunStatus']?.toString() ?? '',
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'].toString())
          : null,
      contractVersion: json['contractVersion']?.toString() ?? '',
      isUseful: json['isUseful'] ?? false,
      relevanceScore: (json['relevanceScore'] ?? 0).toDouble(),
      sourceDocuments: (json['sourceDocuments'] as List<dynamic>?)
              ?.map((e) => SourceDocumentModel.fromJson(e))
              .toList() ??
          [],
      summary: AiSummaryModel.fromJson(json['summary'] ?? {}),
      metrics: AiMetricsModel.fromJson(json['metrics'] ?? {}),
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => AiRequirementModel.fromJson(e))
              .toList() ??
          [],
      userStories: (json['userStories'] as List<dynamic>?)
              ?.map((e) => AiUserStoryModel.fromJson(e))
              .toList() ??
          [],
      qualityReport: json['qualityReport'] != null
          ? QualityReportModel.fromJson(json['qualityReport'])
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
      mimeType: json['mimeType']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString(),
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
      executiveSummary: json['executiveSummary']?.toString() ?? '',
      keyDecisions: (json['keyDecisions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      openQuestions: (json['openQuestions'] as List<dynamic>?)
              ?.map((e) => AiOpenQuestionModel.fromJson(e))
              .toList() ??
          [],
      risks: (json['risks'] as List<dynamic>?)
              ?.map((e) => AiRiskModel.fromJson(e))
              .toList() ??
          [],
      assumptions: (json['assumptions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => AiActionItemModel.fromJson(e))
              .toList() ??
          [],
      stakeholders: (json['stakeholders'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      scope: (json['scope'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      outOfScope: (json['outOfScope'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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
      sourceDocumentIds: (json['sourceDocumentIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sourceRefs: (json['sourceRefs'] as List<dynamic>?)
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
      documentId: json['documentId']?.toString(),
      sourceId: json['sourceId']?.toString(),
      documentTitle: json['documentTitle']?.toString(),
      sourceType: json['sourceType']?.toString(),
      chunkId: json['chunkId']?.toString(),
      confidenceScore: json['confidenceScore'] != null ? (json['confidenceScore'] as num).toDouble() : null,
      fileUrl: json['fileUrl']?.toString(),
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
      overallScore: json['overallScore'] != null ? (json['overallScore'] as num).toDouble() : null,
      traceabilityCoverage: json['traceabilityCoverage'] != null ? (json['traceabilityCoverage'] as num).toDouble() : null,
      groundednessScore: json['groundednessScore'] != null ? (json['groundednessScore'] as num).toDouble() : null,
      storyCompleteness: json['storyCompleteness'] != null ? (json['storyCompleteness'] as num).toDouble() : null,
      acceptanceCriteriaQuality: json['acceptanceCriteriaQuality'] != null ? (json['acceptanceCriteriaQuality'] as num).toDouble() : null,
      duplicateRisk: json['duplicateRisk'] != null ? (json['duplicateRisk'] as num).toDouble() : null,
      highSeverityIssueCount: json['highSeverityIssueCount'] as int?,
      requirementCount: json['requirementCount'] as int?,
      storyCount: json['storyCount'] as int?,
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
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      quality: json['quality'] != null ? QualityInfoModel.fromJson(json['quality']) : null,
      sourceDocumentIds: (json['sourceDocumentIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sourceRefs: (json['sourceRefs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
      workflowStatus: json['workflowStatus']?.toString(),
      version: json['version'] as int?,
      qualityStatus: json['qualityStatus']?.toString(),
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
    if (json['acceptanceCriteria'] != null) {
      for (var item in json['acceptanceCriteria']) {
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
      userStory: json['userStory']?.toString() ?? '',
      acceptanceCriteria: parsedAC,
      priority: json['priority']?.toString() ?? '',
      type: json['type']?.toString(),
      requirementId: json['requirementId']?.toString() ?? '',
      quality: json['quality'] != null ? QualityInfoModel.fromJson(json['quality']) : null,
      sourceRefs: (json['sourceRefs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
      workflowStatus: json['workflowStatus']?.toString(),
      version: json['version'] as int?,
      qualityStatus: json['qualityStatus']?.toString(),
      revisionNumber: json['revisionNumber'] as int?,
      revisionSource: json['revisionSource']?.toString(),
    );
  }
}
