import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../models/purohithusers.dart' as purohith;
import '../providers/categorynotifier.dart';
import '../providers/purohithnotifier.dart';
import '../providers/userprofiledatanotifier.dart';
import '../providers/zegeocloudprovider.dart';
import '../widgets/appbar.dart';
import '../widgets/category_grid.dart';
import '../widgets/user_list.dart';

class CatScreen extends ConsumerStatefulWidget {
  const CatScreen({super.key});

  @override
  ConsumerState<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends ConsumerState<CatScreen> {
  String catname = '';
  String billingMode = '';
  bool shouldWatchData = true;
  @override
  void initState() {
    super.initState();

    initCatScreen();
  }

  void initCatScreen() {
    Future.microtask(() async {
      var index = ModalRoute.of(context)!.settings.arguments as Map;
      catname = index['cat name'];
      final purohithNotifier = ref.read(purohithNotifierProvider);
      // Check if data is already available
      if (purohithNotifier.data != null && purohithNotifier.data!.isNotEmpty) {
        shouldWatchData = false; // Data is available, no need to watch
      } else {
        await ref
            .read(purohithNotifierProvider.notifier)
            .getPurohit(context, ref);
        shouldWatchData = true; // Watch for data updates
      }
      var userDetails = ref.read(userProfileDataProvider);
      // Future.delayed(Duration.zero).then((value) => ref
      //     .read(zegeoCloudNotifierProvider.notifier)
      //     .onUserLogin(
      //         userDetails.data![0].id.toString(),
      //         userDetails.data![0].username!,
      //         context,
      //         catname,
      //         billingMode,
      //         ref));
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ModalRoute.of(context)!.settings.arguments as Map;
    final fbuser = FirebaseAuth.instance.currentUser;
    final uid = fbuser?.uid;
    catname = index['cat name'];
    billingMode = index['billingMode'];

    // List subcat = index['id']['subcat'];
    var productId = index['id'];
    // var catogaries = Provider.of<ApiCalls>(context);
    final DatabaseReference firebaseRealtimeUsersRef =
        FirebaseDatabase.instance.ref().child('presence');
    final DatabaseReference firebaseRealtimeWalletRef =
        FirebaseDatabase.instance.ref().child('wallet');

    return Scaffold(
      appBar: purohithAppBar(context, index['cat name']),
      body: index['cattype'] == 'b'
          ? Consumer(builder: (context, ref, child) {
              List<Data> allCategories = ref.read(categoryProvider).categories;

              // Flatten the list of subcategories into a single list
              List<SubCategory> allSubcategories = allCategories
                  .where((category) =>
                      category.subcat != null && category.subcat!.isNotEmpty)
                  .expand((category) => category.subcat!)
                  .toList();

              // Iterate over each category, filter and add their subcategories to the list

              return CategoryGrid(
                  subcat: allSubcategories, cattype: index['cattype']);
            })
          : Consumer(
              builder: (con, ref, child) {
                List<purohith.Data> users = [];

                final purohithState = shouldWatchData
                    ? ref.watch(purohithNotifierProvider)
                    : ref.read(purohithNotifierProvider);
                if (purohithState.data != null) {
                  // Data is available
                  users = purohithState.data!;

                  // ... Use filteredUsers for your UI
                } else {
                  return const Center(child: CircularProgressIndicator());
                }

                return UserList(
                    catname: catname,
                    users: users,
                    firebaseRealtimeUsersRef: firebaseRealtimeUsersRef,
                    firebaseRealtimeWalletRef: firebaseRealtimeWalletRef,
                    uid: uid,
                    productId: productId,
                    billingMode: billingMode,
                    cattype: index['cattype']);
              },
            ),
    );
  }
}
