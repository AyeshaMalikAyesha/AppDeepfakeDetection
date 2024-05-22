import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_vision/screens/main_app_screen.dart';
import 'package:fake_vision/utils/colors.dart';
import 'package:fake_vision/widgets/app_bar/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late String userId;

  @override
  void initState() {
    super.initState();
    // Set the status bar color when the screen is created
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: colorStatusBar, // Set your desired status bar color
      statusBarIconBrightness: Brightness.light,
    ));
    getUserID();
  }

  // Function to get the current user's ID
  void getUserID() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      setState(() {
        userId = auth.currentUser!.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'History',
        paddingTop: 27,
        backButtonScreen: MainAppScreen(),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('history')
            .doc(userId)
            .collection('entries')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot entry = snapshot.data!.docs[index];
                String result = entry['result'];
                String confidence = entry['confidence'];
                Timestamp timestamp = entry['timestamp'];
                DateTime dateTime = timestamp.toDate();
                String formattedDateTime =
                    DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
                String filePath = entry['file_path'];
                String type = entry['type'];

                return Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    // Delete the item from Firebase
                    FirebaseFirestore.instance
                        .collection('history')
                        .doc(userId)
                        .collection('entries')
                        .doc(entry.id)
                        .delete();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Row to display image or video and other information
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Display image or video based on filePath
                          filePath.toLowerCase().endsWith('.mp4')
                              ? VideoWidget(filePath)
                              : ImageWidget(filePath),
                          // Display other information in a column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type:$type'),
                              Text('Result: $result'),
                              Text('Confidence: $confidence'),
                              Text('Timestamp: $formattedDateTime'),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final String imagePath;

  ImageWidget(this.imagePath);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    print('Image Path: ${widget.imagePath}');
    return Container(
      width: 100, // Set a specific width
      height: 100, // Set a specific height
      child: Image.file(
        File(widget.imagePath),
        fit: BoxFit.cover,
      ),
    );
  }
}


class VideoWidget extends StatefulWidget {
  final String videoPath;

  VideoWidget(this.videoPath);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _toggleVideoPlayback() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleVideoPlayback,
      child: Container(
        width: 100, // Set a specific width
        height: 100, // Set a specific height
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
