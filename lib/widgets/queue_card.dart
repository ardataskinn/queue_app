import 'package:flutter/material.dart';
import '../models/queue.dart';

class QueueCard extends StatelessWidget {
  final QueueModel queue;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const QueueCard({
    super.key,
    required this.queue,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = queue.pendingTasks.length;
    final completedCount = queue.completedTasks.length;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: queue.imagePath != null && queue.imagePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          queue.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.queue,
                              color: Colors.blue,
                              size: 28,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.queue,
                        color: Colors.blue,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      queue.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatChip(
                          Icons.pending,
                          '$pendingCount bekleyen',
                          Colors.orange,
                        ),
                        _buildStatChip(
                          Icons.check_circle,
                          '$completedCount tamamlanmış',
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Colors.red,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
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

