import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/app_brand.dart';
import 'package:wellnessconnect/widgets/app_brand_logo.dart';

void main() {
  testWidgets('hero brand logo renders with its configured asset', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: AppBrandLogo.hero())),
      ),
    );

    final logo = tester.widget<AppBrandLogo>(find.byType(AppBrandLogo));
    final image = tester.widget<Image>(find.byType(Image));

    expect(logo.height, 108);
    expect(logo.elevated, isTrue);
    expect(AppBrand.logoAssetPath, 'assets/app_logo.png');
    expect(image.image, AssetImage(AppBrand.logoAssetPath));
    expect(AppBrand.logoAspectRatio, 1.0);
  });
}
