import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/avatar_data.dart';
import '../widgets/avatar_preview.dart';

class ChatPage extends StatefulWidget {
  final AvatarData userAvatar;

  const ChatPage({super.key, required this.userAvatar});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  // ⚠️ 替换成你的 DeepSeek API Key
  final String deepSeekKey = 'sk-e04671f4bdda416f93c478849030cd6f';

  final Widget aiAvatar = const CircleAvatar(
    radius: 40,
    backgroundColor: Colors.blue,
    child: Text('🤖', style: TextStyle(fontSize: 40)),
  );

  @override
  void initState() {
    super.initState();
    _loadMessages(); // 启动时加载历史记录
  }

  // ===== 加载本地聊天记录 =====
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('chat_messages');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        messages = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  // ===== 保存聊天记录到本地 =====
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_messages', jsonEncode(messages));
  }

  // ===== 发送消息 =====
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isLoading) return;

    // 添加用户消息
    final userMsg = {
      'sender': 'Me',
      'text': text,
      'time': _currentTime(),
    };
    setState(() {
      messages.add(userMsg);
      _controller.clear();
      isLoading = true;
    });
    await _saveMessages(); // 保存

    try {
      final reply = await _getAIResponse(text);
      final aiMsg = {
        'sender': 'AI',
        'text': reply,
        'time': _currentTime(),
      };
      setState(() {
        messages.add(aiMsg);
        isLoading = false;
      });
      await _saveMessages(); // 保存AI回复
    } catch (e) {
      final errorMsg = {
        'sender': 'AI',
        'text': '😅 Sorry, I encountered an error: $e',
        'time': _currentTime(),
      };
      setState(() {
        messages.add(errorMsg);
        isLoading = false;
      });
      await _saveMessages(); // 保存错误信息（可选）
    }
  }

  // ===== 调用 DeepSeek API =====
  Future<String> _getAIResponse(String userMessage) async {
    // DeepSeek API 地址（兼容 OpenAI 格式）
    final url = Uri.parse('https://api.deepseek.com/v1/chat/completions');

    // 构造历史消息（只保留最近的10条，避免超长）
    final history = messages
        .where((m) => m['sender'] != 'system')
        .map((m) => {
              'role': m['sender'] == 'Me' ? 'user' : 'assistant',
              'content': m['text'],
            })
        .toList();

    // 限制历史长度，防止 token 过多（保留最近10条）
    final recentHistory = history.length > 10 ? history.sublist(history.length - 10) : history;

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $deepSeekKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'deepseek-chat', // DeepSeek-V3 模型，也可以换 'deepseek-reasoner'
        'messages': [
          {
            'role': 'system',
            'content': 'You are a warm, caring AI friend living in a cabin. Keep replies short and natural, like a friend chatting. Use a friendly tone.',
          },
          ...recentHistory,
          {'role': 'user', 'content': userMessage},
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('DeepSeek API Error: ${response.statusCode} - ${response.body}');
    }
  }

  String _currentTime() {
    return DateTime.now().toLocal().toString().substring(11, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F0),
      appBar: AppBar(
        title: const Text('🏠 Cabin Chat'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 顶部小人对坐
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    AvatarPreview(avatar: widget.userAvatar, size: 70),
                    const Text('Me', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const Text(
                  '💬 Warm Chat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                Column(
                  children: [
                    aiAvatar,
                    const Text('AI Friend', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // 消息列表
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Start chatting with your AI friend!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender'] == 'Me';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.orange.shade100 : Colors.blue.shade100,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                            ),
                          ),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg['text']!, style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(msg['time']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // 输入框
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.orange),
                    onPressed: _sendMessage,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}