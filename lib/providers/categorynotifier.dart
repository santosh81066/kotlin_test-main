import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as htt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/retry.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/categories.dart';
import '../models/categorystate.dart';
import '../utils/purohitapi.dart';
import 'authnotifier.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  final AuthNotifier authNotifier;

  CategoryNotifier(this.authNotifier) : super(CategoryState());

  get http => null;

  Future<void> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final url = PurohitApi().baseUrl +
        PurohitApi().getcategory; // Replace with your actual URL
    final token =
        authNotifier.state.accessToken; // Replace with how you access the token
    final savedCategoriesJson = prefs.getString('categoryData');
    if (savedCategoriesJson != null) {
      List<dynamic> savedCategories = json.decode(savedCategoriesJson);
      List<Data> newCategories = savedCategories
          .map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(categories: newCategories);
      updateCategoryImages();
      return;
    }
    final client = RetryClient(
      htt.Client(),
      retries: 4,
      when: (response) {
        return response.statusCode == 401 ? true : false;
      },
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && res?.statusCode == 401) {
          // Here, handle your token restoration logic
          // You can access other providers using ref.read if needed
          var accessToken = await authNotifier.restoreAccessToken();

          //print(accessToken); // Replace with actual token restoration logic
          req.headers['Authorization'] = accessToken.toString();
        }
      },
    );

    try {
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!,
        },
      );
      print('${response.body}');
      if (response.statusCode == 200) {
        Map<String, dynamic> categoryTypes = json.decode(response.body);
        // print('all categories: ${categoryTypes['data']['price']}');
        await prefs.setString(
            'categoryData', json.encode(categoryTypes['data']));

        if (categoryTypes['data'] != null) {
          List<Data> newCategories = (categoryTypes['data'] as List)
              .map((e) => Data.fromJson(e as Map<String, dynamic>))
              .toList(); // Assuming this is a List
          // Assuming you have a model for carousel data

          state = state.copyWith(categories: newCategories);
          updateCategoryImages();
        }
      }
    } finally {
      client.close();
    }
  }

  Future<void> updateCategoryImages() async {
    List<Data> updatedCategories = [];
    for (var category in state.categories) {
      // Fetch and set the image for each category
      XFile? categoryImage =
          await getCategoryImage(category.id!, authNotifier.state.accessToken!);
      updatedCategories.add(category.copyWith(xfile: categoryImage));
    }
    state = state.copyWith(categories: updatedCategories);
  }

  Future<XFile> getCategoryImage(int categoryId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'categoryImage_$categoryId';
    final cachedImagePath = prefs.getString(key);

    if (cachedImagePath != null) {
      // Load image from file path
      return XFile(cachedImagePath);
    } else {
      // Fetch image from API and cache it
      final url =
          "${PurohitApi().baseUrl}${PurohitApi().getCatImage}$categoryId";
      final client = RetryClient(
        htt.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            // Here, handle your token restoration logic
            // You can access other providers using ref.read if needed
            var accessToken = await authNotifier.restoreAccessToken();

            //print(accessToken); // Replace with actual token restoration logic
            req.headers['Authorization'] = accessToken.toString();
          }
        },
      );
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/categoryImage_$categoryId');
        await file.writeAsBytes(bytes);
        await prefs.setString(key, file.path);
        return XFile(file.path);
      } else {
        // Handle error or return a placeholder XFile
        return XFile('path_to_placeholder_image'); // Placeholder image path
      }
    }
  }

  List<Data> getFilteredCategories(String filter) {
    return state.categories.where((category) {
      return category.cattype != filter;
    }).toList();
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return CategoryNotifier(authNotifier);
});
