import 'package:equatable/equatable.dart';

class AiResultsDashboard extends Equatable {
  final String projectId;
  final String analysisRunId;
  final String status;
  final DateTime? generatedAt;
  final String contractVersion;
  final bool isUseful;
  final double relevanceScore;
  final List<SourceDocument> sourceDocuments;
  final AiSummary summary;
  final AiMetrics metrics;
  final List<AiRequirement> requirements;
  final List<AiUserStory> userStories;
  final List<AiRequirementCoverage> requirementCoverages;
  final AiExports exports;
  final AiArtifacts artifacts;
  final List<AiQualityIssue> qualityIssues;
  final List<AiWarning> warnings;
  final AiError? error;
  final int processingTimeMs;

  const AiResultsDashboard({
    required this.projectId,
    required this.analysisRunId,
    required this.status,
    this.generatedAt,
    required this.contractVersion,
    required this.isUseful,
    required this.relevanceScore,
    required this.sourceDocuments,
    required this.summary,
    required this.metrics,
    required this.requirements,
    required this.userStories,
    required this.requirementCoverages,
    required this.exports,
    required this.artifacts,
    required this.qualityIssues,
    required this.warnings,
    this.error,
    required this.processingTimeMs,
  });

  @override
  List<Object?> get props => [
        projectId,
        analysisRunId,
        status,
        generatedAt,
        contractVersion,
        isUseful,
        relevanceScore,
        sourceDocuments,
        summary,
        metrics,
        requirements,
        userStories,
        requirementCoverages,
        exports,
        artifacts,
        qualityIssues,
        warnings,
        error,
        processingTimeMs,
      ];
}

class SourceDocument extends Equatable {
  final String id;
  final String backendDocumentId;
  final String title;
  final int type;
  final int language;
  final String mimeType;

  const SourceDocument({
    required this.id,
    required this.backendDocumentId,
    required this.title,
    required this.type,
    required this.language,
    required this.mimeType,
  });

  @override
  List<Object?> get props =>
      [id, backendDocumentId, title, type, language, mimeType];
}

class AiSummary extends Equatable {
  final String executiveSummary;
  final List<String> keyDecisions;
  final List<AiOpenQuestion> openQuestions;
  final List<AiRisk> risks;
  final List<String> assumptions;
  final List<AiActionItem> actionItems;
  final List<String> stakeholders;
  final List<String> scope;
  final List<String> outOfScope;

  const AiSummary({
    required this.executiveSummary,
    required this.keyDecisions,
    required this.openQuestions,
    required this.risks,
    required this.assumptions,
    required this.actionItems,
    required this.stakeholders,
    required this.scope,
    required this.outOfScope,
  });

  @override
  List<Object?> get props => [
        executiveSummary,
        keyDecisions,
        openQuestions,
        risks,
        assumptions,
        actionItems,
        stakeholders,
        scope,
        outOfScope,
      ];
}

class AiOpenQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> sourceDocumentIds;
  final List<SourceRef> sourceRefs;

  const AiOpenQuestion({
    required this.id,
    required this.question,
    required this.sourceDocumentIds,
    required this.sourceRefs,
  });

  @override
  List<Object?> get props => [id, question, sourceDocumentIds, sourceRefs];
}

class AiRisk extends Equatable {
  final String id;
  final String title;
  final String severity;
  final String description;
  final List<SourceRef> sourceRefs;

  const AiRisk({
    required this.id,
    required this.title,
    required this.severity,
    required this.description,
    required this.sourceRefs,
  });

  @override
  List<Object?> get props => [id, title, severity, description, sourceRefs];
}

class AiActionItem extends Equatable {
  final String id;
  final String title;
  final String? owner;
  final String priority;
  final List<SourceRef> sourceRefs;

  const AiActionItem({
    required this.id,
    required this.title,
    this.owner,
    required this.priority,
    required this.sourceRefs,
  });

  @override
  List<Object?> get props => [id, title, owner, priority, sourceRefs];
}

class SourceRef extends Equatable {
  final String sourceDocumentId;
  final String backendDocumentId;
  final int page;
  final String chunkId;
  final String quote;

  const SourceRef({
    required this.sourceDocumentId,
    required this.backendDocumentId,
    required this.page,
    required this.chunkId,
    required this.quote,
  });

