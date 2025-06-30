import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fullstack_instagram_clone/model/user.dart';
import 'package:fullstack_instagram_clone/providers/user_provider.dart';
import 'package:fullstack_instagram_clone/resources/firestore_method.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';
import 'package:fullstack_instagram_clone/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void postImage(String uid, String username, String photoUrl) async {
    if (_file == null) {
      showSnackBar(context, 'Pilih gambar terlebih dahulu!');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      showSnackBar(context, 'Caption tidak boleh kosong!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        photoUrl,
      );
      print("response: $res");

      if (res == "success") {
        clearImage();
        showSnackBar(context, 'Berhasil di post✅');
        setState(() {
          _file = null;
          _descriptionController.clear();
        });
      } else {
        showSnackBar(context, res);
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Pilih Gambar"),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Ambil foto"),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.camera);
                if (file != null) {
                  setState(() {
                    _file = file;
                  });
                } else {
                  showSnackBar(context, 'Gagal mengambil gambar.');
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Ambil dari galeri"),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.gallery);
                if (file != null) {
                  setState(() {
                    _file = file;
                  });
                } else {
                  showSnackBar(context, 'Gagal memilih gambar.');
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _file == null
        ? Center(
          child: IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => _selectImage(context),
          ),
        )
        : Scaffold(
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _file = null;
                });
              },
            ),
            title: const Text("Post To"),
            actions: [
              TextButton(
                onPressed:
                    () => postImage(user.uid, user.username, user.photoUrl),
                child: const Text(
                  "Post",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _isLoading
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: _buildProfileImage(user.photoUrl),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: "Tulis caption...",
                        border: InputBorder.none,
                      ),
                      maxLines: 8,
                    ),
                  ),
                  SizedBox(
                    height: 45,
                    width: 45,
                    child: AspectRatio(
                      aspectRatio: 487 / 451,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(_file!),
                            fit: BoxFit.cover,
                            alignment: FractionalOffset.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        );
  }
}

ImageProvider _buildProfileImage(String? imageString) {
  const defaultUrl =
      'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg';

  if (imageString == null || imageString.trim().isEmpty) {
    return const NetworkImage(defaultUrl);
  }

  if (imageString.startsWith('data:image')) {
    try {
      final base64Data = imageString.split(',').last;
      Uint8List bytes = base64Decode(base64Data);
      return MemoryImage(bytes);
    } catch (_) {
      return const NetworkImage(defaultUrl);
    }
  }

  if (imageString.startsWith('http')) {
    return NetworkImage(imageString);
  }

  return const NetworkImage(defaultUrl);
}
