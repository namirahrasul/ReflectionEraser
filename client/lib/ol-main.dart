import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:camera/camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dio Image Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _response = '';
  File? _image;
  File? _receivedImage; // To store the received image

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final imageFile = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: firstCamera),
      ),
    );

    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
final url_android = 'http://10.0.2.2:5000/upload-image';
    final url =
        'http://127.0.0.1:5000/upload-image'; // Replace with your server URL
    Dio dio = Dio(
      BaseOptions(
        connectTimeout: Duration(minutes: 2),
        receiveTimeout: Duration(minutes: 2),
      ),
    );

    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          _image!.path,
          filename: 'image.jpg', // Specify filename here
        ),
      });

      Response response = await dio.post(
        url,
        data: formData,
      );

      if (response.statusCode == 200) {
        setState(() {
          // Set the received image path
          _receivedImage = File(
              '/home/nami/reflection_removal/client/images/image/dsrnet_s_test_l.png');
          _response = 'Success: Image uploaded and received processed image.';
        });
      } else {
        setState(() {
          _response = 'Error: Failed to upload image using Dio.';
          _response += '\n' + response.data.toString();
        });
      }
    } on DioException catch (e) {
      print('Dio Error Type: ${e.type}');
      if (e.response != null) {
        // DioError can come with response when Dio error occurs
        print('Dio Error Response: ${e.response!.statusCode}');
        print('Dio Error Response Data: ${e.response!.data}');
        setState(() {
          _response = 'Dio Error Response: ${e.response!.statusCode}';
        });
      } else {
        // DioError without response
        print('Dio Error Message: ${e.message}');
        setState(() {
          _response = 'Dio Error: ${e.message}';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _response = 'Exception: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Dio Image Upload'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Response:'),
              Text(_response),
              SizedBox(height: 20),
              _image != null ? Image.file(_image!, height: 200) : Container(),
              SizedBox(height: 20),
              _receivedImage != null
                  ? Image.file(_receivedImage!, height: 200)
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: _takePicture,
                child: Text('Take Picture'),
              ),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();
            Navigator.of(context).pop(image);
          } catch (e) {
            print('Error taking picture: $e');
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
