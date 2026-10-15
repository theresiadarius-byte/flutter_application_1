import 'package:flutter/material.dart';
import '../constants.dart';

// TAHAP 1: local state
class DetailToggle extends StatefulWidget {
  const DetailToggle({super.key});
  @override
  State<DetailToggle> createState() => _DetailToggleState();
}

class _DetailToggleState extends State<DetailToggle> {
  bool show = false;
  @override
  Widget build(BuildContext context) => Card(
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.badge, color: Colors.indigo),
            title: const Text('Info Mahasiswa'),
            trailing: Icon(show ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => show = !show),
          ),
          if (show)
            const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('$studentId - $studentName'))),
        ]),
      );
}

// TAHAP 4: ValueNotifier vs setState
class ValueNotifierDemo extends StatefulWidget {
  const ValueNotifierDemo({super.key});
  @override
  State<ValueNotifierDemo> createState() => _ValueNotifierDemoState();
}

class _ValueNotifierDemoState extends State<ValueNotifierDemo> {
  final counter = ValueNotifier<int>(0);
  int setStateCount = 0;
  int parentBuilds = 0;

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    parentBuilds++;
    final big = Theme.of(context)
        .textTheme
        .headlineMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    return Column(children: [
      const Text('$studentId - $studentName', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: Column(children: [
            const Text('ValueNotifier'),
            ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (_, v, __) => Text('$v', style: big),
            ),
            IconButton.filledTonal(
                icon: const Icon(Icons.add), onPressed: () => counter.value++),
          ]),
        ),
        Expanded(
          child: Column(children: [
            const Text('setState'),
            Text('$setStateCount', style: big),
            IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => setStateCount++)),
          ]),
        ),
      ]),
      const SizedBox(height: 8),
      Text(
          'Widget induk dibuild $parentBuilds x. Tombol ValueNotifier tidak menambahnya, '
          'tombol setState menambahnya.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }
}