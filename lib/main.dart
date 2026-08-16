import 'package:flutter/material.dart';
import 'screens/avatar_create_page.dart';
import 'screens/mood_tracker_page.dart';
import 'screens/cabin_inside_page.dart';
import 'screens/chat_page.dart';
import 'screens/profile_page.dart';
import 'models/avatar_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Cabin',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'PingFang SC', // 保留中文字体，但界面英文
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const AvatarCreatePage(),
            );
          case '/mood':
            return MaterialPageRoute(
              builder: (context) => const MoodTrackerPage(),
            );
          case '/cabin':
            final args = settings.arguments as AvatarData?;
            return MaterialPageRoute(
              builder: (context) => CabinInsidePage(
                userAvatar: args ?? AvatarData.defaultAvatar(),
              ),
            );
          case '/chat':
            final args = settings.arguments as AvatarData?;
            return MaterialPageRoute(
              builder: (context) => ChatPage(
                userAvatar: args ?? AvatarData.defaultAvatar(),
              ),
            );
          case '/profile':
            final args = settings.arguments as AvatarData?;
            return MaterialPageRoute(
              builder: (context) => ProfilePage(
                userAvatar: args ?? AvatarData.defaultAvatar(),
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}