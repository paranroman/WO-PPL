import 'package:eventure/api/database_service.dart';
import 'package:eventure/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentSection extends StatefulWidget {
  final String eventId;
  final String currentUserId;
  final String currentUserName;
  final String? currentUserPhotoUrl;
  final bool isOrganizer;
  final String organizerId;

  const CommentSection({
    super.key,
    required this.eventId,
    required this.currentUserId,
    required this.currentUserName,
    this.currentUserPhotoUrl,
    required this.isOrganizer,
    required this.organizerId,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final Color primaryColor = const Color(0xFFD64A53);
  final TextEditingController _commentController = TextEditingController();
  final DatabaseService _db = DatabaseService();

  bool _isSending = false;

  // For replying
  String? _replyingToCommentId;
  String? _replyingToUserId;
  String? _replyingToUserName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);

    try {
      if (_replyingToCommentId != null) {
        // Sending reply
        await _db.sendReply(
          eventId: widget.eventId,
          commentId: _replyingToCommentId!,
          userId: widget.currentUserId,
          userName: widget.currentUserName,
          userPhotoUrl: widget.currentUserPhotoUrl,
          content: content,
          repliedUserId: _replyingToUserId!,
          repliedUserName: _replyingToUserName!,
        );
      } else {
        // Sending new comment
        await _db.sendComment(
          eventId: widget.eventId,
          userId: widget.currentUserId,
          userName: widget.currentUserName,
          userPhotoUrl: widget.currentUserPhotoUrl,
          content: content,
        );
      }

      _commentController.clear();
      _cancelReply();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengirim: $e',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToUserId = comment.userId;
      _replyingToUserName = comment.userName;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUserId = null;
      _replyingToUserName = null;
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment input section
        _buildCommentInput(),

        const SizedBox(height: 16),

        // Comments list
        StreamBuilder<List<CommentModel>>(
          stream: _db.getCommentStream(widget.eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
              );
            }

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor.withAlpha(100)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.pink.withAlpha(5),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada komentar',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Jadilah yang pertama berkomentar!',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCommentItem(comments[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(12),
        color: Colors.pink.withAlpha(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Replying indicator
          if (_replyingToCommentId != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: Color(0xFFD64A53)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Membalas $_replyingToUserName',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD64A53),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close, size: 16, color: Color(0xFFD64A53)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withAlpha(50),
                backgroundImage:
                    widget.currentUserPhotoUrl != null && widget.currentUserPhotoUrl!.isNotEmpty
                    ? NetworkImage(widget.currentUserPhotoUrl!)
                    : const AssetImage('assets/images/person.png') as ImageProvider,
              ),
              const SizedBox(width: 10),

              // Text field
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLines: 3,
                  minLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: _replyingToCommentId != null
                        ? 'Tulis balasan...'
                        : 'Tulis komentar disini...',
                    hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Send button
              InkWell(
                onTap: _isSending ? null : _sendComment,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    final isCommentOwner = comment.userId == widget.currentUserId;
    final isOrganizerComment = comment.userId == widget.organizerId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withAlpha(80)),
        borderRadius: BorderRadius.circular(12),
        color: isOrganizerComment ? primaryColor.withAlpha(10) : Colors.pink.withAlpha(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: primaryColor.withAlpha(50),
                backgroundImage: comment.userPhotoUrl != null && comment.userPhotoUrl!.isNotEmpty
                    ? NetworkImage(comment.userPhotoUrl!)
                    : const AssetImage('assets/images/person.png') as ImageProvider,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.userName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOrganizerComment) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Panitia',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatTime(comment.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Delete button (only for comment owner or organizer)
              if (isCommentOwner || widget.isOrganizer)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text(
                            'Hapus Komentar?',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          content: const Text(
                            'Komentar beserta balasannya akan dihapus.',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _db.deleteComment(widget.eventId, comment.id);
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Comment content
          Text(comment.content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),

          const SizedBox(height: 8),

          // Reply button
          InkWell(
            onTap: () => _startReply(comment),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.reply, size: 16, color: primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Balas',
                  style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Replies
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: primaryColor.withAlpha(80), width: 2)),
              ),
              child: Column(
                children: comment.replies.map((reply) {
                  return _buildReplyItem(comment.id, reply);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyItem(String commentId, ReplyModel reply) {
    final isReplyOwner = reply.userId == widget.currentUserId;
    final isOrganizerReply = reply.userId == widget.organizerId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: primaryColor.withAlpha(50),
                backgroundImage: reply.userPhotoUrl != null && reply.userPhotoUrl!.isNotEmpty
                    ? NetworkImage(reply.userPhotoUrl!)
                    : const AssetImage('assets/images/person.png') as ImageProvider,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        reply.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOrganizerReply) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'Panitia',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(reply.createdAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Delete reply button
              if (isReplyOwner || widget.isOrganizer)
                InkWell(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text(
                          'Hapus Balasan?',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _db.deleteReply(widget.eventId, commentId, reply.id);
                    }
                  },
                  child: const Icon(Icons.close, size: 14, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: '@${reply.repliedUserName} ',
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: reply.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
