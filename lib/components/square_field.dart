import 'package:flutter/material.dart';
import 'package:qnywhere/components/square_container.dart';

class SquareInput extends StatelessWidget {
  const SquareInput(
      {Key? key,
      required this.icon,
      required this.hint,
      required this.controller})
      : super(key: key);
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SquareContainer(
        size: size * 0.70,
        child: TextField(
          style: const TextStyle(
              color: Color.fromRGBO(141, 141, 141, 100), fontSize: 16),
          keyboardType: TextInputType.emailAddress,
          controller: controller,
          cursorColor: Colors.black,
          decoration: InputDecoration(
              icon: Icon(icon, color: const Color(0xff398E7F)),
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color.fromRGBO(141, 141, 141, 100), fontSize: 18),
              border: InputBorder.none),
        ));
  }
}
