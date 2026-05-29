import 'package:flutter_riverpod/flutter_riverpod.dart';

// 0: Home, 1: Map, 2: Settings
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);