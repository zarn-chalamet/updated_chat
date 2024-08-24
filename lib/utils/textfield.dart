import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final FocusNode? focusNode;

  const TextBox({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.hintText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Container(
        height: 70, // Fixed height
        width: 330,
        alignment: Alignment.center,
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscureText,
          cursorColor: const Color.fromARGB(255, 130, 132, 132),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFCAEEEB),
            hintText: hintText.toUpperCase(),
            hintStyle: const TextStyle(
              letterSpacing: 2,
              color: Color.fromARGB(255, 167, 169, 167),
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 24), // Adjust this to balance vertical padding
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
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
