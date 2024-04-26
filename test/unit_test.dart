// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/docs/cookbook/testing/unit/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_coach/photo_coach.dart';
//import 'package:photo_coach/src/analysis/api_caller.dart';
import 'package:photo_coach/src/analysis/analysis_page.dart';
import 'package:flutter/src/material/colors.dart';

void main() {
  group('Conversion functions', () {
    test('getColor', () {
      expect(getColor(0.0000000000001), Colors.red);
      expect(getColor(0.1), Colors.red);
      expect(getColor(0.2), Colors.red);
      expect(getColor(0.2999999999999), Colors.red);

      expect(getColor(0.3), Colors.yellow);
      expect(getColor(0.4), Colors.yellow);
      expect(getColor(0.5), Colors.yellow);
      expect(getColor(0.5999999999999), Colors.yellow);

      expect(getColor(0.6), Colors.green[300]);
      expect(getColor(0.7), Colors.green[300]);
      expect(getColor(0.7999999999999), Colors.green[300]);

      expect(getColor(0.8), Colors.green);
      expect(getColor(0.9), Colors.green);
      expect(getColor(0.9999999999999), Colors.green);
      expect(getColor(1.0), Colors.green);
      
      expect(getColor(1.0000000000001), Colors.black);
      expect(getColor(1.1), Colors.black);
      expect(getColor(-0.1), Colors.black);
      expect(getColor(-1.0), Colors.black);
      expect(getColor(2.0), Colors.black);
    });
    test('getRating', () {
      expect(getRating(0.0000000000001), 'Poor');
      expect(getRating(0.1), 'Poor');
      expect(getRating(0.2), 'Poor');
      expect(getRating(0.2999999999999), 'Poor');

      expect(getRating(0.3), 'Fair');
      expect(getRating(0.4), 'Fair');
      expect(getRating(0.5), 'Fair');
      expect(getRating(0.5999999999999), 'Fair');

      expect(getRating(0.6), 'Good');
      expect(getRating(0.7), 'Good');
      expect(getRating(0.7999999999999), 'Good');

      expect(getRating(0.8), 'Excellent');
      expect(getRating(0.9), 'Excellent');
      expect(getRating(0.9999999999999), 'Excellent');
      expect(getRating(1.0), 'Excellent');

      expect(getRating(1.0000000000001), 'Error');
      expect(getRating(1.1), 'Error');
      expect(getRating(-0.1), 'Error');
      expect(getRating(-1.0), 'Error');
      expect(getRating(2.0), 'Error');
    });
  });
}
