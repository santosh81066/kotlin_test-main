import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/authnotifier.dart';
import '../providers/userprofiledatanotifier.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final userProfileData = ref.watch(userProfileDataProvider);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<File?>(
                  future: ref
                      .read(userProfileDataProvider.notifier)
                      .getImageFile(context),
                  builder:
                      (BuildContext context, AsyncSnapshot<File?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final file = snapshot.data!;
                        return CircleAvatar(
                          radius: 50.0,
                          backgroundImage: FileImage(file),
                        );
                      } else {
                        return const CircleAvatar(
                          radius: 50.0,
                          child: Icon(Icons.person, size: 50.0),
                        );
                      }
                    } else {
                      return const CircleAvatar(
                        radius: 50.0,
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    userProfileData.data![0].username!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('saveprofile');
                  },
                  leading: const Icon(Icons.person_outlined,
                      color: Color(0xFFF5C662)),
                  title: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Edit Profile'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('register');
                  },
                  leading: Icon(Icons.handshake, color: Color(0xFFF5C662)),
                  title: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Become A Purohith'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "wallet");
                  },
                  leading:
                      Icon(Icons.person_outlined, color: Color(0xFFF5C662)),
                  title: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Reacharge Your Wallet'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('Customer Care');
                  },
                  leading:
                      const Icon(Icons.support_agent, color: Color(0xFFF5C662)),
                  title: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Help Center'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  onTap: () async {
                    // Navigator.of(context).pushReplacementNamed('/');
                    await ref.read(authProvider.notifier).logout().then(
                        (value) => Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                                '/', (Route<dynamic> route) => false));
                  },
                  leading: Icon(Icons.exit_to_app, color: Color(0xFFF5C662)),
                  title: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Logout'),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
