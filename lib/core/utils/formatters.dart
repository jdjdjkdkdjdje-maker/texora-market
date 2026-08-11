import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _priceFormat = NumberFormat('#,###', 'en_US');

  static String formatPrice(int price) {
    return '${_priceFormat.format(price).replaceAll(',', ' ')} so\'m';
  }

  static String formatPriceCompact(int price) {
    if (price >= 1000000) {
      double mln = price / 1000000;
      if (mln % 1 == 0) {
        return '${mln.toInt()} mln';
      }
      return '${mln.toStringAsFixed(1)} mln';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} ming';
    }
    return '$price so\'m';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  static String formatPhone(String phone) {
    // Uzbek format: +998 90 123 45 67
    if (phone.length == 9) {
      return '+998 ${phone.substring(0, 2)} ${phone.substring(2, 5)} ${phone.substring(5, 7)} ${phone.substring(7)}';
    }
    return phone;
  }
}

extension IntPriceExt on int {
  String get toPrice => AppFormatters.formatPrice(this);
}
