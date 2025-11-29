import 'package:flutter/material.dart';

class AddMedScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddMedScreen({super.key, this.initialData});

  @override
  State<AddMedScreen> createState() => _AddMedScreenState();
}

class _AddMedScreenState extends State<AddMedScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController instructionCtrl;
  late List<TimeOfDay> times;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.initialData?['name'] ?? '');
    instructionCtrl = TextEditingController(text: widget.initialData?['instruction'] ?? '');
    times = widget.initialData?['times']?.cast<TimeOfDay>() ?? [const TimeOfDay(hour: 8, minute: 0)];
  }

  void addTime() => setState(() => times.add(const TimeOfDay(hour: 8, minute: 0)));

  Future<void> pickTime(int index) async {
    final t = await showTimePicker(context: context, initialTime: times[index]);
    if (t != null) setState(() => times[index] = t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.teal), onPressed: () => Navigator.pop(context)),
        title: Text(widget.initialData != null ? 'Edit medication' : 'Add medication', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medication name', hintText: 'Ibuprofen', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)))),
            const SizedBox(height: 20),
            TextField(controller: instructionCtrl, decoration: const InputDecoration(labelText: 'Dosage & instructions', hintText: '400mg, take with water', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)))),
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text('Reminder times', style: TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(height: 16),
            ...times.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => pickTime(e.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: e.key == 0 ? Colors.teal : Colors.grey, width: e.key == 0 ? 3 : 2))),
                  child: Center(child: Text(times[e.key].format(context), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.teal))),
                ),
              ),
            )),
            TextButton.icon(onPressed: addTime, icon: const Icon(Icons.add_circle_outline, color: Colors.teal), label: const Text('Add another time', style: TextStyle(color: Colors.teal))),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(context, {
                    'name': nameCtrl.text.trim(),
                    'instruction': instructionCtrl.text.trim(),
                    'times': times,
                    'frequency': widget.initialData?['frequency'] ?? 'Every 6 hours',
                    'duration': widget.initialData?['duration'] ?? 'Ongoing',
                    'stopDate': widget.initialData?['stopDate'],
                  });
                },
                child: const Text('SAVE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}