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
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      return;
    }
    Provider.of<Products>(context, listen: false)
        .addProduct(_titleController.text, double.parse(_priceController.text));
    _titleController.clear();
    _priceController.clear();
  }

  _deleteProduct(String productId) {
    Provider.of<Products>(context, listen: false).removeProduct(productId);
  }

  bool isFormValid() {
    return _titleController.text.isNotEmpty && _priceController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'افزودن غذا'),
      bottomNavigationBar: const CustomNavBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _isFormValid = isFormValid();
                      });
                    },
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'نام غذا',
                    ),
                    textAlign: TextAlign.right,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _isFormValid = isFormValid();
                      });
                    },
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'قیمت'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        isFormValid() ? () => _saveProduct(context) : null,
                    child: const Text('ذخیره'),
                  ),
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
              : products.items.isEmpty
                  ? const Center(
                      child: Text('غذایی ثبت نشده'),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: products.items.length,
                        itemBuilder: (ctx, i) => Card(
                          color: Colors.greenAccent,
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${formatPrice(products.items[i].price)} تومان',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      products.items[i].title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _deleteProduct(products.items[i].id),
                                      color: Theme.of(context).errorColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
