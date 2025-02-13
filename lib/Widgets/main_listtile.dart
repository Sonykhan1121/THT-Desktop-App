import 'dart:ui';
import 'package:flutter/material.dart';

class main_listTile extends StatelessWidget {
  final String image;
  final String text;
  final VoidCallback press;
  const main_listTile({
    super.key, required this.image, required this.text, required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Image.asset(
        image,
        height: 16,
        width: 16,
      ),
      title: Text(text),
    );
  }
}