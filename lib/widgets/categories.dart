import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/authnotifier.dart';
import '/models/categories.dart';
import '/models/purohithusers.dart' as purohith;
import '/providers/carouselstatenotifier.dart';
import '/providers/categorynotifier.dart';
import '/providers/purohithnotifier.dart';
import '../models/carouselimages.dart' as carousel;
import '../utils/purohitapi.dart';

class Categories extends ConsumerWidget {
  const Categories({
    super.key,
    required this.call,
    required this.images,
  });

  final List<Data> call;
  final List<carousel.Data> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter subcategories with cattype "b" and main categories with cattype "e"
    List<SubCategory> subcategoriesTypeB = call
        .where((category) =>
            category.cattype == "b" &&
            category.subcat != null &&
            category.subcat!.isNotEmpty)
        .expand((category) => category.subcat!)
        .toList();

    List<Data> categoriesTypeE = call
        .where((category) =>
            category.cattype == "e" &&
            (category.subcat == null || category.subcat!.isEmpty))
        .toList();

    List<purohith.Data> users = [];
    final purohithState = ref.watch(purohithNotifierProvider);

    if (purohithState.data != null) {
      // Data is available
      users = purohithState.data!;
    } else {
      return const Center(child: CircularProgressIndicator());
    }

    var top = {for (var obj in users) obj.id: obj};
    List<purohith.Data> topSet = top.values.toList();
    List<purohith.Data> topFive = topSet.sublist(0, 5);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final images =
                  ref.watch(carouselStateProvider).carousel?.data ?? [];
              return images.isEmpty
                  ? const CircularProgressIndicator()
                  : CarouselSlider(
                      items: images.map((data) {
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
                const Text(
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
                            return _buildProfileCard(
                                topFive[index],
                                call,
                                context,
                                call[index].cattype!,
                                call[index].id!.toString(),
                                call[index].price == null
                                    ? 0
                                    : call[index].price!);
                          })),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Consumer(builder: (context, ref, child) {
            var categories = ref.watch(categoryProvider);
            return Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Categories",
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
                              itemCount: categories.categories.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    if (categories.categories[index].cattype ==
                                        'e') {
                                      Navigator.pushNamed(context, "events",
                                          arguments: {
                                            'id':
                                                categories.categories[index].id,
                                            'title': categories
                                                .categories[index].title,
                                            'price': categories
                                                .categories[index].price,
                                          });
                                    } else {
                                      Navigator.pushNamed(context, 'catscreen',
                                          arguments: {
                                            'cattype': categories
                                                .categories[index].cattype,
                                            'id':
                                                categories.categories[index].id,
                                            'cat name': categories
                                                .categories[index].title,
                                            'billingMode': categories
                                                .categories[index].billingMode,
                                          });
                                    }
                                  },
                                  child: _buildCategoryCard(
                                    categories.categories[index],
                                    call[index],
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
          }),
          const SizedBox(
            height: 20,
          ),
          Consumer(builder: (context, ref, child) {
            return Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Trending Pooja's",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Consumer(builder: (context, ref, child) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: subcategoriesTypeB.length,
                              itemBuilder: (context, index) {
                                final subcategory = subcategoriesTypeB[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, "subcatscreen",
                                        arguments: {
                                          'parentid': subcategory.parentid,
                                          'id': subcategory.id,
                                          'title': subcategory.title,
                                          'cattype': subcategory.cattype,
                                          'price': subcategory.price,
                                        });
                                  },
                                  child: SizedBox(
                                    width: 100,
                                    child: Column(
                                      children: [
                                        Card(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              side: const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 96, 95, 95),
                                                  width: 0.8)),
                                          child: Container(
                                            width: 100,
                                            height: 130,
                                            padding: const EdgeInsets.all(8),
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(
                                                  "${PurohitApi().baseUrl}${PurohitApi().getCatImage}${subcategory.id}",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          subcategory.title!,
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

  _buildProfileCard(purohith.Data user, List<Data> call, BuildContext context,
      String cattype, String productId, int amt) {
    var category = call
        .where(
          (element) => element.id == user.catid,
        )
        .toList();
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color.fromARGB(255, 96, 95, 95), width: 0.8)),
      child: SizedBox(
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
                        )
                      : const AssetImage('assets/icon.png')
                          as ImageProvider<Object>,
                );
              },
            ),
            Text(
              user.username ?? "",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            for (var cat in category) Text("(${cat.id})"),
            const Row(
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
                Navigator.of(context).pushNamed('profileDetails', arguments: {
                  'url':
                      "${PurohitApi().baseUrl}${PurohitApi().purohithDp}${user.id}",
                  'amount': amt,
                  'cattype': cattype,
                  'user': user,
                  'productId': productId,
                  'mobileNo': user.mobileno
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5C662),
                  foregroundColor: Colors.black),
              child: const Text("View details"),
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
              side: const BorderSide(
                  color: Color.fromARGB(255, 96, 95, 95), width: 0.8)),
          child: Container(
            width: 100,
            height: 130,
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: categori.xfile != null
                  ? FileImage(File(categori.xfile!.path))
                  : const AssetImage('assets/placeholder.png')
                      as ImageProvider<Object>,
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
