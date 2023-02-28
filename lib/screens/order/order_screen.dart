import 'package:ecommerce_app/helpers/format.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/providers/invoices_provider.dart';
import 'package:ecommerce_app/providers/products_provider.dart';
import 'package:ecommerce_app/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/widgets.dart';

class OrderScreen extends StatefulWidget {
  static const String routeName = '/order';

  const OrderScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const OrderScreen(),
    );
  }

  @override
  // ignore: library_private_types_in_public_api
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final dateTimeFormatter = NumberFormat('00');
  final now = DateTime.now().millisecondsSinceEpoch;

  List<Order> orders = [];

  bool? _isButtonEnabled;
  String? _selectedProductId;
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isButtonEnabled = false;
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Future.wait([
        Provider.of<Products>(context).fetchAndSetProducts(),
        Provider.of<Invoices>(context).fetchAndSetInvoices(),
      ]);
      setState(() {
        _isLoading = false;
        _isButtonEnabled = true;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _addItem(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedProduct = Provider.of<Products>(context, listen: false)
        .findById(_selectedProductId!);

    if (selectedProduct != null) {
      final order = Order(
        totalFee: selectedProduct.price * int.parse(_quantityController.text),
        fee: selectedProduct.price,
        qty: int.parse(_quantityController.text),
        title: selectedProduct.title,
      );
      orders.add(order);
    }

    _quantityController.clear();

    setState(() {
      _selectedProductId = null;
      _isButtonEnabled = false;
    });
  }

  Future<void> _saveInvoice(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productTitles = orders.map((order) => order.title).toList();
    final productPrices = orders.map((order) => order.fee).toList();
    final productQuantities = orders.map((order) => order.qty).toList();
    final totalInvoicePrice =
        orders.fold<double>(0, (sum, order) => sum + order.totalFee);

    try {
      await Provider.of<Invoices>(context, listen: false).addInvoice(
        const Uuid().v4(),
        productTitles,
        productPrices,
        productQuantities,
        totalInvoicePrice,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[300],
          content: const Text('فاکتور با موفقیت ساخته شد'),
        ),
      );
    } catch (error) {
      print('Error adding invoice: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در ساخت فاکتور'),
        ),
      );
      return;
    }

    _quantityController.clear();
    setState(() {
      _selectedProductId = null;
    });

    orders.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => const InvoiceScreen(),
      ),
    );
  }

  bool isButtonEnabled() {
    return _selectedProductId != null && _quantityController.text.isNotEmpty;
  }

  void _removeOrderItem(String orderId) {
    // to do
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: ' ثبت سفارش'),
      bottomNavigationBar: const CustomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      value: _selectedProductId,
                      items: products.items.map((product) {
                        return DropdownMenuItem<String>(
                          value: product.id,
                          child: Text(product.title),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'انتخاب مورد',
                      ),
                      onChanged: (selectedProductId) {
                        setState(() {
                          _selectedProductId = selectedProductId;
                          _isButtonEnabled = isButtonEnabled();
                        });
                      },
                    ),
                    TextFormField(
                      controller: _quantityController,
                      onChanged: (value) {
                        setState(() {
                          _isButtonEnabled = isButtonEnabled();
                        });
                      },
                      decoration: const InputDecoration(labelText: 'تعداد'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          isButtonEnabled() ? () => _addItem(context) : null,
                      child: const Text('افزودن'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          orders.isNotEmpty ? _saveInvoice(context) : null,
                      child: const Text('چاپ رسید'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : InvoiceCard(
                    orders: orders,
                    dateTime: DateTime.now().millisecondsSinceEpoch,
                  ),
          ],
        ),
      ),
    );
  }
}
