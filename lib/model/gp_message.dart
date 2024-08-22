import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessageModel {
  final String messageId;
  final String groupId;
  final String senderId;
  final String senderName;
  final String? textMsg;
  final Timestamp timestamp;
  final String? imageUrl; // Optional, only used if the message is an image
  final String? videoUrl;

  GroupMessageModel({
    required this.messageId,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.textMsg,
    required this.timestamp,
    this.imageUrl,
    this.videoUrl,
  });

  // Convert a GroupMessageModel into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'textMsg': textMsg,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }

  // Convert a Firestore document snapshot into a GroupMessageModel
  factory GroupMessageModel.fromMap(Map<String, dynamic> map) {
    return GroupMessageModel(
      messageId: map['messageId'] as String,
      groupId: map['groupId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      textMsg: map['textMsg'] as String,
      timestamp: map['timestamp'] as Timestamp,
      imageUrl: map['imageUrl'] as String?,
      videoUrl: map['videoUrl'] as String?,
    );
  }
}
