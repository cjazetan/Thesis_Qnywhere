// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:qnywhere/components/addBusiness_container.dart';

class AddBusinessInput extends StatelessWidget {
  const AddBusinessInput(
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
    return AddBusinesContainer(
        size: size * 0.78,
        child: TextField(
          style: const TextStyle(color: Colors.white, fontSize: 18),
          keyboardType: TextInputType.emailAddress,
          controller: controller,
          cursorColor: Colors.black,
          decoration: const InputDecoration(border: InputBorder.none),
        ));
  }
}
