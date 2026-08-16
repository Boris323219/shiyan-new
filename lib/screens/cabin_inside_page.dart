import 'package:flutter/material.dart';
import '../models/avatar_data.dart';
import '../widgets/avatar_preview.dart';
import 'mood_tracker_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';

class CabinInsidePage extends StatelessWidget {
  final AvatarData userAvatar;

  const CabinInsidePage({super.key, required this.userAvatar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F0),
      appBar: AppBar(
        title: const Text('🏠 我的小屋'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 右上角：个人主页入口
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: userAvatar,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 显示娃娃
            AvatarPreview(avatar: userAvatar, size: 160),
            const SizedBox(height: 20),
            const Text(
              '欢迎来到你的小屋！',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/mood');
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('情绪日历'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: userAvatar,
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('进入聊天'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}