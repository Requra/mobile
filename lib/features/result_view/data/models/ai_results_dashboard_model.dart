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
    required super.requirementCoverages,
    required super.exports,
    required super.artifacts,
    required super.qualityIssues,
    required super.warnings,
    super.error,
    required super.processingTimeMs,
  });

  factory AiResultsDashboardModel.fromJson(Map<String, dynamic> json) {
    return AiResultsDashboardModel(
      projectId: json['projectId'] ?? '',
      analysisRunId: json['analysisRunId'] ?? '',
      status: json['status'] ?? '',
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'])
          : null,
      contractVersion: json['contractVersion'] ?? '',
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
      requirementCoverages: (json['requirementCoverages'] as List<dynamic>?)
              ?.map((e) => AiRequirementCoverageModel.fromJson(e))
              .toList() ??
          [],
      exports: AiExportsModel.fromJson(json['exports'] ?? {}),
      artifacts: AiArtifactsModel.fromJson(json['artifacts'] ?? {}),
      qualityIssues: (json['qualityIssues'] as List<dynamic>?)
              ?.map((e) => AiQualityIssueModel.fromJson(e))
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => AiWarningModel.fromJson(e))
              .toList() ??
          [],
      error: json['error'] != null ? AiErrorModel.fromJson(json['error']) : null,
      processingTimeMs: json['processingTimeMs'] ?? 0,
    );
  }
}

class SourceDocumentModel extends SourceDocument {
  const SourceDocumentModel({
    required super.id,
    required super.backendDocumentId,
    required super.title,
    required super.type,
    required super.language,
    required super.mimeType,
  });

  factory SourceDocumentModel.fromJson(Map<String, dynamic> json) {
    return SourceDocumentModel(
      id: json['id'] ?? '',
      backendDocumentId: json['backendDocumentId'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 0,
      language: json['language'] ?? 0,
      mimeType: json['mimeType'] ?? '',
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
      executiveSummary: json['executiveSummary'] ?? '',
      keyDecisions: List<String>.from(json['keyDecisions'] ?? []),
      openQuestions: (json['openQuestions'] as List<dynamic>?)
              ?.map((e) => AiOpenQuestionModel.fromJson(e))
              .toList() ??
          [],
      risks: (json['risks'] as List<dynamic>?)
              ?.map((e) => AiRiskModel.fromJson(e))
              .toList() ??
          [],
      assumptions: List<String>.from(json['assumptions'] ?? []),
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => AiActionItemModel.fromJson(e))
              .toList() ??
          [],
      stakeholders: List<String>.from(json['stakeholders'] ?? []),
      scope: List<String>.from(json['scope'] ?? []),
      outOfScope: List<String>.from(json['outOfScope'] ?? []),
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
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      sourceDocumentIds: List<String>.from(json['sourceDocumentIds'] ?? []),
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
    required super.sourceRefs,
  });

