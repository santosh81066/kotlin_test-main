import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../providers/authnotifier.dart';
import '../providers/userprofiledatanotifier.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  var userDetails = ref.read(userProfileDataProvider);
                  return Row(
                    children: [
                      Text(userDetails.data == null
                          ? ''
                          : 'Welcome: ${userDetails.data![0].username} '),
                      FutureBuilder<File?>(
                        future: ref
                            .read(userProfileDataProvider.notifier)
                            .getImageFile(context),
                        builder: (BuildContext context,
                            AsyncSnapshot<File?> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
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
                    ],
                  );
                },
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("My Profile"),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("drawer", true);
              Navigator.pop(context);
              // Navigator.of(context).pushReplacementNamed('/');
              Navigator.of(context).pushNamed('saveprofile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.handshake),
            title: const Text("Become a purohith"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('register');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Customer Care"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('Customer Care');
            },
          ),
          const Divider(),
          Consumer(
            builder: (context, ref, child) {
              return ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Logout"),
                onTap: () async {
                  // Navigator.of(context).pushReplacementNamed('/');
                  await ref.read(authProvider.notifier).logout().then((value) =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', (Route<dynamic> route) => false));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
