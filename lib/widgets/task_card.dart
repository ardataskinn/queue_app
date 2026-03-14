import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: task.isCompleted ? Colors.grey[100] : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey[600] : null,
                    ),
                  ),
                ),
                if (onComplete != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: onComplete,
                    color: Colors.green,
                    tooltip: 'Complete Task',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: Colors.red,
                  tooltip: 'Delete Task',
                ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBadge(
                  Icons.priority_high,
                  'Importance: ${task.importance}',
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  Icons.trending_up,
                  'Difficulty: ${task.difficulty}',
                  Colors.orange,
                ),
                const Spacer(),
                if (task.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${task.points}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


