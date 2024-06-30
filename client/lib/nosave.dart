import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload and Display',
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
  Dio dio = Dio(
      BaseOptions(
        connectTimeout: Duration(minutes: 5),
        receiveTimeout: Duration(minutes: 5),
      ),
    );
  File? _image;
  String _response = '';
  Image? _receivedImage; // Store the received image here

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

    final url = 'http://192.168.1.145:5000/upload-image';

    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          _image!.path,
          filename: 'image.jpg',
        ),
      });

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = 'Success: Image uploaded and processed.';
        });

        // After successful upload, trigger the GET request to fetch the processed image
        _fetchImage(); // Replace with your filename
      } else {
        setState(() {
          _response = 'Error: Failed to upload image.';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _response = 'Dio Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _response = 'Exception: $e';
      });
    }
  }

  Future<void> _fetchImage() async {
    const url = 'http://192.168.1.145:5000/get-image';

    try {
      Response response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = 'Success: Image fetched successfully.';
          // Display the received image
          _receivedImage = Image.memory(
            response.data,
            fit: BoxFit.contain,
          );
        });
      } else {
        setState(() {
          _response = 'Error: Failed to fetch image.';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _response = 'Dio Error: ${e.message}';
      });
    } catch (e) {
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
              _receivedImage != null ? _receivedImage! : Container(),
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
