import 'package:app_chat/auth/auth_gate.dart';
import 'package:app_chat/firebase_options.dart';
import 'package:app_chat/pages/groups.dart';
import 'package:app_chat/pages/home.dart';
import 'package:app_chat/pages/profile.dart';
import 'package:app_chat/pages/setting.dart';
import 'package:app_chat/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/home': (context) => HomePage(),
        '/profile': (context) => Profile(),
        '/setting': (context) => Setting(),
        '/groups': (context) => GroupPage(),
        '/authgate': (context) => AuthGate(),
        // '/loginorsignup': (context) => LoginOrSignUp(),
      },
    );
  }
}
