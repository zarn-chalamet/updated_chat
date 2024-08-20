import 'dart:io';

import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:app_chat/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PhotoService _photoService = PhotoService();
  final AuthService _authService = AuthService();

  //get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore
        .collection("Users")
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> users = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Fetch last message timestamps for each user
      final userID =
          _auth.currentUser!.uid; // Assuming you have the current user ID here
      for (var user in users) {
        String receiverID = user['uid'];
        Message? lastMessage = await getLastMessage(userID, receiverID);
        user['lastMessageTimestamp'] =
            lastMessage?.timestamp ?? Timestamp.now();
      }

      // Sort users by the last message timestamp in descending order
      users.sort((a, b) {
        Timestamp? timestampA = a['lastMessageTimestamp'] as Timestamp?;
        Timestamp? timestampB = b['lastMessageTimestamp'] as Timestamp?;
        return timestampB!.compareTo(timestampA!);
      });

      return users;
    });
  }

  //send message
  Future<void> sendMessage(String receiverID,
      {String? message, File? image, String? videoUrl}) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //construct chat room ID for the two users(sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    String? imageUrl;
    // String? videoUrl;

    if (image != null) {
      var uuid = Uuid();
      String uniqueFileName = uuid.v4();
      // Save the image to Firestore and get the URL
      imageUrl = await _photoService.storeImageToStorage(
          file: image, reference: 'chat_images/$chatRoomID/$uniqueFileName');
    }

    // If a video is provided, upload it and get the URL
    // if (video != null) {
    //   var uuid = Uuid();
    //   String uniqueFileName = uuid.v4();
    //   videoUrl = await _photoService.storeImageToStorage(
    //       file: video, reference: 'chat_videos/$chatRoomID/$uniqueFileName');
    // }

    //create a new message
    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        timestamp: timestamp);

    //add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());

    // Update last active time after sending a message
    await _authService.updateUserLastActive(currentUserID);
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get the last message
  Future<Message?> getLastMessage(String userID, String otherUserID) async {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    QuerySnapshot snapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;

      // Check if the last message is a photo or video
      String senderID = data['senderID'];
      String senderEmail = data['senderEmail'];

      String receiverUserName =
          await _authService.getReceiverUsername(otherUserID);

      if (data['message'] == null && data['imageUrl'] != null) {
        return Message(
          senderID: senderID,
          senderEmail: senderEmail,
          receiverID: otherUserID,
          message: senderID == userID
              ? "You sent a photo"
              : "$receiverUserName sent a photo",
          timestamp: data['timestamp'],
        );
      } else if (data['message'] == null && data['videoUrl'] != null) {
        return Message(
          senderID: senderID,
          senderEmail: senderEmail,
          receiverID: otherUserID,
          message: senderID == userID
              ? "You sent a video"
              : "$receiverUserName sent a video",
          timestamp: data['timestamp'],
        );
      } else {
        // Return the original message if it exists
        return Message.fromMap(data);
      }
    } else {
      return null;
    }
  }
}
