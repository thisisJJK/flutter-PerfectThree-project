import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    _textController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  void _saveGoal() {
    if (_textController.text.isEmpty) return;

    // ViewModel에 추가 요청
    ref.read(goalViewModelProvider.notifier).addGoal(_textController.text);
    
    // 이전 화면으로 복귀
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("목표 만들기")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "어떤 습관을 만들고 싶나요?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              autofocus: true, // 화면 열리자마자 키보드 올라오게
              decoration: InputDecoration(
                hintText: "예: 물 마시기, 독서 10분",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (_) => _saveGoal(), // 엔터 치면 저장
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("저장하기", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}