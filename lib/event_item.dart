import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calender/recurring_event_dialog.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';

class EventItem extends StatefulWidget {
  const EventItem({
    super.key,
    this.calendarEvent,
    required this.deviceCalendarPlugin,
    required this.isReadOnly,
    required this.onTapped,
    required this.onLoadingStarted,
    required this.onDeleteFinished,
  });

  final Event? calendarEvent;
  final DeviceCalendarPlugin deviceCalendarPlugin;
  final bool isReadOnly;

  final Function(Event) onTapped;
  final VoidCallback onLoadingStarted;
  final Function(bool) onDeleteFinished;

  @override
  State<EventItem> createState() => _EventItemState();
}

class _EventItemState extends State<EventItem> {
  final double _eventFieldNameWidth = 75.0;
  Location? _currentLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.calendarEvent != null) {
          widget.onTapped(widget.calendarEvent as Event);
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(widget.calendarEvent?.title ?? ''),
              subtitle: Text(widget.calendarEvent?.description ?? ''),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  if (_currentLocation != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          SizedBox(
                            width: _eventFieldNameWidth,
                            child: const Text('Starts'),
                          ),
                          Text(
                            widget.calendarEvent == null
                                ? ''
                                : _formatDateTime(
                                    dateTime: widget.calendarEvent!.start!,
                                  ),
                          )
                        ],
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  if (_currentLocation != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          SizedBox(
                            width: _eventFieldNameWidth,
                            child: const Text('Ends'),
                          ),
                          Text(
                            widget.calendarEvent?.end == null
                                ? ''
                                : _formatDateTime(
                                    dateTime: widget.calendarEvent!.end!,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _eventFieldNameWidth,
                          child: const Text('Attendees'),
                        ),
                        Expanded(
                          child: Text(
                            widget.calendarEvent?.attendees?.where((a) => a?.name?.isNotEmpty ?? false).map((a) => a?.name).join(', ') ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                if (!widget.isReadOnly) ...[
                  IconButton(
                    onPressed: () {
                      if (widget.calendarEvent != null) {
                        widget.onTapped(widget.calendarEvent as Event);
                      }
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () async {
                      await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          if (widget.calendarEvent?.recurrenceRule == null) {
                            return AlertDialog(
                              title: const Text('Are you sure you want to delete this event?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    widget.onLoadingStarted();
                                    final deleteResult = await widget.deviceCalendarPlugin.deleteEvent(
                                      widget.calendarEvent?.calendarId,
                                      widget.calendarEvent?.eventId,
                                    );
                                    widget.onDeleteFinished(deleteResult.isSuccess && deleteResult.data != null);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          } else {
                            if (widget.calendarEvent == null) {
                              return const SizedBox();
                            }
                            return RecurringEventDialog(
                              deviceCalendarPlugin: widget.deviceCalendarPlugin,
                              calendarEvent: widget.calendarEvent!,
                              onLoadingStarted: widget.onLoadingStarted,
                              onDeleteFinished: widget.onDeleteFinished,
                            );
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () {
                      if (widget.calendarEvent != null) {
                        widget.onTapped(widget.calendarEvent!);
                      }
                    },
                    icon: const Icon(Icons.remove_red_eye),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  void setCurrentLocation() async {
    String? timezone;
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      timezone = timezoneInfo.identifier;
      debugPrint("--- timezone is<event_item.dart>: $timezone ---");
    } catch (e) {
      debugPrint('Could not get the local timezone');
    }
    timezone ??= 'Etc/UTC';
    _currentLocation = timeZoneDatabase.locations[timezone];
    setState(() {});
  }

  /// Formats [dateTime] into a human-readable string.
  /// If [_calendarEvent] is an Android allDay event, then the output will
  /// omit the time.
  String _formatDateTime({DateTime? dateTime}) {
    if (dateTime == null) {
      return 'Error';
    }
    var output = '';
    if (Platform.isAndroid && widget.calendarEvent?.allDay == true) {
      output = DateFormat.yMd().format(dateTime);
    } else {
      output = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        TZDateTime.from(dateTime, _currentLocation!),
      );
    }
    return output;
  }
}
