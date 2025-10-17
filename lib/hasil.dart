import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'detail_detection_page.dart';

class HasilPage extends StatefulWidget {
  const HasilPage({super.key});

  @override
  State<HasilPage> createState() => _HasilPageState();
}

class _HasilPageState extends State<HasilPage> {
  final Color primaryColor = const Color(0xFF064E3B);

  String result = "Loading...";
  String confidenceText = "-";
  String description = "-";
  String method = "-";
  String timestamp = "-";
  String fullText = "-";
  bool isLoading = true;

  StreamSubscription<DatabaseEvent>? _detectionSubscription;

  @override
  void initState() {
    super.initState();
    _listenToUserDetections();
  }

  @override
  void dispose() {
    _detectionSubscription?.cancel();
    super.dispose();
  }

  String generateSummary(String fullText) {
    if (fullText.isEmpty) return "Analisis daun belum tersedia.";
    String clean = fullText
        .replaceAll(RegExp(r'[🌿🔍–—\-•]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    List<String> sentences = clean.split(RegExp(r'(?<=[.!?])\s+'));
    final keywords = ['sehat', 'penyakit', 'bercak', 'jamur', 'virus', 'baik'];

    String? mainSentence = sentences.firstWhere(
          (s) => keywords.any((k) => s.toLowerCase().contains(k)),
      orElse: () => sentences.isNotEmpty ? sentences.first : clean,
    );

    String summary = [mainSentence, if (sentences.length > 1) sentences[1]].join(' ');
    if (summary.length > 220) summary = "${summary.substring(0, 220)}...";
    return summary;
  }

  void _listenToUserDetections() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        result = "User not logged in";
        isLoading = false;
      });
      return;
    }

    _detectionSubscription?.cancel();
    final userDetectionsRef = FirebaseDatabase.instance.ref("users/${user.uid}/detections");

    _detectionSubscription = userDetectionsRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) {
        setState(() {
          result = "No detection history found.";
          isLoading = false;
        });
        return;
      }

      final List<_DetectionEntry> entries = [];
      for (final child in snapshot.children) {
        final Map? data = child.value as Map?;
        if (data == null) continue;

        final label = data['label']?.toString();
        final fullTextRaw = data['fullText']?.toString();
        final method = data['method']?.toString();
        final tsRaw = data['timestamp']?.toString();
        final confRaw = data['confidence'];

        DateTime? ts;
        if (tsRaw != null) {
          try {
            ts = DateTime.parse(tsRaw);
          } catch (_) {
            ts = null;
          }
        }

        double confidence = 0;
        if (confRaw is num) {
          confidence = confRaw.toDouble();
        } else if (confRaw is String) {
          final s = confRaw.replaceAll('%', '').trim();
          final parsed = double.tryParse(s);
          if (parsed != null) confidence = parsed;
        }

        String? labelFinal = label;
        if ((labelFinal == null || labelFinal.isEmpty) && fullTextRaw != null && fullTextRaw.isNotEmpty) {
          labelFinal = generateSummary(fullTextRaw);
        }

        entries.add(
          _DetectionEntry(
            key: child.key,
            label: labelFinal,
            fullText: fullTextRaw,
            confidence: confidence,
            method: method,
            timestamp: ts,
            rawTimestamp: tsRaw,
            rawData: data,
          ),
        );
      }

      _DetectionEntry? newest;
      final withTs = entries.where((e) => e.timestamp != null).toList();
      if (withTs.isNotEmpty) {
        withTs.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
        newest = withTs.first;
      } else if (entries.isNotEmpty) {
        newest = entries.last;
      }

      if (newest == null) {
        setState(() {
          result = "No detection history found.";
          isLoading = false;
        });
        return;
      }

      double conf = newest.confidence ?? 0;
      String confStr;
      if (conf <= 1 && conf > 0) {
        confStr = "${(conf * 100).toStringAsFixed(2)}%";
      } else if (conf > 1 && conf <= 100) {
        confStr = "${conf.toStringAsFixed(conf % 1 == 0 ? 0 : 2)}%";
      } else if (conf == 0 && newest.rawData['confidence'] != null) {
        confStr = newest.rawData['confidence'].toString();
      } else {
        confStr = "-";
      }

      setState(() {
        result = newest?.label ?? "Unknown result";
        confidenceText = confStr;
        method = newest?.method ?? "-";
        timestamp = newest?.rawTimestamp ?? "-";
        fullText = newest?.fullText ?? "-";
        description = "Method: $method • Time: $timestamp";
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Detection Result", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Result Summary"),
            const SizedBox(height: 12),
            _buildResultCard(
              title: result,
              confidence: confidenceText,
              description: description,
              color: result.toLowerCase().contains("mildew") ? Colors.red.shade100 : Colors.green.shade100,
              icon: result.toLowerCase().contains("mildew") ? Icons.warning_amber_rounded : Icons.check_circle,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Next Steps"),
            _buildStep(Icons.medical_services_rounded, "Treatment", "Gunakan fungisida sesuai jenis penyakit daun."),
            _buildStep(Icons.sunny, "Environment", "Pastikan tanaman mendapat cukup cahaya & udara."),
            _buildStep(Icons.refresh, "Recheck", "Pindai ulang dalam 3–5 hari untuk pantauan lanjutan."),
            const SizedBox(height: 24),
            _buildSectionTitle("Tips"),
            const Text(
              "Pastikan foto daun jelas dan dalam pencahayaan baik agar hasil deteksi akurat.",
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String confidence,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailDetectionPage(
                result: title,
                confidenceText: confidence,
                method: method,
                timestamp: timestamp,
                fullText: fullText,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundColor: color, child: Icon(icon, color: primaryColor)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("Confidence: $confidence", style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(description, style: const TextStyle(fontSize: 13.5, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(height: 1.3)),
      ),
    );
  }
}

class _DetectionEntry {
  final String? key;
  final String? label;
  final String? fullText;
  final double? confidence;
  final String? method;
  final DateTime? timestamp;
  final String? rawTimestamp;
  final Map rawData;

  _DetectionEntry({
    this.key,
    this.label,
    this.fullText,
    this.confidence,
    this.method,
    this.timestamp,
    this.rawTimestamp,
    required this.rawData,
  });
}
