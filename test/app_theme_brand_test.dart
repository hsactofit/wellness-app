import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/app_brand.dart';
import 'package:wellnessconnect/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light theme uses the selected product palette', () {
    final theme = AppTheme.light();

    if (AppBrand.isMednovations) {
      expect(theme.scaffoldBackgroundColor, AppTheme.mednovationsBg);
      expect(theme.colorScheme.primary, AppTheme.mednovationsBlue);
      expect(theme.colorScheme.secondary, AppTheme.mednovationsGreen);
      expect(theme.colorScheme.onSurface, AppTheme.mednovationsInk);
      expect(AppTheme.lightNavColor, AppTheme.mednovationsNav);
      expect(AppTheme.lightBorderColor, AppTheme.mednovationsBorder);
    } else {
      expect(theme.scaffoldBackgroundColor, AppTheme.lightBg);
      expect(theme.colorScheme.primary, AppTheme.brandPrimary);
      expect(theme.colorScheme.secondary, const Color(0xFFB89A62));
      expect(theme.colorScheme.onSurface, AppTheme.brandInk);
      expect(AppTheme.lightNavColor, AppTheme.lightNav);
      expect(AppTheme.lightBorderColor, AppTheme.lightBorder);
    }
  });
}
