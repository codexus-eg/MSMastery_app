class CommentStdData {
  String imgUrl;
  String name;

  CommentStdData({
    required this.imgUrl,
    required this.name,
  });

  // تحويل من Firestore (Map -> Object)
  factory CommentStdData.fromMap(Map<String, dynamic> map) {
    return CommentStdData(
      imgUrl: map['imgUrl'] ?? '', // تجنب الـ null
      name: map['name'] ?? '',
    );
  }

  // تحويل إلى Firestore (Object -> Map)
  Map<String, dynamic> toMap() {
    return {
      'imgUrl': imgUrl,
      'name': name,
    };
  }
}
