import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/avatar_data.dart';
import '../widgets/avatar_preview.dart';
import 'avatar_create_page.dart';

class ProfilePage extends StatefulWidget {
  final AvatarData userAvatar;

  const ProfilePage({super.key, required this.userAvatar});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nickname = '';
  String signature = '';
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nickname = prefs.getString('user_nickname') ?? 'My Little One';
      signature = prefs.getString('user_signature') ?? 'Living in the cabin, happy every day';
      _nicknameController.text = nickname;
      _signatureController.text = signature;
    });
  }

  Future<void> _saveNickname(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_nickname', newName);
    setState(() {
      nickname = newName;
    });
  }

  Future<void> _saveSignature(String newSig) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_signature', newSig);
    setState(() {
      signature = newSig;
    });
  }

  void _editNickname() {
    _nicknameController.text = nickname;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Nickname'),
          content: TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(hintText: 'Enter new nickname'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newName = _nicknameController.text.trim();
                if (newName.isNotEmpty) {
                  _saveNickname(newName);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editSignature() {
    _signatureController.text = signature;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Signature'),
          content: TextField(
            controller: _signatureController,
            decoration: const InputDecoration(hintText: 'Enter new signature'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newSig = _signatureController.text.trim();
                if (newSig.isNotEmpty) {
                  _saveSignature(newSig);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AvatarPreview(avatar: widget.userAvatar, size: 200),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nickname'),
              subtitle: Text(nickname),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editNickname,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Signature'),
              subtitle: Text(signature),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editSignature,
              ),
            ),
            const Divider(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AvatarCreatePage(),
                  ),
                ).then((newAvatar) {
                  if (newAvatar != null && newAvatar is AvatarData) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avatar updated! Return to cabin to see.')),
                    );
                  }
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text('Redesign Avatar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Cabin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}