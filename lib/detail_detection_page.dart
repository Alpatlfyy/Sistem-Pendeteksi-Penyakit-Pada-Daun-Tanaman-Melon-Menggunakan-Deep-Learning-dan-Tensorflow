import 'package:flutter/material.dart';

class DetailDetectionPage extends StatelessWidget {
  final String result;
  final String confidenceText;
  final String method;
  final String timestamp;
  final String fullText;

  const DetailDetectionPage({
    super.key,
    required this.result,
    required this.confidenceText,
    required this.method,
    required this.timestamp,
    required this.fullText,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF064E3B);
    const Color cardBackground = Color(0xFFEAF5EF);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Detection Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= RESULT CARD =======
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.check_circle, color: primaryColor),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Berdasarkan pengamatan gambar daun melon yang Anda berikan:",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "🌿 $result",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Confidence: $confidenceText", style: const TextStyle(fontSize: 13)),
                  Text("Method: $method", style: const TextStyle(fontSize: 13)),
                  Text("Detected at: $timestamp", style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ======= RECOMMENDATIONS =======
            const Text(
              "Recommendations",
              style: TextStyle(color: primaryColor, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTipCard(
              icon: Icons.medical_services_rounded,
              title: "Treatment",
              subtitle: "Gunakan fungisida sesuai jenis penyakit daun melon yang terdeteksi.",
            ),
            _buildTipCard(
              icon: Icons.sunny,
              title: "Environment",
              subtitle: "Pastikan tanaman mendapat sinar matahari cukup dan sirkulasi udara baik.",
            ),
            _buildTipCard(
              icon: Icons.refresh_rounded,
              title: "Recheck",
              subtitle: "Lakukan pemindaian ulang 3–5 hari untuk memastikan kondisi membaik.",
            ),
            const SizedBox(height: 24),

            // ======= TIPS =======
            const Text(
              "Tips for Accurate Detection",
              style: TextStyle(color: primaryColor, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.camera_alt_rounded,
              text: "Ambil foto daun dengan pencahayaan cukup, tanpa bayangan berat.",
            ),
            _buildInfoCard(
              icon: Icons.filter_center_focus_rounded,
              text: "Pastikan daun terlihat jelas dan tidak buram.",
            ),
            _buildInfoCard(
              icon: Icons.nature_rounded,
              text: "Ambil foto sejajar dengan daun untuk hasil deteksi optimal.",
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF064E3B), size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF064E3B), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
