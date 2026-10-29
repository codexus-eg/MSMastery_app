// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:salah_online_platform/constants/widgets.dart';

class FullScreenImageViewer extends StatelessWidget {
  String? imageUrl;
  File? img;
  final bool type;
  FullScreenImageViewer(this.imageUrl, this.img,
      {super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultBackBtn(color: Colors.white),
            const SizedBox(height: 32.0),
            Expanded(
              child: type
                  ? PhotoView(
                      imageProvider: NetworkImage(
                        imageUrl!,
                      ),
                    )
                  : Image.file(img!),
            ),
          ],
        ),
      ),
    );
  }

  static void showFullImage(BuildContext context, String? imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageViewer(imageUrl!, null, type: true),
      ),
    );
  }

  static void showFullImage2(BuildContext context, File? img) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer("", img, type: false),
      ),
    );
  }
}
