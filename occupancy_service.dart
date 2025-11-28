import 'api_client.dart';

class OccupancyService {
  final ApiClient apiClient;

  OccupancyService(this.apiClient);

  /// Get room occupancy data
  Future<List<RoomOccupancy>> getRoomOccupancy() async {
    try {
      final response = await apiClient.getList('/seating/v1/rooms/');
      
      if (response is List) {
        return response
            .map((room) => RoomOccupancy(
                  roomCode: room['code'] ?? 'Unknown',
                  capacity: (room['capacity'] ?? 0).toInt(),
                  currentOccupancy: (room['current_occupancy'] ?? 0).toInt(),
                  status: _getOccupancyStatus(
                    (room['current_occupancy'] ?? 0).toInt(),
                    (room['capacity'] ?? 1).toInt(),
                  ),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      throw 'Failed to fetch occupancy data: $e';
    }
  }

  /// Get detailed occupancy for a specific room
  Future<RoomOccupancy?> getRoomOccupancyDetail(String roomCode) async {
    try {
      final response = await apiClient.getList(
        '/seating/v1/rooms/',
        queryParameters: {'code': roomCode},
      );
      
      if (response is List && response.isNotEmpty) {
        final room = response.first;
        return RoomOccupancy(
          roomCode: room['code'] ?? 'Unknown',
          capacity: (room['capacity'] ?? 0).toInt(),
          currentOccupancy: (room['current_occupancy'] ?? 0).toInt(),
          status: _getOccupancyStatus(
            (room['current_occupancy'] ?? 0).toInt(),
            (room['capacity'] ?? 1).toInt(),
          ),
        );
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch room occupancy: $e';
    }
  }

  String _getOccupancyStatus(int current, int capacity) {
    if (capacity == 0) return 'Unknown';
    
    final percentage = (current / capacity) * 100;
    if (percentage >= 90) {
      return 'Critical';
    } else if (percentage >= 70) {
      return 'High';
    } else if (percentage >= 50) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }
}

class RoomOccupancy {
  final String roomCode;
  final int capacity;
  final int currentOccupancy;
  final String status;

  RoomOccupancy({
    required this.roomCode,
    required this.capacity,
    required this.currentOccupancy,
    required this.status,
  });

  double get occupancyPercentage =>
      capacity > 0 ? (currentOccupancy / capacity) * 100 : 0;
}
