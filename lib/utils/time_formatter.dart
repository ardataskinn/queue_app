class TimeFormatter {
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 24) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        }
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      }
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      final days = difference.inDays;
      if (days == 1) {
        return 'Yesterday';
      } else if (days < 7) {
        return '$days days ago';
      } else if (days < 30) {
        final weeks = (days / 7).floor();
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (days < 365) {
        final months = (days / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else {
        final years = (days / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    }
  }

  static String formatAddedTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 24) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'Az önce';
        }
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'dakika' : 'dakika'} önce';
      }
      return '${difference.inHours} ${difference.inHours == 1 ? 'saat' : 'saat'} önce';
    } else {
      final days = difference.inDays;
      if (days == 1) {
        return 'Dün';
      }
      return '$days gün önce';
    }
  }

  static String formatTimeRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'Süresi doldu';
    }

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1 gün kaldı';
      }
      return '${difference.inDays} gün kaldı';
    } else if (difference.inHours > 0) {
      if (difference.inHours == 1) {
        return '1 saat kaldı';
      }
      return '${difference.inHours} saat kaldı';
    } else if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) {
        return '1 dakika kaldı';
      }
      return '${difference.inMinutes} dakika kaldı';
    } else {
      return '1 dakikadan az kaldı';
    }
  }
}
