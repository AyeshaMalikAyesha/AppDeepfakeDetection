import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_vision/screens/main_app_screen.dart';
import 'package:fake_vision/utils/colors.dart';
import 'package:fake_vision/utils/custom_text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class OutputScreen extends StatefulWidget {
  String file_path;
  String type;
  String label;
  String confidence;
  String imageStr;

  OutputScreen(
      {super.key,
      required this.file_path,
      required this.type,
      required this.label,
      required this.confidence,
      required this.imageStr});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  bool _isLoading = false;
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: colorStatusBar,
      statusBarIconBrightness: Brightness.light,
    ));
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      String userId = auth.currentUser!.uid;
      saveDataToFirestore(userId, widget.label, widget.confidence,
          widget.file_path, widget.type);
    }
  }

  void saveDataToFirestore(String userId, String result, String confidence,
      String filePath, String type) {
    FirebaseFirestore.instance
        .collection('history')
        .doc(userId)
        .collection('entries')
        .add({
      'result': result,
      'confidence': confidence,
      'type': type,
      'file_path': filePath,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      print("Data added to Firestore successfully!");
    }).catchError((error) {
      print("Failed to add data: $error");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('Images/bg13.png'), fit: BoxFit.cover)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => MainAppScreen()),
                        );
                      },
                      child: Icon(Icons.cancel_sharp,
                          size: 30.0, color: whiteColor),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [blue, green],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    'Model Results',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                    height: 180, width: 180, child: _guageIndicator(context)),
                SizedBox(width: 90),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        "File:",
                        style: smallWhiteTextStyle,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.file_path,
                            style: smallWhiteTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 10),
                        child: Text(
                          "Type:",
                          style: smallWhiteTextStyle,
                        ),
                      ),
                      Text(widget.type, style: smallWhiteTextStyle)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 10),
                        child: Text(
                          "Confidence of Prediction:",
                          style: smallWhiteTextStyle,
                        ),
                      ),
                      Text(widget.confidence, style: smallWhiteTextStyle)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 10),
                        child: Text(
                          "Result:",
                          style: smallWhiteTextStyle,
                        ),
                      ),
                      widget.label == 'REAL'
                          ? Text(widget.label,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 38, 235, 55),
                                  fontSize: 15,
                                  fontFamily: 'Inter'))
                          : Text(widget.label,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 235, 51, 38),
                                  fontSize: 15,
                                  fontFamily: 'Inter'))
                    ],
                  ),
                ),
                SizedBox(height: 20),
                if (widget.label == 'FAKE')
                  Column(
                    children: [
                      Text(
                          'Red region indicates part of an image or video that is likely to be manipulated',
                          style: smallWhiteTextStyle),
                      Container(
                        width: 150, // Set the width of the container
                        height: 150, // Set the height of the container
                        child: Image.memory(
                          base64Decode(widget.imageStr),
                          fit: BoxFit
                              .cover, // Ensure the image covers the entire container
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 350,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _guageIndicator(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          axisLabelStyle: GaugeTextStyle(color: whiteColor),
          minimum: 0,
          maximum: 110,
          interval: 10,
          ranges: <GaugeRange>[
            GaugeRange(startValue: 0, endValue: 33.3, color: Colors.red),
            GaugeRange(startValue: 33.3, endValue: 66.6, color: Colors.orange),
            GaugeRange(startValue: 66.6, endValue: 100, color: Colors.green),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: double.parse(widget.confidence),
              needleColor: whiteColor,
              enableAnimation: true,
              needleStartWidth: 1,
              needleEndWidth: 8,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Container(
                child: Text(
                  widget.confidence,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Inter',
                    color: whiteColor,
                  ),
                ),
              ),
              angle: 85,
              positionFactor: 0.8,
            ),
          ],
        ),
      ],
    );
  }
}
