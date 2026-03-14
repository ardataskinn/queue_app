import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/queue_provider.dart';
import '../models/task.dart';
import '../widgets/subtask_item.dart';
import '../utils/time_formatter.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String queueId;
  final String taskId;

  const TaskDetailsScreen({
    super.key,
    required this.queueId,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Görev Detayları',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<QueueProvider>(
        builder: (context, provider, child) {
          final queue = provider.getQueueById(queueId);
          if (queue == null) {
            return const Center(child: Text('Queue bulunamadı'));
          }

          final task = queue.tasks.firstWhere(
            (t) => t.id == taskId,
            orElse: () => throw Exception('Task not found'),
          );

          final importanceColor = _getImportanceColor(task.importance);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Task Card
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Colored vertical line on the left
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: importanceColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      // Task Title
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Importance
                      _buildDetailRow(
                        icon: Icons.star_outline,
                        iconColor: Colors.amber,
                        label: 'Önem',
                        value: '${task.importance}/10',
                      ),
                      const SizedBox(height: 16),

                      // Added on
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        iconColor: Colors.blue,
                        label: 'Eklendi',
                        value: DateFormat('MMMM dd, yyyy').format(task.createdAt),
                      ),
                      const SizedBox(height: 16),

                      // Due Date
                      if (task.dueDate != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (task.dueDate!.isBefore(DateTime.now())
                                        ? Colors.red
                                        : Colors.orange)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: task.dueDate!.isBefore(DateTime.now())
                                    ? Colors.red
                                    : Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bitiş Tarihi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${DateFormat('MMMM dd, yyyy').format(task.dueDate!)} at ${TimeOfDay.fromDateTime(task.dueDate!).format(context)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    TimeFormatter.formatTimeRemaining(task.dueDate!),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: task.dueDate!.isBefore(DateTime.now())
                                          ? Colors.red
                                          : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Queue
                      _buildDetailRow(
                        icon: Icons.list,
                        iconColor: Colors.grey,
                        label: 'Queue',
                        value: queue.name,
                      ),

                      // Subtasks
                      if (task.subtasks.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Subtasks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...task.subtasks.map((subtask) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SubtaskItem(
                                subtask: subtask,
                                onToggle: () {
                                  provider.toggleSubTask(queueId, taskId, subtask.id);
                                },
                              ),
                            )),
                      ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Action buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Complete/Undo button (circular)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: task.isCompleted
                                  ? () {
                                      provider.undoCompleteTask(queueId, taskId);
                                      Navigator.pop(context);
                                    }
                                  : () {
                                      provider.completeTask(queueId, taskId);
                                      Navigator.pop(context);
                                    },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: task.isCompleted ? Colors.orange : Colors.blue,
                                ),
                                child: Icon(
                                  task.isCompleted ? Icons.undo : Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Add Subtask button (flat +)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showAddSubtaskDialog(context, provider),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black87,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Delete
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteDialog(context, provider, task),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Sil',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getImportanceColor(int importance) {
    // 1 = sapsarı, 10 = kıpkırmızı, araları turuncu
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

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
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
                      provider.addSubTask(queueId, taskId, controller.text.trim());
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

  void _showEditDialog(BuildContext context, QueueProvider provider, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description ?? '');
    DateTime? dueDate = task.dueDate;
    TimeOfDay? dueTime = task.dueDate != null
        ? TimeOfDay.fromDateTime(task.dueDate!)
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Görevi Düzenle',
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
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Görev Başlığı',
                    hintText: 'Görev başlığını girin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    hintText: 'Görev açıklaması (opsiyonel)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              dueDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dueDate != null
                                    ? DateFormat('dd MMM yyyy', 'tr_TR').format(dueDate!)
                                    : 'Bitiş Tarihi',
                                style: TextStyle(
                                  color: dueDate != null
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (dueDate != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: dueTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              dueTime = time;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                dueTime != null
                                    ? dueTime!.format(context)
                                    : 'Saat',
                                style: TextStyle(
                                  color: dueTime != null
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            dueDate = null;
                            dueTime = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      DateTime? dueDateTime;
                      if (dueDate != null) {
                        if (dueTime != null) {
                          dueDateTime = DateTime(
                            dueDate!.year,
                            dueDate!.month,
                            dueDate!.day,
                            dueTime!.hour,
                            dueTime!.minute,
                          );
                        } else {
                          dueDateTime = DateTime(
                            dueDate!.year,
                            dueDate!.month,
                            dueDate!.day,
                            23,
                            59,
                          );
                        }
                      }
                      provider.updateTask(
                        queueId,
                        taskId,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        dueDate: dueDateTime,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kaydet',
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
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    QueueProvider provider,
    Task task,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Görevi Sil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('"${task.title}" görevini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTask(queueId, taskId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

