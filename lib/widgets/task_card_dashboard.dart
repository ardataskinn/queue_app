import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/queue_provider.dart';
import '../utils/time_formatter.dart';
import '../screens/task_details_screen.dart';
import 'subtask_item.dart';

class TaskCardDashboard extends StatelessWidget {
  final Task task;
  final String queueName;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const TaskCardDashboard({
    super.key,
    required this.task,
    required this.queueName,
    required this.onTap,
    required this.onComplete,
  });

  Color _getImportanceColor(int importance) {
    // 1 = sapsarı (bright yellow), 10 = kıpkırmızı (bright red)
    // Araları turuncu tonları
    if (importance == 1) {
      return const Color(0xFFFFEB3B); // Sapsarı
    } else if (importance == 2) {
      return Colors.yellow[600]!;
    } else if (importance == 3) {
      return Colors.orange[300]!;
    } else if (importance == 4) {
      return Colors.orange[400]!;
    } else if (importance == 5) {
      return Colors.orange[500]!;
    } else if (importance == 6) {
      return Colors.deepOrange[400]!;
    } else if (importance == 7) {
      return Colors.deepOrange[500]!;
    } else if (importance == 8) {
      return Colors.red[400]!;
    } else if (importance == 9) {
      return Colors.red[600]!;
    } else {
      return const Color(0xFFC62828); // Kıpkırmızı
    }
  }

  @override
  Widget build(BuildContext context) {
    final importanceColor = _getImportanceColor(task.importance);
    final provider = Provider.of<QueueProvider>(context, listen: false);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Colored vertical line on the left (1=sapsarı, 10=kıpkırmızı, araları turuncu)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: importanceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                // Task content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Eklendi: ${TimeFormatter.formatAddedTime(task.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Action buttons aligned to right center
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Add subtask button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _showAddSubtaskDialog(context, provider);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.add_task,
                                      size: 20,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Complete button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onComplete,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: task.isCompleted ? Colors.orange : Colors.transparent,
                                      border: Border.all(
                                        color: task.isCompleted
                                            ? Colors.orange
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: task.isCompleted
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: task.dueDate!.isBefore(DateTime.now())
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  TimeFormatter.formatTimeRemaining(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.dueDate!.isBefore(DateTime.now())
                                        ? Colors.red
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Subtasks with indentation (no divider)
            if (task.subtasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 16,
                  top: 8,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: task.subtasks.map((subtask) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          // Indentation line
                          Container(
                            width: 2,
                            height: 20,
                            color: Colors.grey[300],
                            margin: const EdgeInsets.only(right: 12),
                          ),
                          Expanded(
                            child: SubtaskItem(
                              subtask: subtask,
                              onToggle: () {
                                provider.toggleSubTask(task.queueId, task.id, subtask.id);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddSubtaskDialog(BuildContext context, QueueProvider provider) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Alt Görev Ekle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Alt Görev Başlığı',
                  hintText: 'Örn: Araştırma yap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen bir başlık girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      provider.addSubTask(task.queueId, task.id, controller.text.trim());
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ekle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
