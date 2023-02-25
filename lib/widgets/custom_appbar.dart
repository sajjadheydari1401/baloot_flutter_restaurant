import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.lightBlue,
      title: Container(
        color: Colors.lightBlue,
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headline4!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}
