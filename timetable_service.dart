import 'api_client.dart';

class TimetableService {
  final ApiClient apiClient;

  TimetableService(this.apiClient);

  /// Generate timetable for departments
  Future<dynamic> generateTimetable({
    required List<Map<String, dynamic>> departments,
    List<dynamic>? timeslots,
  }) async {
    try {
      final response = await apiClient.post(
        '/timetable/generate_timetable',
        data: {
          'departments': departments,
          'timeslots': timeslots ?? [],
        },
        fromJson: (data) => data,
      );
      return response;
    } catch (e) {
      throw 'Failed to generate timetable: $e';
    }
  }

  /// Parse timetable response into class schedule
  List<ClassSchedule> parseTimetable(dynamic timetableData) {
    try {
      List<ClassSchedule> schedules = [];
      
      if (timetableData is Map) {
        final schedule = timetableData['schedule'];
        if (schedule is List) {
          for (var item in schedule) {
            schedules.add(ClassSchedule(
              subject: item['subject'] ?? 'Unknown',
              time: item['time'] ?? 'TBD',
              room: item['room'] ?? 'TBD',
              teacher: item['teacher'] ?? 'TBD',
            ));
          }
        }
      }
      
      return schedules;
    } catch (e) {
      throw 'Failed to parse timetable: $e';
    }
  }
}

class ClassSchedule {
  final String subject;
  final String time;
  final String room;
  final String teacher;

  ClassSchedule({
    required this.subject,
    required this.time,
    required this.room,
    required this.teacher,
  });
}
