import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/video_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<List<VideoModel>> fetchVideos() async {
    final snapshot = await _firestore
        .collection('drama_videos')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<VideoModel>> watchVideos() {
    return _firestore
        .collection('drama_videos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String?> uploadVideo({
    required String title,
    required String description,
    required XFile videoFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      await signInAnonymously();
    }

    final fileName = const Uuid().v4();
    final storageRef = _storage.ref().child('drama_videos/$fileName.mp4');

    try {
      final uploadTask = await storageRef.putData(
        await videoFile.readAsBytes(),
        SettableMetadata(contentType: 'video/mp4'),
      );

      final videoUrl = await uploadTask.ref.getDownloadURL();
      final thumbnailUrl = videoUrl;

      final video = VideoModel(
        id: fileName,
        title: title.isEmpty ? 'Untitled episode' : title,
        description: description,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        ownerId: _auth.currentUser?.uid ?? 'anonymous',
        ownerName: 'Anonymous Creator',
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('drama_videos').doc(fileName).set(video.toMap());
      return videoUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> likeVideo(String videoId) async {
    final videoRef = _firestore.collection('drama_videos').doc(videoId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(videoRef);
      if (!snapshot.exists) return;

      final currentLikes = snapshot.get('likes') ?? 0;
      transaction.update(videoRef, {'likes': currentLikes + 1});
    });
  }

  Future<void> addComment(String videoId, String commentText) async {
    final videoRef = _firestore.collection('drama_videos').doc(videoId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(videoRef);
      if (!snapshot.exists) return;

      final currentComments = snapshot.get('comments') ?? 0;
      transaction.update(videoRef, {'comments': currentComments + 1});
    });
  }
}
