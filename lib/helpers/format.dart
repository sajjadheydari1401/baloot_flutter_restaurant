import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

String formatPrice(double price) {
  final format = NumberFormat("#,##0.00", "fa_IR");
  return format.format(price);
}

Date getJalaliDateTime(int timestamp) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return Jalali.fromDateTime(dateTime);
}

String replaceFarsiNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], farsi[i]);
  }

  return input;
}
