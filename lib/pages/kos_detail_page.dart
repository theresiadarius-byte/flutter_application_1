import 'package:flutter/material.dart';
import '../services/kos_service.dart';

class KosDetailPage extends StatelessWidget {
  const KosDetailPage({super.key, required this.kosId});

  final String kosId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kos'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: KosService().getById(kosId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError || snap.data == null) {
            return const Center(
              child: Text('Data kos tidak ditemukan atau akses ditolak.'),
            );
          }

          final kos = snap.data!;
          final price = kos['price'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.apartment_rounded,
                              size: 40, color: Colors.indigo),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              kos['name'] ?? 'Tanpa Nama',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              kos['address'] ?? 'Alamat tidak tersedia',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Rp $price / bulan',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.person_pin_outlined,
                              color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Owner ID: ${kos['owner_id'] ?? "-"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule_outlined,
                              color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Dibuat: ${kos['created_at'] != null ? kos['created_at'].toString().substring(0, 10) : "-"}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
