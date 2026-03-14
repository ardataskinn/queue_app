import 'package:flutter/material.dart';
import '../models/task.dart';

class SubtaskItem extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onToggle;

  const SubtaskItem({
    super.key,
    required this.subtask,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: subtask.isCompleted ? Colors.orange : Colors.transparent,
              border: Border.all(
                color: subtask.isCompleted ? Colors.orange : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: subtask.isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            subtask.title,
            style: TextStyle(
              fontSize: 14,
              decoration: subtask.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
              color: subtask.isCompleted ? Colors.grey[600] : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}


