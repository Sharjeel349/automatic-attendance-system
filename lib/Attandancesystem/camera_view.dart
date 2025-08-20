import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../Controllers/camera_controller.dart';

import 'package:image_picker/image_picker.dart';

class CameraViewGetX extends StatelessWidget {
  final void Function(File imageFile) onPictureTaken;

  CameraViewGetX({required this.onPictureTaken});

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final camCtrl = Get.put(CameraControllerX());

    return Scaffold(
      appBar: AppBar(title: Text('Capture Image')),
      body: Obx(() {
        if (!camCtrl.isInitialized.value) {
          return Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            CameraPreview(camCtrl.cameraController!),
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: Obx(() {
                return FloatingActionButton(
                  onPressed: camCtrl.isTakingPicture.value
                      ? null
                      : () async {
                    final file = await camCtrl.takePicture();
                    if (file != null) {
                      onPictureTaken(file);
                      Get.back();
                    } else {
                      Get.snackbar('Error', 'Failed to capture image');
                    }
                  },
                  child: camCtrl.isTakingPicture.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(Icons.camera_alt),
                );
              }),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                heroTag: "galleryButton",
                onPressed: () async {
                  final pickedFile =
                  await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    onPictureTaken(File(pickedFile.path));
                    Get.back();
                  }
                },
                child: Icon(Icons.photo_library),
              ),
            ),
          ],
        );
      }),
    );
  }
}

