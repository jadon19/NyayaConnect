import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 10, 5): ["Court Hearing"],
    DateTime.utc(2025, 10, 10): ["Meeting with Client"],
    DateTime.utc(2025, 10, 12): ["Document Submission"],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _addEvent(String event) {
    if (_selectedDay != null && event.isNotEmpty) {
      setState(() {
        final key =
        DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        _events[key] = [..._getEventsForDay(_selectedDay!), event];
      });
    }
  }

  void _showAddEventDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Event"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter event title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _addEvent(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration:
              BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration:
              BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text("Select a date to see events."))
                : ListView(
              padding: const EdgeInsets.all(16),
              children: _getEventsForDay(_selectedDay!).isEmpty
                  ? [
                const Text(
                  "No events for this day.",
                  style: TextStyle(color: Colors.grey),
                )
              ]
                  : _getEventsForDay(_selectedDay!)
                  .map(
                    (event) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(event),
                  ),
                ),
              )
                  .toList(),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay != null) {
            _showAddEventDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select a date first")),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}