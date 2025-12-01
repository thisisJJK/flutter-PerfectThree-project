// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goalViewModelHash() => r'b01beaee46bbb10def22cdb7a559dcc21e1ac07b';

/// See also [GoalViewModel].
@ProviderFor(GoalViewModel)
final goalViewModelProvider =
    AutoDisposeAsyncNotifierProvider<GoalViewModel, List<Goal>>.internal(
  GoalViewModel.new,
  name: r'goalViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goalViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GoalViewModel = AutoDisposeAsyncNotifier<List<Goal>>;
String _$categoryFilterHash() => r'ae890aa12c2fab2c05c038fbd93078c64a822e60';

/// See also [CategoryFilter].
@ProviderFor(CategoryFilter)
final categoryFilterProvider =
    AutoDisposeNotifierProvider<CategoryFilter, String>.internal(
  CategoryFilter.new,
  name: r'categoryFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoryFilter = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
