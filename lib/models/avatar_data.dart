class AvatarData {
  String body;
  String eyes;
  String mouth;
  String hair;
  String top;
  String bottom;
  String shoes;

  AvatarData({
    required this.body,
    required this.eyes,
    required this.mouth,
    required this.hair,
    required this.top,
    required this.bottom,
    required this.shoes,
  });

  // 默认初始装扮（路径加上 .PNG）
  factory AvatarData.defaultAvatar() {
    return AvatarData(
      body: 'assets/images/body_base.png.PNG',
      eyes: 'assets/images/eyes_01.png.PNG',
      mouth: 'assets/images/mouth_01.png.PNG',
      hair: 'assets/images/hair_01.png.PNG',
      top: 'assets/images/top_01.png.PNG',
      bottom: 'assets/images/bottom_01.png.PNG',
      shoes: 'assets/images/shoes_01.png.PNG',
    );
  }

  // 复制并修改某个部位
  AvatarData copyWith({
    String? body,
    String? eyes,
    String? mouth,
    String? hair,
    String? top,
    String? bottom,
    String? shoes,
  }) {
    return AvatarData(
      body: body ?? this.body,
      eyes: eyes ?? this.eyes,
      mouth: mouth ?? this.mouth,
      hair: hair ?? this.hair,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      shoes: shoes ?? this.shoes,
    );
  }
}