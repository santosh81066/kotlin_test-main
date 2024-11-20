import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../providers/loader.dart';
import '../providers/phoneauthnotifier.dart';
import '/widgets/button.dart';
import 'package:flutter/material.dart';

class Otp extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  const Otp({super.key, this.scaffoldMessengerKey});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  TextEditingController phonecontroler = TextEditingController();
  String button = 'Send otp';

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    // Calculate width and height based on screen size
    double imageWidth = screenSize.width * 0.5; // 50% of screen width
    double imageHeight = screenSize.height * 0.25;
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black,
              ),
              onPressed: () {})),
      body: SingleChildScrollView(
          child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenSize.height * 0.95),
        child: IntrinsicHeight(
            child: Center(
          child: SizedBox(
            width: screenSize.width * 0.95,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  "assets/icon.png",
                  width: imageWidth,
                  height: imageHeight,
                ),
                Container(
                  child: Column(
                    children: [
                      const Text(
                        "Enter Your Phone Number",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          controller: phonecontroler,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixText: "IN +91",
                              label: Text("IN +91 phone number")),
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, value, child) {
                    final isLoading = value.watch(loadingProvider);
                    //print(value.isloading);
                    return isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Button(
                                width: double.infinity,
                                buttonname: button,
                                onTap: isLoading
                                    ? null
                                    : () {
                                        //print(value.isloading);
                                        value
                                            .read(phoneAuthProvider.notifier)
                                            .phoneAuth(
                                                context,
                                                "+91${phonecontroler.text}"
                                                    .toString()
                                                    .trim(),
                                                value);

                                        //print(value.isloading);
                                      },
                              ),
                              Divider(
                                thickness: screenSize.height * 0.006,
                                indent: screenSize.width * 0.3,
                                endIndent: screenSize.width * 0.3,
                                color: Colors.black,
                              )
                            ],
                          );
                  },
                ),
              ],
            ),
          ),
        )),
      )),
    );
  }
}
