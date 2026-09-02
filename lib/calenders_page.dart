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
  bool _isLoading = true;
  bool _hasPermissions = false;

  List<Calendar> get _writableCalendars => _calendars.where((c) => c.isReadOnly == false).toList();

  List<Calendar> get _readOnlyCalendars => _calendars.where((c) => c.isReadOnly == true).toList();

  @override
  void initState() {
    super.initState();
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    _retrieveCalendars();
  }

  Future<void> _retrieveCalendars() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && (permissionsGranted.data == null || permissionsGranted.data == false)) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      }

      final isGranted = permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
      if (!mounted) return;

      setState(() {
        _hasPermissions = isGranted;
      });

      if (isGranted) {
        final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
        if (!mounted) return;
        setState(() {
          _calendars = (calendarsResult.data ?? <Calendar>[]).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } on PlatformException catch (e, s) {
      debugPrint('RETRIEVE_CALENDARS: $e, $s');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddCalendarDialog() async {
    final textController = TextEditingController(text: 'My Calendar');
    final formKey = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New Calendar'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Calendar Name',
                hintText: 'Enter calendar name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final name = textController.text.trim();
                  Navigator.of(dialogContext).pop();
                  final res = await _deviceCalendarPlugin.createCalendar(
                    name,
                    calendarColor: Colors.blue,
                    localAccountName: 'Local Account',
                  );
                  if (res.isSuccess && (res.data?.isNotEmpty ?? false)) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Calendar "$name" created successfully!')),
                    );
                    _retrieveCalendars();
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to create calendar: ${res.errors.map((e) => e.errorMessage).join(", ")}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _retrieveCalendars,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCalendarDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Calendar'),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading calendars...'),
                ],
              ),
            );
          }

          if (!_hasPermissions) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Calendar Permission Required',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This app needs permission to access your device calendars to show and manage events.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _retrieveCalendars,
                      icon: const Icon(Icons.check),
                      label: const Text('Grant Permission'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_calendars.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No Calendars Found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'There are no calendars on this device. Create a local calendar or link a Google/device account.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _showAddCalendarDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Create a Calendar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _retrieveCalendars,
            child: ListView.builder(
              itemCount: _calendars.length,
              itemBuilder: (BuildContext context, int index) {
                final calendar = _calendars[index];
                return GestureDetector(
                  key: Key(calendar.isReadOnly == true
                      ? 'readOnlyCalendar${_readOnlyCalendars.indexWhere((c) => c.id == calendar.id)} color:${calendar.color}'
                      : 'writableCalendar${_writableCalendars.indexWhere((c) => c.id == calendar.id)} color:${calendar.color}'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return CalendarEvents(
                            key: const Key('calendarEventsPage'),
                            calendar: calendar,
                          );
                        },
                      ),
                    );
                    _retrieveCalendars();
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  calendar.name ?? 'Untitled Calendar',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Account: ${calendar.accountName ?? 'Local'}",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (calendar.accountType != null)
                                  Text(
                                    "Type: ${calendar.accountType}",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          if (calendar.color != null)
                            Container(
                              key: ValueKey(calendar.color),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(calendar.color!),
                              ),
                            ),
                          if (calendar.isDefault ?? false)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Default', style: TextStyle(fontSize: 12)),
                            ),
                          Icon(
                            calendar.isReadOnly == true ? Icons.lock : Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
