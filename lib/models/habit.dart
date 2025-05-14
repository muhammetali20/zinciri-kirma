import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'habit.g.dart'; // Generated part file

@HiveType(typeId: 0) // Unique typeId for the adapter
class Habit extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  late List<DateTime> completedDates;

  // Optional fields (can be added later)
  // @HiveField(4)
  // int? colorCode;
  // @HiveField(5)
  // String? goalDescription;

  Habit({
    required this.name,
    // If id is not provided, generate one
    String? id,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    // this.colorCode,
    // this.goalDescription,
  }) {
    this.id = id ?? const Uuid().v4(); // Generate UUID if id is null
    this.createdAt = createdAt ?? DateTime.now();
    this.completedDates = completedDates ?? [];
  }

  // --- Helper Methods --- (Moved from design for clarity)

  // Calculates the current streak
  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    // Sort dates descending to easily check recent days
    final sortedDates = List<DateTime>.from(completedDates);
    sortedDates.sort((a, b) => b.compareTo(a));

    // Remove time part for accurate date comparison
    DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    int streak = 0;
    DateTime today = dateOnly(DateTime.now());
    DateTime yesterday = today.subtract(const Duration(days: 1));

    // Check if today is completed
    bool todayCompleted = sortedDates.any((date) => dateOnly(date) == today);

    if (todayCompleted) {
      streak = 1;
      DateTime expectedDate = yesterday;
      for (final date in sortedDates) {
         final completedDay = dateOnly(date);
         if(completedDay == today) continue; // Skip today if already counted

         if (completedDay == expectedDate) {
           streak++;
           expectedDate = expectedDate.subtract(const Duration(days: 1));
         } else if (completedDay.isBefore(expectedDate)) {
           break; // Gap found, streak broken
         }
      }
    } else {
      // If today is not completed, check if yesterday was
      DateTime expectedDate = yesterday;
       for (final date in sortedDates) {
         final completedDay = dateOnly(date);
         if (completedDay == expectedDate) {
           streak++;
           expectedDate = expectedDate.subtract(const Duration(days: 1));
         } else if (completedDay.isBefore(expectedDate)) {
           break; // Gap found, streak broken
         }
       }
    }
    return streak;
  }

  // Checks if the habit was completed today
  bool isCompletedToday() {
    if (completedDates.isEmpty) return false;
    DateTime today = DateTime.now();
    DateTime todayDateOnly = DateTime(today.year, today.month, today.day);
    return completedDates.any((date) =>
        date.year == todayDateOnly.year &&
        date.month == todayDateOnly.month &&
        date.day == todayDateOnly.day);
  }

  // Marks the habit as completed for a specific date (defaults to today)
  void markCompleted([DateTime? date]) {
    final dateToMark = date ?? DateTime.now();
    final dateOnlyToMark = DateTime(dateToMark.year, dateToMark.month, dateToMark.day);

    // Avoid duplicates for the same day
    if (!completedDates.any((d) => DateTime(d.year, d.month, d.day) == dateOnlyToMark)) {
      completedDates.add(dateOnlyToMark);
      save(); // Save the habit object after modification (HiveObject feature)
    }
  }

  // Removes completion status for a specific date (defaults to today)
  void removeCompleted([DateTime? date]) {
     final dateToRemove = date ?? DateTime.now();
     final dateOnlyToRemove = DateTime(dateToRemove.year, dateToRemove.month, dateToRemove.day);
     completedDates.removeWhere((d) => DateTime(d.year, d.month, d.day) == dateOnlyToRemove);
     save(); // Save the habit object after modification
  }
} 