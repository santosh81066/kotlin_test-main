import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? buttonname;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? buttonTopMargin;
  final double? buttonBottomMargin;
  final double? buttonRightMargin;
  final double? buttonLeftMargin;
  final double? circularRadius;
  const Button(
      {Key? key,
      this.buttonBottomMargin = 15,
      this.buttonname,
      this.onTap,
      this.height = 50,
      this.width, //140
      this.fontSize = 20,
      this.buttonTopMargin = 15,
      this.buttonLeftMargin = 15,
      this.buttonRightMargin = 15,
      this.circularRadius = 30})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: buttonTopMargin!,
          bottom: buttonBottomMargin!,
          left: buttonLeftMargin!,
          right: buttonRightMargin!),
      height: height,
      width: width,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [Colors.blue.shade700, Colors.blue.shade500],
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //   ),
      //   borderRadius: BorderRadius.circular(circularRadius!),
      // ),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF5C662),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3))),
          onPressed: onTap,
          child: ListTile(
            title: Text(
              buttonname!,
              textAlign: TextAlign.center,
            ),
            trailing: Icon(Icons.arrow_forward_sharp),
          )),
    );
  }
}
