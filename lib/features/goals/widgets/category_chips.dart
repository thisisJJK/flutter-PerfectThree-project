import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

class CategoryChips extends ConsumerStatefulWidget {
  final bool isOngoing;
  const CategoryChips({super.key, required this.isOngoing});

  @override
  CategoryChipsState createState() => CategoryChipsState();
}

class CategoryChipsState extends ConsumerState<CategoryChips> {
  @override
  void initState() {
    super.initState();
  }

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
    // int? value = 0; //여기 넣으면 왜 안되는지?

    return widget.isOngoing
        ? SingleChildScrollView(
            //진행중 화면
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(categoryChips.length, (int index) {
                return Row(
                  children: [
                    ChoiceChip(
                      padding: EdgeInsets.all(8),
                      showCheckmark: false,
                      label: Text(categoryChips[index]),
                      selected: value == index,
                      onSelected: (bool selected) {
                        setState(() {
                          value = index;
                        });
                      },
                    ),
                    SizedBox(width: 5),
                  ],
                );
              }).toList(),
            ),
          )
        : Wrap(
            //추가 화면
            spacing: 5,
            children: List.generate(categoryChips.length - 1, (int index) {
              return ChoiceChip(
                padding: EdgeInsets.all(8),
                showCheckmark: false,
                label: Text(categoryChips[index + 1]),
                selected: value == index,
                onSelected: (bool selected) {
                  setState(() {
                    value = index;
                    ref
                        .read(goalViewModelProvider.notifier)
                        .updateCategory(categoryChips[index + 1]);
                  });
                },
              );
            }).toList(),
          );
  }
}
