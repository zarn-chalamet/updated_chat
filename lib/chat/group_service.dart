import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/model/gp_message.dart';
import 'package:app_chat/model/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final AuthService _authService = AuthService();
  //create Group
  Future<DocumentReference> createGroupInFireStore(
      String groupName, List<String> memberIds) async {
    try {
      DocumentReference groupDoc =
          FirebaseFirestore.instance.collection('groups').doc();
      String groupId = groupDoc.id;

      memberIds.add(_authService.getCurrentUserID());

      GroupModel newGroupChat = GroupModel(
          groupId: groupId,
          groupName: groupName,
          members: memberIds,
          admin: _authService.getCurrentUserID(),
          pf_path:
              "https://firebasestorage.googleapis.com/v0/b/app-chat-97ecb.appspot.com/o/Profiles%2Fprofile_image.jpg?alt=media&token=6ffca4f1-2e1c-4d5c-950b-0e1bd7b2076c",
          createdAt: Timestamp.now());
      // Create a new group in Firestore
      await groupDoc.set(newGroupChat.toMap());
      return groupDoc;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //get group by userId
  Stream<List<Map<String, dynamic>>> getGroupStreams(String userId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .where('members',
            arrayContains: userId) // Filter groups where the user is a member
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return docSnapshot.data() as Map<String, dynamic>;
      }).toList();
    });
  }

  //get group info by gpId
  Future<GroupModel> getGroupInfo(String groupId) async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (groupSnapshot.exists) {
        return GroupModel.fromMap(groupSnapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception("Group not found");
      }
    } catch (e) {
      throw Exception("Failed to get group info: $e");
    }
  }

  Future<void> sendGpMessage(String groupId, String? textMsg,
      {String? imageUrl, String? videoUrl}) async {
    String messageId = FirebaseFirestore.instance
        .collection('groups/$groupId/messages')
        .doc()
        .id;
    GroupMessageModel message = GroupMessageModel(
      messageId: messageId,
      groupId: groupId,
      senderId: _authService.getCurrentUserID(),
      senderName: await _authService.getCurrentUserName(),
      textMsg: textMsg,
      timestamp: Timestamp.now(),
      imageUrl: imageUrl,
      videoUrl: videoUrl,
    );

    await FirebaseFirestore.instance
        .collection('groups/$groupId/messages')
        .doc(messageId)
        .set(message.toMap());
  }

  //get Group Message
  Stream<QuerySnapshot> getGroupMessages(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp',
            descending: false) // Order messages by timestamp, newest first
        .snapshots();
  }
}
