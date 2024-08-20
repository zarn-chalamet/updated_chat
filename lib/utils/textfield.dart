import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final FocusNode? focusNode;
  const TextBox(
      {super.key,
      required this.controller,
      required this.obscureText,
      required this.hintText,
      this.focusNode});

  // bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
      child: Container(
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscureText,
          cursorColor: Color.fromARGB(255, 130, 132, 132),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFCAEEEB),
            hintText: hintText.toUpperCase(),
            hintStyle: TextStyle(
                letterSpacing: 2, color: Color.fromARGB(255, 167, 169, 167)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 36, 141, 132),
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}
