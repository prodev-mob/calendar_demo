import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calender/calendar_events.dart';

class CalendersPage extends StatefulWidget {
  const CalendersPage({super.key});

  @override
  State<CalendersPage> createState() => _CalendersPageState();
}

class _CalendersPageState extends State<CalendersPage> {
  late DeviceCalendarPlugin _deviceCalendarPlugin;
  List<Calendar> _calendars = [];

  List<Calendar> get _writableCalendars => _calendars.where((c) => c.isReadOnly == false).toList();

  List<Calendar> get _readOnlyCalendars => _calendars.where((c) => c.isReadOnly == true).toList();

  @override
  void initState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    _retrieveCalendars();
    super.initState();
  }

  void _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && (permissionsGranted.data == null || permissionsGranted.data == false)) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || permissionsGranted.data == null || permissionsGranted.data == false) {
          return;
        }
      }
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _calendars = calendarsResult.data as List<Calendar>;
      });
    } on PlatformException catch (e, s) {
      debugPrint('RETRIEVE_CALENDARS: $e, $s');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              _retrieveCalendars();
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _calendars.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            key: Key(_calendars[index].isReadOnly == true
                ? 'readOnlyCalendar${_readOnlyCalendars.indexWhere((c) => c.id == _calendars[index].id)} color:${_calendars[index].color}'
                : 'writableCalendar${_writableCalendars.indexWhere((c) => c.id == _calendars[index].id)} color:${_calendars[index].color}'),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return CalendarEvents(
                      key: const Key('calendarEventsPage'),
                      calendar: _calendars[index],
                    );
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_calendars[index].id}: ${_calendars[index].name!}",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text("Account: ${_calendars[index].accountName!}"),
                        Text("type: ${_calendars[index].accountType}"),
                      ],
                    ),
                  ),
                  Container(
                    key: ValueKey(_calendars[index].color),
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Color(_calendars[index].color!)),
                  ),
                  const SizedBox(width: 10),
                  if (_calendars[index].isDefault!)
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 5.0, 0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                      child: const Text('Default'),
                    ),
                  Icon(_calendars[index].isReadOnly == true ? Icons.lock : Icons.lock_open)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
