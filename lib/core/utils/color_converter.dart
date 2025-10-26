import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// JSON converter for Flutter Color objects
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}
