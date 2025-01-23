import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

class RecurringEventDialog extends StatefulWidget {
  const RecurringEventDialog({
    super.key,
    required this.deviceCalendarPlugin,
    required this.calendarEvent,
    required this.onLoadingStarted,
    required this.onDeleteFinished,
  });

  final DeviceCalendarPlugin deviceCalendarPlugin;
  final Event calendarEvent;
  final VoidCallback onLoadingStarted;
  final Function(bool) onDeleteFinished;

  @override
  State<RecurringEventDialog> createState() => _RecurringEventDialogState();
}

class _RecurringEventDialogState extends State<RecurringEventDialog> {
  late DeviceCalendarPlugin _deviceCalendarPlugin;
  late Event _calendarEvent;
  VoidCallback? _onLoadingStarted;
  Function(bool)? _onDeleteFinished;

  @override
  void initState() {
    _deviceCalendarPlugin = widget.deviceCalendarPlugin;
    _calendarEvent = widget.calendarEvent;
    _onLoadingStarted = widget.onLoadingStarted;
    _onDeleteFinished = widget.onDeleteFinished;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Are you sure you want to delete this event?'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () async {
            Navigator.of(context).pop(true);
            if (_onLoadingStarted != null) _onLoadingStarted!();
            final deleteResult = await _deviceCalendarPlugin.deleteEventInstance(
              _calendarEvent.calendarId,
              _calendarEvent.eventId,
              _calendarEvent.start?.millisecondsSinceEpoch,
              _calendarEvent.end?.millisecondsSinceEpoch,
              false,
            );
            if (_onDeleteFinished != null) {
              _onDeleteFinished!(deleteResult.isSuccess && deleteResult.data != null);
            }
          },
          child: const Text('This instance only'),
        ),
        SimpleDialogOption(
          onPressed: () async {
            Navigator.of(context).pop(true);
            if (_onLoadingStarted != null) _onLoadingStarted!();
            final deleteResult = await _deviceCalendarPlugin.deleteEventInstance(
              _calendarEvent.calendarId,
              _calendarEvent.eventId,
              _calendarEvent.start?.millisecondsSinceEpoch,
              _calendarEvent.end?.millisecondsSinceEpoch,
              true,
            );
            if (_onDeleteFinished != null) {
              _onDeleteFinished!(deleteResult.isSuccess && deleteResult.data != null);
            }
          },
          child: const Text('This and following instances'),
        ),
        SimpleDialogOption(
          onPressed: () async {
            Navigator.of(context).pop(true);
            if (_onLoadingStarted != null) _onLoadingStarted!();
            final deleteResult = await _deviceCalendarPlugin.deleteEvent(_calendarEvent.calendarId, _calendarEvent.eventId);
            if (_onDeleteFinished != null) {
              _onDeleteFinished!(deleteResult.isSuccess && deleteResult.data != null);
            }
          },
          child: const Text('All instances'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        )
      ],
    );
  }
}
