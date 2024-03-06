import 'package:flutter/material.dart';

Color primaryColor = Color(
  0xfffc3b77,
);

void goTO(BuildContext context, Widget nextScreen) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => nextScreen,
      ));
}

dialogBox(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(text),
    ),
  );
}

Widget progressIndicator(BuildContext context) {
  return Center(
      child: CircularProgressIndicator(
    backgroundColor: primaryColor,
    color: Colors.red,
    strokeWidth: 7,
  ));
}
