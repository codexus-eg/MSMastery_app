class SocialMediaModel {
  String type;
  String linkUrl;

  SocialMediaModel({
    required this.type,
    required this.linkUrl,
  });

  // To convert JSON data to a model
  factory SocialMediaModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaModel(
      type: json['type'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
    );
  }

  // To convert model data to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'linkUrl': linkUrl,
    };
  }
}
