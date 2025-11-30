import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/features/goals/widgets/my_routin_card.dart';

class MyRoutinScreen extends ConsumerWidget {
  const MyRoutinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalViewModelProvider);
    return Scaffold(
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러: $err')),
        data: (goals) {
          final ongoingFalseGoals = ref
              .read(goalViewModelProvider.notifier)
              .filterOngoing(goals, false);
          if (ongoingFalseGoals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.extension, size: 58),
                  const SizedBox(height: 24),
                  Text(
                    "아직 내 습관이 없어요.\n진행중인 3일 도전을 마무리해보세요!",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            // 목표 리스트 렌더링
            return ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // FAB와 겹치지 않게 여백
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(goalViewModelProvider.notifier)
                    .reorder(oldIndex, newIndex, ongoingFalseGoals);
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    final double animValue = Curves.easeInOut.transform(
                      animation.value,
                    );
                    final double elevation = lerpDouble(1, 6, animValue)!;
                    final double scale = lerpDouble(1, 1.03, animValue)!;
                    return Transform.scale(
                      scale: scale,
                      child: MyRoutinCard(
                        goal: ongoingFalseGoals[index],
                        elevation: elevation,
                      ),
                    );
                  },
                );
              },
              itemCount: ongoingFalseGoals.length,
              itemBuilder: (context, index) {
                return MyRoutinCard(
                  goal: ongoingFalseGoals[index],
                  key: ValueKey(ongoingFalseGoals[index].id),
                );
              },
            );
          }
        },
      ),
    );
  }
}
