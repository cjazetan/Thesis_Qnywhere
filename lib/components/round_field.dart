import 'package:flutter/material.dart';
import 'package:qnywhere/components/round_container.dart';

class RoundedInput extends StatelessWidget {
  const RoundedInput(
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
    return InputContainer(
        size: size * 0.8,
        child: TextField(
          style: const TextStyle(color: Color.fromRGBO(141, 141, 141, 100)),
          keyboardType: TextInputType.emailAddress,
          controller: controller,
          cursorColor: Colors.black,
          decoration: InputDecoration(
              icon: Icon(icon, color: const Color.fromRGBO(141, 141, 141, 100)),
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color.fromRGBO(141, 141, 141, 100)),
              border: InputBorder.none),
        ));
  }
}
