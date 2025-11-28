import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'services/occupancy_service.dart';

/// Occupancy page - Lab and classroom occupancy tracking
class OccupancyPage extends StatefulWidget {
  const OccupancyPage({super.key});

  @override
  State<OccupancyPage> createState() => _OccupancyPageState();
}

class _OccupancyPageState extends State<OccupancyPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late OccupancyService _occupancyService;
  List<RoomOccupancy> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdate;

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _occupancyService = OccupancyService(ApiClient());
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOccupancyData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOccupancyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rooms = await _occupancyService.getRoomOccupancy();
      setState(() {
        _rooms = rooms;
        _lastUpdate = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text(
          'Occupancy',
          style: TextStyle(
            color: Color(0xFF222831),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00ADB5),
          labelColor: const Color(0xFF00ADB5),
          unselectedLabelColor: const Color(0xFF393E46),
          tabs: const [
            Tab(text: 'Labs'),
            Tab(text: 'Classrooms'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null && _rooms.isEmpty
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLabsView(),
                    _buildClassroomsView(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00ADB5),
        onPressed: _isLoading ? null : _fetchOccupancyData,
        tooltip: 'Refresh occupancy data',
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // LABS VIEW
  Widget _buildLabsView() {
    final labs = _rooms.where((r) => r.roomCode.toLowerCase().startsWith('lab')).toList();

    if (labs.isEmpty) return const Center(child: Text('No labs available'));

    return RefreshIndicator(
      onRefresh: _fetchOccupancyData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: labs.map((room) => _buildOccupancyCard(room, Icons.computer)).toList(),
      ),
    );
  }

  // CLASSROOMS VIEW
  Widget _buildClassroomsView() {
    final classrooms = _rooms.where((r) => !r.roomCode.toLowerCase().startsWith('lab')).toList();

    if (classrooms.isEmpty) return const Center(child: Text('No classrooms available'));

    return RefreshIndicator(
      onRefresh: _fetchOccupancyData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: classrooms.map((room) => _buildOccupancyCard(room, Icons.meeting_room)).toList(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text('Error Loading Occupancy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[400])),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_errorMessage ?? 'An unexpected error occurred', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _fetchOccupancyData, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00ADB5)), child: const Text('Retry')),
        ],
      ),
    );
  }

  // CARD COMPONENT
  Widget _buildOccupancyCard(RoomOccupancy room, IconData icon) {
    final occupied = room.currentOccupancy;
    final capacity = room.capacity;
    final percentage = capacity > 0 ? (occupied / capacity) * 100 : 0.0;

    Color statusColor;
    switch (room.status) {
      case 'Critical':
        statusColor = Colors.red;
        break;
      case 'High':
        statusColor = Colors.orange;
        break;
      case 'Medium':
        statusColor = Colors.amber;
        break;
      case 'Low':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF00ADB5).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF00ADB5), size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(room.roomCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222831))), const SizedBox(height: 4), Text('$occupied / $capacity occupied', style: TextStyle(fontSize: 14, color: const Color(0xFF393E46).withOpacity(0.7)))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14))),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (percentage / 100).clamp(0.0, 1.0), backgroundColor: Colors.grey[200], color: statusColor, minHeight: 6)),
        if (_lastUpdate != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Last update: ${_lastUpdate!.toLocal()}', style: TextStyle(fontSize: 12, color: Colors.grey[600])))
      ]),
    );
  }
}
