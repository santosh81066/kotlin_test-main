import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final String mobileNo = "+916303344050";

  final String emailId = "info.purohiithulu@gmail.com";
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Care'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildCard(Icons.phone, 'Call us', mobileNo,
                  onPressed: () => makePhoneCall(mobileNo)),
              const SizedBox(height: 20.0),
              _buildCard(
                Icons.email,
                'Email us',
                emailId,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String text,
      {VoidCallback? onPressed}) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 50.0,
          color: Colors.blue,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20.0),
        ),
        subtitle: Text(
          text,
          style: const TextStyle(fontSize: 16.0),
        ),
        onTap: () {
          if (onPressed != null) {
            onPressed.call();
          }
        },
      ),
    );
  }
}
