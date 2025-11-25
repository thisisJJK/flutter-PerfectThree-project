import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final bool isOngoing;
  const CategoryChips({super.key, required this.isOngoing});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  List<String> categoryChips = [
    '일상',
    '아침',
    '점심',
    '저녁',
    '운동',
    '업무',
    '자기계발',
    '기타',
  ];

  List<String> allChips = [
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
              children: List.generate(allChips.length, (int index) {
                return Row(
                  children: [
                    ChoiceChip(
                      padding: EdgeInsets.all(8),
                      showCheckmark: false,
                      label: Text(allChips[index]),
                      selected: value == index,
                      onSelected: (bool selected) {
                        setState(() {
                          value = selected ? index : null;
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
            spacing: 5,
            children: List.generate(categoryChips.length, (int index) {
              return ChoiceChip(
                padding: EdgeInsets.all(8),
                showCheckmark: false,
                label: Text(categoryChips[index]),
                selected: value == index,
                onSelected: (bool selected) {
                  setState(() {
                    value = selected ? index : null;
                  });
                },
              );
            }).toList(),
          );
  }
}
