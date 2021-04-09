// Material Design Icons v5.9.55

library mdi;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'icon_map.dart';

const _fontFamily = 'Material Design Icons';
const _packageName = 'mdi';

/// A const wrapper for [IconData].
class _MdiIconData extends IconData {
  const _MdiIconData(int codePoint)
      : super(codePoint, fontFamily: _fontFamily, fontPackage: _packageName);
}

class MdiIcons {
  static Map<String, IconData> get iconMap => _iconMap.map(
        (name, codePoint) => MapEntry(
          name,
          _MdiIconData(codePoint),
        ),
      );

  static IconData? fromString(String name) {
    final codePoint = _iconMap[name];
    return codePoint == null ? null : _MdiIconData(codePoint);
  }

  static Future<String?> showIconPickerDialog(
    BuildContext context, {
    String title = 'Pick a Color',
    Color color = Colors.blueGrey,
  }) {
    // TODO: implement
    throw Exception('Not Implemented');
  }

  static Future<Map<String, List>> readSearchTerms() async {
    final searchTermsJson = await rootBundle
        .loadString('packages/$_packageName/assets/search_terms.json');
    final map = await json.decode(searchTermsJson);
    return map.cast<String, List>();
  }
}
