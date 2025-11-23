import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_typography.dart';
import 'package:perfect_three/data/models/goal.dart';
import 'package:perfect_three/features/ads/banner_ad_widget.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/features/goals/widgets/goal_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel 상태 구독
    final goalsAsync = ref.watch(goalViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Perfect Three"),
        centerTitle: false,

        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              //설정 화면 이동
              context.push('/settings');
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러: $err')),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "아직 목표가 없어요.\n새로운 3일 도전을 시작해보세요!",
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ],
              ),
            );
          }
          // 목표 리스트 렌더링
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100), // FAB와 겹치지 않게 여백
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return GestureDetector(
                onLongPress: () {
                  _showDeleteDialog(context, ref, goal);
                },
                child: GoalCard(goal: goal),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add'); // 라우터로 이동
        },
        label: const Text("목표 추가"),
        icon: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(height: 60, child: BottomBannerAd()),
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context, WidgetRef ref, Goal goal) async {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      final double width = 110;
      final double height = 45;
      return AlertDialog(
        title: Text('목표 삭제하기'),
        content: Text('삭제하면 되돌릴 수 없어요.'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  ref.read(goalViewModelProvider.notifier).deleteGoal(goal.id);
                  context.pop();
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text(
                      '삭제',
                      style: textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.2,
                      color: colorScheme.onSurface,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '취소',
                      style: textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
