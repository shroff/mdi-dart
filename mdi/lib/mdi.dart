// Material Design Icons v6.1.95

library mdi;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

part 'icon_map.dart';
part 'icon_picker.dart';

const _fontFamily = 'Material Design Icons';
const _packageName = 'mdi';

/// A const wrapper for [IconData].
class _MdiIconData extends IconData {
  const _MdiIconData(int codePoint)
      : super(codePoint, fontFamily: _fontFamily, fontPackage: _packageName);
}

class MdiIcons {
  static IconData? fromString(String name) {
    final codePoint = _iconMap[name];
    return codePoint == null ? null : _MdiIconData(codePoint);
  }

  static Future<String?> showIconPickerDialog(
    BuildContext context, {
    Color? iconColor,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircularProgressIndicator(),
            ),
            Text(
              'Loading Icons',
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ),
    );
    final searchTermsJson = await rootBundle
        .loadString('packages/$_packageName/assets/search_terms.json');
    final rawMap = await json.decode(searchTermsJson);
    final searchTerms = rawMap.cast<String, List>();
    Navigator.of(context).pop();

    final iconMap = _iconMap.map(
      (name, codePoint) => MapEntry(
        name,
        _MdiIconData(codePoint),
      ),
    );

    return showDialog(
      context: context,
      builder: (context) => IconPickerDialog(
        icons: iconMap,
        iconColor: iconColor ?? Colors.blueGrey,
        termsForName: (String name) => searchTerms[name]?.cast<String>(),
      ),
    );
  }
}
