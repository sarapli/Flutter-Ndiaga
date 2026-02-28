import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_style.dart';
import '../app_routes.dart';
import '../session.dart';

class AppointmentsScreen extends StatefulWidget {
  final bool showBottomBar;
  const AppointmentsScreen({super.key, this.showBottomBar = true});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool upcoming = true;


  static String _expandOneHour(String start) {
    // very naive: just return "start - +1h" as mock
    return '$start - 11:00 AM';
  }

  static String _typeLabel(String t) {
    switch (t) {
      case 'voice':
        return 'Voice Call';
      case 'video':
        return 'Video Call';
      default:
        return 'Messaging';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDoctor = appSession.role == UserRole.doctor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My appointments', style: TextStyle(color: kTextColor)),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.incomingCall),
            icon: const Icon(Icons.call, color: kTextColor),
            tooltip: 'Simulate incoming call',
          ),
        ],
      ),
      body: isDoctor
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'This appointments view is reserved for patients.\n\nAs a doctor, please use your Doctor Dashboard to see and manage your patients.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kMutedTextColor, fontSize: 14),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentButton(
                          label: 'Upcoming',
                          selected: upcoming,
                          onTap: () => setState(() => upcoming = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SegmentButton(
                          label: 'Past',
                          selected: !upcoming,
                          onTap: () => setState(() => upcoming = false),
                        ),
                      ),
                    ],
                  ),
                ),
                if (upcoming)
                  Expanded(
                    child: user == null
                        ? const Center(child: Text('Please sign in to see your appointments', style: TextStyle(color: kMutedTextColor)))
                        : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('patientId', isEqualTo: user.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('role', isEqualTo: 'doctor')
                                .snapshots(),
                            builder: (context, doctorSnap) {
                              if (doctorSnap.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final allDocs = doctorSnap.data?.docs ?? [];
                              final docs = allDocs.where((d) {
                                final data = d.data();
                                final name = (data['name'] as String?) ?? '';
                                return name.trim() != 'Version 4.0';
                              }).toList(growable: false);
                              if (docs.isEmpty) {
                                return const Center(
                                  child: Text('No upcoming appointments yet', style: TextStyle(color: kMutedTextColor)),
                                );
                              }

                              final appts = docs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final d = entry.value;
                                final data = d.data();
                                final doctor = (data['name'] as String?) ?? 'Doctor';
                                final doctorId = d.id;
                                final existingAvatar = data['avatarAsset'] as String?;
                                final avatarAsset = existingAvatar ?? _fallbackDoctorAsset(index);

                                // Si aucun avatar n'est encore enregistré pour ce docteur,
                                // on persiste l'avatar de maquette afin qu'il soit réutilisé
                                // partout (search, call ended, compte docteur, etc.).
                                if (existingAvatar == null || existingAvatar.isEmpty) {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(doctorId)
                                      .set({'avatarAsset': avatarAsset}, SetOptions(merge: true));
                                }
                                const type = 'voice';
                                return _ApptItem(
                                  doctor: doctor,
                                  subtitle: _typeLabel(type),
                                  type: type,
                                  timeRange: '09:00 AM - 10:00 AM',
                                  dateLabel: 'Today - 10 June, 2020',
                                  status: 'In Progress',
                                  avatarAsset: avatarAsset,
                                  doctorId: doctorId,
                                );
                              }).toList();

                              return ListView.separated(
                                padding: const EdgeInsets.all(16),
                                physics: const BouncingScrollPhysics(),
                                itemCount: appts.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final it = appts[i];
                                  final baseCard = _AppointmentCard(
                                    item: it,
                                    onTap: () {
                                      // Pour le fallback, tous les rendez-vous sont de type "voice"
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.voiceCall,
                                        arguments: {'doctor': it.doctor},
                                      );
                                    },
                                  );


                                  Widget animatedCard(Widget child) {
                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.94, end: 1.0),
                                      duration: Duration(milliseconds: 320 + (i * 40)),
                                      curve: Curves.easeOutBack,
                                      builder: (context, scale, child) {
                                        final dy = (1.0 - scale) * 24;
                                        return Transform.translate(
                                          offset: Offset(0, dy),
                                          child: Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.identity()
                                              ..setEntry(3, 2, 0.001)
                                              ..rotateX((1.0 - scale) * 0.14)
                                              ..rotateY((1.0 - scale) * -0.10),
                                            child: Transform.scale(
                                              scale: scale,
                                              child: child,
                                            ),
                                          ),
                                        );
                                      },
                                      child: child,
                                    );
                                  }

                                  if (i == 0 || appts[i - 1].dateLabel != it.dateLabel) {
                                    return animatedCard(
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            it.dateLabel,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kMutedTextColor),
                                          ),
                                          const SizedBox(height: 6),
                                          baseCard,
                                        ],
                                      ),
                                    );
                                  }
                                  return animatedCard(baseCard);
                                },
                              );
                            },
                          );
                        }
                        final docs = snapshot.data!.docs;
                        final appts = docs.map((d) {
                          final data = d.data();
                          final type = (data['type'] as String?) ?? 'message';
                          final doctor = (data['doctorName'] as String?) ?? 'Doctor';
                          final doctorId = (data['doctorId'] as String?);
                          final time = (data['time'] as String?) ?? '10:00 AM';
                          final status = (data['status'] as String?) ?? 'Booked';
                          return _ApptItem(
                            doctor: doctor,
                            subtitle: _typeLabel(type),
                            type: type,
                            timeRange: _expandOneHour(time),
                            dateLabel: 'Today - 10 June, 2020',
                            status: status,
                            doctorId: doctorId,
                          );
                        }).toList();
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: appts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final it = appts[i];
                            final baseCard = _AppointmentCard(
                              item: it,
                              onTap: () {
                                final args = {
                                  'doctor': it.doctor,
                                  if (it.doctorId != null) 'doctorId': it.doctorId,
                                };
                                if (it.type == 'message') {
                                  Navigator.of(context).pushNamed(AppRoutes.chat, arguments: args);
                                } else if (it.type == 'voice') {
                                  Navigator.of(context).pushNamed(AppRoutes.voiceCall, arguments: args);
                                } else if (it.type == 'video') {
                                  Navigator.of(context).pushNamed(AppRoutes.videoCall, arguments: args);
                                } else {
                                  Navigator.of(context).pushNamed(AppRoutes.appointmentDetail, arguments: it.toArgs());
                                }
                              },
                            );

                            Widget animatedCard(Widget child) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.94, end: 1.0),
                                duration: Duration(milliseconds: 320 + (i * 40)),
                                curve: Curves.easeOutBack,
                                builder: (context, scale, child) {
                                  final dy = (1.0 - scale) * 24;
                                  return Transform.translate(
                                    offset: Offset(0, dy),
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateX((1.0 - scale) * 0.14)
                                        ..rotateY((1.0 - scale) * -0.10),
                                      child: Transform.scale(
                                        scale: scale,
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: child,
                              );
                            }

                            if (i == 0 || appts[i - 1].dateLabel != it.dateLabel) {
                              return animatedCard(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.dateLabel,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kMutedTextColor),
                                    ),
                                    const SizedBox(height: 6),
                                    baseCard,
                                  ],
                                ),
                              );
                            }
                            return animatedCard(baseCard);
                          },
                        );
                        },
                      ),
                )
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.feed_outlined, size: 96, color: Color(0xFFE9EBF2)),
                          SizedBox(height: 10),
                          Text('You have no appointment in past', style: TextStyle(color: kMutedTextColor)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: widget.showBottomBar ? const _BottomBar(index: 3) : null,
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: selected ? kPrimaryColor : Colors.white,
          foregroundColor: selected ? Colors.white : kTextColor,
          side: const BorderSide(color: kDividerColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label),
      ),
    );
  }
}

