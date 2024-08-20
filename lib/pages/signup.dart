import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/utils/login_button.dart';
import 'package:app_chat/utils/textfield.dart';
import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key, required this.onTap});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final userNameController = TextEditingController();

  final void Function()? onTap;

  void signUp(BuildContext context) {
    final _auth = AuthService();

    if (passwordController.text == confirmPasswordController.text) {
      try {
        _auth.signUpWithEmailPassword(emailController.text,
            passwordController.text, userNameController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Passwords don't match!"),
              ));
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
                'Bring the world closer, one chat at a time',
                style:
                    TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.7),
              ),
              SizedBox(
                height: 50,
              ),
              TextBox(
                  controller: userNameController,
                  obscureText: false,
                  hintText: "   user name"),
              TextBox(
                  controller: emailController,
                  obscureText: false,
                  hintText: "   email"),
              TextBox(
                  controller: passwordController,
                  obscureText: true,
                  hintText: '   password'),
              TextBox(
                  controller: confirmPasswordController,
                  obscureText: true,
                  hintText: '   password'),
              SizedBox(
                height: 20,
              ),
              LoginButton(
                onPressed: () => signUp(context),
                text: 'Register',
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, letterSpacing: 0.7)),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Login Here',
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
