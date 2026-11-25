import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'features/profile/avatar_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  File? _avatar;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreAvatar());
  }

  Future<void> _restoreAvatar() async {
    try {
      final avatar = await context.read<AvatarStore>().load();
      if (mounted && _avatar == null) setState(() => _avatar = avatar);
    } on PlatformException {
      if (mounted) _showMessage('Could not load the saved photo.');
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (_picking) return;
    final store = context.read<AvatarStore>();
    setState(() => _picking = true);
    try {
      if (source == ImageSource.camera) {
        final canTakePhoto = await _requestCamera();
        if (!mounted || !canTakePhoto) return;
      }
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (photo == null || !mounted) return;

      final avatar = await store.save(photo);
      await FileImage(avatar).evict();
      if (!mounted) return;
      setState(() => _avatar = avatar);
    } on PlatformException {
      if (mounted) _showMessage('Could not open or save the photo.');
    } on FileSystemException {
      if (mounted) _showMessage('Could not save the photo.');
    } on MissingPlatformDirectoryException {
      if (mounted) _showMessage('Could not find the photo storage folder.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<bool> _requestCamera() async {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      _showMessage('The camera is available on Android and iOS.');
      return false;
    }
    final status = await Permission.camera.request();
    if (!mounted) return false;
    switch (status) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.denied:
        _showMessage('Allow camera access to take a profile photo.');
      case PermissionStatus.permanentlyDenied:
        final open = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera access is blocked'),
            content: const Text(
              'Allow camera access in the app settings, or choose a photo from your library.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        if (mounted && open == true) {
          final opened = await openAppSettings();
          if (mounted && !opened) _showMessage('Could not open app settings.');
        }
      case PermissionStatus.restricted:
        _showMessage('Camera access is restricted on this device.');
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        _showMessage('The app does not have full camera access.');
    }
    return false;
  }

  void _showMessage(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final avatar = _avatar;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              key: ObjectKey(avatar),
              radius: 54,
              foregroundImage: avatar == null ? null : FileImage(avatar),
              child: Text(
                'P',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose photo'),
            onTap: _picking ? null : () => _pick(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take photo'),
            onTap: _picking ? null : () => _pick(ImageSource.camera),
          ),
        ],
      ),
    );
  }
}
