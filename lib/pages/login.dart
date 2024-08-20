import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/utils/login_button.dart';
import 'package:app_chat/utils/textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.onTap});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final void Function()? onTap;

  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();

    // try login
    try {
      await authService.signInWithEmailPassword(
          emailController.text, passwordController.text);
    }

    // catch any errors
    catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                child: Image.asset('assets/chat_logo.png'),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Welcome Back!',
                style:
                    TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.7),
              ),
              SizedBox(
                height: 50,
              ),
              TextBox(
                  controller: emailController,
                  obscureText: false,
                  hintText: "   email"),
              TextBox(
                  controller: passwordController,
                  obscureText: true,
                  hintText: '   password'),
              SizedBox(
                height: 20,
              ),
              LoginButton(
                onPressed: () => login(context),
                text: 'Login',
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t you have an account? ',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, letterSpacing: 0.7)),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Register Here',
                      style: TextStyle(
                          color: Color.fromARGB(
                            255,
                            27,
                            27,
                            27,
                          ),
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
