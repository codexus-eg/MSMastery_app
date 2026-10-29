class GroupModel {
  String name;
  String id;

  GroupModel({
    required this.name,
    required this.id,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      name: json['Name'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'id': id,
    };
  }
}
