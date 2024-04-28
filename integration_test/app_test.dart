import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_coach/src/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets(
        'Use the camera to take a photo for analysis. You must manually click the permissions pop-ups.',
        (tester) async {
      await tester.pumpWidget(const MyApp());

      Finder uploadButton = find.byKey(const Key("camera_button"));
      expect(uploadButton, findsOneWidget);
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();

      Finder selfieButton = find.byKey(const Key("selfie"));
      expect(selfieButton, findsOneWidget);
      await tester.tap(selfieButton);
      await tester.pumpAndSettle();

      // Time to manually click the permissions pop-ups
      await tester.pumpAndSettle(const Duration(seconds: 10));

      Finder tipsButton = find.byKey(const Key("tips_button"));
      expect(tipsButton, findsOneWidget);
      await tester.tap(tipsButton);
      await tester.pumpAndSettle();

      Finder closeTipsButton = find.byKey(const Key("close_tips_button"));
      expect(closeTipsButton, findsOneWidget);
      await tester.tap(closeTipsButton);
      await tester.pumpAndSettle();

      Finder gridButton = find.byKey(const Key("grid_button"));
      expect(gridButton, findsOneWidget);
      await tester.tap(gridButton);
      await tester.pumpAndSettle();

      Finder levelingBarButton = find.byKey(const Key("leveling_bar_button"));
      expect(levelingBarButton, findsOneWidget);
      await tester.tap(levelingBarButton);
      await tester.pumpAndSettle();

      Finder flashButton = find.byKey(const Key("flash_button"));
      expect(flashButton, findsOneWidget);
      await tester.tap(flashButton);
      await tester.pumpAndSettle();

      Finder takePictureButton = find.byKey(const Key("take_picture_button"));
      expect(takePictureButton, findsOneWidget);
      await tester.tap(takePictureButton);
      await tester.pumpAndSettle();

      Finder analyzeButton = find.byKey(const Key("analyze_button"));
      expect(analyzeButton, findsOneWidget);
      await tester.tap(analyzeButton);
      await tester.pumpAndSettle();

      Finder imagePreview = find.byKey(const Key("image_preview"));
      expect(imagePreview, findsOneWidget);
      await tester.tap(imagePreview);
      await tester.pumpAndSettle();

      Finder bigPreview = find.byKey(const Key("big_preview"));
      expect(bigPreview, findsOneWidget);
      await tester.tap(bigPreview);
      await tester.pumpAndSettle();

      Finder qualityDropdown = find.byKey(const Key("Overall Quality: "));
      expect(qualityDropdown, findsOneWidget);
      await tester.tap(qualityDropdown);
      await tester.pumpAndSettle();

      Finder homeButton = find.byKey(const Key("home_button"));
      expect(homeButton, findsOneWidget);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      Finder historyEntry = find.byKey(const Key("history_entry"));
      expect(historyEntry, findsOneWidget);
      await tester.tap(historyEntry);
      await tester.pumpAndSettle();

      Finder deleteButton = find.byKey(const Key("delete_button"));
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      Finder deleteConfirmationButton =
          find.byKey(const Key("delete_confirmation_button"));
      expect(deleteConfirmationButton, findsOneWidget);
      await tester.tap(deleteConfirmationButton);
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Upload a photo for analysis. You must manually click the image from the Camera Roll pop-up.',
        (tester) async {
      await tester.pumpWidget(const MyApp());

      Finder uploadButton = find.byKey(const Key("upload_button"));
      expect(uploadButton, findsOneWidget);
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();

      // Time to manually click the image to upload
      await tester.pumpAndSettle(const Duration(seconds: 10));

      Finder generalButton = find.byKey(const Key("general"));
      expect(generalButton, findsOneWidget);
      await tester.tap(generalButton);
      await tester.pumpAndSettle();

      Finder homeButton = find.byKey(const Key("home_button"));
      expect(homeButton, findsOneWidget);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      Finder historyEntry = find.byKey(const Key("history_entry"));
      expect(historyEntry, findsOneWidget);
      await tester.longPress(historyEntry);
      await tester.pumpAndSettle();

      Finder deletePopupButton = find.byKey(const Key("delete_popup_button"));
      expect(deletePopupButton, findsOneWidget);
      await tester.tap(deletePopupButton);
      await tester.pumpAndSettle();
    });
  });
}
