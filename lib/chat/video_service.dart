import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class VideoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadVideo(File videoFile, String receiverID) async {
    try {
      String fileName =
          'videos/${DateTime.now().millisecondsSinceEpoch}_${videoFile.path.split('/').last}';
      Reference ref = _storage.ref().child(receiverID).child(fileName);
      UploadTask uploadTask = ref.putFile(videoFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Failed to upload video: $e");
      throw e;
    }
  }
}
