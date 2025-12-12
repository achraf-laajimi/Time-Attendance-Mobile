import 'package:flutter/foundation.dart';
import 'package:objectid/objectid.dart';
import 'dart:developer' as developer;

// Enum values aligned with backend schema
enum TaskPriority { Low, Medium, High, Urgent }
enum TaskStatus { ToDo, InProgress, InReview, Completed }
enum FileType { image, document, other }

class Task {
  final String id;
  final String name;
  final String description;
  final DateTime beginDate;
  final DateTime endDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedTo; 
  final String project; 
  final List<Comment> comments;
  final List<PrivateMessage> privateMessages;
  final List<Attachment> attachments;
  final List<WorkEvidence> workEvidence;
  final List<ChangeLog> changeLog;
  final String? lastUpdatedBy; 

  Task({
    String? id,
    required this.name,
    required this.description,
    required this.beginDate,
    required this.endDate,
    this.priority = TaskPriority.Medium,
    this.status = TaskStatus.ToDo,
    this.assignedTo, 
    required this.project,
    this.comments = const [],
    this.privateMessages = const [],
    this.attachments = const [],
    this.workEvidence = const [],
    this.changeLog = const [],
    this.lastUpdatedBy,
  }) : id = _validateOrGenerateId(id);

  static String _validateOrGenerateId(String? id) {
    if (id == null) {
      final newId = ObjectId().hexString;
      developer.log('Generated new ObjectId: $newId');
      return newId;
    }
    if (_isValidObjectId(id)) {
      return id;
    }
    developer.log('Invalid ObjectID: $id', error: 'Invalid ObjectID format');
    throw ArgumentError('Invalid ObjectID format: $id. Expected a 24-character hexadecimal string.');
  }

