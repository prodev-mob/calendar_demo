import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

class EventAttendee extends StatefulWidget {
  const EventAttendee({super.key, this.attendee});

  final Attendee? attendee;

  @override
  State<EventAttendee> createState() => _EventAttendeeState();
}

class _EventAttendeeState extends State<EventAttendee> {
  Attendee? _attendee;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    if (widget.attendee != null) {
      _attendee = widget.attendee;
      _nameController.text = _attendee?.name ?? '';
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _attendee != null ? 'Edit attendee ${_attendee!.name}' : 'Add an Attendee',
        ),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (_attendee?.isCurrentUser == false && (value == null || value.isEmpty)) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _attendee = Attendee(
                    name: _nameController.text,
                    emailAddress: "",
                    role: AttendeeRole.None,
                    isOrganiser: _attendee?.isOrganiser ?? false,
                    isCurrentUser: _attendee?.isCurrentUser ?? false,
                    iosAttendeeDetails: _attendee?.iosAttendeeDetails,
                    androidAttendeeDetails: AndroidAttendeeDetails.fromJson(
                      {'attendanceStatus': AndroidAttendanceStatus.None.index},
                    ),
                  );
                });
                Navigator.pop(context, _attendee);
              }
            },
            child: Text(_attendee != null ? 'Update' : 'Add'),
          )
        ],
      ),
    );
  }
}
