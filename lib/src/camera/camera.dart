library camera;
import 'dart:ui';
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
  bool _showGrid = false; // Variable to track grid visibility
  Key _gridKey = UniqueKey(); // Unique key for the CustomPaint widget
  double _currentZoom = 1.0;
  double _zoomPercentage = 1.0; // Initial zoom percentage
  bool _isZooming = false; // Variable to track zoom gesture status
  double _maxZoom = 1.0; // Store the maximum zoom level
  FlashMode _flashMode = FlashMode.off;
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
      setState(() {
      double x = event.x;
      double y = event.y;

      // Calculate the tilt angle relative to the horizon
      double angle = -math.atan2(y, x);

      // Adjust angle based on device orientation and invert the tilt for the leveling bar
      angle += math.pi / 2; // Add pi/2 to invert the tilt direction
      if (_previousAngle == -999) {
        _previousAngle = angle;
      }
      double filteredAngle =
          _previousAngle * 0.1 + angle * 0.90; //low-pass filtering.
      _previousAngle = filteredAngle;
      // Update leveling color based on the adjusted angle
      _updateLevelingColor(angle);

      setState(() {
        _rotationAngle = filteredAngle;
        _updateLevelingColor(
            _rotationAngle); // Update based on filtered angle
      });
      });
    });
  }

  void _updateLevelingColor(double angle) {
    // Adjust angle to be between -pi/2 to pi/2 (equivalent to -90 to 90 degrees)
    angle %= (2 * math.pi);
    if (angle > math.pi / 2) {
      angle -= math.pi;
    } else if (angle < -math.pi / 2) {
      angle += math.pi;
    }

    // Determine the orientation based on the angle
    if (angle.abs() < math.pi / 60) {
      _levelingColor = Colors.green; // Portrait orientation
    } else if ((angle.abs() > math.pi / 2 - math.pi / 60 &&
        angle.abs() < math.pi / 2 + math.pi / 120) ||
        (angle.abs() > -math.pi / 2 - math.pi / 120 &&
            angle.abs() < -math.pi / 2 + math.pi / 60)) {
      _levelingColor = Colors.green; // Landscape orientation (within 3 degrees)
    } else {
      _levelingColor = Colors.red; // Other orientations
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

    // Initialize popup title and content based on the category
    if (widget.category == 'selfie') {
      // Set popup title and content for 'selfie' category
      popupTitle = 'Selfie Tips';
      popupContent =
      "Good Lighting: Natural light is often the most flattering. Avoid harsh overhead lighting or direct sunlight.\n\n"
          "Angle: Typically, holding the camera slightly above eye level and angling your face slightly can help accentuate your features.\n\n"
          "Expression: Smile naturally or convey the mood you want to express in the selfie.\n\n"
          "Framing: Center yourself in the frame or use the rule of thirds to create a visually pleasing composition.";
    } else if (widget.category == 'landscapes') {
      // Set popup title and content for 'landscapes' category
      popupTitle = 'Landscape Tips';
      popupContent =
      "Use Leading Lines: Incorporate leading lines like roads, rivers, or fences to draw the viewer's eye into the scene.\n\n"
          "Golden Hour: Shoot during the golden hour (early morning or late afternoon) for warm, soft lighting.\n\n"
          "Foreground Interest: Include interesting foreground elements to add depth and context to your landscape.\n\n"
          "Rule of Thirds: Use the rule of thirds to compose your shot, placing key elements along the grid lines or intersections.";
    } else if (widget.category == 'close-up') {
      // Set popup title and content for 'close-up' category
      popupTitle = 'Close-Up Tips';
      popupContent =
      "Focus on Details: Get close to capture intricate details of your subject.\n\n"
          "Experiment: Try different angles and perspectives to find unique shots.\n\n"
          "Lighting: Soft, diffused light works best for close-ups to avoid harsh shadows.\n\n"
          "Stability: Grip all four corners of your phone to stabilize your hands for sharp close-up shots.";
    } else if (widget.category == 'general') {
      // Set popup title and content for 'general' category
      popupTitle = 'General Photography Tips';
      popupContent =
      "Composition: Follow the rule of thirds and use leading lines for interesting compositions.\n\n"
          "Lighting: Understand natural light and use it to enhance your photos.\n\n"
          "Experiment: Try different angles and perspectives to find unique shots.\n\n"
          "Clean Backgrounds: Avoid cluttered backgrounds to keep the focus on your subject.";
    }

    // Show the dialog with scrollable content
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(popupTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(popupContent),
            ],
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

    await Future.delayed(
        Duration(milliseconds: 500));
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

  Widget _buildZoomPercentageIndicator() {
    return Visibility(
      visible: _isZooming, // Show indicator only when zoom gesture is active
      child: Positioned(
        top: kToolbarHeight + 8, // Adjust the top position as needed
        left: MediaQuery.of(context).size.width / 2 - 50, // Center horizontally
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Zoom: ${_currentZoom.toStringAsFixed(1)}x', // Display zoom factor with one decimal place
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
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
            onPressed: () async {
              final controller = await _controllerFuture;

              setState(() {
                switch (_flashMode) {
                  case FlashMode.off:
                    _flashMode = FlashMode.torch;
                    break;
                  case FlashMode.torch:
                    _flashMode = FlashMode.auto;
                    break;
                  case FlashMode.auto:
                    _flashMode = FlashMode.off; // Change to 'off' instead of 'on'
                    break;
                  default:
                    _flashMode = FlashMode.off;
                    break;
                }
              });

              // Update flash mode directly in CameraController
              controller.setFlashMode(_flashMode);
            },
            icon: Builder(
              builder: (context) {
                IconData icon;
                switch (_flashMode) {
                  case FlashMode.off:
                    icon = Icons.flash_off;
                    break;
                  case FlashMode.torch:
                    icon = Icons.flash_on;
                    break;
                  case FlashMode.auto:
                    icon = Icons.flash_auto;
                    break;
                  case FlashMode.always:
                    icon = Icons.flash_on;
                    break;
                  default:
                    icon = Icons.flash_off;
                    break;
                }
                return Icon(icon);
              },
            ),
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
                _buildFocusIndicator(),
                _buildZoomPercentageIndicator(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.5,
                  child: Visibility(
                    visible: _showLevelingBar,
                    child: Transform.rotate(
                      angle: _rotationAngle > (math.pi / 3) || _rotationAngle < -(math.pi / 3) ? math.pi / 2 : 0,
                      child: Container(
                        height: 10,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.5,
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
                Positioned.fill(
                  child: CustomPaint(
                    key: _gridKey,
                    painter: _showGrid ? GridPainter() : null,
                  ),
                ),
                GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    _handleTapToFocus(details.localPosition, controller);
                  },
                  onScaleUpdate: (ScaleUpdateDetails details) {
                    double zoomInScaleIncrement = 0.015; // Adjust this value for zoom in sensitivity
                    double zoomOutScaleIncrement = 0.015; // Adjust this value for zoom out sensitivity

                    double newZoom = _currentZoom * details.scale;

                    // Check if the pinch gesture is zooming out (scale < 1.0) or zooming in (scale > 1.0)
                    if (details.scale < 1.0) {
                      newZoom = _currentZoom - zoomOutScaleIncrement;
                    } else {
                      newZoom = _currentZoom + zoomInScaleIncrement;
                    }

                    setState(() {
                      _currentZoom = newZoom.clamp(1.0, _maxZoom); // Clamp zoom within limits
                      _updateZoom(controller, _currentZoom);
                    });
                  },
                  onScaleStart: (ScaleStartDetails details) {
                    setState(() {
                      _isZooming = true; // Zoom gesture started
                    });
                  },
                  onScaleEnd: (ScaleEndDetails details) {

                    Future.delayed(Duration(milliseconds: 500), () {
                      setState(() {
                        _isZooming = false; // Keep the zoom text visible for 200 milliseconds after the gesture ends
                      });
                    });
                  },
                  behavior: HitTestBehavior.opaque, // Ensure gesture detector handles taps and scales independently
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = await _controllerFuture;
          await takePicture(controller);
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.photo_camera,
          size: 40,
          color: Colors.black, // Set the color of the camera logo here
        ),
        shape: CircleBorder(),
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
        // Turn off the flash after capturing the photo
        await controller.setFlashMode(FlashMode.off);
        setState(() {
          _flashMode = FlashMode.off; // Update the flash mode state
        });
      } else {
        print('Failed to take picture');
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateZoom(CameraController controller, double zoomValue) {
    controller.setZoomLevel(zoomValue);
    setState(() {
      _currentZoom = zoomValue;
      _zoomPercentage = (_currentZoom / _maxZoom * 100).clamp(0, 100).toInt().toDouble(); // Update zoom percentage calculation
    });
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