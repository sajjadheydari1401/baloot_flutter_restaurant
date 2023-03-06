import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/format.dart';
import '../../providers/products_provider.dart';
import '../../widgets/widgets.dart';

class ProductScreen extends StatefulWidget {
  static const String routeName = '/product';

  const ProductScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const ProductScreen());
  }

  @override
  // ignore: library_private_types_in_public_api
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isInit = true;
  bool _isLoading = false;
  bool _isFormValid = false;

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
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  _saveProduct(BuildContext context) {
    if (_titleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      return;
    }

    final productsProvider = Provider.of<Products>(context, listen: false);
    final existingProductIndex = productsProvider.items
        .indexWhere((product) => product.title == _titleController.text.trim());
    if (existingProductIndex != -1) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('خطا'),
          content: const Text('غذایی با این عنوان قبلاً ثبت شده است'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('تأیید'),
            ),
          ],
        ),
      );
      return;
    }

    productsProvider.addProduct(_titleController.text.trim(),
        double.parse(_priceController.text.trim()));
    _titleController.clear();
    _priceController.clear();
  }

  _deleteProduct(String productId) {
    Provider.of<Products>(context, listen: false).removeProduct(productId);
  }

  bool isFormValid() {
    return _titleController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        !_priceController.text.startsWith("0") &&
        !_priceController.text.contains('.') &&
        !_priceController.text.contains(',');
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'افزودن غذا'),
      bottomNavigationBar: const CustomNavBar(currentTabIndex: 0),
      body: Center(
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    width: 500,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _isFormValid = isFormValid();
                                });
                              },
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              controller: _titleController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                hintText: 'نام غذا',
                                contentPadding: EdgeInsets.only(top: 10),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 50,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _isFormValid = isFormValid();
                                });
                              },
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              controller: _priceController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'قیمت',
                                contentPadding: EdgeInsets.only(top: 10),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: IgnorePointer(
                              ignoring: !isFormValid(),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff70e000),
                                ),
                                onPressed: isFormValid()
                                    ? () => _saveProduct(context)
                                    : null,
                                child: const Text(
                                  'افزودن محصول',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (products.items.isNotEmpty)
                    const Text(
                      'برای حذف محصول، آیتم را به طرف چپ بکشید',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  _isLoading
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
                          : Expanded(
                              child: SizedBox(
                                width: 450,
                                child: ListView.builder(
                                  itemCount: products.items.length,
                                  itemBuilder: (ctx, index) {
                                    final item = products.items[index];

                                    return Dismissible(
                                      key: Key(item.id),
                                      confirmDismiss: (direction) async {
                                        return await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('حذف محصول'),
                                              content: Text(
                                                  'آیا مطمئن هستید که می‌خواهید ${item.title} را حذف کنید؟'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text('خیر'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text('بله'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      onDismissed: (direction) {
                                        _deleteProduct(
                                            products.items[index].id);
                                        // Then show a snackbar.
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('${item.title} حذف شد'),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        color: const Color(0xff70e000),
                                        elevation: 5,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 5,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${formatPrice(products.items[index].price)} تومان',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff112A46),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    products.items[index].title,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff112A46),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
