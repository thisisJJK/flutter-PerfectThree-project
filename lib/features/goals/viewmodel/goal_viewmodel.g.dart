// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goalViewModelHash() => r'77d72dcaaabb423c126b4aecc4dfb6e1b98b9f1a';

/// [GoalViewModel]
/// 목표 리스트의 상태를 관리하고, 핵심 비즈니스 로직(3일 체크, 리셋 등)을 수행합니다.
///
/// Copied from [GoalViewModel].
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
