import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newui/main.dart';
import 'package:newui/model/media_source.dart';
import 'package:newui/widget/video_widget.dart';
import 'package:newui/page/source_page.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
class HomePage extends StatefulWidget
{
  @override
  _HomePageState createState() =>_HomePageState();
}
class _HomePageState extends State<HomePage> {
  String output='Initial output';
  File? fileMedia;
  File? outputfile;
  MediaSource? source;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(MyApp.title),
    ),
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: fileMedia == null
                  ? Icon(Icons.photo, size: 120)
                  : (source == MediaSource.image
                  ? Image.file(fileMedia!)
                  : VideoWidget(fileMedia!)),
            ),
            const SizedBox(height: 24),
            RaisedButton(
              child: Text('Capture Image'),
              shape: StadiumBorder(),
              onPressed: () {
                capture(MediaSource.image);
              },
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
            ),
            const SizedBox(height: 12),
            RaisedButton(
              child: Text('Capture Video'),
              shape: StadiumBorder(),
              onPressed: () => capture(MediaSource.video),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
            ),

            const SizedBox(height: 12),
            RaisedButton(
              child: Text(output),
              shape: StadiumBorder(),
              onPressed: () => {},
              color: Colors.green,
              textColor: Colors.white,
            ),

          ],
        ),
      ),
    ),
  );

  Future fetchData() async{
    String url='http://192.168.225.21:5000/';
    String data='';
    if(source==MediaSource.image){
      data = await uploadImage(fileMedia!, url);
      setState(() {
        output=data;
      });


    }
    if(source == MediaSource.video){

      await convert(fileMedia!);

    }
  }


  Future uploadImage(File fileMedia,String url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', fileMedia.path));
    var res = await request.send();
    if(res.statusCode==200){
      var responseString=await res.stream.bytesToString();
      return responseString;
    }
  }
  Future convert(File file) async {
    String url='http://192.168.225.21:5000/';
    String data='';
    var dir = await getExternalStorageDirectory();
    var x = dir!.path;
    final outputpath = x + '/' + "output.wav";
    final arguments = [
      '-i',file.path,outputpath,
    ];

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    _flutterFFmpeg.executeWithArguments(arguments).then((result) async {

      if (result == 0) {

        data = await uploadAudio(url,File(outputpath));
        setState((){
          output = data;
        });
      } else {
        print(
            'WAV failed to create %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
      }
    });

  }
  Future uploadAudio(String url,File outputfile) async {

    var request = http.MultipartRequest('POST',Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('audio', outputfile.path));
    var res = await request.send();
    await deleteFile(outputfile);

    if(res.statusCode == 200){
      var responseString = await res.stream.bytesToString();
      return responseString;
    }
  }
  Future deleteFile(File file_wav) async{
    if (await file_wav.exists()) {
      await file_wav.delete();
    }
  }
  Future capture(MediaSource source) async {
    setState(() {
      this.source = source;
      this.fileMedia = null;
    });

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SourcePage(),
        settings: RouteSettings(
          arguments: source,
        ),
      ),
    );


    if (result == null) {
      return;
    } else {
      setState(() {
        fileMedia = result;
        fetchData();
      }
      );
    }
  }
}