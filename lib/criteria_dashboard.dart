import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welding_works/app_config.dart';

class CriteriaDashboard extends StatefulWidget {
  const CriteriaDashboard({super.key});

  @override
  State<CriteriaDashboard> createState() => _CriteriaDashboardState();
}

class _CriteriaDashboardState extends State<CriteriaDashboard> {
  bool _isLoading = true;
  String _error = "";
  List<_CriteriaItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadCriteria();
  }

  Future<void> _loadCriteria() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });
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
        throw Exception(data is Map ? (data["message"] ?? "Load failed") : "Load failed");
      }
      final loaded = <_CriteriaItem>[];
      final list = data["criteria"];
      if (list is List) {
        for (final raw in list) {
          if (raw is Map) {
            loaded.add(_CriteriaItem.fromMap(raw));
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _items = loaded;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Criteria Dashboard'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Competency'),
              Tab(text: 'Assessment'),
              Tab(text: 'Grading'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? _ErrorView(message: _error, onRetry: _loadCriteria)
                : TabBarView(
                    children: [
                      _CriteriaList(
                        items: _items.where((i) => i.type == "competency").toList(),
                        categoryOrder: const ["Basic", "Common", "Core"],
                        allowedCategories: const ["Basic", "Common", "Core"],
                      ),
                      _CriteriaList(
                        items: _items.where((i) => i.type == "assessment").toList(),
                        categoryOrder: const [
                          "Perform root pass",
                          "Clean root pass",
                          "Weld subsequent/filling passes",
                          "Perform capping",
                          "Defects (Surface Level)",
                          "Defects (Non-Surface Level)",
                        ],
                        allowedCategories: const [
                          "Perform root pass",
                          "Clean root pass",
                          "Weld subsequent/filling passes",
                          "Perform capping",
                          "Defects (Surface Level)",
                          "Defects (Non-Surface Level)",
                        ],
                      ),
                      _CriteriaList(
                        items: _items.where((i) => i.type == "grading").toList(),
                        categoryOrder: const ["Grading", "Scale"],
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _CriteriaList extends StatelessWidget {
  const _CriteriaList({
    required this.items,
    required this.categoryOrder,
    this.allowedCategories,
  });

  final List<_CriteriaItem> items;
  final List<String> categoryOrder;
  final List<String>? allowedCategories;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No criteria available.'));
    }

    final Set<String>? allowed =
        allowedCategories == null ? null : allowedCategories!.toSet();
    final Map<String, List<_CriteriaItem>> grouped = {};
    for (final item in items) {
      if (allowed != null && !allowed.contains(item.category)) {
        continue;
      }
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final categories = [
      ...categoryOrder.where(grouped.containsKey),
      ...grouped.keys.where((c) => !categoryOrder.contains(c)),
    ];

    if (categories.contains("Grading") || categories.contains("Scale")) {
      return _GradingView(items: items);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final list = grouped[category] ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...list.map(
                (item) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(item.title),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GradingView extends StatelessWidget {
  const _GradingView({required this.items});

  final List<_CriteriaItem> items;

  @override
  Widget build(BuildContext context) {
    final grading = items.where((i) => i.category == "Grading").toList();
    final scale = items.where((i) => i.category == "Scale").toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Grading System",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...grading.map(
          (item) => Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(item.title),
              trailing: item.weightPercent != null
                  ? Text(
                      "${item.weightPercent!.toStringAsFixed(0)}%",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Grade As Follows",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF3F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text("Descriptor", style: TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(flex: 2, child: Text("Grading Scale", style: TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(flex: 2, child: Text("Remark", style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
              ),
              ...scale.map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item.title)),
                      Expanded(flex: 2, child: Text(item.scaleRange ?? "-")),
                      Expanded(flex: 2, child: Text(item.remark ?? "-")),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CriteriaItem {
  _CriteriaItem({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.active,
    this.weightPercent,
    this.scaleRange,
    this.remark,
  });

  final int id;
  final String type;
  final String category;
  final String title;
  final bool active;
  final double? weightPercent;
  final String? scaleRange;
  final String? remark;

  factory _CriteriaItem.fromMap(Map<dynamic, dynamic> raw) {
    return _CriteriaItem(
      id: _parseId(raw["id"]),
      type: (raw["type"] ?? "").toString(),
      category: (raw["category"] ?? "").toString(),
      title: (raw["title"] ?? "").toString(),
      active: (raw["active"] ?? 1).toString() == "1",
      weightPercent: _parseDouble(raw["weight_percent"]),
      scaleRange: _stringOrNull(raw["scale_range"]),
      remark: _stringOrNull(raw["remark"]),
    );
  }
}

int _parseId(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty ? null : str;
}
