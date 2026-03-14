class Task {
  final String id;
  final String queueId;
  final String title;
  final String? description;
  final int importance; // 1-10
  final int difficulty; // 1-10
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<SubTask> subtasks;
  final String? parentTaskId; // null if this is a main task
  final DateTime? dueDate; // Deadline for the task

  Task({
    required this.id,
    required this.queueId,
    required this.title,
    this.description,
    required this.importance,
    required this.difficulty,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    List<SubTask>? subtasks,
    this.parentTaskId,
    this.dueDate,
  }) : subtasks = subtasks ?? [];

  /// Ana görev tamamlandığında kazanılan puan (önceliğe göre 1-10)
  int get points => importance;

  /// Alt görev tamamlandığında kazanılan puan (görevin puanının 1/4'ü, yuvarlanmış)
  int get subtaskPoints => (importance / 4).round();

  Task copyWith({
    String? id,
    String? queueId,
    String? title,
    String? description,
    int? importance,
    int? difficulty,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
    List<SubTask>? subtasks,
    String? parentTaskId,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      queueId: queueId ?? this.queueId,
      title: title ?? this.title,
      description: description ?? this.description,
      importance: importance ?? this.importance,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queueId': queueId,
      'title': title,
      'description': description,
      'importance': importance,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'parentTaskId': parentTaskId,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      queueId: json['queueId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      importance: json['importance'] as int,
      difficulty: json['difficulty'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((s) => SubTask.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      parentTaskId: json['parentTaskId'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }
}

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

