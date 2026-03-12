import 'package:flutter/material.dart';
import 'package:welding_works/admin_dashboard.dart';
import 'package:welding_works/assessment_screen.dart';
import 'package:welding_works/trainee_dashboard.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  final List<_Batch> _batches = [];
  final List<_AssessedRecord> _archive = [];

  Future<void> _openCreateBatchDialog() async {
    final nameController = TextEditingController();
    final traineesController = TextEditingController();

    final result = await showDialog<_Batch>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Batch'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Batch name',
                    hintText: 'Batch A - SMAW NC II',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: traineesController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Trainee names (one per line)',
                    hintText: 'Juan Dela Cruz\nMaria Santos\n... ',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final trainees = traineesController.text
                    .split(RegExp(r'\r?\n'))
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();

                if (name.isEmpty || trainees.isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  _Batch(
                    name: name,
                    createdAt: DateTime.now(),
                    trainees: trainees.map((t) => Trainee(name: t)).toList(),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _batches.insert(0, result);
      });
    }
  }

  void _archiveBatch(_Batch batch) {
    final assessedAt = DateTime.now();
    final records = batch.trainees
        .where((t) => t.assessed)
        .map(
          (t) => _AssessedRecord(
            traineeName: t.name,
            batchName: batch.name,
            assessedAt: assessedAt,
            score: t.score,
          ),
        )
        .toList();

    setState(() {
      _batches.remove(batch);
      _archive.insertAll(0, records);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trainer Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminDashboard(),
                  ),
                );
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Admin panel',
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TraineeDashboard(),
                  ),
                );
              },
              icon: const Icon(Icons.person_outline),
              tooltip: 'Trainee dashboard',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Batches'),
              Tab(text: 'Archive'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openCreateBatchDialog,
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            _BatchesView(
              batches: _batches,
              onOpenBatch: (batch) async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _BatchDetailScreen(
                      batch: batch,
                      onArchive: _archiveBatch,
                    ),
                  ),
                );
                setState(() {});
              },
            ),
            _ArchiveView(records: _archive),
          ],
        ),
      ),
    );
  }
}

class _BatchesView extends StatelessWidget {
  const _BatchesView({
    required this.batches,
    required this.onOpenBatch,
  });

  final List<_Batch> batches;
  final void Function(_Batch batch) onOpenBatch;

  @override
  Widget build(BuildContext context) {
    if (batches.isEmpty) {
      return const Center(
        child: Text('No batches yet. Tap + to create one.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: batches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final batch = batches[index];
        final assessedCount =
            batch.trainees.where((t) => t.assessed).length;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${batch.trainees.length} trainees · '
                  '$assessedCount assessed',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onOpenBatch(batch),
                        child: const Text('Open'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArchiveView extends StatelessWidget {
  const _ArchiveView({required this.records});

  final List<_AssessedRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('No assessed trainees yet.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = records[index];
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(record.traineeName),
          subtitle: Text(
            'Batch: ${record.batchName} · Score: ${record.score}',
          ),
          trailing: Text(
            _formatDate(record.assessedAt),
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        );
      },
    );
  }
}

class _BatchDetailScreen extends StatefulWidget {
  const _BatchDetailScreen({
    required this.batch,
    required this.onArchive,
  });

  final _Batch batch;
  final void Function(_Batch batch) onArchive;

  @override
  State<_BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<_BatchDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final assessedCount =
        widget.batch.trainees.where((t) => t.assessed).length;
    final allAssessed = assessedCount == widget.batch.trainees.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batch.name),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: widget.batch.trainees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final trainee = widget.batch.trainees[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: Text(trainee.name),
              subtitle: Text(
                trainee.assessed
                    ? 'Assessed · Score: ${trainee.score}'
                    : 'Pending assessment',
              ),
              trailing: FilledButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AssessmentScreen(trainee: trainee),
                    ),
                  );
                  setState(() {});
                },
                child: Text(trainee.assessed ? 'Review' : 'Assess'),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: allAssessed
                ? () {
                    widget.onArchive(widget.batch);
                    Navigator.pop(context);
                  }
                : null,
            child: Text(
              allAssessed
                  ? 'Archive Batch ($assessedCount assessed)'
                  : 'Assess all trainees to archive',
            ),
          ),
        ),
      ),
    );
  }
}

class _Batch {
  _Batch({
    required this.name,
    required this.createdAt,
    required this.trainees,
  });

  final String name;
  final DateTime createdAt;
  final List<Trainee> trainees;
}

class Trainee {
  Trainee({
    required this.name,
    this.assessed = false,
    this.score = 0,
    this.result = 'Pending',
    this.comments = '',
  });

  final String name;
  bool assessed;
  int score;
  String result;
  String comments;
}

class _AssessedRecord {
  _AssessedRecord({
    required this.traineeName,
    required this.batchName,
    required this.assessedAt,
    required this.score,
  });

  final String traineeName;
  final String batchName;
  final DateTime assessedAt;
  final int score;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
