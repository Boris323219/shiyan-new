import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/store_keys.dart';
import 'local_storage_service.dart';

class AIService {
  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getReply(String userMessage) async {
    final storage = LocalStorageService();
    final apiKey = await storage.getString(StoreKeys.openaiKey) ?? '';
    if (apiKey.isEmpty) return '请先在设置中输入 OpenAI API Key';

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '你是一个住在森林小屋里的温暖陪伴者，名叫释言。用温柔共情的语气回复，每次两句话以内。'
            },
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 200,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'] ?? '我听到了。';
      }
      return '我好像没听清，你能再说一遍吗？';
    } catch (e) {
      return '抱歉，我现在有点走神，请再说一次吧。';
    }
  }
}