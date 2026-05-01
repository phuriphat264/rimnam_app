import 'package:flutter_riverpod/flutter_riverpod.dart';

// 0: Home, 1: Map, 2: Mission (Places), 3: Profile
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);