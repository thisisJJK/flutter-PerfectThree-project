import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

/// iOS 세그먼트 컨트롤 스타일 카테고리 칩
/// iOS 세그먼트 컨트롤 스타일 카테고리 칩
class CategoryChips extends ConsumerWidget {
  final bool isOngoing;
  final bool isScrollable;
  final String? selectedCategory;
  final ValueChanged<String>? onSelected;
  final bool showAllOption;

  const CategoryChips({
    super.key,
    required this.isOngoing,
    this.isScrollable = true,
    this.selectedCategory,
    this.onSelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 외부에서 선택된 카테고리를 주입받으면 그것을 사용, 아니면 프로바이더 사용
    final currentCategory =
        selectedCategory ?? ref.watch(categoryFilterProvider);

    final List<String> allCategories = [
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

    final List<String> categoryChips = showAllOption
        ? allCategories
        : allCategories.where((c) => c != '전체').toList();

    void onCategoryTap(String category) {
      if (onSelected != null) {
        // 외부 콜백이 있으면 호출
        onSelected!(category);
      } else {
        // 없으면 기존 로직 (필터링)
        if (currentCategory == category) {
          if (category != '전체') {
            ref.read(categoryFilterProvider.notifier).setCategory('전체');
          }
        } else {
          ref.read(categoryFilterProvider.notifier).setCategory(category);
        }
      }
    }

    List<Widget> buildChips() {
      return List.generate(categoryChips.length, (int index) {
        final category = categoryChips[index];
        final isSelected = currentCategory == category;
        final categoryColor = AppColors.getCategoryColor(category);

        return Padding(
          padding: EdgeInsets.only(
            right: isScrollable ? AppSpacing.s : 0,
          ),
          child: _IOSStyleChip(
            label: category,
            isSelected: isSelected,
            color: categoryColor,
            onTap: () => onCategoryTap(category),
          ),
        );
      });
    }

    if (isScrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: buildChips(),
        ),
      );
    } else {
      return Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: buildChips(),
      );
    }
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
          color: isSelected
              ? color
              : isDark
              ? AppColors.surfaceElevatedDark
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          // border: Border.all(
          //   color: isSelected ? color : AppColors.divider,
          //   width: isSelected ? 0 : 0.5,
          // ),
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
