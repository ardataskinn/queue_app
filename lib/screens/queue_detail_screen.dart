import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../models/queue.dart';
import '../screens/add_task_screen.dart';
import '../screens/task_details_screen.dart';
import '../widgets/task_card_dashboard.dart';

class QueueDetailScreen extends StatefulWidget {
  final String queueId;

  const QueueDetailScreen({
    super.key,
    required this.queueId,
  });

  @override
  State<QueueDetailScreen> createState() => _QueueDetailScreenState();
}

class _QueueDetailScreenState extends State<QueueDetailScreen> {
  String _sortLabel(SortOrder order) {
    switch (order) {
      case SortOrder.none:
        return 'Sıralama seçin';
      case SortOrder.lowToHigh:
        return 'Önem: Düşükten yükseğe';
      case SortOrder.highToLow:
        return 'Önem: Yüksekten düşüğe';
      case SortOrder.byDueDate:
        return 'En yakın son tarih';
    }
  }

  IconData _sortIcon(SortOrder order) {
    switch (order) {
      case SortOrder.none:
        return Icons.sort_rounded;
      case SortOrder.lowToHigh:
        return Icons.arrow_upward_rounded;
      case SortOrder.highToLow:
        return Icons.arrow_downward_rounded;
      case SortOrder.byDueDate:
        return Icons.event_rounded;
    }
  }

  void _showSortMenu(BuildContext context, QueueProvider provider, QueueModel queue) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sıralama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              ...SortOrder.values.map((order) {
                if (order == SortOrder.none) return const SizedBox.shrink();
                final isSelected = queue.sortOrder == order;
                return ListTile(
                  leading: Icon(
                    _sortIcon(order),
                    color: isSelected ? Colors.blue : Colors.grey[600],
                  ),
                  title: Text(
                    _sortLabel(order),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.blue.shade700 : Colors.grey[800],
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.blue.shade600, size: 22)
                      : null,
                  onTap: () {
                    provider.updateQueueSortOrder(widget.queueId, order);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

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
        title: Consumer<QueueProvider>(
          builder: (context, provider, child) {
            final queue = provider.getQueueById(widget.queueId);
            return Text(
              queue?.name ?? 'Queue',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      body: Consumer<QueueProvider>(
        builder: (context, provider, child) {
          final queue = provider.getQueueById(widget.queueId);
          if (queue == null) {
            return const Center(child: Text('Queue bulunamadı'));
          }

          return Column(
            children: [
              // Sıralama butonu
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: Colors.white,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showSortMenu(context, provider, queue),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.blue.shade100.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _sortIcon(queue.sortOrder),
                            color: Colors.blue.shade700,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _sortLabel(queue.sortOrder),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Tasks List
              Expanded(
                child: _buildTasksList(context, provider, queue),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(queueId: widget.queueId),
            ),
          );
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Yeni Görev',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTasksList(
    BuildContext context,
    QueueProvider provider,
    QueueModel queue,
  ) {
    final pendingTasks = queue.pendingTasks;
    final completedTasks = queue.completedTasks;

    if (pendingTasks.isEmpty && completedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_outlined,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bu queue\'da henüz görev yok!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Yeni bir görev ekleyerek başlayın. Organize olmanın ve Queue Puanları kazanmanın ilk adımı.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(queueId: widget.queueId),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('İlk görevinizi ekleyin'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pendingTasks.isNotEmpty) ...[
          ...pendingTasks.map((task) => TaskCardDashboard(
                task: task,
                queueName: queue.name,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(
                        queueId: widget.queueId,
                        taskId: task.id,
                      ),
                    ),
                  );
                },
                onComplete: () {
                  provider.completeTask(widget.queueId, task.id);
                },
              )),
          if (completedTasks.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Tamamlanan Görevler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
        if (completedTasks.isNotEmpty)
          ...completedTasks.map((task) => TaskCardDashboard(
                task: task,
                queueName: queue.name,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(
                        queueId: widget.queueId,
                        taskId: task.id,
                      ),
                    ),
                  );
                },
                onComplete: () {
                  provider.undoCompleteTask(widget.queueId, task.id);
                },
              )),
      ],
    );
  }
}
