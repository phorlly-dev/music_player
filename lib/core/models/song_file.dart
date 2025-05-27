class SongFile {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String url; // Path to the file in app's custom directory
  final String artworkUrl;
  bool isFavorite;
  List<String> playlists;

  SongFile({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.url,
    required this.artworkUrl,
    this.isFavorite = false,
    this.playlists = const [],
  });

  // Convert to map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration.inSeconds,
      'url': url,
      'artworkUrl': artworkUrl,
      'isFavorite': isFavorite ? 1 : 0,
      'playlists': playlists.join(','), // Store as comma-separated string
    };
  }

  // Convert from map
  factory SongFile.fromMap(Map<String, dynamic> map) {
    return SongFile(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      album: map['album'],
      duration: Duration(seconds: map['duration']),
      url: map['url'],
      artworkUrl: map['artworkUrl'],
      isFavorite: map['isFavorite'] == 1,
      playlists: map['playlists']?.split(',') ?? [],
    );
  }

  // Copy with method for updates
  SongFile copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? url,
    String? artworkUrl,
    bool? isFavorite,
    List<String>? playlists,
  }) {
    return SongFile(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      url: url ?? this.url,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      playlists: playlists ?? this.playlists,
    );
  }
}
