import 'package:flutter/foundation.dart'; // For ValueListenableBuilder
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../main.dart'; // To get habitBoxName

class HabitService {
  // Get the Hive box for habits
  final Box<Habit> _habitBox = Hive.box<Habit>(habitBoxName);

  // Get all habits as a list
  List<Habit> getAllHabits() {
    // Return habits sorted by creation date (newest first)
    final habits = _habitBox.values.toList();
    habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return habits;
  }

  // Get a specific habit by its ID
  Habit? getHabit(String id) {
    return _habitBox.get(id);
  }

  // Add a new habit
  Future<void> addHabit(String name) async {
    final newHabit = Habit(name: name);
    // Use habit's ID as the key in the box
    await _habitBox.put(newHabit.id, newHabit);
  }

  // Update an existing habit (mainly for marking completion)
  // Hive objects that extend HiveObject can often be modified directly
  // and saved using habit.save(), so a dedicated update method might
  // not be strictly necessary unless you replace the whole object.
  // Example: Toggle completion for today
  Future<void> toggleHabitCompletion(String id, [DateTime? date]) async {
    final habit = getHabit(id);
    if (habit != null) {
      final targetDate = date ?? DateTime.now();
      final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);

      final isCompleted = habit.completedDates.any((d) =>
          DateTime(d.year, d.month, d.day) == targetDateOnly);

      if (isCompleted) {
        habit.removeCompleted(targetDate);
      } else {
        habit.markCompleted(targetDate);
      }
      // Note: habit.save() is called within markCompleted/removeCompleted
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
  }

  // Provide a ValueListenable for reactive UI updates
  ValueListenable<Box<Habit>> getHabitListenable() {
    return _habitBox.listenable();
  }

  // Close the box when the service is disposed (optional, depends on lifecycle)
  // Future<void> dispose() async {
  //   await _habitBox.close();
  // }
} 