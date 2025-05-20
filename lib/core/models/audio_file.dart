class AudioFile {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String url;
  final String artworkUrl; // Can be a URL or file path
  final bool isFavorite;

  const AudioFile({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.url,
    this.artworkUrl = '',
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration.inMilliseconds,
      'url': url,
      'artworkUrl': artworkUrl,
      'isFavorite': isFavorite,
    };
  }

  factory AudioFile.fromMap(Map<String, dynamic> map, String docId) {
    return AudioFile(
      id: docId,
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      duration: Duration(milliseconds: map['duration'] ?? 0),
      url: map['url'] ?? '',
      artworkUrl: map['artworkUrl'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
