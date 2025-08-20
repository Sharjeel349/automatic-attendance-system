import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CameraControllerX extends GetxController {
  CameraController? cameraController;
  final isInitialized = false.obs;
  final isTakingPicture = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final frontCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );


    cameraController = CameraController(frontCamera, ResolutionPreset.high);

    await cameraController!.initialize();
    isInitialized.value = true;
  }

  Future<File?> takePicture() async {
    if (cameraController == null || !isInitialized.value || isTakingPicture.value) {
      return null;
    }
    try {
      isTakingPicture.value = true;
      final XFile xfile = await cameraController!.takePicture();
      return File(xfile.path);
    } finally {
      isTakingPicture.value = false;
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
