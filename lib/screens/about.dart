import 'package:fake_vision/utils/colors.dart';
import 'package:fake_vision/utils/custom_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: colorStatusBar,
      statusBarIconBrightness: Brightness.light,
    ));

    _videoController = VideoPlayerController.asset(
      'Images/fake_vision_video.mp4',
    );

    _videoController.addListener(() {
      setState(() {});
    });

    _initializeVideoPlayer(); // Initialize the video player
  }

  // Function to initialize the video player
  Future<void> _initializeVideoPlayer() async {
    await _videoController.initialize(); // Initialize the controller
    _videoController.setLooping(true); // Loop the video
    _videoController.play(); // Autoplay the video
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
  }

  Widget _buildVideoWidget() {
    if (_videoController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoController.value.isPlaying) {
                    _videoController.pause();
                  } else {
                    _videoController.play();
                  }
                });
              },
              child: AnimatedOpacity(
                opacity: _videoController.value.isPlaying ? 0.0 : 1.0,
                duration: Duration(seconds: 1),
                child: Container(
                  color: Colors.transparent,
                  child: Icon(
                    _videoController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('Images/bg16.png'),
                fit: BoxFit.fill,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [blue, green],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    'FakeVision Blog',
                    style: TextStyle(
                      fontSize: 34.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Video widget
                Container(
                  child: _buildVideoWidget(),
                ),
                SizedBox(height: 20),
                // Content
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cybersecurity faces an emerging threat generally known as deepfakes. Malicious uses of AI-generated synthetic media, the most powerful cyber-weapon in history is just around the corner.Deepfakes are going to be the first real punch from AI to humanity. The cybersecurity industry has a very short time to get ahead of deepfakes before they undermine the public’s trust in reality.',
                        style: smallWhiteTextStyle,textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 20),
                      Text('About Us',style:TextStyle(fontFamily: 'Inter',fontSize: 20,color:whiteColor)),
                      Text('We are a team of three members from Riphah International University, united by our passion for technology and a shared goal to combat emerging threats in the digital realm. Together, we are dedicated to developing a cutting-edge deepfake detection application.',
                      style:smallWhiteTextStyle,textAlign: TextAlign.justify,),
                      SizedBox(height: 20),
                      Text('Our Mission',style:TextStyle(fontFamily: 'Inter',fontSize: 20,color:whiteColor)),
                      Text('At the heart of our mission is the commitment to leveraging advanced algorithms to accurately detect deepfakes. Deepfakes, AI-generated synthetic media, pose a significant challenge to the authenticity of digital content, leading to potential misinformation and deception.',
                      style:smallWhiteTextStyle,textAlign: TextAlign.justify,),
                      SizedBox(height: 20),
                      Text('What we do',style:TextStyle(fontFamily: 'Inter',fontSize: 20,color:whiteColor)),
                      Text('Through our project, we are harnessing the power of innovative algorithms and machine learning techniques to create a robust deepfake detection system. Our goal is not only to detect deepfakes with precision but also to raise awareness within our community about the existence and implications of this technology.',
                      style:smallWhiteTextStyle,textAlign: TextAlign.justify,),
                      SizedBox(height: 20),
                      Text('Why it matters',style:TextStyle(fontFamily: 'Inter',fontSize: 20,color:whiteColor)),
                      Text('In an era where misinformation spreads rapidly across digital platforms, our work holds immense importance. By detecting deepfakes accurately, we aim to safeguard the integrity of digital content, protect individuals from potential harm, and foster a more informed and vigilant online community.',
                      style:smallWhiteTextStyle,textAlign: TextAlign.justify,),
                      SizedBox(height: 20),
                      Text('Join us',style:TextStyle(fontFamily: 'Inter',fontSize: 20,color:whiteColor)),
                      Text('Join us in our mission to combat digital deception and promote digital literacy. Together, we can empower individuals to discern fact from fiction and ensure the integrity of information in the digital age.',
                      style:smallWhiteTextStyle,textAlign: TextAlign.justify,),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
