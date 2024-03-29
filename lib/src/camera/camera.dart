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
  Offset?
      _focusIndicatorPosition; // Variable to store the position of the focus indicator
  bool _showFocusIndicator =
      false; // Variable to track focus indicator visibility
  bool _showSlider = false; // Variable to track slider visibility
  bool _showGrid = false; // Variable to track grid visibility
  Key _gridKey = UniqueKey(); // Unique key for the CustomPaint widget
  double _currentZoom = 1.0;
  double _maxZoom = 1.0; // Store the maximum zoom level
  late StreamSubscription<AccelerometerEvent>
      _subscription; // Subscription for sensor data
  double _rotationAngle = 0.0; // Stores the device's rotation angle
  double _previousAngle = -999;
  late Color _levelingColor = Colors.green; // Initially set to green

  @override
  void initState() {
    super.initState();
    _controllerFuture = initializeCamera();
    _startSensorStream();
    _showLevelingBar = false; // Set leveling bar off by default
  }

  void _startSensorStream() {
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      //Try accelerometerEventStream() instead.
      setState(() {
        double x = event.x;
        double y = event.y;
        double angle = math.atan2(y, x) -
            math.pi / 2; // Calculate angle from accelerometer data
        if (_previousAngle == -999) {
          _previousAngle = angle;
        }
        double filteredAngle =
            _previousAngle * 0.1 + angle * 0.90; //low-pass filtering.
        _previousAngle = filteredAngle;

        setState(() {
          _rotationAngle = filteredAngle;
          _updateLevelingColor(
              _rotationAngle); // Update based on filtered angle
        });
      });
    });
  }

  void _updateLevelingColor(double x) {
    if (x.abs() < 0.10) {
      _levelingColor = Colors.green;
    } else if (x.abs() < .20) {
      _levelingColor = Colors.yellow;
    } else {
      _levelingColor = Colors.red;
    }
  }

  @override
  void dispose() {
    _subscription.cancel(); // Important: Cancel subscription
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

    // Store the maximum zoom level from the controller
    _maxZoom = await controller.getMaxZoomLevel();

    return controller;
  }

  Future<void> _showPopup() async {
    final PageController _pageController = PageController();
    String popupTitle = '';
    String popupContent = '';

    if (widget.category == 'selfie') {
      popupTitle = 'Selfie Tips';
      popupContent =
          "Good Lighting: Natural light is often the most flattering. Avoid harsh overhead lighting or direct sunlight.\n\n"
          "Angle: Typically, holding the camera slightly above eye level and angling your face slightly can help accentuate your features.\n\n"
          "Expression: Smile naturally or convey the mood you want to express in the selfie.\n\n"
          "Framing: Center yourself in the frame or use the rule of thirds to create a visually pleasing composition.";
    } else if (widget.category == 'landscapes') {
      popupTitle = 'Landscape Tips';
      popupContent =
          "Use Leading Lines: Incorporate leading lines like roads, rivers, or fences to draw the viewer's eye into the scene.\n\n"
          "Golden Hour: Shoot during the golden hour (early morning or late afternoon) for warm, soft lighting.\n\n"
          "Foreground Interest: Include interesting foreground elements to add depth and context to your landscape.\n\n"
          "Rule of Thirds: Use the rule of thirds to compose your shot, placing key elements along the grid lines or intersections.";
    } else if (widget.category == 'close-up') {
      popupTitle = 'Close-Up Tips';
      popupContent =
          "Focus on Details: Get close to capture intricate details of your subject.\n\n"
          "Experiment: Try different angles and perspectives to find unique shots.\n\n"
          "Lighting: Soft, diffused light works best for close-ups to avoid harsh shadows.\n\n"
          "Stability: Grip all four corners of your phone to stabilize your hands for sharp close-up shots.";
    } else if (widget.category == 'general') {
      popupTitle = 'General Photography Tips';
      popupContent =
          "Composition: Follow the rule of thirds and use leading lines for interesting compositions.\n\n"
          "Lighting: Understand natural light and use it to enhance your photos.\n\n"
          "Experiment: Try different angles and perspectives to find unique shots.\n\n"
          "Clean Backgrounds: Avoid cluttered backgrounds to keep the focus on your subject.";
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(popupTitle),
            content: SingleChildScrollView(
              child: SizedBox(
                height: 350, // Set a fixed height for the content area
                width: MediaQuery.of(context).size.width *
                    2, // Set width to accommodate two pages
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
                                Text(popupContent),
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
    CameraLensDirection newDirection =
        controller.description.lensDirection == CameraLensDirection.front
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

  void _toggleZoomSlider() {
    setState(() {
      _showSlider = !_showSlider; // Toggle the visibility
    });
  }

  Future<void> setFocusPoint(Offset point, CameraController controller) async {
    try {
      await controller.lockCaptureOrientation();
      await controller.setExposurePoint(point);
      await controller.unlockCaptureOrientation();
    } catch (e) {
      print('Error setting focus point: $e');
    }
  }

  void _handleTapToFocus(
      Offset tapPosition, CameraController controller) async {
    final double x = tapPosition.dx / MediaQuery.of(context).size.width;
    final double y = tapPosition.dy / MediaQuery.of(context).size.height;

    // Perform focus operation
    await setFocusPoint(Offset(x, y), controller);

    // Update the position of the focus indicator
    setState(() {
      _focusIndicatorPosition = tapPosition;
      _showFocusIndicator = true; // Show the focus indicator after delay
    });

    // Delay to display focus indicator for a certain duration (optional)
    await Future.delayed(
        Duration(milliseconds: 500));
    // Hide the focus indicator after a certain duration (optional)
    setState(() {
      _showFocusIndicator =
          false; // Hide the focus indicator after a certain duration
    });
  }

  Widget _buildFocusIndicator() {
    return _showFocusIndicator && _focusIndicatorPosition != null
        ? Positioned(
            left: _focusIndicatorPosition!.dx - 20,
            top: _focusIndicatorPosition!.dy - 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            icon: _showGrid
                ? Icon(Icons.grid_on)
                : Icon(Icons.grid_off),
          ),
          IconButton(
            onPressed: _toggleLevelingBar,
            icon: Icon(Icons.screen_rotation_outlined),
          ),
          IconButton(
            onPressed: _toggleZoomSlider, // Toggle zoom slider visibility
            icon: Icon(Icons.zoom_in_rounded),
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
                GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    _handleTapToFocus(details.localPosition, controller);
                  },
                  child: CameraPreview(controller),
                ),
                _buildFocusIndicator(),
                Positioned.fill(
                  child: CustomPaint(
                    key: _gridKey, // Assign key to CustomPaint
                    painter: _showGrid
                        ? GridPainter()
                        : null, // Conditionally paint grid
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.1,
                  child: Visibility(
                    visible: _showLevelingBar,
                    child: Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
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
                        angle: _rotationAngle,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
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
                if (_showSlider)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).size.height *
                        0.05, // Adjust the position as needed
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Slider(
                          value: _currentZoom,
                          min: 1.0,
                          max: _maxZoom,

                          onChanged: (value) {
                            setState(() {
                              _currentZoom = value;
                              _updateZoom(controller, value);
                            });
                          },
                          divisions: ((_maxZoom - 1.0) * 10)
                              .toInt(), // Set divisions based on the zoom range
                          label:
                              '${_currentZoom.toStringAsFixed(1)}x', // Display zoom label with one decimal place
                        ),
                      ],
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
          MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: pictureFile.path, category: widget.category, lensDirection: controller.description.lensDirection)),
        );
      } else {
        print('Failed to take picture');
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateZoom(CameraController controller, double zoomValue) {
    controller.setZoomLevel(zoomValue);
  }

// Future<void> takePicture(CameraController controller) async {
  //   try {
  //     if (!controller.value.isInitialized) {
  //       return;
  //     }
  //     final Directory extDir = await getTemporaryDirectory();
  //     final String filePath = '${extDir.path}/image.jpg';
  //     final XFile pictureFile = await controller.takePicture();
  //     if (pictureFile != null) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: pictureFile.path, lensDirection: controller.description.lensDirection)),
  //       );
  //     } else {
  //       print('Failed to take picture');
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
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
