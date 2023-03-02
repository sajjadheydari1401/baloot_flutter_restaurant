import 'package:mousavi/models/order_model.dart';
import 'package:mousavi/providers/invoices_provider.dart';
import 'package:mousavi/providers/products_provider.dart';
import 'package:mousavi/screens/screens.dart';
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

  void _addToOrders(product) {
    // Check if the item is already in the orders list
    int index = orders.indexWhere((order) => order.title == product.title);

    if (index == -1) {
      // If the item is not in the orders list, add it
      orders.add(Order(
        title: product.title,
        fee: product.price,
        qty: 1,
        totalFee: product.price,
      ));
    } else {
      // If the item is already in the orders list, update the quantity and total fee
      Order order = orders[index];
      order.qty = (order.qty ?? 0) + 1;
      order.totalFee = (order.qty ?? 0) * order.fee;
      orders[index] = order;
    }

    // Update the UI
    setState(() {});
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
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              // implement GridView.builder
              child: GridView.builder(
                shrinkWrap: true, // to allow scrolling inside the GridView
                physics:
                    NeverScrollableScrollPhysics(), // to disable GridView scrolling
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: MediaQuery.of(context).size.width / 5,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: products.items.length,
                itemBuilder: (BuildContext ctx, index) {
                  // Calculate the row number based on the item index
                  int row = index ~/ 5;

                  // Generate a list of colors to use for each row
                  List<Color> rowColors = const [
                    Color(0xfffdfd96),
                    Color(0xff77dd77),
                    Color(0xffff6961),
                    Color(0xff84b6f4),
                  ];

                  // Get the color to use for the current row
                  Color color = rowColors[row % rowColors.length];

                  // Create a Container widget with the appropriate color
                  return GestureDetector(
                    onTap: () => _addToOrders(products.items[index]),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                products.items[index].title,
                                style: const TextStyle(fontSize: 18),
                              ),
                              if (orders.any((order) =>
                                  order.title == products.items[index].title))
                                Text(
                                  '${orders.firstWhere((order) => order.title == products.items[index].title).qty}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (orders.any((order) =>
                            order.title == products.items[index].title))
                          Positioned(
                            right: 5,
                            bottom: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 5,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                '${orders.firstWhere((order) => order.title == products.items[index].title).qty}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => orders.isNotEmpty ? _saveInvoice(context) : null,
              child: const Text('چاپ رسید'),
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
