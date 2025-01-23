import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'input_dropdown.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    super.key,
    this.labelText,
    this.selectedDate,
    this.selectDate,
  });

  final String? labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? selectDate;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate != null ? DateTime.parse(selectedDate.toString()) : DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate && selectDate != null) {
      selectDate!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.titleLarge;
    return InputDropdown(
      labelText: labelText,
      valueText: selectedDate == null ? '' : DateFormat.yMMMd().format(selectedDate as DateTime),
      valueStyle: valueStyle,
      onPressed: () {
        _selectDate(context);
      },
    );
  }
}
