import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/loader.dart';
import '../providers/phoneauthnotifier.dart';
import '/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

    // Responsive sizing that works on web and mobile
    double maxWidth = kIsWeb ? 600 : screenWidth * 0.95;
    double imageSize = kIsWeb ? 150 : screenWidth * 0.4;
    double horizontalPadding = kIsWeb ? 40 : 20;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
      ),
      body: Center(
        child: Container(
          width: maxWidth,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content up slightly
              const Spacer(flex: 1),

              // Logo/Icon
              Container(
                width: imageSize,
                height: imageSize,
                child: Image.asset(
                  "assets/icon.png",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // Title and Input Section
              Column(
                children: [
                  const Text(
                    "Enter Your Phone Number",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Phone Input
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      controller: phonecontroler,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "IN +91 ",
                        labelText: "Phone number",
                        hintText: "Enter your phone number",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Button Section
              Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(loadingProvider);

                  return Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                          minHeight: 50,
                        ),
                        width: double.infinity,
                        child: isLoading
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : Button(
                          width: double.infinity,
                          buttonname: button,
                          onTap: () {
                            ref.read(phoneAuthProvider.notifier).phoneAuth(
                              context,
                              "+91${phonecontroler.text.trim()}",
                              ref,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Container(
                        width: kIsWeb ? 200 : screenWidth * 0.4,
                        height: 3,
                        color: Colors.black,
                      ),
                    ],
                  );
                },
              ),

              // Bottom spacer
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}