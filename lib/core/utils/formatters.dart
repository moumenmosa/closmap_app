import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String date(DateTime? d) {
    if (d == null) return '';
    return DateFormat('dd/MM/yyyy').format(d);
  }

  static String dateTime(DateTime? d) {
    if (d == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  static String timeRemaining(DateTime? expiresAt) {
    if (expiresAt == null) return '';
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'expired';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }

  static String distance(double km) => km < 1 ? '<1' : km.toStringAsFixed(1);

  static String monthYear(DateTime? d) {
    if (d == null) return '';
    return DateFormat('MMMM yyyy').format(d);
  }

  static String monthYearShort(DateTime? d) {
    if (d == null) return '';
    return DateFormat('MMM yyyy').format(d);
  }

  static String dateRange(
    DateTime? start,
    DateTime? end, {
    bool ongoing = false,
  }) {
    final s = monthYearShort(start);
    final e = ongoing ? 'Present' : monthYearShort(end);
    if (s.isEmpty) return e;
    if (e.isEmpty) return s;
    return '$s - $e';
  }

  static String fileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).round()} KB';
  }
}
