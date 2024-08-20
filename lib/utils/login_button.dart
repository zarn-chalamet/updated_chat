import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  const LoginButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: 55,
          child: MaterialButton(
            onPressed: onPressed,
            color: Color(0xFF0DB0A4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 2.0),
            ),
          )),
    );
  }
}
