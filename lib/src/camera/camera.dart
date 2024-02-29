import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:photo_coach/src/camera/display_picture_screen.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math; // Import math library for rotation calculations

class CameraPage extends StatefulWidget {
  final String category; // Add category parameter

  const CameraPage({Key? key, required this.category}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late Future<CameraController> _controllerFuture;
  bool _showGrid = false; // Variable to track grid visibility
  Key _gridKey = UniqueKey(); // Unique key for the CustomPaint widget
  late StreamSubscription<AccelerometerEvent> _subscription; // Subscription for sensor data
  double _rotationAngle = 0.0; // Stores the device's rotation angle
  late Color _levelingColor = Colors.green; // Initially set to green
  @override
  void initState() {
    super.initState();
    _controllerFuture = initializeCamera();
    _startSensorStream();
  }
  void _startSensorStream() {
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        double x = event.x;
        double y = event.y;
        double angle = math.atan2(y, x) - math.pi / 2; // Calculate angle from accelerometer data
        _rotationAngle = angle; // Set rotation angle
        _updateLevelingColor(x); // Update leveling color based on accelerometer data
      });
    });


  }

  void _updateLevelingColor(double x) {
    if (x.abs() < 0.3) {
      _levelingColor = Colors.green;
    } else if (x.abs() < 1) {
      _levelingColor = Colors.yellow;
    } else {
      _levelingColor = Colors.red;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();  // Important: Cancel subscription
    super.dispose();
  }
  Future<CameraController> initializeCamera() async {
    final cameras = await availableCameras();
    CameraDescription selectedCamera;

    // Choose camera based on the category
    if (widget.category == 'selfie') {
      selectedCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      selectedCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    }

    final controller = CameraController(
      selectedCamera,
      ResolutionPreset.max,

    );
    await controller.initialize();
    return controller;
  }

  Future<void> _showPopup() async {
    final PageController _pageController = PageController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Selfie Tips"),
            content: SingleChildScrollView(
              child: SizedBox(
                height: 350, // Set a fixed height for the content area
                width: MediaQuery.of(context).size.width * 2, // Set width to accommodate two pages
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Good Lighting: Natural light is often the most flattering. Avoid harsh overhead lighting or direct sunlight.\n\n"
                                      "Angle: Typically, holding the camera slightly above eye level and angling your face slightly can help accentuate your features.\n\n"
                                      "Expression: Smile naturally or convey the mood you want to express in the selfie.\n\n"
                                      "Framing: Center yourself in the frame or use the rule of thirds to create a visually pleasing composition.",
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleCamera() async {
    final controller = await _controllerFuture;
    CameraLensDirection newDirection = controller.description.lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final cameras = await availableCameras();
    CameraDescription newCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == newDirection,
    );

    // Dispose of the current controller
    await controller.dispose();

    // Initialize the camera with the new camera description
    final newController = CameraController(
      newCamera,
      ResolutionPreset.max,
    );

    // Initialize the new camera controller
    _controllerFuture = Future.value(newController);
    await newController.initialize();

    setState(() {});
  }

  bool _showLevelingBar = false; // Track the visibility of the leveling bar

  // Method to toggle the visibility of the leveling bar
  void _toggleLevelingBar() {
    setState(() {
      _showLevelingBar = !_showLevelingBar;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
        actions: [
          IconButton(
            onPressed: _showPopup,
            icon: Icon(Icons.info),
          ),
          IconButton(
            onPressed: () {
              _toggleCamera();
              // Function to flip camera
            },
            icon: Icon(Icons.flip_camera_ios_rounded),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid; // Toggle grid visibility
                _gridKey = UniqueKey(); // Update key to rebuild CustomPaint
              });
            },
            icon: _showGrid ? Icon(Icons.grid_on) : Icon(Icons.grid_off), // Updated icon based on _showGrid
          ),
          IconButton(
            onPressed: _toggleLevelingBar,
            icon: Icon(Icons.screen_rotation_outlined),

          ),
        ],
      ),
      body: FutureBuilder<CameraController>(
        future: _controllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final controller = snapshot.data!;
            return Stack(
              children: [
                CameraPreview(controller),
                Positioned.fill(
                  child: CustomPaint(
                    key: _gridKey, // Assign key to CustomPaint
                    painter: _showGrid ? GridPainter() : null, // Conditionally paint grid
                  ),
                ),
                Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).size.height * 0.1,
                child: Visibility(
                visible: _showLevelingBar,
                child: Center(
                    child: Transform.rotate(
                      angle: _rotationAngle, // Apply rotation based on device's tilt
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6, // Adjust width
                        height: 10,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: _levelingColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 10,
            left: 0,
            right: -30,
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () async {
                  final controller = await _controllerFuture;
                  await takePicture(controller);
                },
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.photo_camera,
                  size: 35,
                ),
                shape: CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Future<void> takePicture(CameraController controller) async {
    try {
      if (!controller.value.isInitialized) {
        return;
      }
      final Directory extDir = await getTemporaryDirectory();
      final String filePath = '${extDir.path}/image.jpg';
      final XFile pictureFile = await controller.takePicture();
      if (pictureFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: pictureFile.path, lensDirection: controller.description.lensDirection)),
        );
      } else {
        print('Failed to take picture');
      }
    } catch (e) {
      print(e);
    }
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.5) // Grid line color
      ..strokeWidth = 2; // Grid line thickness

    // Calculate cell size
    final double cellWidth = size.width / 3;
    final double cellHeight = size.height / 3;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final double dx = cellWidth * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final double dy = cellHeight * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

