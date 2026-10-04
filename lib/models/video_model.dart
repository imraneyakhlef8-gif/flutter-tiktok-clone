class VideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String ownerId;
  final String ownerName;
  final int likes;
  final int comments;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.ownerId,
    required this.ownerName,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map, String documentId) {
    return VideoModel(
      id: documentId,
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? 'Anonymous',
      likes: (map['likes'] is int) ? map['likes'] : 0,
      comments: (map['comments'] is int) ? map['comments'] : 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt,
    };
  }
}
