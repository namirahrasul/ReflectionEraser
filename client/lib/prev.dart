import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io'; // Import this for JSON parsing

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
    // Replace with your camera handling code if needed
    // For simplicity, assuming you handle this part correctly
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    // Replace with your server URL
    final url = 'http://127.0.0.1:5000/upload-image';
    Dio dio = Dio();

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
        options: Options(
          responseType: ResponseType.json, // Ensure JSON response type
        ),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        String base64Image = response
            .data['image']; // Assuming 'image' is the key for base64 data
        Uint8List decodedBytes = base64Decode(base64Image);
        setState(() {
          _receivedImage = File.fromRawPath(decodedBytes);
          _response = 'Success: Image uploaded and processed.';
        });
      } else {
        // Handle non-200 status code
        setState(() {
          _response = 'Error: ${response.data['error']}';
        });
      }
    } on DioError catch (e) {
      // Handle Dio errors
      print('Dio Error Type: ${e.type}');
      if (e.response != null) {
        // DioError can come with response when Dio error occurs
        print('Dio Error Response: ${e.response!.statusCode}');
        print('Dio Error Response Data: ${e.response!.data}');
        setState(() {
          _response =
              'Dio Error Response: ${e.response!.statusCode}: ${e.message}';
        });
      } else {
        // DioError without response
        print('Dio Error Message: ${e.message}');
        setState(() {
          _response = 'Dio Error: ${e.message}';
        });
      }
    } catch (e) {
      // Handle other exceptions
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
