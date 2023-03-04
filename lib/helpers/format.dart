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

DateTime convertDatetime(String datetime, String outputCalendar) {
  List<String> datetimeParts = datetime.split(' ');
  List<String> dateParts = datetimeParts[0].split('-');
  int year = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int day = int.parse(dateParts[2]);
  int hour = int.parse(datetimeParts[1].split(':')[0]);
  int minute = int.parse(datetimeParts[1].split(':')[1]);
  int second = int.parse(datetimeParts[1].split(':')[2]);

  if (outputCalendar == 'toGregorian') {
    return Jalali(year, month, day)
        .toGregorian()
        .toDateTime()
        .add(Duration(hours: hour, minutes: minute, seconds: second));
  } else if (outputCalendar == 'toJalali') {
    return Gregorian(year, month, day)
        .toJalali()
        .toDateTime()
        .add(Duration(hours: hour, minutes: minute, seconds: second));
  } else {
    throw ArgumentError('Invalid outputCalendar parameter');
  }
}
