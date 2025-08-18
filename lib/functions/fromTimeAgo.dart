String formatTimeAgo(DateTime? dateTime) {
  if (dateTime == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24)
    return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
  if (diff.inDays < 7)
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';

  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
