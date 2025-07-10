class Player {
  final String telegramId;
  final String username;
  final String? walletAddress;
  final DateTime createdAt;
  final DateTime lastLogin;

  Player({
    required this.telegramId,
    required this.username,
    this.walletAddress,
    required this.createdAt,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'telegramId': telegramId,
      'username': username,
      'walletAddress': walletAddress,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      telegramId: map['telegramId'] as String,
      username: map['username'] as String,
      walletAddress: map['walletAddress'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLogin: DateTime.parse(map['lastLogin'] as String),
    );
  }
}
