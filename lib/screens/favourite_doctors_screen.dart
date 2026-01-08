import 'package:flutter/material.dart';

import '../app_style.dart';

class FavouriteDoctorsScreen extends StatefulWidget {
  const FavouriteDoctorsScreen({super.key});

  @override
  State<FavouriteDoctorsScreen> createState() => _FavouriteDoctorsScreenState();
}

class _FavouriteDoctorsScreenState extends State<FavouriteDoctorsScreen> {
  final List<_FavDoctor> _items = [
    _FavDoctor('Dr. Mahmud Nik Hasan', 'Cardiologist - Dhaka Medical College Hospital'),
    _FavDoctor('Dr. Winston McCaffrey', 'Cardiologist - Dhaka Medical College Hospital'),
    _FavDoctor('Dr. Brycen Bradford', 'Cardiologist - Dhaka Medical College Hospital'),
    _FavDoctor('Dr. Tierra Riley', 'Cardiologist - Dhaka Medical College Hospital'),
  ];

  _FavDoctor? _lastRemoved;
  int _lastRemovedIndex = -1;

  void _confirmUnlist(int index) async {
    final d = _items[index];
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xCC8E95A6),
      builder: (context) => Center(
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFF0F2F9),
                    child: Icon(Icons.favorite_border, color: kTextColor, size: 30),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4, right: 2),
                    decoration: const BoxDecoration(color: Color(0xFF23A56F), shape: BoxShape.circle),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Unlisted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kTextColor)),
              const SizedBox(height: 8),
              Text('Do you want to unlisted ${d.name} from your favourite list?', textAlign: TextAlign.center, style: const TextStyle(color: kMutedTextColor, height: 1.4)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE8EAF0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: kPrimaryColor,
                      ),
                      child: const Text('Cancel it'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Yes, Unlist it'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (ok == true) {
      setState(() {
        _lastRemoved = d;
        _lastRemovedIndex = index;
        _items.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Doctor unlisted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (_lastRemoved != null && _lastRemovedIndex >= 0) {
                setState(() {
                  _items.insert(_lastRemovedIndex, _lastRemoved!);
                  _lastRemoved = null;
                  _lastRemovedIndex = -1;
                });
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Favourite doctors', style: TextStyle(color: kTextColor)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final d = _items[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))]),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE9EBF2)),
              title: Text(d.name, style: const TextStyle(color: kTextColor)),
              subtitle: Text(d.subtitle, style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: kPrimaryColor),
                onPressed: () => _confirmUnlist(i),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavDoctor {
  final String name;
  final String subtitle;
  _FavDoctor(this.name, this.subtitle);
}
