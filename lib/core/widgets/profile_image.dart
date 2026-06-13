import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays a profile/logo image from a network URL or embedded data URL.
class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  static bool isDataUrl(String url) => url.startsWith('data:');

  static ImageProvider? provider(String url) {
    if (url.isEmpty) return null;
    if (isDataUrl(url)) {
      final encoded = url.split(',').last;
      return MemoryImage(base64Decode(encoded));
    }
    return CachedNetworkImageProvider(url);
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    Widget image;
    if (isDataUrl(url)) {
      image = Image.memory(
        base64Decode(url.split(',').last),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            errorWidget ?? const Icon(Icons.broken_image_outlined),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (_, __, ___) =>
            errorWidget ?? const Icon(Icons.broken_image_outlined),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
