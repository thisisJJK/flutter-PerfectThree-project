// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationRepositoryHash() =>
    r'183da36292cdbb86e1cb1b451530f2b430f5069f';

/// See also [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    Provider<NotificationRepository>.internal(
      notificationRepository,
      name: r'notificationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef NotificationRepositoryRef = ProviderRef<NotificationRepository>;
String _$notificationServiceHash() =>
    r'015117d47fe71bf44664bf802ad1290b1e2492d4';

/// See also [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationServiceRef = ProviderRef<NotificationService>;
String _$notificationSettingsViewModelHash() =>
    r'a2e58edc95378835f40d18c317a21dff29b8cee2';

/// See also [NotificationSettingsViewModel].
@ProviderFor(NotificationSettingsViewModel)
final notificationSettingsViewModelProvider =
    AutoDisposeNotifierProvider<
      NotificationSettingsViewModel,
      NotificationSettings
    >.internal(
      NotificationSettingsViewModel.new,
      name: r'notificationSettingsViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationSettingsViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationSettingsViewModel =
    AutoDisposeNotifier<NotificationSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
