import 'package:ecommerce_app/helpers/format.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceCard extends StatelessWidget {
  final List<Order> orders;
  final int dateTime;

  final dateTimeFormatter = NumberFormat('00');
  final _persianNumber = NumberFormat.decimalPattern('fa-IR');

  InvoiceCard({super.key, required this.orders, required this.dateTime});

  TableRow _getDataRow(Order order) {
    return TableRow(
      children: [
        Text(
          formatPrice(order.totalFee).toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        Text(
          _persianNumber.format(order.qty).toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        Text(
          formatPrice(order.fee).toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        Text(
          order.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Card(
      margin:
          const EdgeInsets.only(top: 5.0, bottom: 15.0, left: 8.0, right: 8.0),
      elevation: 5,
      color: Colors.amber[50],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        padding: const EdgeInsets.only(
            bottom: 15.0, left: 7.0, right: 7.0, top: 10.0),
        child: Column(
          children: [
            Column(children: [
              Image.asset(
                'assets/images/logo.png',
                width: 90,
                height: 70,
              ),
              const Text(
                'رستوران موسوی',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${getJalaliDateTime(dateTime).year}/${dateTimeFormatter.format(getJalaliDateTime(dateTime).month)}/${dateTimeFormatter.format(getJalaliDateTime(dateTime).day)} ${dateTimeFormatter.format(getJalaliDateTime(dateTime).hour)}:${dateTimeFormatter.format(getJalaliDateTime(dateTime).minute)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ': تاریخ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (formatPrice(orders.fold<double>(
                      0, (sum, order) => sum + order.totalFee))).toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ': مبلغ کل (تومان)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              border: TableBorder.all(
                color: Colors.black,
                width: 2.0,
                style: BorderStyle.solid,
              ),
              children: [
                const TableRow(children: [
                  TableCell(
                    child: Text('قیمت کل',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                  TableCell(
                      child: Text('تعداد',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)),
                  TableCell(
                      child: Text('قیمت',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)),
                  TableCell(
                      child: Text('محصول',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)),
                ]),
                ...List.generate(
                  orders.length,
                  (index) => _getDataRow(orders[index]),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'پنجتن 41 -نبش خ 12',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ': آدرس',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '09151231245',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ': تلفن',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
