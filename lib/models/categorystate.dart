import '../models/carouselimages.dart' as slider;


import 'categories.dart';

class CategoryState {
  final List<Data> categories;
  final slider.SliderImages? carousel;

  CategoryState({this.categories = const [], this.carousel});

  // Add a method to copy the state with new values
  CategoryState copyWith({
    List<Data>? categories,
    slider.SliderImages? carousel,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      carousel: carousel ?? this.carousel,
    );
  }
}
