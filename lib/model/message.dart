import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String? message;
  final String? imageUrl;
  final String? videoUrl;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    this.message,
    required this.timestamp,
    this.imageUrl,
    this.videoUrl,
  });

  //convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'],
      senderEmail: map['senderEmail'],
      receiverID: map['receiverID'],
      message: map['message'],
      imageUrl: map['imageUrl'], // Extract image URL
      videoUrl: map['videoUrl'],
      timestamp: map['timestamp'],
    );
  }
}
