import 'package:flutter/material.dart';
import 'package:mousavi/models/models.dart';
import 'package:mousavi/providers/profiles_provider.dart';

import 'package:mousavi/widgets/widgets.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const HomeScreen());
  }

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    Profile profile = Provider.of<Profiles>(context, listen: false).profile;

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff70e000),
      textStyle: PersianFonts.Vazir.copyWith(
          fontSize: 20, fontWeight: FontWeight.bold),
    );
    return Scaffold(
        appBar: _isLoading
            ? const CustomAppBar(title: '')
            : profile == null
                ? const CustomAppBar(title: '')
                : CustomAppBar(title: profile.title),
        bottomNavigationBar: const CustomNavBar(currentTabIndex: 0),
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
