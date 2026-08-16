import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  int currentYear = DateTime.now().year;
  int currentMonth = DateTime.now().month;
  int? selectedDay;

  String? selectedMood;

  Map<String, Map<String, dynamic>> moodData = {};

  final List<Map<String, dynamic>> moodLibrary = [
    {'mood': '开心', 'emoji': '😊', 'color': Color(0xFFFFD93D)},
    {'mood': '难过', 'emoji': '😢', 'color': Color(0xFFA8D8EA)},
    {'mood': '生气', 'emoji': '😠', 'color': Color(0xFFFF6B6B)},
    {'mood': '疲惫', 'emoji': '😩', 'color': Color(0xFFB8A9C9)},
    {'mood': '一般', 'emoji': '😐', 'color': Color(0xFFD4D4D4)},
  ];

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('mood_data');
    if (data != null) {
      setState(() {
        moodData = Map<String, Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mood_data', jsonEncode(moodData));
  }

  Future<void> _recordMood(String moodKeyword) async {
    final moodItem = moodLibrary.firstWhere(
      (item) => item['mood'] == moodKeyword,
      orElse: () => moodLibrary.last,
    );

    final todayKey = '$currentYear-${currentMonth.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    setState(() {
      moodData[todayKey] = {
        'text': moodKeyword,
        'emoji': moodItem['emoji'],
        'color': (moodItem['color'] as Color).value,
        'mood': moodKeyword,
      };
      selectedMood = null;
    });
    _saveMoodData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ 记录成功！${moodItem['emoji']} $moodKeyword')),
    );
  }

  Map<String, dynamic>? _getMoodForDay(int day) {
    final key = '$currentYear-${currentMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    if (moodData.containsKey(key)) {
      final data = moodData[key]!;
      return {
        'emoji': data['emoji'],
        'color': Color(data['color']),
        'mood': data['mood'],
        'text': data['text'],
      };
    }
    return null;
  }

  List<Map<String, dynamic>> _getMonthStats() {
    final List<Map<String, dynamic>> stats = [];
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      final mood = _getMoodForDay(i);
      if (mood != null) {
        stats.add({
          'day': i,
          'mood': mood['mood'],
          'emoji': mood['emoji'],
        });
      }
    }
    return stats;
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth += offset;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      } else if (currentMonth < 1) {
        currentMonth = 12;
        currentYear--;
      }
      selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1).weekday;
    final monthStats = _getMonthStats();

    final Map<String, int> moodCount = {};
    for (var item in monthStats) {
      moodCount[item['mood']] = (moodCount[item['mood']] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> moodTags = moodCount.entries.map((entry) {
      final moodItem = moodLibrary.firstWhere(
        (item) => item['mood'] == entry.key,
        orElse: () => moodLibrary.last,
      );
      return {
        'mood': entry.key,
        'emoji': moodItem['emoji'],
        'count': entry.value,
        'color': moodItem['color'],
      };
    }).toList();

    // 圆圈大小 45
    final double circleSize = 45;

    return Scaffold(
      backgroundColor: Color(0xFFF2F5F8),
      appBar: AppBar(
        title: Text(
          '${currentYear}年${currentMonth}月',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // ===== 日历卡片 =====
            Container(
              width: double.infinity, // 强制占满父级宽度
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 星期标题（7列固定宽度）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['一', '二', '三', '四', '五', '六', '日'].map((day) {
                      return SizedBox(
                        width: circleSize,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // 日期网格（每行7列，固定宽度）
                  ...List.generate(
                    ((daysInMonth + firstDayOfMonth % 7) / 7).ceil(),
                    (rowIndex) {
                      final children = <Widget>[];
                      for (int col = 0; col < 7; col++) {
                        final dayIndex = rowIndex * 7 + col - (firstDayOfMonth % 7);
                        final day = dayIndex + 1;
                        if (dayIndex < 0 || dayIndex >= daysInMonth) {
                          // 空白占位
                          children.add(SizedBox(width: circleSize, height: circleSize));
                        } else {
                          final mood = _getMoodForDay(day);
                          final isToday = day == DateTime.now().day &&
                              currentYear == DateTime.now().year &&
                              currentMonth == DateTime.now().month;
                          final isSelected = selectedDay == day;
                          children.add(
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDay = selectedDay == day ? null : day;
                                });
                                if (mood != null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(mood['emoji'], style: TextStyle(fontSize: 48)),
                                            const SizedBox(height: 8),
                                            Text(
                                              mood['mood'],
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              mood['text'] ?? '',
                                              style: TextStyle(color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Text('关闭', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                              child: Container(
                                width: circleSize,
                                height: circleSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: mood != null
                                      ? (mood['color'] as Color).withOpacity(0.25)
                                      : Colors.transparent,
                                  border: isToday
                                      ? Border.all(color: Colors.orange, width: 3)
                                      : (isSelected ? Border.all(color: Colors.orange, width: 2) : null),
                                ),
                                child: Center(
                                  child: mood != null
                                      ? Text(
                                          mood['emoji'],
                                          style: TextStyle(fontSize: circleSize * 0.6),
                                        )
                                      : Text(
                                          day.toString(),
                                          style: TextStyle(
                                            fontSize: circleSize * 0.45,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: children,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== 心情数量统计 =====
            Container(
              width: double.infinity, // 强制占满父级宽度
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '心情数量',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${monthStats.length}次',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: moodTags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (tag['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (tag['color'] as Color).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tag['emoji'], style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '${tag['mood']} ${tag['count']}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (moodTags.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        '本月还没有记录',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== 情绪选择器 =====
            Container(
              width: double.infinity, // 强制占满父级宽度
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今天的心情是？',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: moodLibrary.map((item) {
                      final isSelected = selectedMood == item['mood'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = item['mood'];
                          });
                          _recordMood(item['mood']);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (item['color'] as Color).withOpacity(0.3)
                                : (item['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? (item['color'] as Color)
                                  : (item['color'] as Color).withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item['emoji'], style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 6),
                              Text(
                                item['mood'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.black87 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}