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
  final _tableNumberController = TextEditingController();
  final dateTimeFormatter = NumberFormat('00');
  final now = DateTime.now().millisecondsSinceEpoch;

  List<Order> orders = [];

  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  void _decreaseOrderQty(String title) {
    int index = orders.indexWhere((order) => order.title == title);

    if (index == -1) {
      return;
    }

    Order order = orders[index];

    if (order.qty == 1) {
      orders.removeAt(index);
    } else {
      order.qty = order.qty! - 1; // Add null check
      order.totalFee = order.qty! * order.fee;
      orders[index] = order;
    }

    // Update the UI
    setState(() {});
  }

  int _getOrderQty(String title) {
    final order = orders.firstWhere((order) => order.title == title,
        orElse: () => Order(title: title, fee: 0.0, qty: 0));
    return order.qty!;
  }

  Future<void> _saveInvoice(BuildContext context) async {
    final tableNumber = _tableNumberController.text;
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
        tableNumber.isNotEmpty ? int.parse(tableNumber) : 0,
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

    _tableNumberController.clear();

    orders.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => const InvoiceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: ' ثبت سفارش'),
      bottomNavigationBar: CustomNavBar(currentTabIndex: 0),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : products.items.isEmpty
              ? const Center(
                  child: Text(
                    'غذایی ثبت نشده',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 50.0),
                        // implement GridView.builder
                        child: GridView.builder(
                          shrinkWrap:
                              true, // to allow scrolling inside the GridView
                          physics:
                              const NeverScrollableScrollPhysics(), // to disable GridView scrolling
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                MediaQuery.of(context).size.width / 5,
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
                              child: Column(
                                children: [
                                  Container(
                                    height: 110,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          products.items[index].title,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (_getOrderQty(
                                                products.items[index].title) >
                                            0)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: () =>
                                                    _decreaseOrderQty(products
                                                        .items[index].title),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black38,
                                                      blurRadius: 5,
                                                      offset: Offset(1, 1),
                                                    ),
                                                  ],
                                                ),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: Text(
                                                  '${_getOrderQty(products.items[index].title)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed: () => _addToOrders(
                                                    products.items[index]),
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      TextField(
                        controller: _tableNumberController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: ' (اختیاری)  شماره تخت را وارد کنید ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      IgnorePointer(
                        ignoring: orders.isEmpty,
                        child: ElevatedButton(
                          onPressed: orders.isNotEmpty
                              ? () => _saveInvoice(context)
                              : null,
                          child: const Text('چاپ رسید'),
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
                              tableNumber:
                                  _tableNumberController.text.isNotEmpty
                                      ? int.parse(_tableNumberController.text)
                                      : 0,
                            ),
                    ],
                  ),
                ),
    );
  }
}
