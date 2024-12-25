import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EventCalendarPage extends StatefulWidget {
  const EventCalendarPage({super.key});

  @override
  _EventCalendarPageState createState() => _EventCalendarPageState();
}

class _EventCalendarPageState extends State<EventCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Sample event data
  final Map<DateTime, List<String>> _events = {
    DateTime(2024, 10, 28): ['Event A', 'Event B'],
    DateTime(2024, 10, 29): ['Event C'],
    DateTime(2024, 11, 2): ['Event D', 'Event E', 'Event F'],
  };

  // Get events for the selected day
  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2023, 1, 1),
            lastDay: DateTime(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay, // Load events for the day
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Select a date to see events'))
                : ListView(
                    children: _getEventsForDay(_selectedDay!).map((event) {
                      return ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(event),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

