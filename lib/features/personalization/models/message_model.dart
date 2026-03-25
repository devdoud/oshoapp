import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'SenderId': senderId,
      'Text': text,
      'Timestamp': timestamp,
      'IsRead': isRead,
    };
  }

  factory MessageModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return MessageModel(
      id: snapshot.id,
      senderId: data['SenderId'] ?? '',
      text: data['Text'] ?? '',
      timestamp: (data['Timestamp'] as Timestamp).toDate(),
      isRead: data['IsRead'] ?? false,
    );
  }
}
