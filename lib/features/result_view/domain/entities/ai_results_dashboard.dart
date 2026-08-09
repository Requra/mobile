import 'package:equatable/equatable.dart';

class AiResultsDashboard extends Equatable {
  final String projectId;
  final String analysisRunId;
  final String status; // corresponds to analysisRunStatus
  final DateTime? generatedAt;
  final String contractVersion;
  final bool isUseful;
  final double relevanceScore;
  final List<SourceDocument> sourceDocuments;
  final AiSummary summary;
  final AiMetrics metrics;
  final List<AiRequirement> requirements;
  final List<AiUserStory> userStories;
  final QualityReport? qualityReport;

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
    this.qualityReport,
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
        qualityReport,
      ];
}

class SourceDocument extends Equatable {
  final String id;
  final String title;
  final String? type;
  final String? language;
  final String mimeType;
  final String? fileUrl;

  const SourceDocument({
    required this.id,
    required this.title,
    this.type,
    this.language,
    required this.mimeType,
    this.fileUrl,
  });

  @override
  List<Object?> get props =>
      [id, title, type, language, mimeType, fileUrl];
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
  final List<SourceRef> sourceRefs; // Might not be returned based on JSON, but kept for compatibility if needed

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

  const AiRisk({
    required this.id,
    required this.title,
    required this.severity,
    required this.description,
  });

  @override
  List<Object?> get props => [id, title, severity, description];
}

class AiActionItem extends Equatable {
  final String id;
  final String title;
  final String? owner;
  final String priority;

  const AiActionItem({
    required this.id,
    required this.title,
    this.owner,
    required this.priority,
  });

  @override
  List<Object?> get props => [id, title, owner, priority];
}

class SourceRef extends Equatable {
  final String? documentId;
  final String? sourceId;
  final String? documentTitle;
  final String? sourceType;
  final String? chunkId;
  final double? confidenceScore;
  final String? fileUrl;
  final String? quote;

  const SourceRef({
    this.documentId,
    this.sourceId,
    this.documentTitle,
    this.sourceType,
    this.chunkId,
    this.confidenceScore,
    this.fileUrl,
    this.quote,
  });

  @override
  List<Object?> get props =>
      [documentId, sourceId, documentTitle, sourceType, chunkId, confidenceScore, fileUrl, quote];
}

class QualityInfo extends Equatable {
  final double? score;
  final String? level;
  final List<String>? issues;
  final List<String>? warnings;

  const QualityInfo({
    this.score,
    this.level,
    this.issues,
    this.warnings,
  });

  @override
  List<Object?> get props => [score, level, issues, warnings];
}

class QualityReport extends Equatable {
  final double? overallScore;
  final double? traceabilityCoverage;
  final double? groundednessScore;
  final double? storyCompleteness;
  final double? acceptanceCriteriaQuality;
  final double? duplicateRisk;
  final int? highSeverityIssueCount;
  final int? requirementCount;
  final int? storyCount;

  const QualityReport({
    this.overallScore,
    this.traceabilityCoverage,
    this.groundednessScore,
    this.storyCompleteness,
    this.acceptanceCriteriaQuality,
    this.duplicateRisk,
    this.highSeverityIssueCount,
    this.requirementCount,
    this.storyCount,
  });

  @override
  List<Object?> get props => [
        overallScore,
        traceabilityCoverage,
        groundednessScore,
        storyCompleteness,
        acceptanceCriteriaQuality,
        duplicateRisk,
        highSeverityIssueCount,
        requirementCount,
        storyCount,
      ];
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
  final String? category;
  final String priority;
  final String? actor;
  final double confidenceScore;
  final QualityInfo? quality;
  final List<String> sourceDocumentIds;
  final List<SourceRef> sourceRefs;
  final String? workflowStatus;
  final int? version;
  final String? qualityStatus;

  const AiRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.category,
    required this.priority,
    this.actor,
    required this.confidenceScore,
    this.quality,
    required this.sourceDocumentIds,
    required this.sourceRefs,
    this.workflowStatus,
    this.version,
    this.qualityStatus,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        category,
        priority,
        actor,
        confidenceScore,
        quality,
        sourceDocumentIds,
        sourceRefs,
        workflowStatus,
        version,
        qualityStatus,
      ];
}

class AiUserStory extends Equatable {
  final String id;
  final String title;
  final String description;
  final String userStory;
  final List<String> acceptanceCriteria;
  final String priority;
  final String? type;
  final String requirementId;
  final QualityInfo? quality;
  final List<SourceRef> sourceRefs;
  final String? workflowStatus;
  final int? version;
  final String? qualityStatus;
  final int? revisionNumber;
  final String? revisionSource;

  const AiUserStory({
    required this.id,
    required this.title,
    required this.description,
    required this.userStory,
    required this.acceptanceCriteria,
    required this.priority,
    this.type,
    required this.requirementId,
    this.quality,
    required this.sourceRefs,
    this.workflowStatus,
    this.version,
    this.qualityStatus,
    this.revisionNumber,
    this.revisionSource,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        userStory,
        acceptanceCriteria,
        priority,
        type,
        requirementId,
        quality,
        sourceRefs,
        workflowStatus,
        version,
        qualityStatus,
        revisionNumber,
        revisionSource,
      ];
}
