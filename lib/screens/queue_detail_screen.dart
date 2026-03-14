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
              // Sort and Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Color bar for sort container
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              queue.sortOrder == SortOrder.none
                                  ? 'Sıralama: Yok'
                                  : queue.sortOrder == SortOrder.lowToHigh
                                      ? 'Sıralama: Önem (Düşük-Yüksek)'
                                      : 'Sıralama: Önem (Yüksek-Düşük)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                            PopupMenuButton<SortOrder>(
                              icon: Icon(Icons.arrow_drop_down, color: Colors.blue[900]),
                              onSelected: (order) {
                                provider.updateQueueSortOrder(widget.queueId, order);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: SortOrder.none,
                                  child: Text('Yok'),
                                ),
                                const PopupMenuItem(
                                  value: SortOrder.lowToHigh,
                                  child: Text('Önem (Düşük-Yüksek)'),
                                ),
                                const PopupMenuItem(
                                  value: SortOrder.highToLow,
                                  child: Text('Önem (Yüksek-Düşük)'),
                                ),
                              ],
                            ),
                          ],
                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        // Color bar for filter container
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.filter_list, size: 16, color: Colors.grey[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Filtrele',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
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
