import '../services/local_storage_service.dart';

class EmojiService {
  static const Map<String, (String, String)> _mapping = {
    '开心': ('😊', '一盆向日葵'),
    '难过': ('😢', '一朵乌云'),
    '生气': ('😤', '一个沙袋'),
    '累': ('😴', '一个抱枕'),
    '孤独': ('🥺', '一只小猫'),
    '焦虑': ('😰', '一个警报灯'),
    '迷茫': ('😶', '一块石头'),
    '放松': ('😌', '一杯热茶'),
    '委屈': ('😣', '一堆废纸'),
    '烦躁': ('😫', '一个发泄球'),
  };

  static const List<String> _keywords = [
    '开心', '难过', '生气', '累', '孤独', '焦虑', '迷茫', '放松', '委屈', '烦躁'
  ];

  static final List<String> _defaultEmojis = ['✨', '🌟', '💫', '🌙', '☁️', '🍃', '🌿', '🪵', '🕯️', '📜'];

  static Future<Map<String, String>> generate() async {
    final storage = LocalStorageService();
    final history = await storage.getChatHistory();
    final userMessages = history
        .where((m) => m['role'] == 'user')
        .map((m) => m['content'].toString())
        .toList();

    String found = '';
    for (final msg in userMessages) {
      for (final kw in _keywords) {
        if (msg.contains(kw)) {
          found = kw;
          break;
        }
      }
      if (found.isNotEmpty) break;
    }

    if (found.isNotEmpty && _mapping.containsKey(found)) {
      final result = _mapping[found]!;
      return {
        'emoji': result.$1,
        'item': result.$2,
        'keyword': found,
      };
    } else {
      final today = DateTime.now().day;
      final emoji = _defaultEmojis[today % _defaultEmojis.length];
      return {
        'emoji': emoji,
        'item': '一片叶子',
        'keyword': '日常',
      };
    }
  }
}