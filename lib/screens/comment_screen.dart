import 'package:flutter/material.dart';
import 'package:sliding_up_panel/src/panel.dart';
import 'package:thread_clone_flutter/model/thread_message.dart';
import 'package:thread_clone_flutter/widgets/thread_message.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({
    super.key,
    required this.message,
    required this.panelController,
  });

  final ThreadMessage message;
  final PanelController panelController;
  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Thread',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ThreadMessageWidget(
                message: widget.message,
                onLike: () {},
                onDisLike: () {},
                onComment: () {},
                panelController: widget.panelController,
              )
            ],
          ),
        ),
      ),
    );
  }
}
