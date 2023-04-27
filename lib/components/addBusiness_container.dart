// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AddBusinesContainer extends StatelessWidget {
  const AddBusinesContainer({Key? key, required this.child, required this.size})
      : super(key: key);
  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        height: 45,
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromRGBO(225, 225, 225, 50)),
        child: child);
  }
}
