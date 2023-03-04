import 'package:mousavi/screens/screens.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  final int currentTabIndex;
  const CustomNavBar({Key? key, required this.currentTabIndex})
      : super(key: key);

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    InvoiceScreen(),
    // add more screens here
  ];

  void _onItemTapped(int index) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => _widgetOptions.elementAt(index),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'صفحه اصلی',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'فاکتور ها',
        ),
        // add more items here
      ],
      selectedLabelStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      ),
      currentIndex: widget.currentTabIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      backgroundColor: Colors.blue,
      onTap: _onItemTapped,
    );
  }
}
