import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference dbRef;
  final Color primaryColor = const Color(0xFF064E3B);

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref("users/${user?.uid}/detections");
  }

  // === Dialog hapus semua data ===
  Future<void> _deleteAll() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_forever_rounded,
                          color: Colors.redAccent, size: 42),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Hapus Semua Riwayat?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Tindakan ini akan menghapus seluruh data riwayat analisis secara permanen.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Batal"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await dbRef.remove();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                    Text("Semua riwayat berhasil dihapus"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Hapus Semua",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // === Hapus satu data ===
  Future<void> _deleteOne(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Riwayat Ini"),
        content: const Text("Apakah kamu yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await dbRef.child(id).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Riwayat berhasil dihapus")),
      );
    }
  }

  // === Build UI ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Riwayat Analisis",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            tooltip: "Hapus Semua Riwayat",
            onPressed: _deleteAll,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: dbRef.orderByChild('timestamp').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Text(
                "Belum ada data riwayat.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final Map<dynamic, dynamic> detections =
          Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final sortedKeys = detections.keys.toList()
            ..sort((a, b) =>
                detections[b]['timestamp'].compareTo(detections[a]['timestamp']));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedKeys.length + 1, // +1 untuk Tips
            itemBuilder: (context, index) {
              if (index == sortedKeys.length) {
                // === Bagian Tips ===
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Tips Penggunaan Riwayat",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "• Geser ke kiri untuk menghapus satu riwayat.\n"
                            "• Tekan ikon tempat sampah di atas untuk menghapus semua riwayat.\n"
                            "• Tekan salah satu item untuk melihat hasil analisis lengkap.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final key = sortedKeys[index];
              final item = Map<String, dynamic>.from(detections[key]);
              final method = item['method'] ?? '-';
              final label = item['label'] ?? '-';
              final fullText = item['fullText'] ?? label;
              final confidence = item['confidence']?.toString() ?? '-';
              final timestamp = item['timestamp'] ?? '-';

              final isGemini = method == "Gemini";

              return Dismissible(
                key: Key(key),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteOne(key),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryDetailPage(
                          label: fullText,
                          confidence: confidence,
                          method: method,
                          timestamp: timestamp,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isGemini
                            ? Colors.blue.shade100
                            : Colors.orange.shade100,
                        child: Icon(
                          isGemini
                              ? Icons.psychology_alt
                              : Icons.memory_rounded,
                          color: isGemini
                              ? Colors.blueAccent
                              : Colors.deepOrange,
                        ),
                      ),
                      title: Text(
                        isGemini ? "Analisis Gemini" : "Klasifikasi CNN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                          isGemini ? Colors.blueAccent : Colors.deepOrange,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                timestamp,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
