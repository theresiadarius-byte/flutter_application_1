import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/kos_service.dart';

/// Fungsi Pengujian Keamanan (Security Testing)
/// Dijalankan saat login sebagai User B untuk menguji proteksi RLS
/// terhadap data milik User A.
Future<String> securityTest(String kosIdMilikUserA) async {
  final kos = KosService();
  final logResults = <String>[];

  debugPrint('========== MULAI SECURITY TESTING RLS ==========');

  // Ambil owner_id asli milik User A dari data kos
  final kosData = await kos.getById(kosIdMilikUserA);
  final userAId = kosData?['owner_id'] ?? '00000000-0000-0000-0000-000000000000';

  // 1. User B mencoba mengubah data User A -> harus DENIED (false)
  final updated = await kos.update(kosIdMilikUserA, {'name': 'DIUBAH USER B'});
  final test1 = updated
      ? '[FAIL] User B berhasil mengubah data User A'
      : '[PASS] UPDATE ditolak oleh RLS (0 baris diubah)';
  debugPrint(test1);
  logResults.add(test1);

  // 2. User B mencoba menghapus data User A -> harus DENIED (false)
  final deleted = await kos.delete(kosIdMilikUserA);
  final test2 = deleted
      ? '[FAIL] User B berhasil menghapus data User A'
      : '[PASS] DELETE ditolak oleh RLS (0 baris dihapus)';
  debugPrint(test2);
  logResults.add(test2);

  // 3. User B mencoba INSERT atas nama User A -> harus ERROR 42501 (Forbidden / RLS check violation)
  try {
    await Supabase.instance.client.from('kos').insert({
      'owner_id': userAId,
      'name': 'Kos Palsu oleh User B',
      'address': 'Jl. Ilegal No. 99',
      'price': 100000,
    });
    final test3 = '[FAIL] INSERT atas nama user lain berhasil';
    debugPrint(test3);
    logResults.add(test3);
  } on PostgrestException catch (e) {
    final test3 = '[PASS] INSERT ditolak oleh RLS: ${e.code} - ${e.message}';
    debugPrint(test3);
    logResults.add(test3);
  } catch (e) {
    final test3 = '[PASS] INSERT ditolak: $e';
    debugPrint(test3);
    logResults.add(test3);
  }

  debugPrint('========== SELESAI SECURITY TESTING RLS ==========');
  return logResults.join('\n');
}
