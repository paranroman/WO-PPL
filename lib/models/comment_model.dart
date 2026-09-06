class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;
  final List<ReplyModel> replies;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
    this.replies = const [],
  });

  factory CommentModel.fromJson(String id, Map<String, dynamic> json) {
    List<ReplyModel> replyList = [];

    if (json['replies'] != null && json['replies'] is Map) {
      final repliesMap = Map<dynamic, dynamic>.from(json['replies'] as Map);
      for (final entry in repliesMap.entries) {
        final replyId = entry.key.toString();
        final replyData = entry.value;
        if (replyData is Map) {
          replyList.add(ReplyModel.fromJson(replyId, Map<String, dynamic>.from(replyData)));
        }
      }
      replyList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return CommentModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Anonim',
      userPhotoUrl: json['userPhotoUrl'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      replies: replyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ReplyModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final String repliedUserId;
  final String repliedUserName;
  final DateTime createdAt;

  ReplyModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.repliedUserId,
    required this.repliedUserName,
    required this.createdAt,
  });

  factory ReplyModel.fromJson(String id, Map<String, dynamic> json) {
    return ReplyModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Anonim',
      userPhotoUrl: json['userPhotoUrl'] as String?,
      content: json['content'] as String? ?? '',
      repliedUserId: json['repliedUserId'] as String? ?? '',
      repliedUserName: json['repliedUserName'] as String? ?? 'Anonim',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'repliedUserId': repliedUserId,
      'repliedUserName': repliedUserName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
