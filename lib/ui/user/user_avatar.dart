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
      child: photoUrl != null && photoUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              width: width,
              height: height,
              errorWidget: (context, url, error) => Icon(
                Icons.account_circle,
                size: width,
              ),
            )
          : Icon(
              Icons.account_circle,
              size: width,
            ),
    );
  }
}
