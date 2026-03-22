import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/queue.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

/// Tek bir puan kazanma kaydı (görev veya alt görev tamamlandığında)
class PointEntry {
  final String taskId;
  final String taskTitle;
  final int points;
  final DateTime dateTime;
  /// Alt görev tamamlandıysa dolu; ana görev tamamlandıysa null
  final String? subtaskId;
  final String? subtaskTitle;

  PointEntry({
    required this.taskId,
    required this.taskTitle,
    required this.points,
    required this.dateTime,
    this.subtaskId,
    this.subtaskTitle,
  });

  bool get isSubtask => subtaskId != null;

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'points': points,
        'dateTime': dateTime.toIso8601String(),
        if (subtaskId != null) 'subtaskId': subtaskId,
        if (subtaskTitle != null) 'subtaskTitle': subtaskTitle,
      };

  factory PointEntry.fromJson(Map<String, dynamic> json) => PointEntry(
        taskId: json['taskId'] as String,
        taskTitle: json['taskTitle'] as String,
        points: json['points'] as int,
        dateTime: DateTime.parse(json['dateTime'] as String),
        subtaskId: json['subtaskId'] as String?,
        subtaskTitle: json['subtaskTitle'] as String?,
      );
}

class QueueProvider with ChangeNotifier {
  final List<QueueModel> _queues = [];
  int _totalPoints = 0;
  final List<PointEntry> _pointsHistory = [];
  final _uuid = const Uuid();

  List<QueueModel> get queues => List.unmodifiable(_queues);
  int get totalPoints => _totalPoints;
  /// Puan kazanma geçmişi (en yeni en üstte)
  List<PointEntry> get pointsHistory => List.unmodifiable(_pointsHistory.reversed);

  QueueProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queuesJson = prefs.getString('queues');
      final points = prefs.getInt('totalPoints') ?? 0;
      final historyJson = prefs.getString('pointsHistory');

      if (queuesJson != null) {
        final List<dynamic> decoded = json.decode(queuesJson);
        _queues.clear();
        _queues.addAll(
          decoded.map((q) => QueueModel.fromJson(q as Map<String, dynamic>)),
        );
      }

      _totalPoints = points;
      _pointsHistory.clear();
      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        _pointsHistory.addAll(
          decoded.map((e) => PointEntry.fromJson(e as Map<String, dynamic>)),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queuesJson = json.encode(
        _queues.map((q) => q.toJson()).toList(),
      );
      await prefs.setString('queues', queuesJson);
      await prefs.setInt('totalPoints', _totalPoints);
      await prefs.setString(
        'pointsHistory',
        json.encode(_pointsHistory.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> addQueue(String name, {String? description, String? imagePath}) async {
    final queue = QueueModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      imagePath: imagePath,
    );
    _queues.add(queue);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateQueueImage(String queueId, String? imagePath) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    final queue = _queues[queueIndex];
    _queues[queueIndex] = queue.copyWith(imagePath: imagePath);
    await _saveData();
    notifyListeners();
  }

  Future<void> deleteQueue(String queueId) async {
    _queues.removeWhere((q) => q.id == queueId);
    await _saveData();
    notifyListeners();
  }

  Future<void> addTaskToQueue(
    String queueId,
    String title, {
    String? description,
    required int importance,
    required int difficulty,
    DateTime? dueDate,
  }) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    final task = Task(
      id: _uuid.v4(),
      queueId: queueId,
      title: title,
      description: description,
      importance: importance,
      difficulty: difficulty,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );

    final queue = _queues[queueIndex];
    final updatedTasks = List<Task>.from(queue.tasks)..add(task);
    _queues[queueIndex] = queue.copyWith(tasks: updatedTasks);

    await _saveData();
    notifyListeners();
  }

  Future<void> completeTask(String queueId, String taskId) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    final queue = _queues[queueIndex];
    final taskIndex = queue.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = queue.tasks[taskIndex];
    if (task.isCompleted) return;

    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    // Remove task from current position and add to end of pending tasks
    final updatedTasks = List<Task>.from(queue.tasks);
    updatedTasks.removeAt(taskIndex);
    
    // Find the last pending task index
    int insertIndex = updatedTasks.length;
    for (int i = updatedTasks.length - 1; i >= 0; i--) {
      if (!updatedTasks[i].isCompleted) {
        insertIndex = i + 1;
        break;
      }
    }
    
    // If no pending tasks, insert at beginning
    if (insertIndex == updatedTasks.length && updatedTasks.isNotEmpty && updatedTasks[0].isCompleted) {
      insertIndex = 0;
    }
    
    updatedTasks.insert(insertIndex, updatedTask);
    _queues[queueIndex] = queue.copyWith(tasks: updatedTasks);

    _totalPoints += task.points;
    _pointsHistory.add(PointEntry(
      taskId: task.id,
      taskTitle: task.title,
      points: task.points,
      dateTime: DateTime.now(),
    ));

    await _saveData();
    notifyListeners();
  }

  Future<void> undoCompleteTask(String queueId, String taskId) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    final queue = _queues[queueIndex];
    final taskIndex = queue.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = queue.tasks[taskIndex];
    if (!task.isCompleted) return;

    final updatedTask = task.copyWith(
      isCompleted: false,
      completedAt: null,
    );

    // Remove task from current position
    final updatedTasks = List<Task>.from(queue.tasks);
    updatedTasks.removeAt(taskIndex);
    
    // Add to end of all tasks (will be at the end of pending tasks)
    updatedTasks.add(updatedTask);
    _queues[queueIndex] = queue.copyWith(tasks: updatedTasks);

