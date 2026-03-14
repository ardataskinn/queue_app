import 'task.dart';

enum SortOrder {
  none,
  lowToHigh,   // Önem düşükten yükseğe
  highToLow,   // Önem yüksekten düşüğe
  byDueDate,   // En yakın son tarih
}

class QueueModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final List<Task> tasks;
  final SortOrder sortOrder;
  final String? imagePath;

  QueueModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    List<Task>? tasks,
    this.sortOrder = SortOrder.none,
    this.imagePath,
  }) : tasks = tasks ?? [];

  List<Task> get sortedTasks {
    // Separate pending and completed tasks
    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();
    
    // Sort pending tasks if needed
    switch (sortOrder) {
      case SortOrder.lowToHigh:
        pending.sort((a, b) => a.importance.compareTo(b.importance));
        break;
      case SortOrder.highToLow:
        pending.sort((a, b) => b.importance.compareTo(a.importance));
        break;
      case SortOrder.byDueDate:
        pending.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortOrder.none:
        break;
    }
    
    // Completed tasks go after pending tasks
    return [...pending, ...completed];
  }

  List<Task> get pendingTasks {
    return sortedTasks.where((task) => !task.isCompleted).toList();
  }

  List<Task> get completedTasks {
    return tasks.where((task) => task.isCompleted).toList();
  }
  
  List<Task> get importantTasks {
    // Tasks with importance >= 7
    return tasks.where((task) => task.importance >= 7 && !task.isCompleted).toList();
  }

  QueueModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<Task>? tasks,
    SortOrder? sortOrder,
    String? imagePath,
  }) {
    return QueueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      tasks: tasks ?? this.tasks,
      sortOrder: sortOrder ?? this.sortOrder,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'sortOrder': sortOrder.name,
      'imagePath': imagePath,
    };
  }

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((task) => Task.fromJson(task as Map<String, dynamic>))
              .toList() ??
          [],
      sortOrder: SortOrder.values.firstWhere(
        (e) => e.name == json['sortOrder'],
        orElse: () => SortOrder.none,
      ),
      imagePath: json['imagePath'] as String?,
    );
  }
}

