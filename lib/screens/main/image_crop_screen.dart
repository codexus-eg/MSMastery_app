import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

/// شاشة قص صورة السؤال. بترجع الصورة بعد القص، أو null لو الطالب لغى.
class ImageCropScreen extends StatefulWidget {
  const ImageCropScreen({
    super.key,
    required this.image,
    required this.primaryColor,
  });

  final Uint8List image;
  final Color primaryColor;

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final CropController _controller = CropController();
  bool _ready = false;
  bool _cropping = false;

  void _onCropped(CropResult result) {
    if (!mounted) return;
    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.pop(context, croppedImage);
      case CropFailure():
        setState(() => _cropping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مش قادر أقص الصورة — جرب تاني')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('حدد السؤال'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Crop(
                    image: widget.image,
                    controller: _controller,
                    onCropped: _onCropped,
                    baseColor: Colors.black,
                    maskColor: Colors.black.withValues(alpha: 0.6),
                    interactive: true,
                    onStatusChanged: (status) {
                      if (!mounted) return;
                      setState(() {
                        _ready = status == CropStatus.ready;
                        _cropping = status == CropStatus.cropping;
                      });
                    },
                    progressIndicator: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  if (_cropping)
                    const ColoredBox(
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'حرّك الأطراف عشان تحدد السؤال بس',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _cropping ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _ready && !_cropping
                                ? () {
                                    setState(() => _cropping = true);
                                    _controller.crop();
                                  }
                                : null,
                            icon: const Icon(Icons.crop),
                            label: const Text('قص الصورة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
