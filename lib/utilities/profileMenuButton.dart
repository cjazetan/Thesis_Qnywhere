// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ProfileMenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback press;

  const ProfileMenuButton(
      {Key? key, required this.text, required this.icon, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: const Color(0xFFF5F6F9),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        onPressed: press,
        child: Padding(
          padding: const EdgeInsets.all(16.5),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: const Color(0xff294243),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: Text(
                text,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xff294243)),
              )),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xff294243),
                size: 16,
              )
            ],
          ),
        ),
      ),
    );
  }
}
