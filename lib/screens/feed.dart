import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/thread_logo.png",
                  width: 30,
                ),
                const ThreadMessage(),
                const ThreadMessage(),
                const ThreadMessage(),
                const ThreadMessage(),
                const ThreadMessage(),
                const ThreadMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThreadMessage extends StatelessWidget {
  const ThreadMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/profile.png',
              width: 45,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Jane Doe',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Text('5min'),
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
                      const Text('Hi everyone how are you all ?'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_outline),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.mode_comment_outlined),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/retweet.png',
                              width: 25,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/send.png',
                              width: 25,
                            ),
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
}
