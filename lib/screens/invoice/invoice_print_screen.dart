import 'package:flutter/material.dart';
import 'package:mousavi/helpers/file.dart';
import 'package:mousavi/models/models.dart';
import 'package:mousavi/providers/invoices_provider.dart';
import 'package:provider/provider.dart';

import '../../widgets/widgets.dart';

class InvoicePrintScreen extends StatefulWidget {
  static const String routeName = '/print';
  final String selectedInvoiceId;

  const InvoicePrintScreen({Key? key, required this.selectedInvoiceId})
      : super(key: key);

  static Route route(String selectedInvoiceId) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) =>
            InvoicePrintScreen(selectedInvoiceId: selectedInvoiceId));
  }

  @override
  // ignore: library_private_types_in_public_api
  _InvoicePrintScreenState createState() => _InvoicePrintScreenState();
}

class _InvoicePrintScreenState extends State<InvoicePrintScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  late Invoice _selectedInvoice;

  @override
  void initState() {
    super.initState();
    _selectedInvoice = Provider.of<Invoices>(context, listen: false)
        .findById(widget.selectedInvoiceId);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Invoices>(context).fetchAndSetInvoices().then((_) {
        setState(() {
          _isLoading = false;
        });
        _selectedInvoice = Provider.of<Invoices>(context, listen: false)
            .findById(widget.selectedInvoiceId);
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey key = GlobalKey();

    final orders = _selectedInvoice.productTitles.asMap().entries.map((entry) {
      final index = entry.key;
      return Order(
        title: entry.value,
        qty: _selectedInvoice.productQuantities[index],
        fee: _selectedInvoice.productPrices[index],
        totalFee: int.parse(_selectedInvoice.productQuantities[index]) *
            _selectedInvoice.productPrices[index],
      );
    }).toList();

    return Scaffold(
        appBar: const CustomAppBar(title: 'چاپ فاکتور'),
        bottomNavigationBar: const CustomNavBar(currentTabIndex: 0),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                const Text(
                  'برای چاپ، فاکتور را کمی فشار دهید \n و بعد اپلیکیشن پرینتر خود را انتخاب نمایید',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                RepaintBoundary(
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
                    child: InvoiceCard(
                      orders: orders,
                      dateTime: _selectedInvoice.dateTime,
                      tableNumber: _selectedInvoice.tableNumber ?? 0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
