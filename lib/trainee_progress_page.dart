import 'package:flutter/material.dart';

class TraineeProgressPage extends StatefulWidget {
  const TraineeProgressPage({super.key});

  @override
  State<TraineeProgressPage> createState() => _TraineeProgressPageState();
}

class _TraineeProgressPageState extends State<TraineeProgressPage> {
  String _oralStatus = 'pending';
  String _writtenStatus = 'pending';
  String _demoStatus = 'pending';
  String _oralDate = '-';
  String _writtenDate = '-';
  String _demoDate = '-';

  String _today() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  bool get _canAssessDemo =>
      _oralStatus == 'competent' && _writtenStatus == 'competent';

  String _labelFor(String status) {
    switch (status) {
      case 'competent':
        return 'Competent';
      case 'not_yet_competent':
        return 'Not Yet Competent';
      default:
        return 'Pending';
    }
  }

  Future<void> _confirmSetStatus({
    required String type,
    required String status,
  }) async {
    final currentStatus = switch (type) {
      'Oral' => _oralStatus,
      'Written' => _writtenStatus,
      _ => _demoStatus,
    };

    if (currentStatus == status) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$type is already ${_labelFor(status)}.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Change'),
        content: Text('Change $type to ${_labelFor(status)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        final date = status == 'competent' ? _today() : '-';
        switch (type) {
          case 'Oral':
            _oralStatus = status;
            _oralDate = date;
            if (!_canAssessDemo) {
              _demoStatus = 'pending';
              _demoDate = '-';
            }
            break;
          case 'Written':
            _writtenStatus = status;
            _writtenDate = date;
            if (!_canAssessDemo) {
              _demoStatus = 'pending';
              _demoDate = '-';
            }
            break;
          case 'Demo':
            _demoStatus = status;
            _demoDate = date;
            break;
        }
      });
    }
  }

  Widget _statusButton({
    required String type,
    required String status,
  }) {
    final isSelected = switch (type) {
      'Oral' => _oralStatus == status,
      'Written' => _writtenStatus == status,
      _ => _demoStatus == status,
    };
    final color = status == 'competent' ? Colors.green : Colors.red;
    return OutlinedButton(
      onPressed: () => _confirmSetStatus(type: type, status: status),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.12) : null,
        side: BorderSide(color: isSelected ? color : Colors.grey.shade400),
      ),
      child: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? color : Colors.grey,
        size: 18,
      ),
    );
  }

  Widget _assessmentRow({
    required String label,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Center(child: _statusButton(type: label, status: 'competent')),
          ),
          Expanded(
            child: Center(child: _statusButton(type: label, status: 'not_yet_competent')),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trainee Progress',
          style: TextStyle(
            color: Color(0xFF005BAC),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMAW NC I',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Trainee: Trainee Name'),
                Text('Email: trainee@email.com'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Assessment Result',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                _HeaderCell('Area', flex: 2),
                _HeaderCell('Competent', flex: 3, allowWrap: false),
                _HeaderCell('Not Yet\nCompetent', flex: 3),
                _HeaderCell('Date\nCompleted', flex: 2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _assessmentRow(label: 'Oral', date: _oralDate),
          _assessmentRow(label: 'Written', date: _writtenDate),
          const SizedBox(height: 6),
          const Text(
            '* Oral and Written must both be Competent before Demo can be assessed.',
            style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (!_canAssessDemo)
                  const Text(
                    'Demo is locked. Oral and Written must both be Competent.',
                    style: TextStyle(color: Colors.redAccent),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Result: ${_labelFor(_demoStatus)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _confirmSetStatus(type: 'Demo', status: 'competent'),
                        child: const Text('Competent'),
                      ),
                      TextButton(
                        onPressed: () => _confirmSetStatus(
                          type: 'Demo',
                          status: 'not_yet_competent',
                        ),
                        child: const Text('Not Yet'),
                      ),
                    ],
                  ),
                  Text(
                    'Date Completed: $_demoDate',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(
    this.text, {
    required this.flex,
    this.allowWrap = true,
  });

  final String text;
  final int flex;
  final bool allowWrap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: allowWrap ? 2 : 1,
          softWrap: allowWrap,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}
