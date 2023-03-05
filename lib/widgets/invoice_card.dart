import 'package:mousavi/helpers/format.dart';
import 'package:mousavi/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceCard extends StatelessWidget {
  final List<Order> orders;
  final int dateTime;
  final int tableNumber;

  final dateTimeFormatter = NumberFormat('00');

  InvoiceCard(
      {super.key,
      required this.orders,
      required this.dateTime,
      required this.tableNumber});

  TableRow _getDataRow(Order order) {
    return TableRow(
      children: [
        Text(
          formatPrice(order.totalFee).toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        Text(
          replaceFarsiNumber(order.qty.toString()),
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
    return Center(
      child: SizedBox(
        width: 300,
        child: Card(
          elevation: 10,
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.only(
                bottom: 15.0, left: 7.0, right: 7.0, top: 10.0),
            child: Column(
              children: [
                Column(children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 70,
                    height: 70,
                  ),
                  const Text(
                    'رستوران موسوی',
                    style: TextStyle(
                      fontSize: 18,
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
                      replaceFarsiNumber(
                        '${getJalaliDateTime(dateTime).year}/${dateTimeFormatter.format(getJalaliDateTime(dateTime).month)}/${dateTimeFormatter.format(getJalaliDateTime(dateTime).day)} ${dateTimeFormatter.format(getJalaliDateTime(dateTime).hour)}:${dateTimeFormatter.format(getJalaliDateTime(dateTime).minute)}',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ': تاریخ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                (tableNumber == 0)
                    ? const SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            replaceFarsiNumber(tableNumber.toString()),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ': شماره تخت',
                            style: TextStyle(
                              fontSize: 16,
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
                                fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      TableCell(
                          child: Text('تعداد',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                      TableCell(
                          child: Text('قیمت',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                      TableCell(
                          child: Text('محصول',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                    ]),
                    ...List.generate(
                      orders.length,
                      (index) => _getDataRow(orders[index]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (formatPrice(orders.fold<double>(
                                0, (sum, order) => sum + order.totalFee)))
                            .toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        ': مبلغ کل (تومان)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      replaceFarsiNumber('پنجتن 41 -نبش خ 12'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ': آدرس',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      replaceFarsiNumber('09151231245'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ': تلفن',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'سفارش مجالس پذیرفته میشود',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      replaceFarsiNumber('09057302285'),
                      style: const TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ': نرم افزار بلوط',
                      style: TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
