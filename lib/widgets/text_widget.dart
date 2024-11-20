import 'package:flutter/material.dart';

class TextWidget extends StatefulWidget {
  const TextWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.ofsecuretext,
    this.initialvalue,
    this.keyBoardType,
    this.onTap,
    this.onTextChanged, // Add this line
  });

  final TextEditingController controller;
  final String? hintText;
  final bool? ofsecuretext;
  final String? initialvalue;
  final TextInputType? keyBoardType;
  final Function()? onTap;
  final Function(String)? onTextChanged;
  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  // Add this line
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: widget.onTap,
      initialValue: widget.initialvalue,
      keyboardType: widget.keyBoardType,
      obscureText: widget.ofsecuretext == null ? false : widget.ofsecuretext!,
      controller: widget.controller,
      decoration: InputDecoration(labelText: widget.hintText),
      onChanged: widget.onTextChanged, // Add this line
    );
  }
}
