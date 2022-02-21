import 'dart:html';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;







void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool loading = true;
  List pdfList;


  String progress = "0";
  final Dio dio = Dio();
  String pdfPath = "http://192.168.1.103/upload_video_tutorial/pdffile.php";

  // check permission status

  Future<bool> requestPermission(Permission permission) async{
    final status = await permission.request();
    if(permission != PermissionStatus.granted){
      await ([Permission.storage]);
    }
    return permission == PermissionStatus.granted;
  }
  Future<Directory>getDownloadDirectory() async {
    if(io.Platform.isAndroid){
      return await DownloadPathProvider.downloadsDirectory;


    }
    return getApplicationDocumentsDirectory();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: const Text("testing"),
      ),
    );
  }
}

