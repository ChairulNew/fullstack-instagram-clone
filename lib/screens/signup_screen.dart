import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullstack_instagram_clone/resources/auth_methods.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';
import 'package:fullstack_instagram_clone/utils/utils.dart';
import 'package:fullstack_instagram_clone/widgets/text_field_input.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    // Validasi apakah image sudah dipilih
    if (_image == null) {
      showSnackBar(context, 'Please select a profile image');
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      String res = await AuthMethods().singUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!,
      );

      if (res == 'success') {
        showSnackBar(context, 'Account created successfully!');
        // Navigate to home screen atau login screen
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        showSnackBar(context, res);
      }
    } catch (e) {
      showSnackBar(context, 'An error occurred: ${e.toString()}');
    }

    // Reset loading state
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                SvgPicture.asset(
                  "assets/instagram-logo.svg",
                  color: primaryColor,
                  height: 64,
                ),
                const SizedBox(height: 62),

                // Foto profil
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                        : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                            "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg",
                          ),
                        ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // Username
                TextFieldInput(
                  hintText: "Masukkan username",
                  textInputType: TextInputType.text,
                  textEditingController: _usernameController,
                ),
                const SizedBox(height: 24),

                // Email
                TextFieldInput(
                  hintText: "Masukkan email",
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
                const SizedBox(height: 24),

                // Password
                TextFieldInput(
                  hintText: "Masukkan Password",
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  isPass: true,
                ),
                const SizedBox(height: 24),

                // Bio
                TextFieldInput(
                  hintText: "Masukkan bio",
                  textInputType: TextInputType.text,
                  textEditingController: _bioController,
                ),
                const SizedBox(height: 24),

                // Tombol daftar
                InkWell(
                  onTap: _isLoading ? null : signUpUser,
                  child: Container(
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Daftar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: ShapeDecoration(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      color: _isLoading ? Colors.grey : blueColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Sudah punya akun
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: const Text("Sudah memiliki akun? "),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    GestureDetector(
                      onTap: () {
                        // navigasi ke login
                      },
                      child: Container(
                        child: const Text(
                          "Masuk",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