  static bool _isValidObjectId(String id) {
    final isValid = RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id);
    if (!isValid) {
      developer.log('ObjectID validation failed for: $id');
    }
    return isValid;
  }

  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? beginDate,
    DateTime? endDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo, 
    String? project,
    List<Comment>? comments,
    List<PrivateMessage>? privateMessages,
    List<Attachment>? attachments,
    List<WorkEvidence>? workEvidence,
    List<ChangeLog>? changeLog,
    String? lastUpdatedBy,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      beginDate: beginDate ?? this.beginDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo, 
      project: project ?? this.project,
      comments: comments ?? this.comments,
      privateMessages: privateMessages ?? this.privateMessages,
      attachments: attachments ?? this.attachments,
      workEvidence: workEvidence ?? this.workEvidence,
      changeLog: changeLog ?? this.changeLog,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'beginDate': beginDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'priority': _priorityToString(priority),
      'status': _statusToString(status),
      'assignedTo': assignedTo, 
      'project': project,
      'comments': comments.map((e) => e.toJson()).toList(),
      'privateMessages': privateMessages.map((e) => e.toJson()).toList(),
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'workEvidence': workEvidence.map((e) => e.toJson()).toList(),
      'changeLog': changeLog.map((e) => e.toJson()).toList(),
      'lastUpdatedBy': lastUpdatedBy,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    // Handle assignedTo which can be String or Map
    dynamic assignedToValue = json['assignedTo'];
    String? assignedTo;
    
    if (assignedToValue is Map) {
      assignedTo = assignedToValue['_id']?.toString();
    } else if (assignedToValue is String) {
      assignedTo = assignedToValue;
    }

    // Handle project which can be String or Map
    dynamic projectValue = json['project'];
    String project;
    
    if (projectValue is Map) {
      project = projectValue['_id']?.toString() ?? '';
    } else {
      project = projectValue?.toString() ?? '';
    }

    // Handle lastUpdatedBy which can be String or Map
    dynamic lastUpdatedByValue = json['lastUpdatedBy'];
    String? lastUpdatedBy;
    
    if (lastUpdatedByValue is Map) {
      lastUpdatedBy = lastUpdatedByValue['_id']?.toString();
    } else if (lastUpdatedByValue is String) {
      lastUpdatedBy = lastUpdatedByValue;
    }

    // Handle changeLog items
    List<ChangeLog> parseChangeLog(List<dynamic>? changeLogJson) {
      if (changeLogJson == null) return [];
      return changeLogJson.map((item) {
        dynamic updatedByValue = item['updatedBy'];
        String updatedBy;
        
        if (updatedByValue is Map) {
          updatedBy = updatedByValue['_id']?.toString() ?? '';
        } else {
          updatedBy = updatedByValue?.toString() ?? '';
        }

        return ChangeLog(
          id: item['_id']?.toString() ?? '',
          updatedBy: updatedBy,
          updatedAt: DateTime.parse(item['updatedAt'] as String),
          changes: Map<String, dynamic>.from(item['changes'] as Map),
          message: item['message'] as String?,
        );
      }).toList();
    }

    return Task(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      beginDate: DateTime.parse(json['beginDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      priority: _stringToPriority(json['priority'] as String),
      status: _stringToStatus(json['status'] as String),
      assignedTo: assignedTo,
      project: project,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      privateMessages: (json['privateMessages'] as List<dynamic>?)
              ?.map((e) => PrivateMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      workEvidence: (json['workEvidence'] as List<dynamic>?)
              ?.map((e) => WorkEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      changeLog: parseChangeLog(json['changeLog'] as List<dynamic>?),
      lastUpdatedBy: lastUpdatedBy,
    );
  }

  static String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.Low:
        return 'Low';
      case TaskPriority.Medium:
        return 'Medium';
      case TaskPriority.High:
        return 'High';
      case TaskPriority.Urgent:
        return 'Urgent';
    }
  }

  static TaskPriority _stringToPriority(String priority) {
    switch (priority) {
      case 'Low':
        return TaskPriority.Low;
      case 'Medium':
        return TaskPriority.Medium;
      case 'High':
        return TaskPriority.High;
      case 'Urgent':
        return TaskPriority.Urgent;
      default:
        developer.log('Invalid priority value: $priority, defaulting to Medium');
        return TaskPriority.Medium;
    }
  }

  // Convert TaskStatus to backend-compatible string
  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.ToDo:
        return 'To Do';
      case TaskStatus.InProgress:
        return 'In Progress';
      case TaskStatus.InReview:
        return 'In Review';
      case TaskStatus.Completed:
        return 'Completed';
    }
  }

  // Convert backend status string to TaskStatus
  static TaskStatus _stringToStatus(String status) {
    switch (status) {
      case 'To Do':
        return TaskStatus.ToDo;
      case 'In Progress':
        return TaskStatus.InProgress;
      case 'In Review':
        return TaskStatus.InReview;
      case 'Completed':
        return TaskStatus.Completed;
      default:
        developer.log('Invalid status value: $status, defaulting to ToDo');
        return TaskStatus.ToDo;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.beginDate == beginDate &&
        other.endDate == endDate &&
        other.priority == priority &&
        other.status == status &&
        other.assignedTo == assignedTo &&
        other.project == project &&
        listEquals(other.comments, comments) &&
        listEquals(other.privateMessages, privateMessages) &&
        listEquals(other.attachments, attachments) &&
        listEquals(other.workEvidence, workEvidence) &&
        listEquals(other.changeLog, changeLog) &&
        other.lastUpdatedBy == lastUpdatedBy;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        beginDate.hashCode ^
        endDate.hashCode ^
        priority.hashCode ^
        status.hashCode ^
        assignedTo.hashCode ^
        project.hashCode ^
        comments.hashCode ^
        privateMessages.hashCode ^
        attachments.hashCode ^
        workEvidence.hashCode ^
        changeLog.hashCode ^
        lastUpdatedBy.hashCode;
  }
}

class Comment {
  final String id;
  final String user; // User ID (ObjectId)
  final String content;
  final DateTime createdAt;

  Comment({
    String? id,
    required this.user,
    required this.content,
    DateTime? createdAt,
  }) : id = id ?? ObjectId().hexString,
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] as String,
      user: json['user'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.user == user &&
        other.content == content &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ user.hashCode ^ content.hashCode ^ createdAt.hashCode;
  }
}

