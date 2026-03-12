import 'package:flutter/material.dart';

class TraineeDashboard extends StatelessWidget {
  const TraineeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const tesdaBlue = Color(0xFF0B3D91);
    const tesdaGold = Color(0xFFF2C94C);

    final progressItems = [
      _ProgressItem(
        title: 'Safety & PPE',
        score: 92,
        status: 'Passed',
      ),
      _ProgressItem(
        title: 'Joint Preparation',
        score: 78,
        status: 'Needs Review',
      ),
      _ProgressItem(
        title: 'Arc Striking',
        score: 88,
        status: 'Passed',
      ),
      _ProgressItem(
        title: 'Bead Formation',
        score: 64,
        status: 'In Progress',
      ),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trainee Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Progress'),
              Tab(text: 'Reports'),
              Tab(text: 'Evaluation'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: LinearProgressIndicator(
                                  value: 0.72,
                                  minHeight: 10,
                                  backgroundColor: tesdaBlue.withOpacity(0.1),
                                  valueColor:
                                      const AlwaysStoppedAnimation(tesdaBlue),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '72%',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: tesdaBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '4 modules - 2 completed - 1 in progress',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Assessment Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...progressItems.map((item) => _ProgressCard(item: item)),
                const SizedBox(height: 18),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Recommended Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Bead Formation Practice - Level 2'),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: tesdaGold,
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('Start Practice'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const _ReportsTab(),
            const _EvaluationTab(),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.item});

  final _ProgressItem item;

  Color _statusColor() {
    switch (item.status) {
      case 'Passed':
        return Colors.green.shade600;
      case 'Needs Review':
        return Colors.orange.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        title: Text(item.title),
        subtitle: Text('Score: ${item.score}%'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor().withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.status,
            style: TextStyle(
              color: _statusColor(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressItem {
  const _ProgressItem({
    required this.title,
    required this.score,
    required this.status,
  });

  final String title;
  final int score;
  final String status;
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    final reports = [
      _ReportItem('Batch A - SMAW NC II', 'Passed', 86, '2026-03-10'),
      _ReportItem('Batch B - SMAW NC II', 'Needs Review', 72, '2026-03-07'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            title: Text(report.batch),
            subtitle: Text('Score: ${report.score}% - ${report.date}'),
            trailing: _StatusChip(status: report.status),
          ),
        );
      },
    );
  }
}

class _EvaluationTab extends StatefulWidget {
  const _EvaluationTab();

  @override
  State<_EvaluationTab> createState() => _EvaluationTabState();
}

class _EvaluationTabState extends State<_EvaluationTab> {
  double _clarity = 4;
  double _support = 4;
  double _fairness = 4;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Trainer Evaluation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _RatingSlider(
          label: 'Clarity of instruction',
          value: _clarity,
          onChanged: (value) => setState(() => _clarity = value),
        ),
        _RatingSlider(
          label: 'Support and guidance',
          value: _support,
          onChanged: (value) => setState(() => _support = value),
        ),
        _RatingSlider(
          label: 'Fairness of assessment',
          value: _fairness,
          onChanged: (value) => setState(() => _fairness = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _feedbackController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Additional feedback',
            hintText: 'What went well? What can improve?',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Evaluation submitted.')),
            );
            _feedbackController.clear();
          },
          child: const Text('Submit Evaluation'),
        ),
      ],
    );
  }
}

class _RatingSlider extends StatelessWidget {
  const _RatingSlider({
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              label: value.toStringAsFixed(0),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color _color() {
    switch (status) {
      case 'Passed':
        return Colors.green.shade600;
      case 'Needs Review':
        return Colors.orange.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color(),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ReportItem {
  const _ReportItem(this.batch, this.status, this.score, this.date);

  final String batch;
  final String status;
  final int score;
  final String date;
}
