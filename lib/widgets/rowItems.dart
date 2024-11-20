import 'package:flutter/material.dart';

class RowItems extends StatelessWidget {
  const RowItems({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    Size screensize = MediaQuery.of(context).size;
    double screenWidth = screensize.width;
    return Container(
      alignment: Alignment.center,
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.orange,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 10),
          )
        ],
      ),
    );
  }
}
