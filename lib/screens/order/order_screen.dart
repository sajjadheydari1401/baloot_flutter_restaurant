import 'package:mousavi/models/models.dart';
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
  bool isDelivery = false;
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
      ScaffoldMessenger.of(context).clearSnackBars();
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
        qty: '1',
        totalFee: product.price,
      ));
    } else {
      // If the item is already in the orders list, update the quantity and total fee
      Order order = orders[index];
      order.qty = (int.parse(order.qty) + 1).toString();
      order.totalFee = int.parse(order.qty) * order.fee;
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

    if (order.qty == "1") {
      orders.removeAt(index);
    } else {
      order.qty = (int.parse(order.qty) - 1).toString(); // Add null check
      order.totalFee = int.parse(order.qty) * order.fee;
      orders[index] = order;
    }

    // Update the UI
    setState(() {});
  }

  String _getOrderQty(String title) {
    final order = orders.firstWhere((order) => order.title == title,
        orElse: () => Order(title: title, fee: 0.0, qty: '0'));
    return order.qty;
  }

  Future<void> _saveInvoice(BuildContext context) async {
    final invoiceId = const Uuid().v4();
    final tableNumber = _tableNumberController.text;
    final productTitles = orders.map((order) => order.title).toList();
    final productPrices = orders.map((order) => order.fee).toList();
    final productQuantities = orders.map((order) => order.qty).toList();
    final totalInvoicePrice =
        orders.fold<double>(0, (sum, order) => sum + order.totalFee);
    try {
      await Provider.of<Invoices>(context, listen: false).addInvoice(
        invoiceId,
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
          duration: const Duration(milliseconds: 500),
        ),
      );
    } catch (error) {
      print('Error adding invoice: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در ساخت فاکتور'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return;
    }

    _tableNumberController.clear();

    orders.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => InvoicePrintScreen(
          selectedInvoiceId: invoiceId,
        ),
      ),
    );
  }

  bool validatedForm() {
    if (orders.isNotEmpty &&
        _tableNumberController.text.trim().isNotEmpty &&
        _tableNumberController.text.trim() != "0") {
      return true;
    } else if (orders.isNotEmpty && isDelivery == true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: ' ثبت سفارش'),
      bottomNavigationBar: const CustomNavBar(currentTabIndex: 0),
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
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: products.items.length,
                          itemBuilder: (BuildContext ctx, index) {
                            // Calculate the width of each item based on available space
                            final double itemWidth = (MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.8 -
                                    80 -
                                    4 * 20 -
                                    20 * 4) /
                                5; // 80% of screen width minus 80 pixels of horizontal padding and 4 * 20 pixels of spacing, divided by 5 columns

                            // Generate a list of colors to use for each row
                            final List<Color> rowColors = [
                              const Color(0xfffdfd96),
                              const Color(0xff77dd77),
                              const Color(0xffff6961),
                              const Color(0xff84b6f4),
                            ];

                            // Get the color to use for the current item
                            final Color color =
                                rowColors[index % rowColors.length];

                            // Create a Container widget with the appropriate color
                            return GestureDetector(
                              onTap: () => _addToOrders(products.items[index]),
                              child: Column(
                                children: [
                                  Container(
                                    width: itemWidth + 30,
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
                                        if (int.parse(_getOrderQty(
                                                products.items[index].title)) >
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
                                              Container(
                                                width: 20,
                                                height: 20,
                                                alignment: Alignment.center,
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
                                                child: Text(
                                                  _getOrderQty(products
                                                      .items[index].title),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'بیرون بر',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Checkbox(
                            value: isDelivery,
                            onChanged: (bool? value) {
                              if (value != null &&
                                  _tableNumberController.text.trim().isEmpty) {
                                setState(() {
                                  isDelivery = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                        width: 200,
                        child: TextField(
                          enabled: isDelivery == false,
                          onChanged: (value) => setState(() {}),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          controller: _tableNumberController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'شماره تخت (اختیاری)',
                            border: UnderlineInputBorder(),
                            contentPadding: EdgeInsets.only(right: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff70e000),
                            ),
                            onPressed: validatedForm()
                                ? () => _saveInvoice(context)
                                : null,
                            child: const Text(
                              'چاپ رسید',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
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
                                  _tableNumberController.text.trim().isNotEmpty
                                      ? int.parse(_tableNumberController.text)
                                      : 0,
                            ),
                    ],
                  ),
                ),
    );
  }
}
