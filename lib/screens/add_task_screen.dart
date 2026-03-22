import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/queue_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final String? queueId;

  const AddTaskScreen({
    super.key,
    this.queueId,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedQueueId;
  int _importance = 5;
  bool _showNotification = false;
  bool _isSubmitting = false;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    _selectedQueueId = widget.queueId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Dropdown ve gönderim için: seçili id her zaman mevcut queue listesinde olur
  String? _effectiveQueueId(QueueProvider provider) {
    if (provider.queues.isEmpty) return null;
    final ids = provider.queues.map((q) => q.id).toList();
    if (_selectedQueueId != null && ids.contains(_selectedQueueId)) {
      return _selectedQueueId;
    }
    return ids.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni Görev Ekle',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Task Name
                const Text(
                  'Görev Adı',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Örn: Bicepsten sushi ye',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir görev adı girin';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: 24),

                // Add to Queue
                const Text(
                  'Queue\'ya Ekle',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<QueueProvider>(
                  builder: (context, provider, child) {
                    if (provider.queues.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Queue bulunamadı. Lütfen önce bir queue oluşturun.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final effectiveId = _effectiveQueueId(provider)!;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: effectiveId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items: provider.queues.map((queue) {
                          return DropdownMenuItem(
                            value: queue.id,
                            child: Text(queue.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedQueueId = value;
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // How important is this?
                const Text(
                  'Ne kadar önemli?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _importance.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: Colors.orange,
                          inactiveColor: Colors.grey[300],
                          onChanged: (value) {
                            setState(() {
                              _importance = value.toInt();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '$_importance',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Date Added
                const Text(
                  'Ekleme Tarihi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Due Date
                const Text(
                  'Bitiş Tarihi ve Saati (Opsiyonel)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _dueDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dueDate != null
                                    ? DateFormat('d MMM yyyy', 'tr_TR').format(_dueDate!)
                                    : 'Tarih seçin',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _dueDate != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_dueDate != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _dueTime = time;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dueTime != null
                                    ? _dueTime!.format(context)
                                    : 'Saat',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _dueTime != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                            _dueTime = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),

                // Add Task Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Görev Ekle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Notification
          if (_showNotification)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildNotification(),
            ),
        ],
      ),
    );
  }

  Widget _buildNotification() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Görev eklendi! Tamamlandığında +$_importance puan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                _showNotification = false;
              });
            },
          ),
        ],
      ),
    );
  }

  void _submitTask() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    _isSubmitting = true;
    setState(() {});

    final provider = Provider.of<QueueProvider>(context, listen: false);
    final queueId = _effectiveQueueId(provider);
    if (queueId == null) {
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }

    DateTime? dueDateTime;
    if (_dueDate != null) {
      if (_dueTime != null) {
        dueDateTime = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
      } else {
        dueDateTime = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          23,
          59,
        );
      }
    }

    provider.addTaskToQueue(
      queueId,
      _titleController.text.trim(),
      description: null,
      importance: _importance,
      difficulty: 5,
      dueDate: dueDateTime,
    );

    // Hemen kapat; kayıt arka planda tamamlanır
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
