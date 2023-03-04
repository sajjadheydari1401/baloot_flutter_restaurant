import 'package:flutter/material.dart';

import 'package:mousavi/widgets/widgets.dart';
import 'package:persian_fonts/persian_fonts.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const HomeScreen());
  }

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      textStyle: PersianFonts.Vazir.copyWith(
          fontSize: 20, fontWeight: FontWeight.bold),
    );
    return Scaffold(
        appBar: const CustomAppBar(title: 'رستوران موسوی'),
        bottomNavigationBar: CustomNavBar(currentTabIndex: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/product');
                  },
                  style: buttonStyle,
                  child: const Text('افزودن غذا'),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/order');
                  },
                  style: buttonStyle,
                  child: const Text('ثبت سفارش'),
                ),
              ),
            ],
          ),
        ));
  }
}
