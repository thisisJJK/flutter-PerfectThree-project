import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/features/goals/widgets/category_chips.dart';
import 'package:perfect_three/shared/ads/banner_ad_widget.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _textController = TextEditingController();
  String _selectedCategory = '일상';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_textController.text.isEmpty) return;

    ref
        .read(goalViewModelProvider.notifier)
        .addGoal(_textController.text, _selectedCategory);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "루틴 만들기",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //헤더
            const Text("어떤 습관을 만들고 싶나요?", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            //카테고리
            CategoryChips(
              isOngoing: false,
              isScrollable: false,
              showAllOption: false,
              selectedCategory: _selectedCategory,
              onSelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

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
              child: const Text("저장하기"),
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
