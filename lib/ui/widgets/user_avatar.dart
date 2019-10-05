import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String photoUrl;
  final double width;
  final double height;

  const UserAvatar({
    Key key,
    this.photoUrl,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: photoUrl != null
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.scaleDown,
              width: width,
              height: height,
            )
          : Icon(
              Icons.account_circle,
              size: width,
            ),
    );
  }
}
