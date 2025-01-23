import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calender/date_picker.dart';
import 'package:flutter_calender/event_attendee.dart';
import 'package:flutter_calender/time_picker.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';

class CalendarEvent extends StatefulWidget {
  const CalendarEvent({
    super.key,
    required this.calendar,
    this.event,
  });

  final Calendar calendar;
  final Event? event;

  @override
  State<CalendarEvent> createState() => _CalendarEventState();
}

class _CalendarEventState extends State<CalendarEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final Calendar _calendar;
  late final DeviceCalendarPlugin _deviceCalendarPlugin;
  Event? _event;

  DateTime get nowDate => DateTime.now();

  TZDateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  List<Attendee>? _attendees;
  String _timezone = 'Etc/UTC';

  @override
  void initState() {
    _calendar = widget.calendar;
    _event = widget.event;
    getCurrentLocation();
    super.initState();
  }

  void getCurrentLocation() async {
    try {
      _timezone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      debugPrint('Could not get the local timezone');
    }

    _deviceCalendarPlugin = DeviceCalendarPlugin();

    final event = _event;
    if (event == null) {
      debugPrint('calendar_event _timezone ------------------------- $_timezone');
      final currentLocation = timeZoneDatabase.locations[_timezone];
      if (currentLocation != null) {
        final now = TZDateTime.now(currentLocation);
        _eventDate = now;
        _startTime = TimeOfDay(hour: now.hour, minute: now.minute);
        final oneHourLater = now.add(const Duration(hours: 1));
        _endTime = TimeOfDay(hour: oneHourLater.hour, minute: oneHourLater.minute);
      } else {
        var fallbackLocation = timeZoneDatabase.locations['Etc/UTC'];
        final now = TZDateTime.now(fallbackLocation!);
        _eventDate = now;
        _startTime = TimeOfDay(hour: now.hour, minute: now.minute);
        final oneHourLater = now.add(const Duration(hours: 1));
        _endTime = TimeOfDay(hour: oneHourLater.hour, minute: oneHourLater.minute);
      }
      _event = Event(_calendar.id, start: _eventDate, end: _eventDate);

      debugPrint('DeviceCalendarPlugin calendar id is: ${_calendar.id}');
    } else {
      final start = event.start;
      final end = event.end;
      if (start != null && end != null) {
        _eventDate = start;
        _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
        _endTime = TimeOfDay(hour: end.hour, minute: end.minute);
      }

      final attendees = event.attendees;
      if (attendees != null && attendees.isNotEmpty) {
        _attendees = <Attendee>[];
        _attendees?.addAll(attendees as Iterable<Attendee>);
      }
    }
    setState(() {});
  }

  void printAttendeeDetails(Attendee attendee) {
    debugPrint('attendee name: ${attendee.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _event?.eventId?.isEmpty ?? true
              ? 'Create event'
              : _calendar.isReadOnly == true
                  ? 'View event ${_event?.title}'
                  : 'Edit event ${_event?.title}',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: AbsorbPointer(
            absorbing: _calendar.isReadOnly ?? false,
            child: Column(
              children: [
                Form(
                  autovalidateMode: _autovalidate,
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          key: const Key('titleField'),
                          initialValue: _event?.title,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'Meeting with Gloria...',
                          ),
                          validator: (value) {
                            if (value == null) return null;
                            if (value.isEmpty) {
                              return 'Name is required.';
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            _event?.title = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          initialValue: _event?.description,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Remember to buy flowers...',
                          ),
                          onSaved: (String? value) {
                            _event?.description = value;
                          },
                        ),
                      ),
                      if (_eventDate != null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: DatePicker(
                            labelText: 'Event Date',
                            selectedDate: _eventDate,
                            selectDate: (DateTime date) {
                              setState(() {
                                var currentLocation = timeZoneDatabase.locations[_timezone];
                                if (currentLocation != null) {
                                  _eventDate = TZDateTime.from(date, currentLocation);
                                  _event?.start = _combineDateWithTime(_eventDate, _startTime);
                                  _event?.end = _combineDateWithTime(_eventDate, _endTime);
                                }
                              });
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            TimePicker(
                              labelText: 'Start Time',
                              selectedTime: _startTime,
                              selectTime: (TimeOfDay time) {
                                setState(() {
                                  _startTime = time;
                                  _event?.start = _combineDateWithTime(_eventDate, _startTime);
                                });
                              },
                            ),
                            SizedBox(width: 10.0),
                            TimePicker(
                              labelText: 'End Time',
                              selectedTime: _endTime,
                              selectTime: (TimeOfDay time) {
                                setState(() {
                                  _endTime = time;
                                  _event?.end = _combineDateWithTime(_eventDate, _endTime);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        onTap: _calendar.isReadOnly == false
                            ? () async {
                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const EventAttendee();
                                    },
                                  ),
                                );
                                if (result != null) {
                                  _attendees ??= [];
                                  setState(() {
                                    _attendees?.add(result);
                                  });
                                }
                              }
                            : null,
                        leading: const Icon(Icons.people),
                        title: Text(_calendar.isReadOnly == false ? 'Add Attendees' : 'Attendees'),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _attendees?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                            color: (_attendees?[index].isOrganiser ?? false)
                                ? MediaQuery.of(context).platformBrightness == Brightness.dark
                                    ? Colors.black26
                                    : Colors.greenAccent[100]
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_attendees?[index].name}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                IconButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    setState(() {
                                      _attendees?.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.redAccent,
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: _calendar.isReadOnly == false,
        child: FloatingActionButton(
          key: const Key('saveEventButton'),
          onPressed: () async {
            final form = _formKey.currentState;
            if (form?.validate() == false) {
              _autovalidate = AutovalidateMode.always;
              showInSnackBar(context, 'Please fix the errors in red before submitting.');
              return;
            } else {
              form?.save();
              _event?.attendees = _attendees;
            }
            var createEventResult = await _deviceCalendarPlugin.createOrUpdateEvent(_event);
            if (createEventResult?.isSuccess == true) {
              if (!context.mounted) return;
              Navigator.pop(context, true);
            } else {
              if (!context.mounted) return;
              showInSnackBar(context, createEventResult?.errors.map((err) => '[${err.errorCode}] ${err.errorMessage}').join(' | ') as String);
            }
          },
          child: const Icon(Icons.check),
        ),
      ),
    );
  }

  TZDateTime? _combineDateWithTime(TZDateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    var currentLocation = timeZoneDatabase.locations[_timezone];

    final dateWithoutTime = TZDateTime.from(DateTime.parse(DateFormat('y-MM-dd 00:00:00').format(date)), currentLocation!);

    if (time == null) return dateWithoutTime;
    if (Platform.isAndroid && _event?.allDay == true) return dateWithoutTime;

    return dateWithoutTime.add(Duration(hours: time.hour, minutes: time.minute));
  }

  void showInSnackBar(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
