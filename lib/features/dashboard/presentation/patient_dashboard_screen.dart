import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app_routes.dart';
import '../../../app_style.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('DoctorPoint', style: TextStyle(color: kTextColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: kTextColor),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.appointments),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search doctor, categories, topic...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Specialist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
              const SizedBox(height: 12),
              SizedBox(
                height: 88,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('specialties').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load specialties'));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No specialties'));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final label = (data['shortName'] as String?) ?? (data['name'] as String?) ?? 'Specialist';
                        final count = (data['doctorsCount'] as num?)?.toInt() ?? 0;
                        return _SpecialistChip(label: label, count: count);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const _InfoCard(
                title: 'Cardio Issues?',
                subtitle: 'For cardio patient here can easily contact with doctor. Can chat & live chat.',
                priceTag: '\$100',
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Top doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextColor)),
                  Text('View all', style: TextStyle(fontSize: 13, color: kPrimaryColor)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor').limit(10).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load doctors'));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No top doctors'));
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data();
                        final name = (data['name'] as String?) ?? 'Doctor';
                        final specialty = (data['specialtyLabel'] as String?) ?? (data['specialtyId'] as String?) ?? 'Specialist';
                        return _DoctorCard(
                          name: name,
                          specialty: specialty,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorDetail, arguments: doc.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialistChip extends StatelessWidget {
  final String label;
  final int count;
  const _SpecialistChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.doctorsList),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
              const SizedBox(height: 6),
              Text('$count Doctors', style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priceTag;
  const _InfoCard({required this.title, required this.subtitle, required this.priceTag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE7F3F1), borderRadius: BorderRadius.circular(8)),
                child: Text(priceTag, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.4, color: kMutedTextColor)),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final VoidCallback onTap;
  const _DoctorCard({required this.name, required this.specialty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: ColoredBox(color: Color(0xFFE9EBF2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: kTextColor)),
                  const SizedBox(height: 4),
                  Text(specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
