import 'package:flutter/material.dart';

import 'field.dart';
import 'field_codec.dart';
import 'field_type.dart';

extension DateTimeExtension on DateTime {
  /// Converts the [DateTime] to a string object supported by the field
  String toSimpleFormat() {
    String pad(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '$year-${pad(month)}-${pad(day)} ${pad(hour)}:${pad(minute)}';
  }
}

class DateTimeField extends Field<DateTime> {
  DateTimeField({
    required super.name,
    required super.initialValue,
    super.onChanged,
    required this.start,
    required this.end,
  }) : super(
          type: FieldType.dateTime,
          codec: FieldCodec<DateTime>(
            toParam: (value) {
              // encode the date time to a string to replace all instances of
              // ':' with '%3A' to avoid issues with retrieving the value
              // from the param in the query group because it is saved in a map
              return Uri.encodeComponent(value.toSimpleFormat());
            },
            toValue: (param) {
              return param == null
                  ? null
                  : DateTime.tryParse(Uri.decodeComponent(param));
            },
          ),
        );

  /// The starting [DateTime] value used for the date and time pickers.
  final DateTime start;

  /// The ending [DateTime] value used for the date and time pickers.
  final DateTime end;

  @override
  Widget toWidget(BuildContext context, String group, DateTime? value) {
    return TextFormField(
      initialValue: (value ?? initialValue)?.toSimpleFormat(),
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_rounded),
          onPressed: () async {
            final dateTime = await showDateTimePicker(
              context,
              value ?? initialValue,
            );

            if (dateTime == null) return;

            updateField(
              context,
              group,
              dateTime,
            );
          },
        ),
      ),
      onChanged: (value) => updateField(
        context,
        group,
        codec.toValue(value) ?? initialValue ?? DateTime.now(),
      ),
    );
  }

  /// Shows a date and time picker dialog and returns the selected date and time
  Future<DateTime?> showDateTimePicker(
    BuildContext context, [
    DateTime? value,
  ]) async {
    final initialDate = value ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: start,
      lastDate: end,
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'start': codec.toParam(start),
      'end': codec.toParam(end),
    };
  }
}
