import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat timeFormatter = DateFormat('HH:mm');
  static final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDate(DateTime date) => dateFormatter.format(date);
  static String formatTime(DateTime time) => timeFormatter.format(time);
  static String formatDateTime(DateTime dateTime) => dateTimeFormatter.format(dateTime);

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
