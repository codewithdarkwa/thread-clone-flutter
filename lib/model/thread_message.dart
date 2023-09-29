// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ThreadMessage {
  final String id;
  final String senderName;
  final String senderProfileImageUrl;
  final String message;
  final DateTime timestamp;
  final int likesCount;
  final int retweetCount;
  final int commentsCount;

  ThreadMessage(
      {required this.id,
      required this.senderName,
      required this.senderProfileImageUrl,
      required this.message,
      required this.timestamp,
      required this.likesCount,
      required this.retweetCount,
      required this.commentsCount});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'senderName': senderName,
      'senderProfileImageUrl': senderProfileImageUrl,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'likesCount': likesCount,
      'retweetCount': retweetCount,
      'commentsCount': commentsCount,
    };
  }

  factory ThreadMessage.fromMap(Map<String, dynamic> map) {
    return ThreadMessage(
      id: map['id'] as String,
      senderName: map['senderName'] as String,
      senderProfileImageUrl: map['senderProfileImageUrl'] as String,
      message: map['message'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      likesCount: map['likesCount'] as int,
      retweetCount: map['retweetCount'] as int,
      commentsCount: map['commentsCount'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ThreadMessage.fromJson(String source) =>
      ThreadMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}

List<ThreadMessage> threadMessages = [
  ThreadMessage(
    id: '1',
    senderName: 'John Doe',
    senderProfileImageUrl: 'assets/profile_1.jpeg',
    message: 'Hello, how are you?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    likesCount: 10,
    commentsCount: 5,
    retweetCount: 2,
  ),
  ThreadMessage(
    id: '2',
    senderName: 'Alice Smith',
    senderProfileImageUrl: 'assets/profile_2.jpeg',
    message: 'I\'m doing well, thanks!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    likesCount: 8,
    commentsCount: 3,
    retweetCount: 1,
  ),
  ThreadMessage(
    id: '3',
    senderName: 'John Doe',
    senderProfileImageUrl: 'assets/profile_3.jpeg',
    message: 'That\'s great to hear!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    likesCount: 6,
    commentsCount: 2,
    retweetCount: 0,
  ),
  ThreadMessage(
    id: '4',
    senderName: 'Eve Williams',
    senderProfileImageUrl: 'assets/profile_4.jpeg',
    message: 'What\'s new with you?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    likesCount: 12,
    commentsCount: 4,
    retweetCount: 3,
  ),
  ThreadMessage(
    id: '5',
    senderName: 'Alice Smith',
    senderProfileImageUrl: 'assets/profile_5.jpeg',
    message: 'I just started a new project at work!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    likesCount: 15,
    commentsCount: 6,
    retweetCount: 2,
  ),
];
