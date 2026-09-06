import 'dart:io';

import 'package:eventure/api/storage_service.dart';
import 'package:eventure/models/comment_model.dart';
import 'package:eventure/services/format_date.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eventure/models/user_model.dart';
import 'package:eventure/models/event_model.dart';
import 'package:eventure/models/attendance_model.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<void> saveUserData(UserModel user) async {
    try {
      await _db.ref('users/${user.uid}').set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final snapshot = await _db.ref('users/$uid').get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromFirebase(uid, data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> cariEvent(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    try {
      final snap = await _db.ref('events').get();

      if (!snap.exists || snap.value == null || snap.value is! Map) {
        return [];
      }

      final raw = Map<dynamic, dynamic>.from(snap.value as Map);

      final results = <EventModel>[];

      for (final entry in raw.entries) {
        final key = entry.key.toString();
        final value = entry.value;

        if (value is! Map) continue;

        final map = Map<String, dynamic>.from(value);

        map['id'] ??= key;

        final event = EventModel.fromJson(map);

        final haystack = [
          event.title,
          event.organizerName,
          event.tags,
          event.description,
          event.eventType,
          event.isOnline ? 'online' : 'offline',
        ].join(' ').toLowerCase();

        if (haystack.contains(q)) {
          results.add(event);
        }
      }
      return results;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createEvent(EventModel event) async {
    try {
      final newEventRef = _db.ref('events').push();
      event.id = newEventRef.key;
      await newEventRef.set(event.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent({
    required String eventId,
    required EventModel oldEvent,
    required String title,
    required String organizerName,
    required String description,
    required String tags,
    required String eventType,
    required DateTime eventDay,
    required String startTime,
    required String endTime,
    required bool isOnline,
    required String locationAddress,
    double? locationLat,
    double? locationLng,
    String? onlineLink,
    File? bannerImageFile,
    File? photoImageFile,
    File? skFile,
  }) async {
    try {
      String? bannerDownloadUrl = oldEvent.bannerUrl;
      String? photoDownloadUrl = oldEvent.photoUrl;
      String? skDownloadUrl = oldEvent.skUrl;

      if (bannerImageFile != null) {
        final ext = bannerImageFile.path.split('.').last;
        bannerDownloadUrl = await StorageService().uploadDocument(
          bannerImageFile,
          eventId,
          'banner.$ext',
        );
      }

      if (photoImageFile != null) {
        final ext = photoImageFile.path.split('.').last;
        photoDownloadUrl = await StorageService().uploadDocument(
          photoImageFile,
          eventId,
          'photo.$ext',
        );
      }

      if (skFile != null) {
        final ext = skFile.path.split('.').last;
        skDownloadUrl = await StorageService().uploadDocument(skFile, eventId, 'sk.$ext');
      }

      final updated = EventModel(
        id: eventId,
        title: title,
        description: description,
        locationAddress: isOnline ? 'Online' : locationAddress,
        locationLat: isOnline ? null : locationLat,
        locationLng: isOnline ? null : locationLng,
        organizerId: oldEvent.organizerId,
        organizerName: organizerName,
        startTime: startTime,
        endTime: endTime,
        createdAt: oldEvent.createdAt,
        bannerUrl: bannerDownloadUrl,
        photoUrl: photoDownloadUrl,
        skUrl: skDownloadUrl,
        eventType: eventType,
        eventDay: FormatDate().formatDateForDb(eventDay),
        tags: tags,
        isOnline: isOnline,
        onlineLink: isOnline ? onlineLink : null,
      );

      await _db.ref('events/$eventId').update(updated.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final ref = _db.ref('events/$eventId');
      await StorageService().deleteDocument(ref.child("bannerUrl").toString());
      await StorageService().deleteDocument(ref.child("photoUrl").toString());
      await ref.remove();
    } catch (e) {
      rethrow;
    }
  }

  Stream<DatabaseEvent> getAllEventsStream() {
    return _db.ref('events').onValue;
  }

  Stream<Set<String>> getRegisteredEvent(String userId) async* {
    await for (final ev in _db.ref('events').onValue) {
      final data = ev.snapshot.value;

      if (data == null || data is! Map) {
        yield <String>{};
        continue;
      }

      final raw = Map<dynamic, dynamic>.from(data);

      final registered = <String>{};

      for (final entry in raw.entries) {
        final key = entry.key.toString();
        final value = entry.value;

        if (value is! Map) continue;

        final map = Map<dynamic, dynamic>.from(value);
        final eventId = (map['id'] as String?) ?? key;

        final rsvps = map['rsvps'];
        if (rsvps is Map && rsvps.containsKey(userId)) {
          registered.add(eventId);
        }
      }

      yield registered;
    }
  }

  Stream<DatabaseEvent> getEventStream(String eventId) {
    return _db.ref('events/$eventId').onValue;
  }

  Stream<DatabaseEvent> getUserRsvpStream(String eventId, String userId) {
    return _db.ref('events/$eventId/rsvps/$userId').onValue;
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      final attendanceRef = _db.ref('events/$eventId/rsvps/$userId');
      final newAttendance = AttendanceModel(
        userId: userId,
        eventId: eventId,
        registeredAt: DateTime.now(),
      );
      await attendanceRef.set(newAttendance.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAttendance(String eventId, String userId) async {
    try {
      final attendanceRef = _db.ref('events/$eventId/rsvps/$userId');
      await attendanceRef.update({
        'attended': true,
        'attendedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<DatabaseEvent> getEventAttendanceStream(String eventId, String userId) {
    return _db.ref('events/$eventId/rsvps/$userId/attended').onValue;
  }

  // ============ COMMENT METHODS ============

  /// Stream semua komentar dari suatu event
  Stream<List<CommentModel>> getCommentStream(String eventId) {
    return _db.ref('events/$eventId/comments').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) {
        return <CommentModel>[];
      }

      final raw = Map<dynamic, dynamic>.from(data);
      final comments = <CommentModel>[];

      for (final entry in raw.entries) {
        final commentId = entry.key.toString();
        final commentData = entry.value;

        if (commentData is Map) {
          comments.add(CommentModel.fromJson(commentId, Map<String, dynamic>.from(commentData)));
        }
      }

      // Sort by createdAt descending (newest first)
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return comments;
    });
  }

  /// Kirim komentar baru ke event
  Future<void> sendComment({
    required String eventId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
  }) async {
    try {
      final commentRef = _db.ref('events/$eventId/comments').push();

      final comment = CommentModel(
        id: commentRef.key!,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        createdAt: DateTime.now(),
      );

      await commentRef.set(comment.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Balas komentar yang sudah ada
  Future<void> sendReply({
    required String eventId,
    required String commentId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
    required String repliedUserId,
    required String repliedUserName,
  }) async {
    try {
      final replyRef = _db.ref('events/$eventId/comments/$commentId/replies').push();

      final reply = ReplyModel(
        id: replyRef.key!,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        repliedUserId: repliedUserId,
        repliedUserName: repliedUserName,
        createdAt: DateTime.now(),
      );

      await replyRef.set(reply.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Hapus komentar
  Future<void> deleteComment(String eventId, String commentId) async {
    try {
      await _db.ref('events/$eventId/comments/$commentId').remove();
    } catch (e) {
      rethrow;
    }
  }

  /// Hapus reply
  Future<void> deleteReply(String eventId, String commentId, String replyId) async {
    try {
      await _db.ref('events/$eventId/comments/$commentId/replies/$replyId').remove();
    } catch (e) {
      rethrow;
    }
  }
}
