import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For formatting

import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final HabitService _habitService = HabitService();
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late Set<DateTime> _completedDays;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadCompletedDays();

    // Listen for changes in the specific habit if needed, though
    // HiveObject updates might automatically reflect if using it directly.
    // For simplicity, we reload data on init.
  }

  void _loadCompletedDays() {
    // Ensure dates are stored/compared as date-only (without time)
    setState(() {
      _completedDays = widget.habit.completedDates
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet();
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Ensure we are comparing Date only
    final selectedDateOnly = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    // Prevent selecting future dates (optional)
    // if (selectedDateOnly.isAfter(DateTime.now())) {
    //   return;
    // }

    setState(() {
      _selectedDay = selectedDateOnly;
      _focusedDay = focusedDay; // update `_focusedDay` here as well
    });

    // Toggle completion for the selected date
    _habitService.toggleHabitCompletion(widget.habit.id, selectedDateOnly);

    // Reload completed days to reflect the change immediately in the calendar UI
    _loadCompletedDays();
  }

  List<DateTime> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    // Return a list with the date if it's in the completed set
    return _completedDays.contains(dateOnly) ? [dateOnly] : [];
  }

  @override
  Widget build(BuildContext context) {
    // Use a listener for the specific habit if edits from other places need to be reflected
    // Or simply rely on HiveObject auto-update if widget.habit is used directly in build

    final currentStreak = widget.habit.currentStreak;
    // Calculate longest streak (could be a getter in Habit model)
    // int longestStreak = calculateLongestStreak(widget.habit.completedDates);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        // Maybe add an edit button here too?
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Calendar --- 
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    locale: 'tr_TR', // Set locale for Turkish day/month names
                    firstDay: widget.habit.createdAt.subtract(const Duration(days: 365)), // Allow viewing past year
                    lastDay: DateTime.now().add(const Duration(days: 365)), // Allow viewing future year (adjust as needed)
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    eventLoader: _getEventsForDay,
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      // Style for days with events (completed days)
                      markerDecoration: BoxDecoration(
                         color: Colors.lightGreenAccent[400], // Use a distinct marker color
                         shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    onDaySelected: _onDaySelected,
                    onPageChanged: (focusedDay) {
                      // No need to call `setState()` here
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Stats --- 
              Card(
                 elevation: 2,
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       Text('İstatistikler', style: Theme.of(context).textTheme.headlineSmall),
                       const SizedBox(height: 12),
                       _buildStatRow('Mevcut Seri', '🔥 $currentStreak gün'),
                       const Divider(),
                       _buildStatRow('Toplam Tamamlama', '${widget.habit.completedDates.length} gün'),
                       const Divider(),
                       // Placeholder for longest streak
                       // _buildStatRow('En Uzun Seri', '🏆 $longestStreak gün'), 
                       // const Divider(),
                       _buildStatRow('Başlangıç Tarihi', DateFormat.yMMMd('tr_TR').format(widget.habit.createdAt)),
                     ],
                   ),
                 ),
              ),
              const SizedBox(height: 70), // Space for potential Banner Ad
            ],
          ),
        ),
      ),
      // TODO: Add Banner Ad at the bottom
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
} 