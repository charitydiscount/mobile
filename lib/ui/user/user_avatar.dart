import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String photoUrl;
  final double width;
  final double height;

  const UserAvatar({
    Key key,
    this.photoUrl,
    this.width = 35.0,
    this.height = 35.0,
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
              errorWidget: (context, url, error) => Icon(Icons.account_circle),
            )
          : Center(
              child: Icon(Icons.account_circle),
            ),
    );
  }
}