    _totalPoints -= task.points;
    if (_totalPoints < 0) _totalPoints = 0;
    _pointsHistory.removeWhere((e) => e.taskId == taskId && e.subtaskId == null);

    await _saveData();
    notifyListeners();
  }

  Future<void> addSubTask(String queueId, String taskId, String subtaskTitle) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    final queue = _queues[queueIndex];
    final taskIndex = queue.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = queue.tasks[taskIndex];
    final subtask = SubTask(
      id: _uuid.v4(),
      title: subtaskTitle,
      createdAt: DateTime.now(),
    );

    final updatedSubtasks = List<SubTask>.from(task.subtasks)..add(subtask);
    final updatedTask = task.copyWith(subtasks: updatedSubtasks);

    final updatedTasks = List<Task>.from(queue.tasks);
    updatedTasks[taskIndex] = updatedTask;
    _queues[queueIndex] = queue.copyWith(tasks: updatedTasks);

    await _saveData();
    notifyListeners();
  }

  Future<void> toggleSubTask(String queueId, String taskId, String subtaskId) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    final queue = _queues[queueIndex];
    final taskIndex = queue.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = queue.tasks[taskIndex];
    final subtaskIndex = task.subtasks.indexWhere((s) => s.id == subtaskId);
    if (subtaskIndex == -1) return;

    final subtask = task.subtasks[subtaskIndex];
    final updatedSubtask = subtask.copyWith(isCompleted: !subtask.isCompleted);
    
    final updatedSubtasks = List<SubTask>.from(task.subtasks);
    updatedSubtasks[subtaskIndex] = updatedSubtask;
    final updatedTask = task.copyWith(subtasks: updatedSubtasks);

    final updatedTasks = List<Task>.from(queue.tasks);
    updatedTasks[taskIndex] = updatedTask;
    _queues[queueIndex] = queue.copyWith(tasks: updatedTasks);

    final subtaskPoints = task.subtaskPoints;
    if (updatedSubtask.isCompleted) {
      _totalPoints += subtaskPoints;
      _pointsHistory.add(PointEntry(
        taskId: task.id,
        taskTitle: task.title,
        points: subtaskPoints,
        dateTime: DateTime.now(),
        subtaskId: updatedSubtask.id,
        subtaskTitle: updatedSubtask.title,
      ));
    } else {
      _totalPoints -= subtaskPoints;
      if (_totalPoints < 0) _totalPoints = 0;
      _pointsHistory.removeWhere((e) => e.taskId == taskId && e.subtaskId == subtaskId);
    }

    await _saveData();
    notifyListeners();
  }

  Future<void> deleteTask(String queueId, String taskId) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    final queue = _queues[queueIndex];
    final updatedTasks = queue.tasks.where((t) => t.id != taskId).toList();
    _queues[queueIndex] = queue.copyWith(tasks: updatedTasks);

    await _saveData();
    notifyListeners();
  }

  Future<void> updateQueueSortOrder(
    String queueId,
    SortOrder sortOrder,
  ) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    _queues[queueIndex] = _queues[queueIndex].copyWith(sortOrder: sortOrder);
    await _saveData();
    notifyListeners();
  }

  QueueModel? getQueueById(String queueId) {
    try {
      return _queues.firstWhere((q) => q.id == queueId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateTask(
    String queueId,
    String taskId, {
    String? title,
    String? description,
    int? importance,
    DateTime? dueDate,
  }) async {
    final queueIndex = _queues.indexWhere((q) => q.id == queueId);
    if (queueIndex == -1) return;

    final queue = _queues[queueIndex];
    final taskIndex = queue.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = queue.tasks[taskIndex];
    final updatedTask = task.copyWith(
      title: title ?? task.title,
      description: description ?? task.description,
      importance: importance ?? task.importance,
      dueDate: dueDate ?? task.dueDate,
    );

    final updatedTasks = List<Task>.from(queue.tasks);
    updatedTasks[taskIndex] = updatedTask;
    _queues[queueIndex] = queue.copyWith(tasks: updatedTasks);

    await _saveData();
    notifyListeners();
  }

  List<Task> getTasksWithDueDate() {
    final tasksWithDueDate = <Task>[];
    for (final queue in _queues) {
      for (final task in queue.tasks) {
        if (task.dueDate != null && !task.isCompleted) {
          tasksWithDueDate.add(task);
        }
      }
    }
    // Sort by due date, earliest first
    tasksWithDueDate.sort((a, b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return tasksWithDueDate;
  }

  /// Sadece ana görev tamamlamaları (alt görev hariç)
  List<PointEntry> get _taskCompletions =>
      _pointsHistory.where((e) => !e.isSubtask).toList();

  int get completedTodayCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _taskCompletions
        .where((e) => !e.dateTime.isBefore(today) && e.dateTime.isBefore(tomorrow))
        .length;
  }

  int get completedThisWeekCount {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return _taskCompletions
        .where((e) => !e.dateTime.isBefore(startOfWeek))
        .length;
  }

  int get completedThisMonthCount {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _taskCompletions
        .where((e) => !e.dateTime.isBefore(startOfMonth))
        .length;
  }

  int get totalCompletedCount => _taskCompletions.length;

  /// Ardışık gün serisi: bugünden geriye kaç gün üst üste en az 1 görev tamamlanmış
  int get currentStreak {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = _taskCompletions
        .map((e) => DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day))
        .toSet()
        .toList();
    dates.sort((a, b) => b.compareTo(a));
    if (dates.isEmpty || dates.first != today) return 0;
    int streak = 0;
    DateTime check = today;
    for (final d in dates) {
      if (d == check) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else if (d.isBefore(check)) {
        break;
      }
    }
    return streak;
  }
}

