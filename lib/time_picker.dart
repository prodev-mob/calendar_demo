import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'input_dropdown.dart';

class TimePicker extends StatelessWidget {
  const TimePicker({
    super.key,
    this.labelText,
    this.selectedTime,
    this.selectTime,
  });

  final String? labelText;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay>? selectTime;

  Future<void> _selectTime(BuildContext context) async {
    if (selectedTime == null) return;
    final picked = await showTimePicker(context: context, initialTime: selectedTime!);
    if (picked != null && picked != selectedTime) selectTime!(picked);
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.titleLarge;
    return Flexible(
      child: InputDropdown(
        labelText: labelText,
        valueText: selectedTime?.format(context) ?? '',
        valueStyle: valueStyle,
        onPressed: () {
          _selectTime(context);
        },
      ),
    );
  }
}
