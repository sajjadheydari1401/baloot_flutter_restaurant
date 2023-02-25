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
