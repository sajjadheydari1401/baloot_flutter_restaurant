import 'package:mousavi/helpers/file.dart';
import 'package:mousavi/helpers/format.dart';
import 'package:mousavi/models/invoice_model.dart';
import 'package:mousavi/models/order_model.dart';
import 'package:mousavi/providers/invoices_provider.dart';
import 'package:mousavi/widgets/widgets.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  String loadedContentLabel = 'لطفا بازه ی تاریخ ثبت فاکتور را مشخص کنید';

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
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      Provider.of<Invoices>(context).fetchAndSetInvoices().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
  }

  void filterInvoices() {
    final invoices = Provider.of<Invoices>(context, listen: false).items;

    if (toLabel == 'انتخاب تاریخ' || fromLabel == 'انتخاب تاریخ') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'انتخاب تمامی فیلد ها الزامیست',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    DateTime grFromLabel = convertDatetime(fromLabel, 'toGregorian');
    DateTime grToLabel = convertDatetime(toLabel, 'toGregorian');

    if (grToLabel.isBefore(grFromLabel)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تاریخ انتها نباید از تاریخ ابتدا کمتر باشد',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
      setState(() {
        toLabel = 'انتخاب تاریخ';
      });
      return;
    }

    List<Invoice> filteredInvoices = invoices.where((invoice) {
      DateTime invoiceDateTime =
          DateTime.fromMillisecondsSinceEpoch(invoice.dateTime);

      if (grFromLabel.isAfter(grToLabel)) {
        return false; // invalid date range
      } else if (invoiceDateTime.isBefore(grFromLabel) ||
          invoiceDateTime.isAfter(grToLabel.add(const Duration(days: 1)))) {
        return false; // outside the date range
      } else {
        return true;
      }
    }).toList();

    setState(() {
      invoicesToShow = filteredInvoices;
      if (filteredInvoices.isEmpty) {
        loadedContentLabel = 'فاکتوری ثبت نشده';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'فاکتورها'),
      bottomNavigationBar: const CustomNavBar(currentTabIndex: 1),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              bottom: 10.0,
            ),
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            // color: const Color(0xffccff33),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        filterInvoices();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff70e000),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff70e000),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff70e000),
                      ),
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
                ((toLabel == 'انتخاب تاریخ' || fromLabel == 'انتخاب تاریخ') ||
                        invoicesToShow.isEmpty)
                    ? const SizedBox()
                    : Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            color: const Color(0xff70e000),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (formatPrice(invoicesToShow.fold<double>(0,
                                          (sum, inv) => sum + inv.totalPrice)))
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  ': فروش کل در این بازه (تومان)',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
              ],
            ),
          ),
          if (invoicesToShow.isNotEmpty)
            const Text(
              'برای حذف فاکتور، آیتم را به طرف چپ بکشید',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: invoicesToShow.isEmpty
                ? _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: Text(
                          loadedContentLabel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                : ListView.builder(
                    itemCount: invoicesToShow.length,
                    itemBuilder: (BuildContext context, int index) {
                      final invoice = invoicesToShow[index];
                      return _buildInvoiceCard(
                          context, invoice, filterInvoices);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _buildInvoiceCard(
    BuildContext context, Invoice invoice, Function filterInvoices) {
  final GlobalKey key = GlobalKey();

  final orders = invoice.productTitles.asMap().entries.map((entry) {
    final index = entry.key;
    return Order(
      title: entry.value,
      qty: invoice.productQuantities[index],
      fee: invoice.productPrices[index],
      totalFee: int.parse(invoice.productQuantities[index]) *
          invoice.productPrices[index],
    );
  }).toList();

  return RepaintBoundary(
    key: key,
    child: GestureDetector(
      onLongPress: () async {
        final imageBytes = await captureImageBytes(key);
        if (imageBytes != null) {
          await shareImageBytes(imageBytes);
        } else {
          print('imageBytes is null');
        }
      },
      child: Dismissible(
        key: Key(invoice.id),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('حذف فاکتور'),
                content: const Text(
                    'آیا مطمئن هستید که می‌خواهید این فاکتور را حذف کنید؟'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('خیر'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('بله'),
                  ),
                ],
              );
            },
          );
        },
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          Provider.of<Invoices>(context, listen: false)
              .removeInvoice(invoice.id);
          filterInvoices();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // Then show a snackbar.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فاکتور حذف شد'),
              duration: Duration(milliseconds: 500),
            ),
          );
        },
        child: InvoiceCard(
          orders: orders,
          dateTime: invoice.dateTime,
          tableNumber: invoice.tableNumber ?? 0,
        ),
      ),
    ),
  );
}
