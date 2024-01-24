import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'result_screen.dart';
import '../custom/custom_appbar.dart';

class ScannerPage extends StatefulWidget {
  final String title;

  const ScannerPage({
    super.key,
    required this.title,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  CameraController? _cameraController;
  late final Future<void> _future;
  final _textRecognizer = TextRecognizer();

  bool _isScanning =
      false; // Állapotváltozó a szkennelés folyamatának figyelésére

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    _stopCamera();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: widget.title),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          return _isPermissionGranted
              ? FutureBuilder<List<CameraDescription>>(
                  future: availableCameras(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _initCameraController(snapshot.data!);
                      return CameraPreview(_cameraController!);
                    } else {
                      return const LinearProgressIndicator();
                    }
                  },
                )
              : Center(
                  child: Container(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                    child: const Text(
                      'Camera permission denied',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
        },
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          ElevatedButton(
            onPressed: _isScanning ? null : _scanImage,
            child: Text(_isScanning ? 'Scanning...' : 'Scan text'), // Felirat a gombon
          ),
          if (_isScanning) // Loading spinner középen és lila színben
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple), // Lila szín
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    setState(() {
      _isScanning = true; // Beállítjuk a szkennelés állapotát
    });

    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultScreen(
                text: recognizedText.text,
                title: widget.title,),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
    setState(() {
      _isScanning = false; // Szkennelés befejeződött, loading spinner eltűnik
    });
  }
}
