import 'package:mousavi/helpers/format.dart';
import 'package:mousavi/models/models.dart';
import 'package:mousavi/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mousavi/providers/profiles_provider.dart';
import 'package:provider/provider.dart';

class InvoiceCard extends StatefulWidget {
  final List<Order> orders;
  final int dateTime;
  final int tableNumber;

  InvoiceCard(
      {super.key,
      required this.orders,
      required this.dateTime,
      required this.tableNumber});

  @override
  State<InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {
  final dateTimeFormatter = NumberFormat('00');

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
      Provider.of<Profiles>(context).fetchProfile().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

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
    Profile profile = Provider.of<Profiles>(context, listen: false).profile;
    print(profile);
    return _isLoading
        ? const CircularProgressIndicator()
        : profile == null
            ? const Text('')
            : Center(
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
                            Text(
                              profile.title,
                              style: const TextStyle(
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
                                  '${getJalaliDateTime(widget.dateTime).year}/${dateTimeFormatter.format(getJalaliDateTime(widget.dateTime).month)}/${dateTimeFormatter.format(getJalaliDateTime(widget.dateTime).day)} ${dateTimeFormatter.format(getJalaliDateTime(widget.dateTime).hour)}:${dateTimeFormatter.format(getJalaliDateTime(widget.dateTime).minute)}',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget.tableNumber == 0
                                  ? const Text(
                                      'بیرون بر',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      replaceFarsiNumber(
                                          widget.tableNumber.toString()),
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
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                ),
                                TableCell(
                                    child: Text('تعداد',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center)),
                                TableCell(
                                    child: Text('قیمت',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center)),
                                TableCell(
                                    child: Text('محصول',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center)),
                              ]),
                              ...List.generate(
                                widget.orders.length,
                                (index) => _getDataRow(widget.orders[index]),
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
                                  (formatPrice(widget.orders.fold<double>(
                                      0,
                                      (sum, order) =>
                                          sum + order.totalFee))).toString(),
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
                          const Text(
                            ': آدرس',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            replaceFarsiNumber(profile.address),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            ': تلفن',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            replaceFarsiNumber(profile.phone),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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
                                ),
                              ),
                              const Text(
                                ': نرم افزار بلوط',
                                style: TextStyle(
                                  fontSize: 16,
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
