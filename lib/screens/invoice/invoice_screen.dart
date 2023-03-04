import 'package:mousavi/helpers/format.dart';
import 'package:mousavi/models/invoice_model.dart';
import 'package:mousavi/models/order_model.dart';
import 'package:mousavi/providers/invoices_provider.dart';
import 'package:mousavi/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'dart:ui' as ui;

class InvoiceScreen extends StatefulWidget {
  static const routeName = '/invoice';

  const InvoiceScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const InvoiceScreen(),
    );
  }

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  String fromLabel = '';
  String toLabel = '';

  List<Invoice> invoicesToShow = [];

  @override
  void initState() {
    super.initState();
    fromLabel = 'انتخاب تاریخ';
    toLabel = 'انتخاب تاریخ';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    invoicesToShow = Provider.of<Invoices>(context, listen: true).items;
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Invoices>(context).fetchAndSetInvoices().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
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

  void filterInvoices() {
    final invoices = Provider.of<Invoices>(context, listen: false).items;

    if (toLabel == 'انتخاب تاریخ' && fromLabel == 'انتخاب تاریخ') {
      setState(() {
        invoicesToShow = invoices;
      });
      return;
    }

    DateTime grFromLabel = convertDatetime(fromLabel, 'toGregorian');
    DateTime grToLabel = convertDatetime(toLabel, 'toGregorian');

    List<Invoice> filteredInvoices = invoices.where((invoice) {
      DateTime invoiceDateTime =
          DateTime.fromMillisecondsSinceEpoch(invoice.dateTime);

      if (grFromLabel.isAfter(grToLabel)) {
        return false; // invalid date range
      } else if (invoiceDateTime.isBefore(grFromLabel) ||
          invoiceDateTime.isAfter(grToLabel.add(Duration(days: 1)))) {
        return false; // outside the date range
      } else {
        return true;
      }
    }).toList();

    setState(() {
      invoicesToShow = filteredInvoices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'فاکتورها'),
      bottomNavigationBar: CustomNavBar(currentTabIndex: 1),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            color: Colors.cyan[100],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        filterInvoices();
                      },
                      child: const Text(
                        'جستجو',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Jalali? picked = await showPersianDatePicker(
                          context: context,
                          initialDate: Jalali.now(),
                          firstDate: Jalali(1400, 8),
                          lastDate: Jalali(1440, 9),
                        );
                        if (picked != null) {
                          setState(() {
                            toLabel = picked.toJalaliDateTime();
                          });
                        }
                      },
                      child: Text(
                        replaceFarsiNumber(toLabel),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      ': تا تاریخ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Jalali? picked = await showPersianDatePicker(
                          context: context,
                          initialDate: Jalali.now(),
                          firstDate: Jalali(1385, 8),
                          lastDate: Jalali(1450, 9),
                        );
                        if (picked != null) {
                          setState(() {
                            fromLabel = picked.toJalaliDateTime();
                          });
                        }
                      },
                      child: Text(
                        replaceFarsiNumber(fromLabel),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      ': فاکتورهای ثبت شده از تاریخ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: invoicesToShow.isEmpty
                ? _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(
                        child: Text(
                          'فاکتوری ثبت نشده',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                : ListView.builder(
                    itemCount: invoicesToShow.length,
                    itemBuilder: (BuildContext context, int index) {
                      final invoice = invoicesToShow[index];
                      return _buildInvoiceCard(invoice);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _buildInvoiceCard(Invoice invoice) {
  final GlobalKey key = GlobalKey();

  final orders = invoice.productTitles.asMap().entries.map((entry) {
    final index = entry.key;
    return Order(
      title: entry.value,
      qty: invoice.productQuantities[index],
      fee: invoice.productPrices[index],
      totalFee: invoice.productQuantities[index] * invoice.productPrices[index],
    );
  }).toList();

  return RepaintBoundary(
    key: key,
    child: GestureDetector(
      onLongPress: () async {
        final imageBytes = await _captureImageBytes(key);
        if (imageBytes != null) {
          await _shareImageBytes(imageBytes);
        } else {
          // handle error
        }
      },
      child: InvoiceCard(
        orders: orders,
        dateTime: invoice.dateTime,
        tableNumber: invoice.tableNumber ?? 0,
      ),
    ),
  );
}

Future<Uint8List?> _captureImageBytes(GlobalKey key) async {
  RenderRepaintBoundary? boundary;
  if (key.currentContext != null) {
    boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary?;
  }
  if (boundary != null) {
    ui.Image? image = await boundary.toImage(pixelRatio: 3.0);
    if (image != null) {
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    }
  }
  return null;
}

Future<void> _shareImageBytes(Uint8List bytes) async {
  try {
    await Printing.sharePdf(bytes: bytes, filename: 'invoice.png');
  } catch (e) {
    print(e);
  }
}
