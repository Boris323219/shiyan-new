import 'package:flutter/material.dart';
import '../models/avatar_data.dart';
import '../widgets/avatar_preview.dart';

class AvatarCreatePage extends StatefulWidget {
  const AvatarCreatePage({super.key});

  @override
  State<AvatarCreatePage> createState() => _AvatarCreatePageState();
}

class _AvatarCreatePageState extends State<AvatarCreatePage> {
  late AvatarData currentAvatar;
  int selectedTab = 0;

  final Map<String, List<String>> partsLibrary = {
    'hair': [
      'assets/images/hair_01.png.PNG',
      'assets/images/hair_02.png.PNG',
      'assets/images/hair_03.png.PNG',
      'assets/images/hair_04.png.PNG',
    ],
    'eyes': [
      'assets/images/eyes_01.png.PNG',
      'assets/images/eyes_02.png.PNG',
      'assets/images/eyes_03.png.PNG',
      'assets/images/eyes_04.png.PNG',
    ],
    'mouth': [
      'assets/images/mouth_01.png.PNG',
      'assets/images/mouth_02.png.PNG',
      'assets/images/mouth_03.png.PNG',
    ],
    'top': [
      'assets/images/top_01.png.PNG',
      'assets/images/top_02.png.PNG',
      'assets/images/top_03.png.PNG',
      'assets/images/top_04.png.PNG',
    ],
    'bottom': [
      'assets/images/bottom_01.png.PNG',
      'assets/images/bottom_02.png.PNG',
      'assets/images/bottom_03.png.PNG',
      'assets/images/bottom_04.png.PNG',
    ],
    'shoes': [
      'assets/images/shoes_01.png.PNG',
      'assets/images/shoes_02.png.PNG',
      'assets/images/shoes_03.png.PNG',
    ],
  };

  final List<String> tabLabels = ['Hair', 'Eyes', 'Mouth', 'Top', 'Bottom', 'Shoes'];
  final List<String> tabKeys = ['hair', 'eyes', 'mouth', 'top', 'bottom', 'shoes'];

  @override
  void initState() {
    super.initState();
    currentAvatar = AvatarData.defaultAvatar();
  }

  void _updatePart(String partKey, String imagePath) {
    setState(() {
      switch (partKey) {
        case 'hair':
          currentAvatar = currentAvatar.copyWith(hair: imagePath);
          break;
        case 'eyes':
          currentAvatar = currentAvatar.copyWith(eyes: imagePath);
          break;
        case 'mouth':
          currentAvatar = currentAvatar.copyWith(mouth: imagePath);
          break;
        case 'top':
          currentAvatar = currentAvatar.copyWith(top: imagePath);
          break;
        case 'bottom':
          currentAvatar = currentAvatar.copyWith(bottom: imagePath);
          break;
        case 'shoes':
          currentAvatar = currentAvatar.copyWith(shoes: imagePath);
          break;
      }
    });
  }

  String _getCurrentPartValue(String key) {
    switch (key) {
      case 'hair':
        return currentAvatar.hair;
      case 'eyes':
        return currentAvatar.eyes;
      case 'mouth':
        return currentAvatar.mouth;
      case 'top':
        return currentAvatar.top;
      case 'bottom':
        return currentAvatar.bottom;
      case 'shoes':
        return currentAvatar.shoes;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Your Avatar'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: AvatarPreview(avatar: currentAvatar),
            ),
          ),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final isSelected = selectedTab == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tabLabels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: partsLibrary[tabKeys[selectedTab]]!.length,
              itemBuilder: (context, index) {
                final imagePath = partsLibrary[tabKeys[selectedTab]]![index];
                final isSelected = imagePath == _getCurrentPartValue(tabKeys[selectedTab]);
                return GestureDetector(
                  onTap: () {
                    _updatePart(tabKeys[selectedTab], imagePath);
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/cabin',
                    arguments: currentAvatar,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Enter Cabin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}