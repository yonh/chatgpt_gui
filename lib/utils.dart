import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void initWindow() {
  if (isDesktop()) {
    doWhenWindowReady(() {
      // const initialSize = Size(600, 450);
      // appWindow.minSize = initialSize;
      // appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

bool isDesktop() {
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

Future<String?> saveAs({
  String? fileName,
}) async {
  return await FilePicker.platform.saveFile(
    dialogTitle: 'Save as...',
    fileName: fileName ?? 'untitled',
  );
}
