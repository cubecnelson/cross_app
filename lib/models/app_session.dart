class AppSession {
  final String userId;
  final String username;
  final String source; // 'local' or 'supabase'

  const AppSession({
    required this.userId,
    required this.username,
    this.source = 'local',
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'username': username,
        'source': source,
      };

  factory AppSession.fromMap(Map<dynamic, dynamic> map) => AppSession(
        userId: map['userId'] as String,
        username: map['username'] as String,
        source: map['source'] as String? ?? 'local',
      );
}
