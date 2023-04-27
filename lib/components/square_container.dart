import 'package:flutter/material.dart';

class SquareContainer extends StatelessWidget {
  const SquareContainer({Key? key, required this.child, required this.size})
      : super(key: key);
  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: const Color.fromRGBO(223, 223, 223, 100)),
        child: child);
  }
}
