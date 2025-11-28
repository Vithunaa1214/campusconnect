import 'package:flutter/material.dart';

/// Attendance page - Quick attendance management
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _selectedClass = 'CS101';
  final List<String> _classes = ['CS101', 'CS202', 'CS303', 'LAB-A1'];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: Color(0xFF222831),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildClassSelector(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAttendanceCard('John Doe', '2021001', true),
                  _buildAttendanceCard('Jane Smith', '2021002', true),
                  _buildAttendanceCard('Mike Johnson', '2021003', false),
                  _buildAttendanceCard('Sarah Williams', '2021004', true),
                  _buildAttendanceCard('Tom Brown', '2021005', false),
                ],
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Select Class:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222831),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedClass,
              isExpanded: true,
              items: _classes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClass = newValue!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(String name, String rollNo, bool isPresent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF00ADB5).withOpacity(0.1),
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                color: Color(0xFF00ADB5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222831),
                  ),
                ),
                Text(
                  rollNo,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF393E46).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isPresent,
            onChanged: (value) {
              setState(() {
                // Update attendance status
              });
            },
            activeColor: const Color(0xFF00ADB5),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance submitted')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00ADB5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Submit Attendance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
