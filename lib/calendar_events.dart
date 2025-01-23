import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calender/calendar_event.dart';
import 'package:flutter_calender/event_item.dart';

class CalendarEvents extends StatefulWidget {
  final Calendar calendar;
  const CalendarEvents({super.key, required this.calendar});

  @override
  State<CalendarEvents> createState() => _CalendarEventsState();
}

class _CalendarEventsState extends State<CalendarEvents> {
  late Calendar _calendar;
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  late DeviceCalendarPlugin _deviceCalendarPlugin;
  List<Event> _calendarEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    _calendar = widget.calendar;
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    _retrieveCalendarEvents();
    super.initState();
  }

  Future _retrieveCalendarEvents() async {
    final startDate = DateTime.now().add(const Duration(days: -30));
    final endDate = DateTime.now().add(const Duration(days: 365 * 10));
    var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
      _calendar.id,
      RetrieveEventsParams(
        startDate: startDate,
        endDate: endDate,
      ),
    );
    setState(() {
      _calendarEvents = calendarEventsResult.data ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('${_calendar.name} events'),
      ),
      body: (_calendarEvents.isNotEmpty || _isLoading)
          ? Stack(
              children: [
                ListView.builder(
                  itemCount: _calendarEvents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return EventItem(
                      calendarEvent: _calendarEvents[index],
                      deviceCalendarPlugin: _deviceCalendarPlugin,
                      onLoadingStarted: _onLoading,
                      onDeleteFinished: _onDeletedFinished,
                      onTapped: _onTapped,
                      isReadOnly: _calendar.isReadOnly != null && _calendar.isReadOnly as bool,
                    );
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
              ],
            )
          : const Center(
              child: Text('No events found'),
            ),
      floatingActionButton: _getAddEventButton(context),
    );
  }

  Widget? _getAddEventButton(BuildContext context) {
    if (_calendar.isReadOnly == false || _calendar.isReadOnly == null) {
      return FloatingActionButton(
        key: const Key('addEventButton'),
        onPressed: () async {
          final refreshEvents = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return CalendarEvent(calendar: _calendar, event: null);
              },
            ),
          );
          if (refreshEvents == true) {
            await _retrieveCalendarEvents();
          }
        },
        child: const Icon(Icons.add),
      );
    } else {
      return null;
    }
  }

  void _onLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  Future _onDeletedFinished(bool deleteSucceeded) async {
    if (deleteSucceeded) {
      await _retrieveCalendarEvents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Oops, we ran into an issue deleting the event'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _onTapped(Event event) async {
    final refreshEvents = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return CalendarEvent(
            calendar: _calendar,
            event: event,
          );
        },
      ),
    );
    if (refreshEvents != null && refreshEvents) {
      await _retrieveCalendarEvents();
    }
  }
}
