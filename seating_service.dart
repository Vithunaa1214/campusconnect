import 'dart:typed_data';
import 'api_client.dart';

class SeatingService {
  final ApiClient apiClient;

  SeatingService(this.apiClient);

  /// Get available rooms for an exam
  Future<List<dynamic>> getAvailableRooms({
    required String examDate,
    required String session,
  }) async {
    try {
      final response = await apiClient.getList(
        '/seating/v1/seating/available-rooms',
        queryParameters: {
          'exam_date': examDate,
          'session': session,
        },
      );
      return response is List ? response : [response];
    } catch (e) {
      throw 'Failed to fetch available rooms: $e';
    }
  }

  /// Get seating arrangement by room
  Future<dynamic> getSeatingByRoom({
    required String examDate,
    required String session,
    required String roomCode,
  }) async {
    try {
      final response = await apiClient.getList(
        '/seating/v1/seating/by-room',
        queryParameters: {
          'exam_date': examDate,
          'session': session,
          'room_code': roomCode,
        },
      );
      return response;
    } catch (e) {
      throw 'Failed to fetch seating arrangement: $e';
    }
  }

  /// Generate seating for an exam
  Future<dynamic> generateSeating({
    required String examDate,
    required String session,
    List<String>? roomCodes,
  }) async {
    try {
      final response = await apiClient.post(
        '/seating/v1/seating/generate',
        data: {
          'exam_date': examDate,
          'session': session,
          'room_codes': roomCodes ?? [],
        },
        fromJson: (data) => data,
      );
      return response;
    } catch (e) {
      throw 'Failed to generate seating: $e';
    }
  }

  /// Create a new exam (date + session)
  Future<dynamic> createExam({
    required String examDate,
    required String session,
  }) async {
    try {
      final response = await apiClient.post(
        '/seating/v1/exams/',
        data: {
          'exam_date': examDate,
          'session': session,
        },
        fromJson: (data) => data,
      );
      return response;
    } catch (e) {
      throw 'Failed to create exam: $e';
    }
  }

  /// Get all exams
  Future<List<dynamic>> getExams() async {
    try {
      final response = await apiClient.getList('/seating/v1/exams/');
      return response is List ? response : [response];
    } catch (e) {
      throw 'Failed to fetch exams: $e';
    }
  }

  /// Download seating CSV for all rooms
  Future<Uint8List> downloadSeatingCSV({
    required String examDate,
    required String session,
  }) async {
    try {
      final bytes = await apiClient.downloadBytes(
        '/seating/v1/seating/download-csv/all',
        queryParameters: {
          'exam_date': examDate,
          'session': session,
        },
      );
      return bytes;
    } catch (e) {
      throw 'Failed to download seating CSV: $e';
    }
  }

  /// Get SVG visualization of seating
  Future<String> getSeatingVisualization({
    required String examDate,
    required String session,
    required String roomCode,
  }) async {
    try {
      final response = await apiClient.getList(
        '/seating/v1/seating/svg/by-room',
        queryParameters: {
          'exam_date': examDate,
          'session': session,
          'room_code': roomCode,
        },
      );
      return response.toString();
    } catch (e) {
      throw 'Failed to fetch seating visualization: $e';
    }
  }
}
