import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoPickerExample extends StatefulWidget {
  @override
  _PhotoPickerExampleState createState() => _PhotoPickerExampleState();
}

class _PhotoPickerExampleState extends State<PhotoPickerExample> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // 카메라 열기
  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 앨범 열기
  Future<void> _openGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("사진 선택")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, width: 200, height: 200, fit: BoxFit.cover)
                : Text("사진이 없습니다."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openCamera,
              child: Text("카메라로 찍기"),
            ),
            ElevatedButton(
              onPressed: _openGallery,
              child: Text("앨범에서 선택"),
            ),
          ],
        ),
      ),
    );
  }
}