  factory AiRiskModel.fromJson(Map<String, dynamic> json) {
    return AiRiskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      sourceRefs: (json['sourceRefs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AiActionItemModel extends AiActionItem {
  const AiActionItemModel({
    required super.id,
    required super.title,
    super.owner,
    required super.priority,
    required super.sourceRefs,
  });

  factory AiActionItemModel.fromJson(Map<String, dynamic> json) {
    return AiActionItemModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      owner: json['owner'],
      priority: json['priority'] ?? '',
      sourceRefs: (json['sourceRefs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SourceRefModel extends SourceRef {
  const SourceRefModel({
    required super.sourceDocumentId,
    required super.backendDocumentId,
    required super.page,
    required super.chunkId,
    required super.quote,
  });

  factory SourceRefModel.fromJson(Map<String, dynamic> json) {
    return SourceRefModel(
      sourceDocumentId: json['sourceDocumentId'] ?? '',
      backendDocumentId: json['backendDocumentId'] ?? '',
      page: json['page'] ?? 0,
      chunkId: json['chunkId'] ?? '',
      quote: json['quote'] ?? '',
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
    required super.priority,
    required super.confidenceScore,
    required super.sourceDocumentIds,
    required super.sourceRefs,
  });

  factory AiRequirementModel.fromJson(Map<String, dynamic> json) {
    return AiRequirementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      priority: json['priority'] ?? '',
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      sourceDocumentIds: List<String>.from(json['sourceDocumentIds'] ?? []),
      sourceRefs: (json['sourceRefs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
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
    required super.requirementId,
    required super.sourceRefs,
  });

  factory AiUserStoryModel.fromJson(Map<String, dynamic> json) {
    return AiUserStoryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userStory: json['userStory'] ?? '',
      acceptanceCriteria: (json['acceptanceCriteria'] as List<dynamic>?)
              ?.map((e) => AiAcceptanceCriteriaModel.fromJson(e))
              .toList() ??
          [],
      priority: json['priority'] ?? '',
      requirementId: json['requirementId'] ?? '',
      sourceRefs: (json['sourceRefs'] as List<dynamic>?)
              ?.map((e) => SourceRefModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AiAcceptanceCriteriaModel extends AiAcceptanceCriteria {
  const AiAcceptanceCriteriaModel({
    required super.id,
    required super.text,
    required super.format,
  });

  factory AiAcceptanceCriteriaModel.fromJson(Map<String, dynamic> json) {
    return AiAcceptanceCriteriaModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      format: json['format'] ?? '',
    );
  }
}

class AiRequirementCoverageModel extends AiRequirementCoverage {
  const AiRequirementCoverageModel({
    required super.requirementId,
    required super.userStoryIds,
    required super.coverageStatus,
  });

  factory AiRequirementCoverageModel.fromJson(Map<String, dynamic> json) {
    return AiRequirementCoverageModel(
      requirementId: json['requirementId'] ?? '',
      userStoryIds: List<String>.from(json['userStoryIds'] ?? []),
      coverageStatus: json['coverageStatus'] ?? '',
    );
  }
}

class AiExportsModel extends AiExports {
  const AiExportsModel({
    required super.excel,
    required super.jira,
  });

  factory AiExportsModel.fromJson(Map<String, dynamic> json) {
    return AiExportsModel(
      excel: AiExportDataModel.fromJson(json['excel'] ?? {}),
      jira: AiExportDataModel.fromJson(json['jira'] ?? {}),
    );
  }
}

class AiExportDataModel extends AiExportData {
  const AiExportDataModel({
    required super.available,
    super.columns,
    super.rows,
    super.issueType,
  });

  factory AiExportDataModel.fromJson(Map<String, dynamic> json) {
    return AiExportDataModel(
      available: json['available'] ?? false,
      columns: json['columns'] != null
          ? List<String>.from(json['columns'])
          : null,
      rows: json['rows'] != null
          ? List<Map<String, dynamic>>.from(json['rows'])
          : null,
      issueType: json['issueType'],
    );
  }
}

class AiArtifactsModel extends AiArtifacts {
  const AiArtifactsModel({
    required super.excelFile,
  });

  factory AiArtifactsModel.fromJson(Map<String, dynamic> json) {
    return AiArtifactsModel(
      excelFile: AiArtifactFileModel.fromJson(json['excelFile'] ?? {}),
    );
  }
}

class AiArtifactFileModel extends AiArtifactFile {
  const AiArtifactFileModel({
    required super.available,
    required super.fileUrl,
    required super.fileName,
    required super.mimeType,
  });

  factory AiArtifactFileModel.fromJson(Map<String, dynamic> json) {
    return AiArtifactFileModel(
      available: json['available'] ?? false,
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'] ?? '',
      mimeType: json['mimeType'] ?? '',
    );
  }
}

class AiQualityIssueModel extends AiQualityIssue {
  const AiQualityIssueModel({
    required super.id,
    required super.severity,
    required super.message,
    required super.targetId,
  });

  factory AiQualityIssueModel.fromJson(Map<String, dynamic> json) {
    return AiQualityIssueModel(
      id: json['id'] ?? '',
      severity: json['severity'] ?? '',
      message: json['message'] ?? '',
      targetId: json['targetId'] ?? '',
    );
  }
}

class AiWarningModel extends AiWarning {
  const AiWarningModel({
    required super.code,
    required super.message,
  });

  factory AiWarningModel.fromJson(Map<String, dynamic> json) {
    return AiWarningModel(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class AiErrorModel extends AiError {
  const AiErrorModel({
    required super.code,
    required super.message,
    super.details,
  });

  factory AiErrorModel.fromJson(Map<String, dynamic> json) {
    return AiErrorModel(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      details: json['details'],
    );
  }
}
