import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: Colors.lightBlueAccent,
      duration: const Duration(seconds: 3),
    ),
  );
}

Future<Uint8List> compressImage(Uint8List imageBytes) async {
  // Decode image
  img.Image? image = img.decodeImage(imageBytes);

  if (image == null) return imageBytes;

  img.Image resized = img.copyResize(
    image,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.linear,
  );

  List<int> compressedBytes = img.encodeJpg(resized, quality: 70);

  return Uint8List.fromList(compressedBytes);
}

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? _file = await imagePicker.pickImage(
    source: source,
    maxWidth: 400,
    maxHeight: 400,
    imageQuality: 50,
  );

  if (_file != null) {
    return await _file.readAsBytes();
  }

  print("NO image selected");
  return null; // penting agar bisa di-handle di UI
}
