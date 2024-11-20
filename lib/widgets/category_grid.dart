import 'package:flutter/material.dart';

import '../models/categories.dart';
import '../utils/purohitapi.dart';

class CategoryGrid extends StatelessWidget {
  final List<SubCategory> subcat;
  final String cattype;

  const CategoryGrid({super.key, required this.subcat, required this.cattype});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      shrinkWrap: true,
      itemCount: subcat.length,
      itemBuilder: (con, index) {
        print('sub cat price:${subcat[index].price}');
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "subcatscreen", arguments: {
              'parentid': subcat[index].parentid,
              'id': subcat[index].id,
              'title': subcat[index].title,
              'price': subcat[index].price,
              'cattype': cattype
            });
          },
          child: Card(
            color: const Color.fromARGB(255, 249, 191, 66),
            child: Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                        "${PurohitApi().baseUrl}${PurohitApi().getCatImage}${subcat[index].id}",
                        // headers: {"Authorization": token.accessToken!},
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    subcat[index].title!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
