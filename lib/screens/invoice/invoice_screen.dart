import 'package:ecommerce_app/models/invoice_model.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/providers/invoices_provider.dart';
import 'package:ecommerce_app/widgets/widgets.dart';
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

  @override
  void initState() {
    super.initState();
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
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final invoices = Provider.of<Invoices>(context)
        .items
        .where((invoice) => invoice.isDeleted == 0)
        .toList();

    return Scaffold(
      appBar: const CustomAppBar(title: 'فاکتورها'),
      bottomNavigationBar: const CustomNavBar(),
      body: invoices.isEmpty
          ? const Center(
              child: Text('فاکتوری ثبت نشده'),
            )
          : ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (ctx, i) {
                return _buildInvoiceCard(invoices[i]);
              },
            ),
    );
  }
}

Widget _buildInvoiceCard(Invoice invoice) {
  final orders = invoice.productTitles.asMap().entries.map((entry) {
    final index = entry.key;
    return Order(
      title: entry.value,
      qty: invoice.productQuantities[index],
      fee: invoice.productPrices[index],
      totalFee: invoice.totalPrice,
    );
  }).toList();
  return InvoiceCard(
    orders: orders,
    dateTime: invoice.dateTime,
  );
}
