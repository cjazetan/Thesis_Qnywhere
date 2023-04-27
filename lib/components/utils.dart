import 'package:flutter/material.dart';
import 'package:qnywhere/main.dart';

class Utils {
  static errorSnackBar(IconData? icon, String? text) {
    if (text == null) return;

    final snackbar = SnackBar(
      content: Row(children: [
        Icon(icon),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: Text(
          text,
          maxLines: 2,
          softWrap: true,
        ))
      ]),
      backgroundColor: Colors.red,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackbar);
  }

  static successSnackBar(IconData? icon, String? text) {
    if (text == null) return;

    final snackbar = SnackBar(
      content: Row(children: [
        Icon(icon),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: Text(
          text,
          maxLines: 2,
          softWrap: true,
        ))
      ]),
      backgroundColor: Colors.green,
    );

    messengerKey.currentState!.showSnackBar(snackbar);
  }

  InputDecoration textInputDecoration(
      [String lableText = "", String hintText = ""]) {
    return InputDecoration(
      hintText: hintText,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0)),
    );
  }
}
