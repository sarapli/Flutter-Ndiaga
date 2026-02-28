import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_style.dart';
import '../session.dart';

class DoctorsListScreen extends StatelessWidget {
  const DoctorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Please sign in to see notifications',
            style: TextStyle(color: kMutedTextColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF9CA3B7)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notifications', style: TextStyle(color: kTextColor)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: user.uid)
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load notifications',
                style: TextStyle(color: kMutedTextColor),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            final isDoctor = appSession.role == UserRole.doctor;
            return Center(
              child: Text(
                isDoctor
                    ? 'No messages yet.\nYour patients conversations will appear here.'
                    : 'No messages yet.\nYour doctors conversations will appear here.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kMutedTextColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              // participants: [patientUid, doctorUid]
              final participants = (data['participants'] as List<dynamic>? ?? const [])
                  .map((e) => e.toString())
                  .toList();
              String otherId = user.uid;
              for (final id in participants) {
                if (id != user.uid) {
                  otherId = id;
                  break;
                }
              }

              final namesMap = (data['names'] as Map<String, dynamic>?) ?? const {};
              final otherName = (namesMap[otherId] as String?) ?? 'User';

              final lastType = (data['lastType'] as String?) ?? 'text';
              final lastMessage = (data['lastMessage'] as String?) ?? '';
              final unreadMap = (data['unread'] as Map<String, dynamic>?) ?? const {};
              final unreadCount = (unreadMap[user.uid] as num?)?.toInt() ?? 0;

              String subtitle;
              switch (lastType) {
                case 'image':
                  subtitle = 'Image';
                  break;
                case 'video':
                  subtitle = 'Video';
                  break;
                case 'audio':
                  subtitle = 'Voice message';
                  break;
                default:
                  subtitle = lastMessage.isEmpty ? 'New message' : lastMessage;
              }

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                color: const Color(0xFFF7F8FB),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    // Ouvre le chat avec l’autre participant.
                    Navigator.of(context).pushNamed(
                      AppRoutes.chat,
                      arguments: {
                        'doctor': otherName,
                        'doctorId': otherId,
                      },
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE9EBF2),
                    child: Icon(Icons.chat_bubble_outline, color: kPrimaryColor),
                  ),
                  title: Text(
                    otherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kMutedTextColor),
                  ),
                  trailing: unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}