import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullstack_instagram_clone/utils/colors.dart';
import 'package:fullstack_instagram_clone/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // inisiasi textediting controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 2),
              // gambar ig
              SvgPicture.asset(
                "assets/instagram-logo.svg",
                color: primaryColor,
                height: 64,
              ),
              const SizedBox(height: 62),
              // circular widget untuk
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1744925327375-bb40cd276379?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add_a_photo),
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // textfield untuk username
              TextFieldInput(
                hintText: "Masukkan username",
                textInputType: TextInputType.text,
                textEditingController: _usernameController,
              ),

              const SizedBox(height: 24),
              // untuk text field email
              TextFieldInput(
                hintText: "Masukkan email",
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
              ),
              const SizedBox(height: 24),
              // untuk text field password
              TextFieldInput(
                hintText: "Masukkan Password",
                textInputType: TextInputType.text,
                textEditingController: _passwordController,
                isPass: true,
              ),
              const SizedBox(height: 24),
              // textfield untuk bio
              TextFieldInput(
                hintText: "Masukkan bio",
                textInputType: TextInputType.text,
                textEditingController: _bioController,
              ),

              const SizedBox(height: 24),
              // button login
              InkWell(
                child: Container(
                  child: const Text('Log in'),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    color: blueColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: Container(), flex: 2),

              // transition for sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text("Sudah memiliki akun? "),
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  GestureDetector(
                    onTap: () {},
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
            ],
          ),
        ),
      ),
    );
  }
}
