import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PhotoService {
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<File?> pickImage(
      {required bool fromCamera, required Function(String) onFail}) async {
    File? fileImage;
    if (fromCamera) {
      //get image from camera
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile == null) {
          onFail('No image selected');
        } else {
          fileImage = File(pickedFile.path);
        }
      } catch (e) {
        onFail(e.toString());
      }
    } else {
      //get image form gallery
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile == null) {
          onFail('No image selected');
        } else {
          fileImage = File(pickedFile.path);
        }
      } catch (e) {
        onFail(e.toString());
      }
    }
    return fileImage;
  }

  //pick video from phone
  Future<File?> pickVideo({required Function(String) onFail}) async {
    File? videoFile;

    //get video from gallery
    try {
      final pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFail('No video selected');
      } else {
        videoFile = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
    return videoFile;
  }

  //store image to fire storage
  Future<String> storeImageToStorage({
    required File file,
    required String reference,
  }) async {
    // Reference reference = _storage.ref().child(reference);
    UploadTask uploadTask = _storage.ref(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  //put image path into firestore with their respective person
  Future<void> saveImageToFireStore(File file, String reference) async {
    try {
      String currentUserID = _auth.currentUser!.uid;
      String image_url = await storeImageToStorage(
          file: file, reference: 'Profiles/$reference');
      _fireStore.collection("Users").doc(currentUserID).update({
        'pf_path': image_url,
      });
    } catch (e) {
      throw Exception('Failed to upate the profile image: $e');
    }
  }

  //get profile path
  Future<String> getProfileUrl(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _fireStore.collection("Users").doc(userId).get();
      return userDoc['pf_path'];
    } catch (e) {
      throw Exception('Error fetching username: $e');
    }
  }

  Future<String> storeVideoFileToStorage({
    required File file,
    required String reference,
    String? contentType,
  }) async {
    try {
      // Set the content type if provided
      SettableMetadata metadata = SettableMetadata(contentType: contentType);

      // Upload the file with the correct content type
      UploadTask uploadTask = _storage.ref(reference).putFile(file, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL after the upload is complete
      String fileUrl = await taskSnapshot.ref.getDownloadURL();
      return fileUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
