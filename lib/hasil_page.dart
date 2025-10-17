import 'package:flutter/material.dart';

class DetectionResult {
  final String rawGeminiOutput;
  final String method; // "CNN" atau "Gemini"

  DetectionResult({
    required this.rawGeminiOutput,
    required this.method,
  });
}

class HasilPage extends StatelessWidget {
  final DetectionResult result;

  const HasilPage({super.key, required this.result});

  // Bersihkan Markdown dari teks AI
  String _cleanMarkdown(String text) {
    String cleaned = text;

    // Hapus heading Markdown (#, ##, ###)
    cleaned = cleaned.replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '');
    // Hapus bold/italic (** , __ , *, _)
    cleaned = cleaned.replaceAll(RegExp(r'(\*\*|__|\*|_)'), '');
    // Hapus strikethrough (~~)
    cleaned = cleaned.replaceAll('~~', '');
    // Hilangkan baris kosong berlebih
    cleaned = cleaned.replaceAll(RegExp(r'\n{2,}'), '\n\n');
    return cleaned.trim();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF064E3B);

    // Bersihkan teks sebelum ditampilkan
    final String displayText = result.method == "CNN"
        ? result.rawGeminiOutput
        : _cleanMarkdown(result.rawGeminiOutput);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Hasil Deteksi",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Diagnosa AI", primaryColor),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.method == "CNN"
                          ? "Analisis Cepat Offline (CNN):"
                          : "Analisis dari Model Gemini 2.5 Flash:",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Divider(height: 20),
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 14,
                        color: result.method == "CNN" ? Colors.black : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (result.method == "Gemini") ...[
              _buildSectionTitle("Catatan", primaryColor),
              const SizedBox(height: 8),
              const Text(
                "Hasil ini dihasilkan oleh model AI dan harus digunakan sebagai referensi. "
                    "Konsultasikan dengan ahli pertanian untuk konfirmasi.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
