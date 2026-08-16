import 'package:flutter/material.dart';
import '../models/avatar_data.dart';

class AvatarPreview extends StatelessWidget {
  final AvatarData avatar;
  final double size; // 新增尺寸参数，默认为 200

  const AvatarPreview({
    super.key,
    required this.avatar,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = size * 0.8;
    return SizedBox(
      width: size,
      height: size * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(avatar.body, width: imageSize, height: imageSize * 1.4),
          Image.asset(avatar.bottom, width: imageSize, height: imageSize * 1.4),
          Image.asset(avatar.top, width: imageSize, height: imageSize * 1.4),
          Image.asset(avatar.shoes, width: imageSize, height: imageSize * 1.4),
          Image.asset(avatar.hair, width: imageSize, height: imageSize * 1.4),
          Image.asset(avatar.eyes, width: imageSize, height: imageSize * 1.4),
          Image.asset(avatar.mouth, width: imageSize, height: imageSize * 1.4),
        ],
      ),
    );
  }
}