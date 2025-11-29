import 'package:flutter/material.dart';

class ReminderSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> med;
  final Function(Map<String, dynamic>) onSave;

  const ReminderSettingsScreen({
    super.key,
    required this.med,
    required this.onSave,
  });

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  late String _frequency;
  late String _duration;
  late DateTime? _stopDate;

  @override
  void initState() {
    super.initState();
    _frequency = widget.med['frequency'] ?? 'Every 6 hours';
    _duration = widget.med['duration'] ?? 'Ongoing';
    _stopDate = widget.med['stopDate'];
  }

  Future<void> _pickStopDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _stopDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _stopDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reminder settings',
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequency',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'Every 6 hours', child: Text('Every 6 hours')),
                DropdownMenuItem(value: 'Every 4 hours', child: Text('Every 4 hours')),
                DropdownMenuItem(value: 'Every 8 hours', child: Text('Every 8 hours')),
                DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem(value: 'Twice daily', child: Text('Twice daily')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _frequency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Duration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            RadioListTile<String>(
              title: const Text('Ongoing'),
              value: 'Ongoing',
              groupValue: _duration,
              onChanged: (value) {
                setState(() {
                  _duration = value!;
                  if (_duration == 'Ongoing') _stopDate = null;
                });
              },
              activeColor: Colors.teal,
            ),
            RadioListTile<String>(
              title: const Text('Limited time'),
              value: 'Limited time',
              groupValue: _duration,
              onChanged: (value) {
                setState(() {
                  _duration = value!;
                });
              },
              activeColor: Colors.teal,
            ),
            if (_duration == 'Limited time') ...[
              const SizedBox(height: 16),
              const Text(
                'Stop date',
                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickStopDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: const BorderSide(color: Colors.teal, width: 2)),
                  ),
                  child: Text(
                    _stopDate != null
                        ? '${_stopDate!.month}/${_stopDate!.day}/${_stopDate!.year}'
                        : 'Select date',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updatedMed = {
                    ...widget.med,
                    'frequency': _frequency,
                    'duration': _duration,
                    'stopDate': _stopDate,
                  };
                  widget.onSave(updatedMed);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'DONE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}