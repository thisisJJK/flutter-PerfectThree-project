import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

/// iOS 세그먼트 컨트롤 스타일 카테고리 칩
class CategoryChips extends ConsumerStatefulWidget {
  final bool isOngoing;

  const CategoryChips({super.key, required this.isOngoing});

  @override
  CategoryChipsState createState() => CategoryChipsState();
}

class CategoryChipsState extends ConsumerState<CategoryChips> {
  List<String> categoryChips = [
    '전체',
    '일상',
    '아침',
    '점심',
    '저녁',
    '운동',
    '업무',
    '자기계발',
    '기타',
  ];
  int? value = 0;

  @override
  Widget build(BuildContext context) {
    return widget.isOngoing
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(categoryChips.length, (int index) {
                final isSelected = value == index;
                final category = categoryChips[index];
                final categoryColor = AppColors.getCategoryColor(category);

                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.s),
                  child: _IOSStyleChip(
                    label: category,
                    isSelected: isSelected,
                    color: categoryColor,
                    onTap: () {
                      setState(() {
                        value = index;
                        ref
                            .read(categoryFilterProvider.notifier)
                            .setCategory(category);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          )
        : Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: List.generate(categoryChips.length - 1, (int index) {
              final category = categoryChips[index + 1];
              final isSelected = value == index;
              final categoryColor = AppColors.getCategoryColor(category);

              return _IOSStyleChip(
                label: category,
                isSelected: isSelected,
                color: categoryColor,
                onTap: () {
                  setState(() {
                    value = index;
                    ref
                        .read(goalViewModelProvider.notifier)
                        .updateCategory(category);
                  });
                },
              );
            }).toList(),
          );
  }
}

/// iOS 스타일 칩 위젯
class _IOSStyleChip extends ConsumerWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _IOSStyleChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 0 : 0.5,
          ),
          // iOS 스타일 그림자 (선택시)
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Font.main.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
