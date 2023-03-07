import 'package:mousavi/providers/invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:mousavi/providers/profiles_provider.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';

import './providers/products_provider.dart';
import 'package:flutter/services.dart';

import 'config/app_router.dart';

import 'screens/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Products()),
        ChangeNotifierProvider.value(value: Invoices()),
        ChangeNotifierProvider.value(value: Profiles()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: PersianFonts.vazirTextTheme,
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: HomeScreen.routeName,
      ),
    );
  }
}
