import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  // 임시 상태 값 (UI 확인용)
  bool _allowNotifications = true;
  bool _routineAlerts = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _marketingAlerts = false;
  TimeOfDay _dailyBriefingTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    final themeMode =
        ref.watch(themeModeNotifierProvider).valueOrNull ?? ThemeMode.system;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "알림 설정",
          style: Font.display.copyWith(
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        children: [
          _buildSectionHeader('전체 알림', isDark),
          _buildSettingsGroup(
            isDark: isDark,
            children: [
              _buildSwitchTile(
                title: '알림 허용',
                subtitle: '모든 알림을 켜고 끕니다.',
                value: _allowNotifications,
                isDark: isDark,
                onChanged: (value) {
                  setState(() {
                    _allowNotifications = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (_allowNotifications) ...[
            _buildSectionHeader('목표 알림', isDark),
            _buildSettingsGroup(
              isDark: isDark,
              children: [
                _buildSwitchTile(
                  title: '데일리 목표 알림',
                  subtitle: '매일 설정한 시간에 목표 확인 알림을 받습니다.',
                  value: _routineAlerts,
                  isDark: isDark,
                  onChanged: (value) {
                    setState(() {
                      _routineAlerts = value;
                    });
                  },
                ),
                _buildDivider(isDark),
                _buildTimePickerTile(
                  title: '알림 시간',
                  time: _dailyBriefingTime,
                  isDark: isDark,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _dailyBriefingTime,
                      builder: (context, child) {
                        return Theme(
                          data: isDark ? ThemeData.dark() : ThemeData.light(),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != _dailyBriefingTime) {
                      setState(() {
                        _dailyBriefingTime = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            _buildSectionHeader('성공 및 응원', isDark),
            _buildSettingsGroup(
              isDark: isDark,
              children: [
                _buildSwitchTile(
                  title: '3일 성공 미리 알림',
                  subtitle: '작심삼일 성공 당일 미리 알림을 받습니다.',
                  value: true, // 임시 값
                  isDark: isDark,
                  onChanged: (value) {},
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: '응원 메시지',
                  subtitle: '목표 달성을 위한 응원 메시지를 받습니다.',
                  value: _marketingAlerts,
                  isDark: isDark,
                  onChanged: (value) {
                    setState(() {
                      _marketingAlerts = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            _buildSectionHeader('알림 방식', isDark),
            _buildSettingsGroup(
              isDark: isDark,
              children: [
                _buildSwitchTile(
                  title: '소리',
                  value: _soundEnabled,
                  isDark: isDark,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: '진동',
                  value: _vibrationEnabled,
                  isDark: isDark,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ],
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

  Widget _buildSwitchTile({
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

  Widget _buildTimePickerTile({
    required String title,
    required TimeOfDay time,
    required bool isDark,
    required VoidCallback onTap,
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
              Expanded(
                child: Text(
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
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  time.format(context),
                  style: Font.main.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.m),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
    );
  }
}
