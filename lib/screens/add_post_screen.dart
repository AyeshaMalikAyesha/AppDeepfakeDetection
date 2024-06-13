import 'dart:convert';
import 'dart:io';

import 'package:fake_vision/providers/user_provider.dart';
import 'package:fake_vision/resources/firestore_methods.dart';
import 'package:fake_vision/utils/colors.dart';
import 'package:fake_vision/utils/custom_text_style.dart';
import 'package:fake_vision/utils/utils.dart';
import 'package:fake_vision/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file; //it can be null
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _videoURL;
  VideoPlayerController? _controller;
  String? _downloadURL;
  String _postType = 'video';
  String label = '';

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(_videoURL!))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
  }

  Widget _videoPreviewWidget() {
    if (_controller != null) {
      return SizedBox(
        height: 200,
        width: 200,
        child: AspectRatio(
          aspectRatio: 387 / 351,
          child: Container(child: VideoPlayer(_controller!)),
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

// Function to upload video to Firebase and post it
  void postVideo(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Post video with description to Firestore
      if (label == 'FAKE') {
        _descriptionController.text =
            'Deepfake Detected\n' + _descriptionController.text;
      }

      String res = await FirestoreMethods().uploadVideo(
          _descriptionController.text,
          _videoURL!,
          uid,
          username,
          profImage,
          _postType!);

      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        // Show success dialog
        successDialogBox(
          context,
          "Success",
          "Posted Successfully",
        );

        clearImageOrVideo();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  _selectImageOrVideo(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: blueColor,
          title: const Text(
            'Create a Post',
            style: TextStyle(fontFamily: 'Inter', color: whiteColor),
          ),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose Image from Gallery',
                    style: TextStyle(fontFamily: 'Inter', color: whiteColor)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                    _postType = 'image';
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose Video from Gallery',
                    style: TextStyle(fontFamily: 'Inter', color: whiteColor)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _videoURL = await pickVideo();
                  setState(() {
                    _isLoading = true;
                  });
                  var request = http.MultipartRequest(
                      'POST',
                      Uri.parse(
                          'https://sparrow-helpful-yearly.ngrok-free.app/predict_media'));
                  // var request = http.MultipartRequest(
                  //     'POST', Uri.parse('http://10.0.2.2:5000/predict_media'));

                  // Add the video file to the request
                  request.files.add(
                      await http.MultipartFile.fromPath('file', _videoURL!));

                  // Send the request
                  var streamedResponse = await request.send();

                  // Get the response
                  var response =
                      await http.Response.fromStream(streamedResponse);

                  // Parse the response data
                  var decoded = jsonDecode(response.body);

                  // Update the output state
                  setState(() {
                    _isLoading = false;
                    label = decoded['label'];
                  });
                  _initializeVideoPlayer();
                }),
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  decoration: BoxDecoration(
                    color: redColor, // Set the background color to red
                    borderRadius: BorderRadius.circular(35), // Rounded corners
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color:
                          Colors.white, // Text color, white for better contrast
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      if (label == 'FAKE') {
        _descriptionController.text =
            'Deepfake Detected\n' + _descriptionController.text;
      }
      String res = await FirestoreMethods().uploadPost(
          _descriptionController.text,
          _file!,
          uid,
          username,
          profImage,
          _postType!);
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        successDialogBox(
          context,
          "Success",
          "Posted Successfully",
        );

        clearImageOrVideo();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImageOrVideo() {
    setState(() {
      _file = null;
      _videoURL = null;
      if (_controller != null) {
        _controller!.pause(); // Pause the video if it's playing
        _controller!.dispose(); // Dispose of the video player controller
        _controller = null; // Set the controller to null
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _file != null
        ? Scaffold(
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: colorStatusBar, // Set the status bar color
                statusBarIconBrightness:
                    Brightness.light, // Status bar icons' color
              ),
              flexibleSpace: Stack(
                children: [
                  // Clipping the background image to the bounds of the AppBar
                  ClipRect(
                    child: Positioned.fill(
                      child: Container(),
                    ),
                  ),
                  // Actual AppBar content

                  Padding(
                    padding: const EdgeInsets.only(left: 55.0, top: 44.0),
                    child: Row(
                      children: [
                        SizedBox(width: 8.0), // Add some spacing
                        Text(
                          "Post to",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Inter',
                            color: blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.cancel_sharp,
                ),
                onPressed: clearImageOrVideo,
              ),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImage(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        fontFamily: 'Inter'),
                  ),
                )
              ],
            ),
            // POST FORM
            body: Column(
              children: <Widget>[
                _isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            userProvider.getUser.photoUrl,
                          ),
                        ),
                        if (label == 'FAKE')
                          Expanded(
                            child: Text(
                              'Deepfake Detected',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: redColor,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              hintText: "What do you want to talk about?",
                              hintStyle: TextStyle(fontFamily: 'Inter'),
                              border: InputBorder.none,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      height: 155.0,
                      width: 135.0,
                      child: AspectRatio(
                        aspectRatio: 387 / 351,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                            image: MemoryImage(_file!),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : _controller != null
            ? Scaffold(
                appBar: AppBar(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: colorStatusBar, // Set the status bar color
                    statusBarIconBrightness:
                        Brightness.light, // Status bar icons' color
                  ),
                  flexibleSpace: Stack(
                    children: [
                      // Clipping the background image to the bounds of the AppBar
                      ClipRect(
                        child: Positioned.fill(
                          child: Container(),
                        ),
                      ),
                      // Actual AppBar content

                      Padding(
                        padding: const EdgeInsets.only(left: 55.0, top: 44.0),
                        child: Row(
                          children: [
                            SizedBox(width: 8.0), // Add some spacing
                            Text(
                              "Post to",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Inter',
                                color: blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.cancel_sharp,
                    ),
                    onPressed: clearImageOrVideo,
                  ),
                  centerTitle: false,
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => postVideo(
                        userProvider.getUser.uid,
                        userProvider.getUser.username,
                        userProvider.getUser.photoUrl,
                      ),
                      child: const Text(
                        "Post",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            fontFamily: 'Inter'),
                      ),
                    )
                  ],
                ),
                // POST FORM
                body: Column(
                  children: <Widget>[
                    _isLoading
                        ? const LinearProgressIndicator()
                        : const Padding(padding: EdgeInsets.only(top: 0.0)),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                userProvider.getUser.photoUrl,
                              ),
                            ),
                            if (label == 'FAKE')
                              Expanded(
                                child: Text(
                                  'Deepfake Detected',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: redColor,
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  hintText: "What do you want to talk about?",
                                  hintStyle: TextStyle(fontFamily: 'Inter'),
                                  border: InputBorder.none,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        _videoURL != null
                            ? _videoPreviewWidget()
                            : const Text("No Video Selected"),
                      ],
                    ),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('Images/bg13.png'), fit: BoxFit.fill),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [blue, green],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        'Upload Image/Video',
                        style: TextStyle(
                          fontSize: 23.0,
                          fontFamily: 'Inter',
                          // The color must be set to white for the gradient to show
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomText(
                      textColor: whiteColor,
                      fontSize: 16.sp,
                      title:
                          "Upload Image or Video to create deepfake awareness among community",
                      textOverFlow: TextOverflow.ellipsis,
                      maxline: 5,
                    ),
                    Lottie.asset(
                      'Images/upload.json',
                      height: 150,
                      width: 150,
                    ),
                    InkWell(
                      onTap: () => _selectImageOrVideo(context),
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color.fromRGBO(53, 102, 172, 1), // light blue
                                Color.fromARGB(255, 106, 175, 169) // dark blue
                              ]),
                        ),
                        child: !_isLoading
                            ? Text(
                                'Upload',
                                style: smallWhiteTextStyle,
                              )
                            : const CircularProgressIndicator(
                                color: whiteColor,
                              ),
                      ),
                    ),
                  ],
                ),
              );
  }
}
