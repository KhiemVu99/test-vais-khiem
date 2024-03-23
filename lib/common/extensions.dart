import 'package:flutter/material.dart';
import 'package:khiem_vais_test/model/status_filter.dart';
import 'package:khiem_vais_test/model/task.dart';

extension BuildContextExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  double get widthScreen => MediaQuery.sizeOf(this).width;
  double get heightScreen => MediaQuery.sizeOf(this).height;
}

extension IntExtension on int {
  DateTime get toDateTime => DateTime.fromMillisecondsSinceEpoch(this);
}

extension DateTimeExtensions on DateTime {
  String convertToPrettyFormat() {
    final now = DateTime.now();
    final difference = now.difference(this);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  int convertToRemainDays() {
    final now = DateTime.now();
    final difference = this.difference(now);
    if (difference.inDays > 0) {
      return difference.inDays;
    } else {
      return 0;
    }
  }

  String convertToFormatDate() {
    final day = this.day.toString().padLeft(2, '0');
    final month = this.month.toString().padLeft(2, '0');
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$day-$month $hour:$minute';
  }
}

extension StringExtensions on String? {
  Status toStatus() {
    switch (this) {
      case 'COMPLETED':
        return Status.COMPLETED;
      case 'UNCOMPLETED':
        return Status.UNCOMPLETED;
      case 'IN_PROGRESS':
        return Status.IN_PROGRESS;
      case 'EXPIRED':
        return Status.EXPIRED;
      default:
        return Status.UNCOMPLETED;
    }
  }
}

extension StatusExtension on Status {
  String toText() {
    switch (this) {
      case Status.COMPLETED:
        return 'Completed';
      case Status.UNCOMPLETED:
        return 'Uncompleted';
      case Status.IN_PROGRESS:
        return 'In Progress';
      case Status.EXPIRED:
        return 'Expired';
      default:
        return 'Uncompleted';
    }
  }
}

extension StatusFilterExtension on StatusFilter {
  String toText() {
    switch (this) {
      case StatusFilter.ALL:
        return 'All';
      case StatusFilter.COMPLETED:
        return 'Completed';
      case StatusFilter.UNCOMPLETED:
        return 'Uncompleted';
      case StatusFilter.IN_PROGRESS:
        return 'In Progress';
      case StatusFilter.EXPIRED:
        return 'Expired';
      default:
        return 'All';
    }
  }
}
