import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: 3), // You can adjust the duration as needed
    action: SnackBarAction(
      label: 'Close',
      onPressed: () {
        // Some code to execute when the action is pressed, if needed
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
