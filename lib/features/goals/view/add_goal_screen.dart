import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_typography.dart';
import 'package:perfect_three/features/ads/banner_ad_widget.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_textController.text.isEmpty) return;

    ref.read(goalViewModelProvider.notifier).addGoal(_textController.text);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("습관 만들기")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("어떤 습관을 만들고 싶나요?", style: AppTypography.title),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: "예: 물 마시기, 독서 10분",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("저장하기", style: AppTypography.body),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(height: 60, child: BottomBannerAd()),
      ),
    );
  }
}
