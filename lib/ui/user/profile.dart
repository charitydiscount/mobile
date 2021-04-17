import 'dart:io';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/models/user_profile.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/charity.dart';
import 'package:charity_discount/state/locator.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/app/auth_dialog.dart';
import 'package:charity_discount/ui/app/util.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
import 'package:charity_discount/util/authorize.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('profile'),
        ),
      ),
      body: StreamBuilder<UserProfile>(
        stream: locator<AuthService>().userDoc,
        builder: (context, snapshot) {
          final loading = buildConnectionLoading(
            context: context,
            snapshot: snapshot,
          );

          if (loading != null) {
            return loading;
          }

          return Profile(userProfile: snapshot.data);
        },
      ),
    );
  }
}

class Profile extends StatelessWidget {
  final UserProfile userProfile;

  const Profile({Key key, @required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final signOutButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          primary: Theme.of(context).primaryColor,
        ),
        onPressed: () => _signOut(context),
        child: Text(
          'LOG OUT',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    final emailLabel = Text('Email: ');
    final email = userProfile.email ?? '';

    final nameLabel = Text('${tr('name')}:');
    final name = userProfile.name ?? '';

    final deleteAccountButton = TextButton(
      child: Text(
        tr('deleteAccount').toUpperCase(),
        style: Theme.of(context).textTheme.button,
      ),
      onPressed: () async {
        bool agreed = await showDialog(
          context: context,
          builder: _deleteConfirmationDialogBuilder,
        );
        if (!agreed) {
          return;
        }

        bool didAuthenticate = await authorize(
          context: context,
          title: tr('deleteAuthorization'),
          charityService: locator<CharityService>(),
        );

        if (!didAuthenticate) {
          return;
        }

        bool requiresSignIn = await userController.deleteAccount();
        if (requiresSignIn) {
          bool accepted = await showDialog(
            context: context,
            builder: reAuthDialogBuilder,
          );
          if (accepted) {
            await _signOut(context);
          }
        } else {
          await _signOut(context);
        }
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ProfilePhoto(photoUrl: userProfile.photoUrl),
              SizedBox(height: 48.0),
              SizedBox(height: 12.0),
              emailLabel,
              Text(email, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12.0),
              nameLabel,
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12.0),
              CheckboxListTile(
                title: Text(tr('privateName')),
                subtitle: Text(tr('privateNameExplanation')),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                value: userProfile.privateName,
                onChanged: (value) async {
                  try {
                    await locator<AppModel>()
                        .updateUserSettings(privateName: value);
                  } catch (_) {
                    Fluttertoast.showToast(msg: tr('changeQuota'));
                  }
                },
              ),
              SizedBox(height: 12.0),
              CheckboxListTile(
                title: Text(tr('privatePhoto')),
                subtitle: Text(tr('privatePhotoExplanation')),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                value: userProfile.privatePhoto,
                onChanged: (value) async {
                  try {
                    await locator<AppModel>()
                        .updateUserSettings(privatePhoto: value);
                  } catch (_) {
                    Fluttertoast.showToast(msg: tr('changeQuota'));
                  }
                },
              ),
              SizedBox(height: 24.0),
              signOutButton,
              deleteAccountButton,
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteConfirmationDialogBuilder(context) {
    Widget cancelButton = TextButton(
      child: Text(tr('cancel')),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = TextButton(
      child: Text(tr('agree')),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );

    return AlertDialog(
      content: Text(tr('deleteConfirmation')),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await userController.signOut();
    await Navigator.pushNamedAndRemoveUntil(context, '/signin', (r) => false);
  }
}

class ProfilePhoto extends StatefulWidget {
  final String photoUrl;

  ProfilePhoto({Key key, @required this.photoUrl}) : super(key: key);

  @override
  _ProfilePhotoState createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  FirebaseStorage _storage;
  UploadTask _uploadTask;

  @override
  Widget build(BuildContext context) {
    List<Widget> avatarWidgets = [
      CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 60.0,
        child: UserAvatar(
          photoUrl: this.widget.photoUrl,
          width: 120.0,
          height: 120.0,
        ),
      )
    ];

    if (_uploadTask != null &&
        _uploadTask.snapshot.state == TaskState.running) {
      avatarWidgets.add(CircularProgressIndicator());
    }

    avatarWidgets.add(Positioned(
      left: 100.0,
      right: 0.0,
      bottom: 0.0,
      child: PopupMenuButton<ImageSource>(
        child: Icon(
          Icons.edit,
          color: Theme.of(context).primaryColor,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: ImageSource.gallery,
            child: Text(tr('gallery')),
          ),
          PopupMenuItem(
            value: ImageSource.camera,
            child: Text(tr('camera')),
          ),
        ],
        onSelected: (source) {
          _pickImage(source);
        },
      ),
    ));

    return Stack(
      alignment: AlignmentDirectional.center,
      children: avatarWidgets,
    );
  }

  Future _pickImage(ImageSource source) async {
    final selectedImage = await ImagePicker().getImage(
      source: source,
      imageQuality: 85,
    );
    if (selectedImage == null) {
      return;
    }
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: selectedImage.path,
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.jpg,
      maxHeight: 400,
      maxWidth: 400,
    );
    if (croppedImage == null) {
      return;
    }

    _startUpload(croppedImage);
  }

  void _startUpload(File image) async {
    if (_storage == null) {
      String bucket = await remoteConfig.getPicturesBucket();
      _storage = FirebaseStorage.instanceFor(bucket: 'gs://$bucket');
    }

    String picturePath =
        'profilePhotos/${AppModel.of(context).user.userId}/profilePicture.png';

    setState(() {
      _uploadTask = _storage.ref().child(picturePath).putFile(image);
    });

    _uploadTask.then((snap) async {
      String imageUrl = await snap.ref.getDownloadURL();
      var userState = AppModel.of(context).user;
      userState.photoUrl = imageUrl;
      await locator<AuthService>().updateUser(photoUrl: imageUrl);
      setState(() {
        AppModel.of(context).setUser(userState);
        _uploadTask = null;
      });
    }).catchError((error) {
      print(error.message);
    });
  }
}
