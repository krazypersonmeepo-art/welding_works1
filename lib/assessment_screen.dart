import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:welding_works/app_config.dart';
import 'package:welding_works/trainer_dashboard.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key, required this.trainee});

  final Trainee trainee;

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = "";
  String _demoImageUrl = "";
  String _demoLabel = "";
  String _demoConfidence = "";
  String _demoReason = "";
  bool _hasPerformanceAssessment = false;
  final Map<String, int> _criteriaScores = {};
  bool _criteriaLoaded = false;
  String _oralStatus = 'pending';
  String _writtenStatus = 'pending';
  String _demoStatus = 'pending';
  String _oralDate = '-';
  String _writtenDate = '-';
  String _demoDate = '-';
  String _summaryStatus = '';
  String _summaryResult = '';
  bool _syncingDemoStatus = false;
  final ImagePicker _picker = ImagePicker();
  List<_CriteriaSection> _assessmentSections = [];
  final List<_CriteriaSection> _fallbackSections = [
    _CriteriaSection(
      title: "Perform root pass",
      items: [
        "1.1 Root pass is performed in accordance with WPS and/or client specifications.",
        "1.2 Task is performed in accordance with company or industry requirement and safety procedure.",
        "1.3 Weld is visually checked for defects and repaired, as required.",
        "1.4 Weld is visually acceptable in accordance with applicable codes and standards.",
      ],
    ),
    _CriteriaSection(
      title: "Clean root pass",
      items: [
        "2.1 Root pass is cleaned and free from defects and discontinuities.",
        "2.2 Task is performed in accordance with approved WPS.",
      ],
    ),
    _CriteriaSection(
      title: "Weld subsequent/filling passes",
      items: [
        "3.1 Subsequent/ filling passes is performed in accordance with approved WPS.",
        "3.2 Weld visually is checked for defects and repaired, as required.",
        "3.3 Weld is visually acceptable in accordance with applicable codes and standards.",
      ],
    ),
    _CriteriaSection(
      title: "Perform capping",
      items: [
        "4.1 Capping is performed in accordance with approved WPS and/or client specifications.",
        "4.2 Weld is visually checked for defects and repaired, as required.",
        "4.3 Weld is visually acceptable in accordance with applicable codes and standards.",
      ],
    ),
    _CriteriaSection(
      title: "Defects (Surface Level)",
      isSurfaceDefects: true,
      items: [
        "Porosity",
        "Undercut",
        "Arc Strike",
        "Spatters",
        "Burn Through",
        "Crater cracks",
        "Cracks",
        "Pinholes/Blowholes",
        "Overlap",
        "Misalignment",
      ],
    ),
    _CriteriaSection(
      title: "Defects (Non-Surface Level)",
      items: [
        "Distortion",
        "Slag inclusion",
        "Concavity/convexity",
        "Degree of reinforcement",
        "Lack of Fusion",
        "Under Fill",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAssessmentCriteria().then((_) => _fetchProgress());
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "-";
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }

  int _oralPoints() => _oralStatus == 'competent' ? 25 : 0;
  int _writtenPoints() => _writtenStatus == 'competent' ? 25 : 0;
  static const int _demoMaxPoints = 50;

  int _demoPoints() {
    final sectionItems = _assessmentSections.fold<int>(
      0,
      (sum, section) => sum + section.items.length,
    );
    final totalItems = sectionItems > 0 ? sectionItems : _criteriaScores.length;
    if (totalItems == 0) return 0;
    final scored = _criteriaScores.entries.fold<int>(0, (sum, entry) {
      final isDefect = _isDefectItem(entry.key);
      if (isDefect) {
        return sum + (entry.value == 0 ? 1 : 0);
      }
      return sum + (entry.value == 1 ? 1 : 0);
    });
    final ratio = scored / totalItems;
    return (ratio * _demoMaxPoints).round();
  }

  int _totalPoints() => _oralPoints() + _writtenPoints() + _demoPoints();

  String _totalCompetencyLabel() {
    final total = _totalPoints();
    return total >= 75 ? "Competent" : "Not Yet Competent";
  }

  String _effectiveDemoStatus() {
    return _totalPoints() >= 75 ? 'competent' : 'not_yet_competent';
  }

  bool get _assessmentComplete =>
      _oralStatus != 'pending' &&
      _writtenStatus != 'pending' &&
      _demoStatus != 'pending';

  Future<void> _exportTraineeReport() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln("Trainee Report");
      buffer.writeln("Trainee,${widget.trainee.name}");
      buffer.writeln("Training Center,${widget.trainee.trainingCenter}");
      buffer.writeln("Oral,${_labelFor(_oralStatus)},${_oralDate},${_oralPoints()}");
      buffer.writeln("Written,${_labelFor(_writtenStatus)},${_writtenDate},${_writtenPoints()}");
      buffer.writeln("Demo,${_labelFor(_effectiveDemoStatus())},${_demoDate},${_demoPoints()}");
      buffer.writeln("Total Points,${_totalPoints()}");
      buffer.writeln("Result,${_totalCompetencyLabel()}");

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/trainee_report_${widget.trainee.id}_${DateTime.now().millisecondsSinceEpoch}.csv",
      );
      await file.writeAsString(buffer.toString());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Trainee assessment report",
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: $e")),
      );
    }
  }

  String _resolveImageUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return "";
    final normalizedSlashes = trimmed.replaceAll("\\", "/");
    final parsed = Uri.tryParse(normalizedSlashes);
    final base = Uri.parse(AppConfig.baseHost);

    if (parsed != null && parsed.hasScheme) {
      return normalizedSlashes;
    }

    if (normalizedSlashes.startsWith("/")) {
      return "${base.scheme}://${base.host}${base.hasPort ? ":${base.port}" : ""}$normalizedSlashes";
    }

    return "${AppConfig.weldingApi}/$normalizedSlashes";
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

  Future<void> _fetchProgress() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });
    try {
      final url = Uri.parse("${AppConfig.weldingApi}/get_assessment_progress.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "batch_trainee_id": widget.trainee.id,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception("Server returned ${response.statusCode}");
      }
      final data = jsonDecode(response.body);
      if (data is! Map || data["status"] != "success") {
        throw Exception(data is Map ? (data["message"] ?? "Load failed") : "Load failed");
      }
      final progress = (data["progress"] ?? {}) as Map;
      setState(() {
        _oralStatus = (progress["oral_status"] ?? "pending").toString();
        _writtenStatus = (progress["written_status"] ?? "pending").toString();
        _demoStatus = (progress["demo_status"] ?? "pending").toString();
        _oralDate = _formatDate(progress["oral_date_completed"]?.toString());
        _writtenDate = _formatDate(progress["written_date_completed"]?.toString());
        _demoDate = _formatDate(progress["demo_date_completed"]?.toString());
        final annotated = _resolveImageUrl((progress["demo_annotated_image_url"] ?? "").toString());
        final original = _resolveImageUrl((progress["demo_image_url"] ?? "").toString());
        _demoImageUrl = annotated.isNotEmpty ? annotated : original;
        final saved = (progress["performance_criteria_json"] ?? "").toString();
        if (saved.trim().isNotEmpty) {
          try {
            final decoded = jsonDecode(saved);
            if (decoded is Map) {
              _criteriaScores
                ..clear()
                ..addAll(decoded.map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0)));
              _hasPerformanceAssessment = _criteriaScores.isNotEmpty;
            }
          } catch (_) {}
        }
      });
      await _syncBatchTraineeStatus();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAssessmentCriteria() async {
    try {
      final url = Uri.parse("${AppConfig.weldingApi}/criteria_list.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );
      if (response.statusCode != 200) {
        throw Exception("Server returned ${response.statusCode}");
      }
      final data = jsonDecode(response.body);
      if (data is! Map || data["status"] != "success") {
        throw Exception("Load failed");
      }
      final list = data["criteria"];
      if (list is! List) {
        throw Exception("Load failed");
      }
      final items = <_CriteriaItem>[];
      for (final raw in list) {
        if (raw is Map) {
          items.add(_CriteriaItem.fromMap(raw));
        }
      }

      final assessmentItems = items.where((i) => i.type == "assessment").toList();
      if (assessmentItems.isEmpty) {
        setState(() {
          _assessmentSections = List<_CriteriaSection>.from(_fallbackSections);
          _criteriaLoaded = true;
        });
        return;
      }

      final Map<String, List<String>> grouped = {};
      for (final item in assessmentItems) {
        grouped.putIfAbsent(item.category, () => []).add(item.title);
      }

      final categoryOrder = [
        "Perform root pass",
        "Clean root pass",
        "Weld subsequent/filling passes",
        "Perform capping",
        "Defects (Surface Level)",
        "Defects (Non-Surface Level)",
      ];
      final sections = <_CriteriaSection>[];
      for (final category in categoryOrder) {
        final titles = grouped[category] ?? [];
        if (titles.isEmpty) continue;
        sections.add(
          _CriteriaSection(
            title: category,
            isSurfaceDefects: category == "Defects (Surface Level)",
            items: titles,
          ),
        );
      }
      for (final entry in grouped.entries) {
        if (categoryOrder.contains(entry.key)) continue;
        sections.add(_CriteriaSection(title: entry.key, items: entry.value));
      }

      setState(() {
        _assessmentSections = sections.isEmpty
            ? List<_CriteriaSection>.from(_fallbackSections)
            : sections;
        _criteriaLoaded = true;
      });
      await _syncBatchTraineeStatus();
    } catch (_) {
      setState(() {
        _assessmentSections = List<_CriteriaSection>.from(_fallbackSections);
        _criteriaLoaded = true;
      });
      await _syncBatchTraineeStatus();
    }
  }

  Future<void> _updateAssessment({
    required String type,
    required String status,
  }) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final url = Uri.parse("${AppConfig.weldingApi}/update_assessment_progress.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "batch_trainee_id": widget.trainee.id,
          "assessment_type": type.toLowerCase(),
          "status": status,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception("Server returned ${response.statusCode}");
      }
      final data = jsonDecode(response.body);
      if (data is! Map || data["status"] != "success") {
        final message = data is Map ? (data["message"] ?? "Update failed") : "Update failed";
        throw Exception(message);
      }
      if (!mounted) return;
      await _fetchProgress();
      await _syncBatchTraineeStatus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _syncBatchTraineeStatus() async {
    if (!_criteriaLoaded) {
      return;
    }
    final allDone = _oralStatus != 'pending' &&
        _writtenStatus != 'pending' &&
        _demoStatus != 'pending';
    final summaryResult = allDone ? 'Assessed' : 'Pending';
    final summaryStatus = _totalPoints() >= 75 ? 'Competent' : 'Not Yet Competent';
    if (summaryStatus == _summaryStatus && summaryResult == _summaryResult) {
      return;
    }

    _summaryResult = summaryResult;
    _summaryStatus = summaryStatus;
    widget.trainee.result = summaryResult;
    widget.trainee.status = summaryStatus;

    try {
      final url = Uri.parse("${AppConfig.weldingApi}/update_trainee_status.php");
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "batch_trainee_id": widget.trainee.id,
          "status": summaryStatus,
          "result": summaryResult,
        }),
      );
    } catch (_) {
      // Ignore sync errors; will retry on next fetch.
    }

    final desiredDemo = _totalPoints() >= 75 ? 'competent' : 'not_yet_competent';
    final needsDemoDate = desiredDemo == 'competent' && (_demoDate == '-' || _demoDate.isEmpty);
    if (( _demoStatus != desiredDemo || needsDemoDate) && !_syncingDemoStatus) {
      _syncingDemoStatus = true;
      try {
        if (needsDemoDate && mounted) {
          setState(() {
            _demoDate = _formatDate(DateTime.now().toIso8601String());
          });
        }
        await _updateAssessment(type: 'Demo', status: desiredDemo);
      } finally {
        _syncingDemoStatus = false;
      }
    }
  }

  Future<void> _uploadAndAssessDemo(XFile imageFile) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final uri = Uri.parse("${AppConfig.weldingApi}/assess_demo_yolo.php");
      final request = http.MultipartRequest("POST", uri)
        ..fields["batch_trainee_id"] = widget.trainee.id.toString()
        ..files.add(await http.MultipartFile.fromPath("demo_image", imageFile.path));

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final data = jsonDecode(body);
      if (data is! Map || data["status"] != "success") {
        final message = data is Map ? (data["message"] ?? "Assessment failed") : "Assessment failed";
        throw Exception(message);
      }
      _demoLabel = (data["label"] ?? "").toString();
      _demoConfidence = (data["confidence"] ?? "").toString();
      _demoReason = (data["reason"] ?? "").toString();
      final annotated = _resolveImageUrl((data["annotated_image_url"] ?? "").toString());
      final original = _resolveImageUrl((data["original_image_url"] ?? "").toString());
      _demoImageUrl = annotated.isNotEmpty ? annotated : original;
      _resetCriteriaScores();
      if (_demoLabel.toLowerCase() == "good welding") {
        _applySurfaceDefectsScore(0);
      } else {
        _applySurfaceDefectsScore(1);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("YOLO: ${_demoLabel.isEmpty ? "No label" : _demoLabel}")),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("YOLO Result"),
          content: Text(
            _demoLabel.isEmpty ? "Result ready." : "${_demoLabel} detected.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Continue"),
            ),
          ],
        ),
      );
      final updated = await _showPerformanceCriteriaDialog();
      if (updated) {
        await _savePerformanceCriteria();
        await _syncBatchTraineeStatus();
      }
      await _fetchProgress();
      if (_demoImageUrl.isNotEmpty && mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("YOLO Result"),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    _demoImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Text("Unable to load image."),
                  ),
                  if (_demoLabel.isNotEmpty || _demoConfidence.isNotEmpty || _demoReason.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text("Label: $_demoLabel"),
                    if (_demoConfidence.isNotEmpty) Text("Confidence: $_demoConfidence"),
                    if (_demoReason.isNotEmpty) Text("Reason: $_demoReason"),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("YOLO failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _applyAllCriteriaScore(int score) {
    if (_assessmentSections.isEmpty) return;
    for (final section in _assessmentSections) {
      for (final item in section.items) {
        _criteriaScores[item] = score;
      }
    }
    _hasPerformanceAssessment = true;
  }

  void _applySurfaceDefectsScore(int score) {
    if (_assessmentSections.isEmpty) return;
    for (final section in _assessmentSections) {
      if (!section.isSurfaceDefects) continue;
      for (final item in section.items) {
        _criteriaScores[item] = score;
      }
    }
    _hasPerformanceAssessment = true;
  }

  void _resetCriteriaScores() {
    _criteriaScores.clear();
    for (final section in _assessmentSections) {
      for (final item in section.items) {
        _criteriaScores[item] = 0;
      }
    }
    _hasPerformanceAssessment = true;
  }

  bool _isDefectItem(String item) {
    for (final section in _assessmentSections) {
      if (section.isSurfaceDefects || section.title.toLowerCase().contains("defects")) {
        if (section.items.contains(item)) return true;
      }
    }
    return false;
  }

  Future<bool> _showPerformanceCriteriaDialog() async {
    final tempScores = Map<String, int>.from(_criteriaScores);
    for (final section in _assessmentSections) {
      for (final item in section.items) {
        tempScores.putIfAbsent(item, () => 0);
      }
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Assessment Criteria"),
              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tap 1 or 0 for each criteria.",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      ..._assessmentSections.map(
                        (section) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  section.title,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                ...section.items.map((item) {
                                  final value = tempScores[item] ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: const TextStyle(height: 1.3),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _ScoreRadio(
                                          value: value,
                                          onChanged: (next) {
                                            setDialogState(() => tempScores[item] = next);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _criteriaScores
                        ..clear()
                        ..addAll(tempScores);
                      _hasPerformanceAssessment = true;
                    });
                    _savePerformanceCriteria();
                    Navigator.pop(context, true);
                  },
                  child: const Text("Continue"),
                ),
              ],
            );
          },
        );
      },
    );
    return result == true;
  }

  Future<void> _savePerformanceCriteria() async {
    try {
      final url = Uri.parse("${AppConfig.weldingApi}/update_performance_criteria.php");
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "batch_trainee_id": widget.trainee.id,
          "criteria_scores": _criteriaScores,
        }),
      );
      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _pickAndAssessDemoImage() async {
    final hasPriorDemo = _demoDate != '-' || _demoStatus != 'pending' || _demoImageUrl.isNotEmpty;
    if (hasPriorDemo) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reassess Demo'),
          content: const Text('A demo assessment already exists. Reassess and overwrite it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reassess'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assess Demo with YOLO"),
        content: const Text("Choose image source"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text("Gallery"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text("Camera"),
          ),
        ],
      ),
    );

    if (source == null) return;
    final image = await _picker.pickImage(source: source, imageQuality: 90);
    if (image == null) return;
    if (!File(image.path).existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected image file is unavailable.")),
      );
      return;
    }
    if (!_criteriaLoaded) {
      await _loadAssessmentCriteria();
    }
    await _uploadAndAssessDemo(image);
  }

  Future<void> _showDemoPreview(String imageUrl) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Demo Image Preview"),
        content: SizedBox(
          width: 360,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Unable to load demo image preview."),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
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

    if (type == 'Demo' && !_canAssessDemo) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demo is locked. Oral and Written must both be Competent."),
        ),
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
      await _updateAssessment(type: type, status: status);
      await _syncBatchTraineeStatus();
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
      onPressed: _isSaving ? null : () => _confirmSetStatus(type: type, status: status),
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
              style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final className = widget.trainee.trainingCenter.isNotEmpty
        ? widget.trainee.trainingCenter
        : 'SMAW NC I';
    final traineeName =
        widget.trainee.name.isNotEmpty ? widget.trainee.name : 'Trainee';

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
        actions: [
          if (_assessmentComplete)
            IconButton(
              onPressed: _exportTraineeReport,
              icon: const Icon(Icons.download_outlined),
              tooltip: 'Export report',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  className,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Trainee: $traineeName'),
                                const Text('Email: trainee@email.com'),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total Points',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_totalPoints()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                _totalCompetencyLabel(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _totalPoints() >= 75 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Oral: ${_oralPoints()} pts',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Written: ${_writtenPoints()} pts',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Demo: ${_demoPoints()} pts',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '* Oral and Written must both be Competent before Demo can be accessed.',
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
                                    'Result: ${_labelFor(_effectiveDemoStatus())}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Date Completed: $_demoDate',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _isSaving ? null : _pickAndAssessDemoImage,
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text("Assess with YOLO"),
                              ),
                            ),
                          ],
                            const SizedBox(height: 8),
                            if (_demoImageUrl.isNotEmpty)
                              GestureDetector(
                                onTap: () => _showDemoPreview(_demoImageUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _demoImageUrl,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 140,
                                      color: const Color(0xFFEFF3F9),
                                      alignment: Alignment.center,
                                      child: const Text('Unable to load demo image'),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF3F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Text('No demo image uploaded yet'),
                              ),
                        ],
                      ),
                    ),
                    if (_hasPerformanceAssessment) ...[
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
                              "Performance Criteria",
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            ..._assessmentSections.map(
                              (section) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(section.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    ...section.items.map(
                                      (item) => Row(
                                        children: [
                                          Expanded(child: Text(item)),
                                          Text(
                                            (_criteriaScores[item] ?? 0).toString(),
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _CriteriaSection {
  const _CriteriaSection({
    required this.title,
    required this.items,
    this.isSurfaceDefects = false,
  });

  final String title;
  final List<String> items;
  final bool isSurfaceDefects;
}

class _ScoreRadio extends StatelessWidget {
  const _ScoreRadio({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<int>(
          value: 1,
          groupValue: value,
          onChanged: (_) => onChanged(1),
        ),
        const Text("1"),
        const SizedBox(width: 6),
        Radio<int>(
          value: 0,
          groupValue: value,
          onChanged: (_) => onChanged(0),
        ),
        const Text("0"),
      ],
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

class _CriteriaItem {
  _CriteriaItem({
    required this.type,
    required this.category,
    required this.title,
  });

  final String type;
  final String category;
  final String title;

  factory _CriteriaItem.fromMap(Map<dynamic, dynamic> raw) {
    return _CriteriaItem(
      type: (raw["type"] ?? "").toString(),
      category: (raw["category"] ?? "").toString(),
      title: (raw["title"] ?? "").toString(),
    );
  }
}
