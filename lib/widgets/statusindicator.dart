import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final ValueNotifier<bool> statusNotifier;

  const StatusIndicator(this.statusNotifier, {super.key});

  @override
  Widget build(BuildContext context) {
    bool status = statusNotifier.value;

    return Row(
      children: <Widget>[
        Container(
          height: 20.0, // Adjust size as needed
          width: 20.0, // Adjust size as needed
          decoration: BoxDecoration(
            color: status == false ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10), // For spacing
        Text(
          status == false ? '' : 'Busy',
          style: const TextStyle(fontSize: 16), // Adjust text styling as needed
        ),
      ],
    );
  }
}
