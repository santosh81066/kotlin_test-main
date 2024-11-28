import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../widgets/appbar.dart';
import '../widgets/button.dart';
import '../widgets/text_widget.dart';

class Wallet extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  const Wallet({super.key, this.scaffoldMessengerKey});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  TextEditingController amt = TextEditingController();
  late Razorpay razorpay;
  String amount = 'Add amount to wallet';
  String balance = 'balance ₹100';

  final fbuser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    razorpay.clear();
    amt.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final scaffoldKey = widget.scaffoldMessengerKey?.currentState;

    if (scaffoldKey != null) {
      scaffoldKey.showSnackBar(SnackBar(
        content: Text('Payment successful: ${response.paymentId}'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.green,
      ));
    }

    // Capture the payment to avoid it being refunded
    try {
      await capturePayment(
          response.paymentId!, (num.parse(amt.text) * 100).toInt());
    } catch (e) {
      if (scaffoldKey != null) {
        scaffoldKey.showSnackBar(SnackBar(
          content: Text('Error capturing payment: $e'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    // Update user's wallet in Firebase
    final uid = fbuser?.uid;
    if (uid != null) {
      try {
        final userDataSnapshot =
        await databaseReference.child('wallet').child(uid).once();
        int? walletamount = int.tryParse(amt.text.trim());

        if (walletamount != null) {
          if (userDataSnapshot.snapshot.value == null) {
            // User wallet does not exist, create new wallet with amount
            await databaseReference.child('wallet').child(uid).set({'amount': walletamount});
          } else {
            // User wallet exists, update the amount
            var currentAmount = (userDataSnapshot.snapshot.value as Map)['amount'] ?? 0;
            await databaseReference.child('wallet').child(uid).update({'amount': currentAmount + walletamount});
          }
        }
      } catch (e) {
        if (scaffoldKey != null) {
          scaffoldKey.showSnackBar(SnackBar(
            content: Text('Error updating wallet balance: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final scaffoldKey = widget.scaffoldMessengerKey?.currentState;
    if (scaffoldKey != null) {
      scaffoldKey.showSnackBar(SnackBar(
        content: Text('Payment failed: ${response.message}'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final scaffoldKey = widget.scaffoldMessengerKey?.currentState;
    if (scaffoldKey != null) {
      scaffoldKey.showSnackBar(SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.green,
      ));
    }
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_live_pO1cUwo4WWYNyt',
      // Replace with your live key or test key
      'amount': (num.parse(amt.text) * 100).toInt(),
      // Razorpay accepts amount in paise
      'name': 'Purohithulu',
      'description': 'Wallet Payment',
      'prefill': {
        'contact': '9502105833', // Replace with user's contact
        'email': 'manjunadh043@gmail.com' // Replace with user's email
      }
    };
    try {
      razorpay.open(options);
    } catch (e) {
      final scaffoldKey = widget.scaffoldMessengerKey?.currentState;
      if (scaffoldKey != null) {
        scaffoldKey.showSnackBar(SnackBar(
          content: Text('Error opening Razorpay: $e'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> capturePayment(String paymentId, int amount) async {
    final basicAuth = 'Basic ' +
        base64Encode(utf8.encode('rzp_live_pO1cUwo4WWYNyt:p05Q1dXqlqU7Dak20EtKUvUw')); // Replace with your API Key and Secret
    final url = 'https://api.razorpay.com/v1/payments/$paymentId/capture';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'amount': amount, // The amount must be in paise
      }),
    );

    if (response.statusCode == 200) {
      // Payment captured successfully
      print('Payment captured successfully');
    } else {
      // Failed to capture payment
      throw Exception('Failed to capture payment: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: purohithAppBar(context, 'Wallet'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var amount in [100, 200, 300, 400, 500, 1000])
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            amt.text = amount.toString();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.currency_rupee,
                                  size: 30,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  amount.toString(),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextWidget(
                  controller: amt,
                  hintText: amount,
                ),
              ],
            ),
            Button(
              onTap: () {
                openCheckout();
              },
              buttonname: "Add Amount",
            )
          ],
        ),
      ),
    );
  }
}
