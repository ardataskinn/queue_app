import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../models/task.dart';
import '../widgets/points_display.dart';
import '../screens/queue_detail_screen.dart';
import '../screens/add_task_screen.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../widgets/task_card_dashboard.dart';
import '../widgets/queue_card.dart';
import '../utils/time_formatter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.dashboard, color: Colors.black87),
            const SizedBox(width: 8),
            Flexible(
              child: const Text(
                'Ana Sayfa',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bar_chart_rounded, color: Colors.purple, size: 22),
            ),
            tooltip: 'İstatistikler',
          ),
          const PointsDisplay(),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<QueueProvider>(
        builder: (context, provider, child) {
          // Tüm queue'lardan tamamlanmamış görevleri topla
          final allRecentTasks = <Task>[];
          for (final queue in provider.queues) {
            allRecentTasks.addAll(queue.pendingTasks);
          }
          allRecentTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Tüm Yapılacaklar için
          // "Bunları Unutma": En yakın bitiş tarihine sahip görevler önce (dueDate artan)
          final tasksWithDueDate = allRecentTasks.where((t) => t.dueDate != null).toList();
          tasksWithDueDate.sort((a, b) {
            if (a.dueDate == null || b.dueDate == null) return 0;
            return a.dueDate!.compareTo(b.dueDate!); // En yakın tarih ilk
          });
          final importantTasks = <Task>[];
          if (tasksWithDueDate.isNotEmpty) {
            importantTasks.addAll(tasksWithDueDate); // Hepsi, en yakın bitiş tarihi en başta
          } else {
            // Son tarihi olmayan görevler: en eskiden yeniye, en fazla 2
            final oldestTasks = List<Task>.from(allRecentTasks);
            oldestTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            importantTasks.addAll(oldestTasks.take(2));
          }
          
          // Get recent tasks for "Your Current Queue" (up to 4)
          final currentQueueTasks = allRecentTasks.take(4).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Don't Forget These Section
                          if (importantTasks.isNotEmpty) ...[
                            const Text(
                              "Bunları Unutma!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: importantTasks.length,
                                itemBuilder: (context, index) {
                                  final task = importantTasks[index];
                                  final queue = provider.getQueueById(task.queueId);
                                  return Container(
                                    width: constraints.maxWidth * 0.7,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: _buildImportantTaskCard(
                                      context,
                                      task,
                                      queue?.name ?? 'Bilinmeyen',
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Your Current Queue Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tüm Yapılacaklar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Consumer<QueueProvider>(
                                builder: (context, provider, child) {
                                  return IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                                    ),
                                    onPressed: () {
                                      if (provider.queues.isEmpty) {
                                        _showQueueRequiredDialog(context);
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddTaskScreen(
                                            queueId: provider.queues.first.id,
                                          ),
                                        ),
                                      );
                                    },
                                    tooltip: 'Yeni Görev',
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (currentQueueTasks.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(48),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.inbox_outlined,
                                        size: 60,
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
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32),
                                      child: Text(
                                        'Yeni bir görev ekleyerek başlayın. Organize olmanın ve Queue Puanları kazanmanın ilk adımı.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    OutlinedButton(
                                      onPressed: () {
                                        final provider = Provider.of<QueueProvider>(context, listen: false);
                                        if (provider.queues.isEmpty) {
                                          _showQueueRequiredDialog(context);
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddTaskScreen(
                                              queueId: provider.queues.first.id,
                                            ),
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
                                        side: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      child: const Text(
                                        'İlk görevinizi ekleyin',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...currentQueueTasks.map((task) {
                              final queue = provider.getQueueById(task.queueId);
                              return TaskCardDashboard(
                                task: task,
                                queueName: queue?.name ?? 'Bilinmeyen',
                                onTap: () {
                                  if (queue != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QueueDetailScreen(
                                          queueId: queue.id,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onComplete: () {
                                  if (queue != null) {
                                    provider.completeTask(queue.id, task.id);
                                  }
                                },
                              );
                            }),
                          // Bottom padding for Manage Queues button
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  // Bottom buttons
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.queue, color: Colors.white),
                          label: const Text(
                            'Queue\'ları Yönet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImportantTaskCard(
    BuildContext context,
    Task task,
    String queueName,
  ) {
    // Create gradient based on importance (yellow to red)
    final colors = _getGradientColors(task.importance);

    return GestureDetector(
      onTap: () {
        final provider = Provider.of<QueueProvider>(context, listen: false);
        final queue = provider.getQueueById(task.queueId);
        if (queue != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QueueDetailScreen(queueId: queue.id),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Text(
                task.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                TimeFormatter.formatAddedTime(task.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(int importance) {
    // Yellow to red gradient based on importance (1-10)
    // 1 = yellow, 10 = red
    if (importance <= 2) {
      return [Colors.yellow[300]!, Colors.yellow[400]!];
    } else if (importance <= 4) {
      return [Colors.yellow[400]!, Colors.orange[300]!];
    } else if (importance <= 6) {
      return [Colors.orange[300]!, Colors.orange[400]!];
    } else if (importance <= 8) {
      return [Colors.orange[400]!, Colors.red[300]!];
    } else {
      return [Colors.red[300]!, Colors.red[500]!];
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    QueueProvider provider,
    String queueId,
    String queueName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Queue\'yu Sil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('"$queueName" queue\'sunu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteQueue(queueId);
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

  void _showCreateQueueDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.queue,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Yeni Queue Oluştur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Queue Adı *',
                    hintText: 'Örn: İş Görevleri',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir queue adı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama (opsiyonel)',
                    hintText: 'Queue hakkında kısa bir açıklama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Provider.of<QueueProvider>(context, listen: false).addQueue(
                  nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Oluştur',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQueueRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.queue,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Queue Gerekli',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Görev eklemek için önce bir queue oluşturmanız gerekiyor.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Queue Oluştur'),
          ),
        ],
      ),
    );
  }
}
