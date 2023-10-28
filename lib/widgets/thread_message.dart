import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thread_clone_flutter/model/thread_message.dart';

class ThreadMessageWidget extends StatelessWidget {
  ThreadMessageWidget({
    super.key,
    required this.message,
    required this.onLike,
    required this.onDisLike,
    required this.onComment,
    required this.panelController,
  });

  final ThreadMessage message;
  final void Function() onLike;
  final void Function() onDisLike;
  final void Function() onComment;

  final PanelController panelController;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(message.senderProfileImageUrl),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        message.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(_getTimeDifference(message.timestamp)),
                      IconButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(Icons.more_horiz),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.message),
                      Row(
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (message.likes.contains(userId)) {
                                    onDisLike();
                                  } else {
                                    onLike();
                                  }
                                },
                                icon: message.likes.contains(userId)
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      )
                                    : const Icon(
                                        Icons.favorite_outline,
                                      ),
                              ),
                              Text(
                                message.likes.isEmpty
                                    ? ''
                                    : message.likes.length.toString(),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  panelController.open();
                                  onComment();
                                },
                                icon: const Icon(Icons.mode_comment_outlined),
                              ),
                              Text(
                                message.comments.isEmpty
                                    ? ''
                                    : message.comments.length.toString(),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/retweet.png',
                                  width: 25,
                                ),
                              ),
                              const Text('')
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/send.png',
                                  width: 25,
                                ),
                              ),
                              const Text(''),
                            ],
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        const Divider()
      ],
    );
  }

  String _getTimeDifference(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr';
    } else {
      return '${difference.inDays} day';
    }
  }
}
