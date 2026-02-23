import 'package:flutter/foundation.dart';

@immutable
class InstrumentCategoryModel {
  const InstrumentCategoryModel({required this.category, required this.instruments});

  final String category;
  final List<String> instruments;
}
