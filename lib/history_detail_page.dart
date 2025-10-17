import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryDetailPage extends StatelessWidget {
  final String label;
  final String confidence;
  final String method;
  final String timestamp;

  const HistoryDetailPage({
    super.key,
    required this.label,
    required this.confidence,
    required this.method,
    required this.timestamp,
  });

  String _formatTime(String time) {
    try {
      final parsed = DateTime.parse(time);
      return DateFormat('EEEE, dd MMM yyyy • HH:mm').format(parsed);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGemini = method.toLowerCase().contains("gemini");
    final Color primaryColor = isGemini ? Colors.blueAccent : const Color(0xFF064E3B);
    final Color secondaryColor = isGemini ? Colors.blue.shade50 : Colors.green.shade50;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text("Detail Analisis"),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isGemini ? Icons.psychology_alt_rounded : Icons.memory_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGemini ? "Analisis Gemini AI" : "Deteksi CNN Model",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(timestamp),
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // INFO CARD
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Informasi Analisis",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Metode:", style: TextStyle(color: Colors.black54)),
                          Text(method, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Confidence:", style: TextStyle(color: Colors.black54)),
                          Text("$confidence", style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ANALISIS CARD
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hasil Analisis",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          label,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // FOOTER NOTE
              if (isGemini)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Analisis ini dihasilkan oleh model AI Gemini dan bersifat rekomendatif. "
                              "Gunakan sebagai referensi tambahan untuk diagnosis tanaman melon Anda.",
                          style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
