import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String conversationIdFor(String otherId) {
    final me = _auth.currentUser?.uid ?? 'anonymous';
    final pair = [me, otherId]..sort();
    return '${pair.first}__${pair.last}';
  }

  Future<String> ensureConversation({required String otherId, String? otherName}) async {
    final me = _auth.currentUser?.uid ?? 'anonymous';
    final convId = conversationIdFor(otherId);
    final ref = _db.collection('conversations').doc(convId);
    await ref.set({
      'participants': [me, otherId],
      'names': {me: _auth.currentUser?.displayName, otherId: otherName},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return convId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> sendText(String conversationId, String text) async {
    final me = _auth.currentUser?.uid ?? 'anonymous';
    final msgRef = _db.collection('conversations').doc(conversationId).collection('messages').doc();
    await msgRef.set({
      'id': msgRef.id,
      'from': me,
      'type': 'text',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _touchConversation(conversationId);
  }

  Future<void> sendMedia(String conversationId, {required String url, required String type}) async {
    final me = _auth.currentUser?.uid ?? 'anonymous';
    final msgRef = _db.collection('conversations').doc(conversationId).collection('messages').doc();
    await msgRef.set({
      'id': msgRef.id,
      'from': me,
      'type': type, // 'image' | 'video'
      'url': url,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _touchConversation(conversationId);
  }

  Future<void> _touchConversation(String conversationId) async {
    await _db.collection('conversations').doc(conversationId).set({
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
