import 'package:flutter/material.dart';

class ModelOption extends StatelessWidget {
  const ModelOption({
    super.key,
    required this.option, required this.value, required this.groupValue, required this.onChanged,
  });

  final int value;
  final String option;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(value: value, groupValue: groupValue, activeColor: Colors.green, onChanged: onChanged),
        Text(option, style: Theme.of(context).textTheme.bodyLarge,),
      ],
    );
  }
}