import 'dart:io';
import 'package:charity_discount/controllers/user_controller.dart';
import 'package:charity_discount/services/auth.dart';
import 'package:charity_discount/services/factory.dart';
import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/user/user_avatar.dart';
import 'package:charity_discount/ui/app/loading.dart';
import 'package:charity_discount/util/remote_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
      body: Profile(),
    );
  }
}

class Profile extends StatefulWidget {
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _loadingVisible = false;
  FirebaseStorage _storage;
  StorageUploadTask _uploadTask;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    var appState = AppModel.of(context);
    if (appState.user == null) {
      return Container();
    }

    List<Widget> logoWidgets = [
      CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 60.0,
        child: UserAvatar(
          photoUrl: appState.user.photoUrl,
          width: 120.0,
          height: 120.0,
        ),
      )
    ];

    if (_uploadTask != null && !_uploadTask.isComplete) {
      logoWidgets.add(
        StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (context, snapshot) {
            if (_uploadTask.isComplete) {
              return Container(
                width: 0,
                height: 0,
              );
            }
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColor,
              ),
            );
          },
        ),
      );
    }

    logoWidgets.add(Positioned(
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

    Widget logoWithEdit = Stack(
      alignment: AlignmentDirectional.center,
      children: logoWidgets,
    );

    final signOutButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: () => _signOut(context),
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text(
          'LOG OUT',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    final emailLabel = Text('Email: ');
    final email = appState?.user?.email ?? '';

    final nameLabel = Text('${tr('name')}:');
    final name = appState.user.name ?? '';

    return LoadingScreen(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                logoWithEdit,
                SizedBox(height: 48.0),
                SizedBox(height: 12.0),
                emailLabel,
                Text(email, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12.0),
                nameLabel,
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12.0),
                SizedBox(height: 12.0),
                signOutButton,
              ],
            ),
          ),
        ),
      ),
      inAsyncCall: _loadingVisible,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await userController.signOut();
    await AppModel.of(context).closeListeners();
    AppModel.of(context).setUser(null);
    clearInstances();
    await Navigator.pushNamedAndRemoveUntil(context, '/signin', (r) => false);
  }

  Future _pickImage(ImageSource source) async {
    final selectedImage = await ImagePicker().getImage(source: source);
    if (selectedImage == null) {
      return;
    }
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: selectedImage.path,
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 30,
    );
    if (croppedImage == null) {
      return;
    }

    _startUpload(croppedImage);
  }

  void _startUpload(File image) async {
    if (_storage == null) {
      String bucket = await remoteConfig.getPicturesBucket();
      _storage = FirebaseStorage(storageBucket: 'gs://$bucket');
    }

    String picturePath =
        'profilePhotos/${AppModel.of(context).user.userId}/profilePicture.png';

    setState(() {
      _uploadTask = _storage.ref().child(picturePath).putFile(image);
      _uploadTask.onComplete.then((snap) async {
        String imageUrl = await snap.ref.getDownloadURL();
        var userState = AppModel.of(context).user;
        setState(() {
          userState.photoUrl = imageUrl;
        });
        authService.updateUser(photoUrl: imageUrl);
      });
    });
  }
}
