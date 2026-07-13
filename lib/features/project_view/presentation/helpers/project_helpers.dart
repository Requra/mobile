import 'package:flutter/material.dart';
import 'package:requra/core/theme/color_manager.dart';

/// Maps a raw API status value to a human-readable label.
String statusLabel(String status) {
  switch (status) {
    case 'InProgress':
      return 'In Progress';
    case 'Completed':
      return 'Completed';
    case 'Draft':
      return 'Draft';
    default:
      return status;
  }
}

/// Maps a project status string to its display badge label.
String projectStatusBadge(String status) {
  final s = status.toLowerCase();
  if (s.contains('process') || s.contains('progress')) {
    return 'IN PROGRESS';
  }
  if (s.contains('complet') || s.contains('finish')) {
    return 'FINISHED';
  }
  return 'Draft';
}

/// Returns the background color for a project status badge.
Color statusBadgeBg(String badge) {
  if (badge == 'IN PROGRESS') return AppColors.statusInProgressLight;
  if (badge == 'FINISHED') return AppColors.statusFinishedLight;
  return AppColors.grey;
}

/// Returns the text/icon color for a project status badge.
Color statusBadgeColor(String badge) {
  if (badge == 'IN PROGRESS') return AppColors.statusInProgress;
  if (badge == 'FINISHED') return AppColors.statusFinished;
  return AppColors.lightgrey;
}


