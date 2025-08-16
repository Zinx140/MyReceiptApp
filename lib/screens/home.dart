import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/print.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Receipt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 350,
              child: MaterialButton(
                onPressed: pickImageFromGallery,
                color: Colors.blue[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // ⬅ Border radius here
                ),
                child: Text(
                  "Pick image from Gallery",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Container(
              width: 350,
              child: MaterialButton(
                onPressed: pickImageFromCamera,
                color: Colors.red[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // ⬅ Border radius here
                ),
                minWidth: 150,
                child: Text(
                  "Pick image from Camera",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 20),
            selectedImage != null
                ? Text("Image received!", style: TextStyle(fontSize: 24))
                : Text(
                    "Please select the image!",
                    style: TextStyle(fontSize: 24),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (returnedImage != null) {
      setState(() {
        selectedImage = File(returnedImage.path);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintPage(imageFile: selectedImage!),
        ),
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (returnedImage != null) {
      setState(() {
        selectedImage = File(returnedImage.path);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintPage(imageFile: selectedImage!),
        ),
      );
    }
  }
}
