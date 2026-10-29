import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VoiceNoteService {
  final AudioRecorder _record = AudioRecorder();
  String? _filePath;

  /// Start recording
  Future<void> startRecording() async {
    // Check and request permissions
    if (await _record.hasPermission()) {
      final dir = await getTemporaryDirectory();
      _filePath = '${dir.path}/voice.m4a';

      await _record.start(const RecordConfig(), path: _filePath!);
    } else {
      throw Exception('Recording permissions not granted');
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    if (await _record.isRecording()) {
      await _record.stop();
      return _filePath;
    }
    return null;
  }

  /// Upload the recorded file to Firebase
  Future<String> uploadVoiceNote(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) throw Exception('File not found');

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('voice_notes/${DateTime.now().toIso8601String()}.m4a');

      // Upload the file
      final uploadTask = storageRef.putFile(file);

      // Wait for completion
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading voice note: $e');
      rethrow;
    }
  }
}
