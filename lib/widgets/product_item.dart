import 'package:ecommerce_app/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'fa-IR',
      symbol: 'تومان',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          product.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 4),
        Text(
          formatter.format(product.price),
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }
}
