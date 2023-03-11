import 'package:flutter/material.dart';

import '../screens/screens.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    // ignore: avoid_print
    print('This is route: ${settings.name}');

    switch (settings.name) {
      case './':
        return HomeScreen.route();
      case HomeScreen.routeName:
        return HomeScreen.route();
      case OrderScreen.routeName:
        return OrderScreen.route();
      case ProductScreen.routeName:
        return ProductScreen.route();
      case InvoiceScreen.routeName:
        return InvoiceScreen.route();
      case ProfileScreen.routeName:
        return ProfileScreen.route();
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: './error'),
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
      ),
    );
  }
}