class _ApptItem {
  final String doctor;
  final String subtitle; // Voice Call • Accepted
  final String type; // voice | message | video
  final String timeRange;
  final String dateLabel;
  final String status; // Accepted | In Progress | Decline
  final String? avatarAsset;
  final String? doctorId;

  const _ApptItem({
    required this.doctor,
    required this.subtitle,
    required this.type,
    required this.timeRange,
    required this.dateLabel,
    required this.status,
    this.avatarAsset,
    this.doctorId,
  });

  Map<String, dynamic> toArgs() => {
        'doctor': doctor,
        'type': type,
        'timeRange': timeRange,
        'date': dateLabel,
        'status': status,
        'doctorId': doctorId,
      };
}

class _AppointmentCard extends StatelessWidget {
  final _ApptItem item;
  final VoidCallback onTap;
  const _AppointmentCard({required this.item, required this.onTap});

  IconData get _icon => item.type == 'voice'
      ? Icons.call
      : item.type == 'video'
          ? Icons.videocam_outlined
          : Icons.message_outlined;

  Color get _typeColor => item.type == 'message'
      ? const Color(0xFFFF9130)
      : const Color(0xFF6F6F86);

  Color get _statusColor {
    switch (item.status.toLowerCase()) {
      case 'accepted':
      case 'booked':
        return const Color(0xFF1CA796);
      case 'in progress':
        return const Color(0xFFFFA000);
      case 'decline':
      case 'canceled':
        return const Color(0xFFE53935);
      default:
        return kMutedTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0,6))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.avatarAsset == null
                  ? const ColoredBox(
                      color: Color(0xFFE9EBF2),
                      child: SizedBox(width: 66, height: 66),
                    )
                  : Image.asset(
                      item.avatarAsset!,
                      width: 66,
                      height: 66,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_icon, color: _typeColor, size: 16),
                          const SizedBox(width: 6),
                          Text(item.subtitle, style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                        ],
                      ),
                      Text(
                        item.status,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.doctor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextColor)),
                  const SizedBox(height: 4),
                  Text(item.timeRange, style: const TextStyle(fontSize: 12, color: kMutedTextColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  const _BottomBar({required this.index});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: const Color(0xFFB6BACC),
      currentIndex: index,
      onTap: (i) {
        if (i == 0) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.homePatient);
        } else if (i == 1) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.notifications);
        } else if (i == 2) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.search);
        } else if (i == 3) {
        } else if (i == 4) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Appts'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}

String _fallbackDoctorAsset(int index) {
  const assets = [
    'asset/Imagedoctor1.png',
    'asset/imagedoctor2.png',
    'asset/imagedoctor3.png',
    'asset/imagedoctor4.png',
  ];
  return assets[index % assets.length];
}
