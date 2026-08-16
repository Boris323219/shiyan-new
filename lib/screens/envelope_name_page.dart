import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/store_keys.dart';
import 'avatar_create_page.dart';

class EnvelopeNamePage extends StatefulWidget {
  const EnvelopeNamePage({Key? key}) : super(key: key);
  @override
  State<EnvelopeNamePage> createState() => _EnvelopeNamePageState();
}

class _EnvelopeNamePageState extends State<EnvelopeNamePage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _openAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _openAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _enterCabin() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先写下你的名字')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StoreKeys.userName, name);
    if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AvatarCreatePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E4C1),
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) => _buildEnvelope(_openAnim.value),
          ),
        ),
      ),
    );
  }

  Widget _buildEnvelope(double progress) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFFFF8F0), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Transform.scale(scale: 1 - progress * 0.3, child: const Icon(Icons.mail, size: 48, color: Colors.brown)),
        const SizedBox(height: 16),
        if (progress > 0.5) ...[
          const Text('有一封来自释言小屋的信', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('亲爱的朋友：\n\n欢迎来到释言小屋。这里很安全，你可以做自己。\n请写下你的名字，然后进入小屋吧。', style: TextStyle(fontSize: 14, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextField(controller: _nameController, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: '你的名字', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _enterCabin, child: const Text('进入小屋')),
        ],
      ]),
    );
  }
}