import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/events.dart';
import '/providers/loader.dart';
import '/widgets/button.dart';

class EventCard extends StatelessWidget {
  final EventData event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8.0),
                ),
                image: DecorationImage(
                  image: event.xfile != null
                      ? FileImage(File(event.xfile!.path))
                      : Image.asset("assets/icon.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    event.eventName ?? '',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    event.dateAndTime ?? '',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8.0),
                  _buildDetailsColumn(
                    label: 'Amount',
                    value: event.amount?.toString() ?? '',
                  ),
                  _buildDetailsColumn(
                    label: 'Address',
                    value: event.address ?? '',
                  ),
                  _buildDetailsColumn(
                    label: 'Description',
                    value: event.description ?? '',
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      var isLoading = ref.read(loadingProvider);
                      return Button(
                        buttonname: 'book',
                        onTap: isLoading
                            ? null
                            : () {
                                Navigator.of(context)
                                    .pushNamed('eventForm', arguments: {
                                  'catid': event.catid,
                                  'address': event.address,
                                  'dateAndTime': event.dateAndTime,
                                  'amount': event.amount
                                });
                              },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // This line is important
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14.0,
              ),
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