  @override
  List<Object?> get props =>
      [sourceDocumentId, backendDocumentId, page, chunkId, quote];
}

class AiMetrics extends Equatable {
  final int totalRequirements;
  final int functionalRequirements;
  final int nonFunctionalRequirements;
  final int businessRequirements;
  final int userStories;
  final int highPriorityItems;
  final int risksCount;
  final int openQuestionsCount;
  final int warningsCount;
  final int qualityIssuesCount;

  const AiMetrics({
    required this.totalRequirements,
    required this.functionalRequirements,
    required this.nonFunctionalRequirements,
    required this.businessRequirements,
    required this.userStories,
    required this.highPriorityItems,
    required this.risksCount,
    required this.openQuestionsCount,
    required this.warningsCount,
    required this.qualityIssuesCount,
  });

  @override
  List<Object?> get props => [
        totalRequirements,
        functionalRequirements,
        nonFunctionalRequirements,
        businessRequirements,
        userStories,
        highPriorityItems,
        risksCount,
        openQuestionsCount,
        warningsCount,
        qualityIssuesCount,
      ];
}

class AiRequirement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type;
  final String priority;
  final double confidenceScore;
  final List<String> sourceDocumentIds;
  final List<SourceRef> sourceRefs;

  const AiRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.confidenceScore,
    required this.sourceDocumentIds,
    required this.sourceRefs,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        priority,
        confidenceScore,
        sourceDocumentIds,
        sourceRefs,
      ];
}

class AiUserStory extends Equatable {
  final String id;
  final String title;
  final String description;
  final String userStory;
  final List<AiAcceptanceCriteria> acceptanceCriteria;
  final String priority;
  final String requirementId;
  final List<SourceRef> sourceRefs;

  const AiUserStory({
    required this.id,
    required this.title,
    required this.description,
    required this.userStory,
    required this.acceptanceCriteria,
    required this.priority,
    required this.requirementId,
    required this.sourceRefs,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        userStory,
        acceptanceCriteria,
        priority,
        requirementId,
        sourceRefs,
      ];
}

class AiAcceptanceCriteria extends Equatable {
  final String id;
  final String text;
  final String format;

  const AiAcceptanceCriteria({
    required this.id,
    required this.text,
    required this.format,
  });

  @override
  List<Object?> get props => [id, text, format];
}

class AiRequirementCoverage extends Equatable {
  final String requirementId;
  final List<String> userStoryIds;
  final String coverageStatus;

  const AiRequirementCoverage({
    required this.requirementId,
    required this.userStoryIds,
    required this.coverageStatus,
  });

  @override
  List<Object?> get props => [requirementId, userStoryIds, coverageStatus];
}

class AiExports extends Equatable {
  final AiExportData excel;
  final AiExportData jira;

  const AiExports({
    required this.excel,
    required this.jira,
  });

  @override
  List<Object?> get props => [excel, jira];
}

class AiExportData extends Equatable {
  final bool available;
  final List<String>? columns;
  final List<Map<String, dynamic>>? rows;
  final String? issueType;

  const AiExportData({
    required this.available,
    this.columns,
    this.rows,
    this.issueType,
  });

  @override
  List<Object?> get props => [available, columns, rows, issueType];
}

class AiArtifacts extends Equatable {
  final AiArtifactFile excelFile;

  const AiArtifacts({required this.excelFile});

  @override
  List<Object?> get props => [excelFile];
}

class AiArtifactFile extends Equatable {
  final bool available;
  final String fileUrl;
  final String fileName;
  final String mimeType;

  const AiArtifactFile({
    required this.available,
    required this.fileUrl,
    required this.fileName,
    required this.mimeType,
  });

  @override
  List<Object?> get props => [available, fileUrl, fileName, mimeType];
}

class AiQualityIssue extends Equatable {
  final String id;
  final String severity;
  final String message;
  final String targetId;

  const AiQualityIssue({
    required this.id,
    required this.severity,
    required this.message,
    required this.targetId,
  });

  @override
  List<Object?> get props => [id, severity, message, targetId];
}

class AiWarning extends Equatable {
  final String code;
  final String message;

  const AiWarning({
    required this.code,
    required this.message,
  });

  @override
  List<Object?> get props => [code, message];
}

class AiError extends Equatable {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const AiError({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [code, message, details];
}
