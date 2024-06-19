import 'dart:io';

import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/authnotifier.dart';
import '../providers/userprofiledatanotifier.dart';
import '/models/categories.dart';
import '/models/purohithusers.dart' as purohith;
import '/providers/carouselstatenotifier.dart';
import '/providers/categorynotifier.dart';
import '/providers/purohithnotifier.dart';

import '../models/carouselimages.dart' as carousel;
import '../utils/purohitapi.dart';

class Categories extends ConsumerWidget {
  const Categories({
    Key? key,
    required this.call,
    required this.images,
  }) : super(key: key);

  final List<Data> call;
  final List<carousel.Data> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // for (var i = 0; i < call.length; i++)
    //   if (call[i].cattype == "b") {
    //     Consumer(builder: (context, ref, child) {
    //       List<Data> allCategories = ref.read(categoryProvider).categories;

    //       // Flatten the list of subcategories into a single list
    //       List<SubCategory> allSubcategories = allCategories
    //           .where((category) =>
    //               category.subcat != null && category.subcat!.isNotEmpty)
    //           .expand((category) => category.subcat!)
    //           .toList();

    //       // Iterate over each category, filter and add their subcategories to the list

    //       return CategoryListView(
    //           subcat: allSubcategories, cattype: call[i].cattype.toString());
    //     });
    //   } else {
    //     return Text("no data");
    //   }
    List<SubCategory> allSubcategories = call
        .where((category) =>
            category.cattype == "b" &&
            category.subcat != null &&
            category.subcat!.isNotEmpty)
        .expand((category) => category.subcat!)
        .toList();

    List<purohith.Data> users = [];

    final purohithState = ref.watch(purohithNotifierProvider);

    if (purohithState.data != null) {
      // Data is available
      users = purohithState.data!;

      // ... Use filteredUsers for your UI
    } else {
      return Center(child: CircularProgressIndicator());
    }
    var top = {for (var obj in users) obj.id: obj};
    List<purohith.Data> topSet = top.values.toList();
    List<purohith.Data> topFive = topSet.sublist(0, 5);

    //var catogaries = Provider.of<ApiCalls>(context);
    var filteredCall = call.where((item) => item.cattype != 'e').toList();
    var events = call.where((item) => item.cattype == 'e').toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final images =
                  ref.watch(carouselStateProvider).carousel?.data ?? [];
              return images.isEmpty
                  ? CircularProgressIndicator()
                  : CarouselSlider(
                      items: images.map((data) {
                        //      print(data.xfile!.path.isEmpty ? 'no image' : data.xfile!.path);
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: data.xfile != null
                                ? DecorationImage(
                                    image: FileImage(File(data.xfile!.path)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 180.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        viewportFraction: 0.8,
                      ),
                    );
            },
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Purohithlu On Demand",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: topFive.length,
                          itemBuilder: ((context, index) {
                            return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, 'catscreen',
                                      arguments: {
                                        'cattype': call[index].cattype,
                                        'id': call[index].id,
                                        'cat name': call[index].title,
                                        'billingMode': call[index].billingMode,
                                      });
                                },
                                child: _buildProfileCard(topFive[index], call));
                          })),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Consumer(builder: (context, ref, child) {
            var categories = ref.watch(categoryProvider);
            return Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Interact With Purohotulu For",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Consumer(builder: (context, ref, child) {
                    var categories = ref.watch(categoryProvider);
                    return Column(
                      children: [
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: filteredCall.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, 'catscreen',
                                        arguments: {
                                          'cattype': call[index].cattype,
                                          'id': call[index].id,
                                          'cat name': call[index].title,
                                          'billingMode':
                                              call[index].billingMode,
                                        });
                                  },
                                  child: _buildCategoryCard(
                                    categories.categories[index],
                                    filteredCall[index],
                                  ),
                                );
                              }
                              // Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Text("Astrology"),
                              //     )
                              ),
                        )
                      ],
                    );
                  })
                ],
              ),
            );
          }),
          SizedBox(
            height: 20,
          ),
          Consumer(builder: (context, ref, child) {
            return Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Trending Pooja's",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Consumer(builder: (context, ref, child) {
                    var categories = ref.watch(categoryProvider);
                    return Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: allSubcategories.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, "subcatscreen",
                                        arguments: {
                                          'parentid':
                                              allSubcategories[index].parentid,
                                          'id': allSubcategories[index].id,
                                          'title':
                                              allSubcategories[index].title,
                                          'cattype':
                                              allSubcategories[index].cattype,
                                          'price':
                                              allSubcategories[index].price,
                                        });
                                  },
                                  child: Container(
                                    width: 100,
                                    child: Column(
                                      children: [
                                        Card(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              side: BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 96, 95, 95),
                                                  width: 0.8)),
                                          child: Container(
                                            width: 100,
                                            height: 130,
                                            padding: EdgeInsets.all(8),
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(
                                                  "${PurohitApi().baseUrl}${PurohitApi().getCatImage}${allSubcategories[index].id}",
                                                  // headers: {"Authorization": token.accessToken!},
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          allSubcategories[index].title!,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    );
                  })
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  _buildProfileCard(
    purohith.Data user,
    List<Data> call,
  ) {
    var category = call
        .where(
          (element) => element.id == user.catid,
        )
        .toList();
    // String categoryTitle =
    //     category.isNotEmpty ? category[0].title ?? "No Title" : "No Category";
    // print("list :$category,$categoryTitle");
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Color.fromARGB(255, 96, 95, 95), width: 0.8)),
      child: Container(
        width: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final authNotifier = ref.watch(authProvider);
                return CircleAvatar(
                  radius: 30,
                  backgroundImage: user.profilepic != null
                      ? NetworkImage(
                          "${PurohitApi().baseUrl}${PurohitApi().purohithDp}${user.id}",
                          headers: {"Authorization": authNotifier.accessToken!},
                        )
                      : const AssetImage('assets/icon.png')
                          as ImageProvider<Object>,
                  // Optionally, you can add a radius or other styling properties here
                );
              },
            ),

            Text(
              user.username ?? "",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            for (var cat in category) Text("(${cat.id})"),
            // Text(user.role ?? ""),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.orange,
                ),
                Text("4.8(1948)"),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // handleCallTap(
                //     context, ref, user, walletAmount, productId, fcmToken);
              },
              child: Text("View details"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5C662),
                  foregroundColor: Colors.black),
            )
          ],
        ),
      ),
    );
  }

  _buildCategoryCard(Data categori, Data filteredCall) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                  color: Color.fromARGB(255, 96, 95, 95), width: 0.8)),
          child: Container(
            width: 100,
            height: 130,
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: categori.xfile != null
                  ? FileImage(File(categori.xfile!.path))
                  : const AssetImage('assets/placeholder.png')
                      as ImageProvider<Object>, // Placeholder image
            ),
          ),
        ),
        Text(
          filteredCall.title ?? "",
        )
      ],
    );
  }
}