class PrivateMessage {
  final String id;
  final String sender; // User ID (ObjectId)
  final String recipient; // User ID (ObjectId)
  final String content;
  final DateTime createdAt;

  PrivateMessage({
    String? id,
    required this.sender,
    required this.recipient,
    required this.content,
    DateTime? createdAt,
  }) : id = id ?? ObjectId().hexString,
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'recipient': recipient,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PrivateMessage.fromJson(Map<String, dynamic> json) {
    return PrivateMessage(
      id: json['_id'] as String,
      sender: json['sender'] as String,
      recipient: json['recipient'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrivateMessage &&
        other.id == id &&
        other.sender == sender &&
        other.recipient == recipient &&
        other.content == content &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sender.hashCode ^
        recipient.hashCode ^
        content.hashCode ^
        createdAt.hashCode;
  }
}

class Attachment {
  final String id;
  final String name;
  final String url;
  final FileType fileType;
  final String uploadedBy; // User ID (ObjectId)
  final DateTime uploadedAt;

  Attachment({
    String? id,
    required this.name,
    required this.url,
    this.fileType = FileType.other,
    required this.uploadedBy,
    DateTime? uploadedAt,
  }) : id = id ?? ObjectId().hexString,
        uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'url': url,
      'fileType': fileType.name,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['_id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      fileType: _stringToFileType(json['fileType'] as String),
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  static FileType _stringToFileType(String type) {
    switch (type) {
      case 'image':
        return FileType.image;
      case 'document':
        return FileType.document;
      case 'other':
        return FileType.other;
      default:
        developer.log('Invalid fileType: $type, defaulting to other');
        return FileType.other;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Attachment &&
        other.id == id &&
        other.name == name &&
        other.url == url &&
        other.fileType == fileType &&
        other.uploadedBy == uploadedBy &&
        other.uploadedAt == uploadedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        url.hashCode ^
        fileType.hashCode ^
        uploadedBy.hashCode ^
        uploadedAt.hashCode;
  }
}

class WorkEvidence {
  final String id;
  final String imageUrl;
  final String originalName;
  final String uploadedBy; // User ID (ObjectId)
  final DateTime uploadedAt;

  WorkEvidence({
    String? id,
    required this.imageUrl,
    this.originalName = 'unnamed file',
    required this.uploadedBy,
    DateTime? uploadedAt,
  }) : id = id ?? ObjectId().hexString,
        uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
      'originalName': originalName,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory WorkEvidence.fromJson(Map<String, dynamic> json) {
    return WorkEvidence(
      id: json['_id'] as String,
      imageUrl: json['imageUrl'] as String,
      originalName: json['originalName'] as String? ?? 'unnamed file',
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkEvidence &&
        other.id == id &&
        other.imageUrl == imageUrl &&
        other.originalName == originalName &&
        other.uploadedBy == uploadedBy &&
        other.uploadedAt == uploadedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        imageUrl.hashCode ^
        originalName.hashCode ^
        uploadedBy.hashCode ^
        uploadedAt.hashCode;
  }
}

class ChangeLog {
  final String id;
  final String updatedBy; // User ID (ObjectId)
  final DateTime updatedAt;
  final Map<String, dynamic> changes;
  final String? message;

  ChangeLog({
    String? id,
    required this.updatedBy,
    DateTime? updatedAt,
    required this.changes,
    this.message,
  }) : id = id ?? ObjectId().hexString,
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt.toIso8601String(),
      'changes': changes,
      'message': message,
    };
  }

  factory ChangeLog.fromJson(Map<String, dynamic> json) {
    return ChangeLog(
      id: json['_id'] as String,
      updatedBy: json['updatedBy'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      changes: Map<String, dynamic>.from(json['changes'] as Map),
      message: json['message'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeLog &&
        other.id == id &&
        other.updatedBy == updatedBy &&
        other.updatedAt == updatedAt &&
        mapEquals(other.changes, changes) &&
        other.message == message;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        updatedBy.hashCode ^
        updatedAt.hashCode ^
        changes.hashCode ^
        message.hashCode;
  }
}