import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final dynamicHeight = (size.height * 0.055).clamp(40.0, 52.0);
    final dynamicFontSize = (size.width * 0.035).clamp(12.0, 16.0);
    final dynamicIconSize = (size.width * 0.05).clamp(18.0, 22.0);

    return Container(
      height: dynamicHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD64F5C), width: 1.3),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: dynamicFontSize,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: dynamicFontSize,
            color: const Color(0xFFCCCCCC),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFD64F5C),
            size: dynamicIconSize,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.010,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
