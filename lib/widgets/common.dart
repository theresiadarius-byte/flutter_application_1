import 'package:flutter/material.dart';

Icon favIcon(bool fav) => Icon(fav ? Icons.favorite : Icons.favorite_border,
    color: fav ? Colors.red : Colors.grey);

(String, Color) statusInfo(String? s) => switch (s) {
      'done' => ('Selesai', Colors.green),
      'active' => ('Berjalan', Colors.orange),
      _ => ('Belum', Colors.blueGrey),
    };

IconData statusIcon(String? s) => switch (s) {
      'done' => Icons.check_circle,
      'active' => Icons.play_circle,
      _ => Icons.schedule,
    };

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  const Tag(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final Color color;
  const SummaryCard(this.icon, this.title, this.value,
      {super.key, this.color = Colors.indigo});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      );
}