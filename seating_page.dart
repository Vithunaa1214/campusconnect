import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'services/seating_service.dart';

/// Seating arrangement page - Exam seating management
class SeatingPage extends StatefulWidget {
  const SeatingPage({super.key});

  @override
  State<SeatingPage> createState() => _SeatingPageState();
}

class _SeatingPageState extends State<SeatingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late SeatingService _seatingService;
  List<dynamic> _exams = [];
  List<dynamic> _availableRooms = [];
  String? _selectedExamDate;
  String? _selectedSession = 'FN';
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _seatingService = SeatingService(ApiClient());
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exams = await _seatingService.getExams();
      setState(() {
        _exams = exams;
        _isLoading = false;
        if (exams.isNotEmpty) {
          _selectedExamDate = exams.first['exam_date']?.toString();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableRooms() async {
    if (_selectedExamDate == null || _selectedSession == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rooms = await _seatingService.getAvailableRooms(
        examDate: _selectedExamDate!,
        session: _selectedSession!,
      );
      setState(() {
        _availableRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSeating() async {
    if (_selectedExamDate == null || _selectedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exam date and session')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      await _seatingService.generateSeating(
        examDate: _selectedExamDate!,
        session: _selectedSession!,
      );

      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seating generated successfully!')),
      );

      _fetchAvailableRooms();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showCreateExamDialog() async {
    final dateController = TextEditingController();
    String session = 'FN';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Exam'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Exam Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: session,
                items: const [
                  DropdownMenuItem(value: 'FN', child: Text('FN')),
                  DropdownMenuItem(value: 'AN', child: Text('AN')),
                ],
                onChanged: (v) {
                  if (v != null) session = v;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final date = dateController.text.trim();
      if (date.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide an exam date')),
        );
        return;
      }

      try {
        setState(() => _isLoading = true);
        await _seatingService.createExam(examDate: date, session: session);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam created')),
        );
        await _fetchExams();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create exam: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadSeatingCsv() async {
    if (_selectedExamDate == null || _selectedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select exam date and session first')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final Uint8List bytes = await _seatingService.downloadSeatingCSV(
        examDate: _selectedExamDate!,
        session: _selectedSession!,
      );

      final userProfile = Platform.environment['USERPROFILE'] ?? '.';
      final downloadsPath = '$userProfile\\Downloads';
      final fileName = 'seating_${_selectedExamDate}_${_selectedSession}.csv';
      final filePath = '$downloadsPath\\$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved CSV to: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download CSV: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _viewSvgForRoom(String roomCode) async {
    if (_selectedExamDate == null || _selectedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select exam date and session first')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final svg = await _seatingService.getSeatingVisualization(
        examDate: _selectedExamDate!,
        session: _selectedSession!,
        roomCode: roomCode,
      );

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('SVG for $roomCode'),
          content: SingleChildScrollView(
            child: SelectableText(svg ?? 'No SVG available'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load SVG: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text(
          'Exam Seating',
          style: TextStyle(
            color: Color(0xFF222831),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Create Exam',
            onPressed: _showCreateExamDialog,
            icon: const Icon(Icons.add_box, color: Color(0xFF222831)),
          ),
          IconButton(
            tooltip: 'Download CSV',
            onPressed: _downloadSeatingCsv,
            icon: const Icon(Icons.download, color: Color(0xFF222831)),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _exams.isEmpty
                ? _buildErrorWidget()
                : Column(
                    children: [
                      _buildFilterSection(),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_isGenerating)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Generating seating arrangements...'),
                                    ],
                                  ),
                                ),
                              ),
                            if (!_isGenerating && _availableRooms.isNotEmpty)
                              ..._buildRoomsList(),
                            if (!_isGenerating && _availableRooms.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text(
                                    'No rooms available. Generate seating to populate.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateSeating,
        backgroundColor: const Color(0xFF00ADB5),
        child: const Icon(Icons.add),
        tooltip: 'Generate Seating',
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222831),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedExamDate,
                  isExpanded: true,
                  hint: const Text('Select Exam Date'),
                  items: _exams.map<DropdownMenuItem<String>>((exam) {
                    final date = exam['exam_date']?.toString() ?? 'Unknown';
                    return DropdownMenuItem<String>(
                      value: date,
                      child: Text(date),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedExamDate = newValue;
                      _availableRooms = [];
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedSession,
                items: const [
                  DropdownMenuItem(value: 'FN', child: Text('FN')),
                  DropdownMenuItem(value: 'AN', child: Text('AN')),
                ].toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSession = newValue;
                    _availableRooms = [];
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _fetchAvailableRooms,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Fetch Available Rooms'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoomsList() {
    return _availableRooms.asMap().entries.map((entry) {
      final index = entry.key;
      final room = entry.value;
      final roomCode = room['code']?.toString() ?? 'Room $index';
      final capacity = room['capacity'] ?? 0;
      final occupancy = room['current_occupancy'] ?? 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    roomCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222831),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ADB5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Capacity: $capacity',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00ADB5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: capacity > 0 ? occupancy / capacity : 0,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getOccupancyColor(occupancy, capacity),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Occupied: $occupancy / $capacity',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'View SVG',
                    onPressed: () => _viewSvgForRoom(roomCode),
                    icon: const Icon(Icons.image, size: 18),
                  ),
                  IconButton(
                    tooltip: 'Download CSV',
                    onPressed: _downloadSeatingCsv,
                    icon: const Icon(Icons.download, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getOccupancyColor(int current, int capacity) {
    if (capacity == 0) return Colors.grey;

    final percentage = (current / capacity) * 100;
    if (percentage >= 90) {
      return Colors.red;
    } else if (percentage >= 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Exams',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchExams,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ADB5),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
