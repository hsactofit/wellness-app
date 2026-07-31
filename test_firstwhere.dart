import 'package:flutter/foundation.dart';

void main() {
  final List<dynamic> values = [
    {'title': 'A'},
  ];
  final result = values.firstWhere(
    (value) => value['title'] == 'B',
    orElse: () => null,
  );
  debugPrint('$result');
}
