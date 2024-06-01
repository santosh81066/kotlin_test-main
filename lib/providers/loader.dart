// Inside a new or existing Dart file (e.g., lib/providers/loading_provider.dart)
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = StateProvider<bool>((ref) => false);
final secondLoadingProvider = StateProvider<bool>((ref) => false);
