import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/settings/view/notification_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '준비 중',
          style: Font.main.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$feature 기능은 곧 출시될 예정입니다.\n조금만 기다려주세요!',
          style: Font.main,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: Font.main.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "설정",
          style: Font.display.copyWith(
            fontSize: 20,
          ),
        ),
      ),
      body: themeModeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('설정 로드 에러: $e')),
        data: (currentThemeMode) {
          final isDark = currentThemeMode == ThemeMode.dark;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            children: [
              // 일반 섹션
              _buildSectionHeader('일반', isDark),
              _buildSettingsGroup(
                isDark: isDark,
                children: [
                  _buildSwitchTile(
                    icon: Icons.brightness_6_outlined,
                    title: '다크 모드',
                    subtitle: currentThemeMode == ThemeMode.dark ? '켜짐' : '꺼짐',
                    value: currentThemeMode == ThemeMode.dark,
                    isDark: isDark,
                    onChanged: (bool value) {
                      ref
                          .read(themeModeNotifierProvider.notifier)
                          .setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildListTile(
                    icon: Icons.notifications_outlined,
                    title: '알림',
                    subtitle: '루틴 알림 설정',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.l),

              // 멤버십 섹션
              _buildSectionHeader('멤버십', isDark),
              _buildSettingsGroup(
                isDark: isDark,
                children: [
                  _buildPremiumTile(
                    isDark: isDark,
                    onTap: () => _showComingSoonDialog(context, '프리미엄'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.l),

              // 데이터 섹션
              _buildSectionHeader('데이터', isDark),
              _buildSettingsGroup(
                isDark: isDark,
                children: [
                  _buildListTile(
                    icon: Icons.backup_outlined,
                    title: '백업 및 복원',
                    subtitle: '데이터 백업 및 복원 (준비 중)',
                    isDark: isDark,
                    onTap: () => _showComingSoonDialog(context, '백업 및 복원'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.l),

              // 정보 섹션
              _buildSectionHeader('정보', isDark),
              _buildSettingsGroup(
                isDark: isDark,
                children: [
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final appVersion = snapshot.hasData
                          ? 'v${snapshot.data!.version} (Build ${snapshot.data!.buildNumber})'
                          : 'v1.0.0 (Build 1)';

                      return _buildListTile(
                        icon: Icons.info_outline,
                        title: '앱 정보',
                        subtitle: appVersion,
                        isDark: isDark,
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Perfect Three',
                            applicationVersion: appVersion,
                            applicationIcon: Icon(
                              Icons.check_circle_outline,
                              color: AppColors.primary,
                              size: 48,
                            ),
                            children: [
                              Text(
                                "3일 성공 구조를 통해 포기하지 않는 습관을 만드세요.",
                                style: Font.main,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildListTile(
                    icon: Icons.gavel_outlined,
                    title: '오픈소스 라이선스',
                    isDark: isDark,
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Perfect Three',
                        applicationIcon: Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      );
                    },
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: Font.main.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(
          color: (isDark ? AppColors.dividerDark : AppColors.divider)
              .withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Font.main.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Font.main.copyWith(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Font.main.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Font.main.copyWith(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTile({
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.accent.withValues(alpha: 0.15),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프리미엄',
                      style: Font.main.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '더 많은 기능을 이용해보세요 (준비 중)',
                      style: Font.main.copyWith(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.m + 32 + AppSpacing.m),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
    );
  }
}
