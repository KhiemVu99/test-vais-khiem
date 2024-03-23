// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:khiem_vais_test/common/extensions.dart';

class Task extends Equatable {
  final String title;
  final Status status;
  final int deadline;
  final int createdAt;
  final bool isPinned;
  const Task({
    required this.title,
    this.status = Status.UNCOMPLETED,
    this.deadline = 0,
    this.createdAt = 0,
    this.isPinned = false,
  });

  Task copyWith({
    String? title,
    Status? status,
    int? deadline,
    int? createdAt,
    bool? isPinned,
  }) {
    return Task(
      title: title ?? this.title,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'status': status.name,
      'deadline': deadline,
      'createdAt': createdAt,
      'isPinned': isPinned,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] as String,
      status: (map['status'] as String).toStatus(),
      deadline: map['deadline'] as int,
      createdAt: map['createdAt'] as int,
      isPinned: map['isPinned'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      title,
      status,
      deadline,
      createdAt,
      isPinned,
    ];
  }

  bool isExpired() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return deadline > 0 && currentTime > deadline;
  }

  String getRemainingTime() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final remainingTime = deadline - currentTime;

    final days = remainingTime ~/ (24 * 60 * 60 * 1000);
    final hours = (remainingTime % (24 * 60 * 60 * 1000)) ~/ (60 * 60 * 1000);
    final minutes = (remainingTime % (60 * 60 * 1000)) ~/ (60 * 1000);

    return '$days days, $hours hours, $minutes minutes';
  }
}

enum Status {
  COMPLETED,
  UNCOMPLETED,
  IN_PROGRESS,
  EXPIRED,
}
