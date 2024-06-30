import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; 
import 'package:flutter/services.dart'; 
import 'package:open_file/open_file.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  List<int>? _receivedImageBytes;
  bool _isLoadingResponse = false; // Track loading state
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _pickImage();
        break;
      case 1:
        _takePicture();
        break;
      case 2:
        _uploadImage();
        break;
      case 3:
        _saveImage(context);
        break;
    }
  }

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
        _fetchImage(); 
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
          _receivedImageBytes = List<int>.from(response.data);
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

  /*Future<void> _saveImage(BuildContext context) async {
    if (_receivedImageBytes == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No image available to save.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final TextEditingController textController = TextEditingController();
    String fileName = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Image'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "Enter file name"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Save'),
            onPressed: () {
              fileName = textController.text;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    if (fileName.isEmpty) {
      return;
    }

    final status = await Permission.storage.request();
    if (status.isGranted) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/$fileName.jpg';
      final file = File(imagePath);

      await file.writeAsBytes(_receivedImageBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to $imagePath')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }*/

  Future<void> _saveImage(BuildContext context) async {
    if (_receivedImageBytes == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No image available to save.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final TextEditingController textController = TextEditingController();
    String fileName = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Image'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "Enter file name"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Save'),
            onPressed: () {
              fileName = textController.text;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    if (fileName.isEmpty) {
      return;
    }

    final status = await Permission.storage.request();
    if (status.isGranted) {
      final galleryPath = await getExternalStorageDirectory();
      final imagePath = '${galleryPath!.path}/$fileName.jpg';
      final file = File(imagePath);

      await file.writeAsBytes(_receivedImageBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to $imagePath')),
      );
      
      OpenFile.open(imagePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ReflectionEraser',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Your image:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                SizedBox(height: 20),
                _image != null ? Image.file(_image!, height: 200) : Container(),
                Text(
                  _response,
                  style: TextStyle(
                      color: Colors.green.shade400,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Result image:',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                _receivedImage != null
                    ? Container(child: _receivedImage!, height: 200)
                    : Container(),
                SizedBox(height: 20),
                /*ElevatedButton(
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
                ElevatedButton(
                  onPressed: () => _saveImage(context),
                  child: Text('Save Image'),
                ),*/
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Pick Image',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Take Picture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload Image',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Save Image',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple.shade900,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(color: Colors.deepPurple.shade900),
        unselectedLabelStyle: TextStyle(color: Colors.grey.shade600),
        onTap: _onItemTapped,
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
