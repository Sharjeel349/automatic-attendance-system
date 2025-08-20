import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FaceRecognitionAttendance {
  final String flaskUrl; // e.g. http://192.168.1.5:5000/recognize
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  FaceRecognitionAttendance({required this.flaskUrl});

  /// Initializes the back camera for capturing image
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(backCamera, ResolutionPreset.high);
    await _cameraController!.initialize();
    _isCameraInitialized = true;
  }

  /// Dispose camera when not needed
  Future<void> disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    }
  }

  /// User calls this method to capture an image and send to server
  Future<List<Map<String, dynamic>>> pickImageAndRecognize() async {
    if (!_isCameraInitialized) {
      await initializeCamera();
    }

    try {
      final imageFile = await _takePicture();
      if (imageFile == null) {
        Get.snackbar('Error', 'No image captured');
        return [];
      }

      final recognizedFaces = await _sendToServer(imageFile);
      await imageFile.delete(); // clean temp file
      return recognizedFaces;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  /// Private helper: Take picture from camera
  Future<File?> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Get.snackbar('Error', 'Camera not initialized');
      return null;
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = path.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      final XFile xFile = await _cameraController!.takePicture();
      final File file = File(xFile.path);
      final savedFile = await file.copy(filePath);
      return savedFile;
    } catch (e) {
      Get.snackbar('Error taking picture', e.toString());
      return null;
    }
  }

  /// Private helper: Send image to Flask server and parse result
  Future<List<Map<String, dynamic>>> _sendToServer(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse(flaskUrl));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      Get.snackbar('Recognition failed', 'Status code: ${response.statusCode}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> recognizeFromFile(File imageFile) async {
    return await _sendToServer(imageFile);
  }
}