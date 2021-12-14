import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Quiz(),
    );
  }
}

class Quiz extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Quiz> {
  bool play = false;
  bool downloaded = false;
  String mp3link;
  AudioPlayer audioPlayer = AudioPlayer();
  bool loading = false;
  bool paused = false;
  TextEditingController link = TextEditingController();

  playLocal() async {
    int result = await audioPlayer.play(mp3link, isLocal: true);
  }

  Future<void> download() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    print("permission done ");
    print("url is " + link.text.toString());
    Dio dio = Dio();

    try {
      var dir = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      print("getting download directory succes " + dir.toString());
      setState(() {
        loading = true;
      });
      await dio.download(link.text.toString(), "${dir}/music.mp3",
          onReceiveProgress: (rec, total) {
        print("rec : $rec , total : $total");
      });
      setState(() {
        Fluttertoast.showToast(msg: "Download completed");
        downloaded = true;
        loading = false;
        mp3link = "$dir/music.mp3";
      });
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "QUIZ",
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: 150,
                        width: 150,
                        child: Image.asset(
                          "assets/1.png",
                          fit: BoxFit.cover,
                        )),
                    Container(
                        height: 150,
                        width: 150,
                        child: Image.asset(
                          "assets/2.png",
                          fit: BoxFit.cover,
                        )),
                    Container(
                        height: 150,
                        width: 150,
                        child: Image.asset(
                          "assets/3.png",
                          fit: BoxFit.cover,
                        )),
                    Container(
                        height: 150,
                        width: 150,
                        child: Image.asset(
                          "assets/4.png",
                          fit: BoxFit.cover,
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 40, right: 40),
                child: TextField(
                  controller: link,
                  decoration: InputDecoration(
                    labelText: "Enter your music link",
                  ),
                ),
              ),
              loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      width: 150,
                      child: ElevatedButton(
                          onPressed: () async {
                            await download();
                          },
                          child: Text(
                            "Download Music",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
             downloaded ?  play
                 ? Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 paused
                     ? IconButton(
                   onPressed: () async {
                     await audioPlayer.resume();
                     setState(() {
                       paused = false;
                     });
                   },
                   icon: Icon(
                     Icons.play_circle_filled,
                     size: 50,
                   ),
                   color: Colors.deepOrangeAccent,
                 )
                     : IconButton(
                   onPressed: () async {
                     await audioPlayer.pause();
                     setState(() {
                       paused = true;
                     });
                   },
                   icon: Icon(
                     Icons.pause_circle_filled,
                     size: 50,
                   ),
                   color: Colors.deepOrangeAccent,
                 ),
                 IconButton(
                   onPressed: () async {
                     await audioPlayer.stop();
                     setState(() {
                       play = !play;
                     });
                   },
                   icon: Icon(
                     Icons.stop,
                     size: 50,
                   ),
                   color: Colors.deepOrangeAccent,
                 )
               ],
             )
                 : Center(
               child: IconButton(
                 onPressed: () {
                   playLocal();
                   setState(() {
                     play = !play;
                   });
                 },
                 icon: Icon(
                   Icons.play_circle_filled,
                   size: 50,
                 ),
                 color: Colors.deepOrangeAccent,
               ),
             ) : Container()
            ],
          ),
        ),
      ),
    );
  }
}
