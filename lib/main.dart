import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool loading = true;
  String progress = "0";
  final Dio dio = Dio();
  String pdfPath = "http://192.168.1.103/upload_video_tutorial/pdffile.php";
  late List pdfList;

  // check permission status
  Future<bool> requestPermission() async{
    // if(permission != PermissionStatus.granted){
    //   await ([Permission.storage]);
    // }
    // return permission == PermissionStatus.granted;
    if(await Permission.storage.request().isDenied){
      await Permission.storage.request();
    }
    return Permission == PermissionStatus.granted;

  }
  Future<Directory?>getDownloadDirectory() async {
    if(io.Platform.isAndroid){
      return await DownloadsPathProvider.downloadsDirectory;

    }
    return getApplicationDocumentsDirectory();
  }

  Future startDownload(String savePath, String urlPath) async {
    Map<String, dynamic> result = {
      "isSuccess": false,
      "filePath": null,
      "error": null
    };
    try {
      var response = await dio.download(urlPath, savePath,
          onReceiveProgress: _onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (e) {
      result['error'] = e.toString();
    } finally {
      _showNotification(result);
    }
  }

  _onReceiveProgress(int receive, int total) {
    if (total != -1) {
      setState(() {
        progress = (receive / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future _showNotification(Map<String, dynamic> downloadStatus) async {
    const android =  AndroidNotificationDetails(
      "alausasabi",
      "alausasabi channel",
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,);
    const ios = IOSNotificationDetails();
    const notificationDetails = NotificationDetails(android: android, iOS: ios);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];
    await FlutterLocalNotificationsPlugin().show(
        0,
        isSuccess ? "Sucess" : "error",
        isSuccess ? "File Download Successful" : "File Download Faild",
        notificationDetails,
        payload: json);
  }
  Future _onselectedNotification(String json) async {
    final obj = jsonDecode(json);
    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(obj['error']),
          ));
    }
  }

  Future download(String fileUrl, String fileName) async {
    final dir = await getDownloadDirectory();
    final permissionStatus = await requestPermission();
    if (permissionStatus) {
      final savePath = path.join(dir!.path, fileName);
      await startDownload(savePath, fileUrl);
      print(savePath);
    } else {
      print("Permission Denied!");
    }
  }

  Future fetchAllPdf() async {
    final response = await http
        .get(Uri.parse(pdfPath));
    if (response.statusCode == 200) {
      setState(() {
        pdfList = jsonDecode(response.body);
        loading = false;
      });
      //print(pdfList);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllPdf();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('mipmap/ic_launcher');
    final ios = IOSInitializationSettings();
    final initSetting = InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: _onselectedNotification());
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


// to download the pdf in firebase


