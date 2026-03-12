import 'package:flutter/material.dart';
import 'package:welding_works/trainer_dashboard.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key, required this.trainee});

  final Trainee trainee;

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final TextEditingController _commentsController = TextEditingController();
  double _safety = 0.8;
  double _prep = 0.7;
  double _arc = 0.75;
  double _bead = 0.6;

  @override
  void initState() {
    super.initState();
    _commentsController.text = widget.trainee.comments;
    if (widget.trainee.assessed) {
      final seed = (widget.trainee.score / 100).clamp(0.0, 1.0);
      _safety = seed;
      _prep = seed;
      _arc = seed;
      _bead = seed;
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  int _score() {
    final avg = (_safety + _prep + _arc + _bead) / 4;
    return (avg * 100).round();
  }

  String _result(int score) {
    if (score >= 75) return 'Passed';
    if (score >= 60) return 'Needs Review';
    return 'Fail';
  }

  void _saveAssessment() {
    final score = _score();
    widget.trainee.assessed = true;
    widget.trainee.score = score;
    widget.trainee.result = _result(score);
    widget.trainee.comments = _commentsController.text.trim();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final score = _score();
    final result = _result(score);

    return Scaffold(
      appBar: AppBar(
        title: Text('Assess: ${widget.trainee.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Score',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: score / 100,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$score%',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Result: $result'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ScoreSlider(
            label: 'Safety & PPE',
            value: _safety,
            onChanged: (value) => setState(() => _safety = value),
          ),
          _ScoreSlider(
            label: 'Joint Preparation',
            value: _prep,
            onChanged: (value) => setState(() => _prep = value),
          ),
          _ScoreSlider(
            label: 'Arc Striking',
            value: _arc,
            onChanged: (value) => setState(() => _arc = value),
          ),
          _ScoreSlider(
            label: 'Bead Formation',
            value: _bead,
            onChanged: (value) => setState(() => _bead = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentsController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Trainer comments',
              hintText: 'Strengths, gaps, and next steps...',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saveAssessment,
            child: const Text('Save Assessment'),
          ),
        ],
      ),
    );
  }
}

class _ScoreSlider extends StatelessWidget {
  const _ScoreSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
