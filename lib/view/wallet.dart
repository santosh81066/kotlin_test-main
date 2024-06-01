import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


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
    super.dispose();
    amt.dispose();
    razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final ScaffoldMessengerState scaffoldKey =
        widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
    scaffoldKey.showSnackBar(SnackBar(
      content: Text('${response.paymentId}'),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.green,
    ));
    final uid = fbuser?.uid;
    final userDataSnapshot =
        await databaseReference.child('wallet').child(uid!).once();
    int? walletamount = int.tryParse(amt.text.trim());
    if (userDataSnapshot.snapshot.value == null) {
      await databaseReference
          .child('wallet')
          .child(uid)
          .set({'amount': walletamount});
    } else {
      var currentAmount = (userDataSnapshot.snapshot.value
              as Map<dynamic, dynamic>)['amount'] ??
          0;
      await databaseReference
          .child('wallet')
          .child(uid)
          .update({'amount': currentAmount + walletamount});
    }
    // try {
    //   if (fbuser == null) {}
    //   await _firestore.runTransaction((transaction) async {
    //     DocumentReference userDocRef =
    //         _firestore.collection('users').doc(fbuser!.uid);
    //     DocumentSnapshot userSnapshot = await transaction.get(userDocRef);

    //     if (userSnapshot.exists) {
    //       // Update the existing document with the new wallet balance
    //       Map<String, dynamic> userData =
    //           userSnapshot.data() as Map<String, dynamic>;
    //       int currentBalance = int.parse(userData['wallet'].toString());

    //       int updatedBalance = currentBalance + int.parse(amt.text.trim());
    //       transaction.update(userDocRef, {'wallet': updatedBalance});
    //     } else {
    //       // Create a new document with the initial wallet balance
    //       transaction.set(userDocRef, {
    //         'wallet': amt.text.trim(),
    //         'id': apicalls.userDetails!.data![0].id,
    //         // Add more fields if needed
    //       });
    //     }
    //   });
    // } catch (e) {}
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final ScaffoldMessengerState scaffoldKey =
        widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
    scaffoldKey.showSnackBar(SnackBar(
      content: Text('${response.message}'),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.red,
    ));
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final ScaffoldMessengerState scaffoldKey =
        widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
    scaffoldKey.showSnackBar(SnackBar(
      content: Text('${response.walletName}'),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.green,
    ));
    // Do something when an external wallet was selected
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
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "100";
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "100",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "200";
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "200",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "300";
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "300",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "400";
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "400",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "500";
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "500",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "1000";
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "1000",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
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
                buttonname: "Add Amount")
          ],
        ),
      ),
    );
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_live_C8yj1yxpYihWIJ',
      'amount': num.parse(amt.text) * 100,
      'name': 'Purohithulu',
      'description': 'wallet',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
    };
    razorpay.open(options);
  }
}
